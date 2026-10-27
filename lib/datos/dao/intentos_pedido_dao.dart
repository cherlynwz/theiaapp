import 'dart:convert';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class IntentosPedidoDAO {
  static Future<Database>? _apertura;

  Future<Database> get _database async {
    final apertura = _apertura ??= _abrir();

    try {
      return await apertura;
    } catch (_) {
      if (identical(_apertura, apertura)) {
        _apertura = null;
      }

      rethrow;
    }
  }

  Future<Database> _abrir() async {
    final carpeta = await getDatabasesPath();

    return openDatabase(
      p.join(carpeta, 'theia_intentos_pedido.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE intentos_pedido (
            uid TEXT PRIMARY KEY,
            id INTEGER NOT NULL,
            datos TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Map<String, dynamic> _leer(Map<String, Object?> fila) {
    final contenido = jsonDecode(fila['datos'] as String);

    if (contenido is! Map) {
      throw const FormatException(
        'El intento de pedido guardado no es válido.',
      );
    }

    return {
      'id': fila['id'] as int,
      'datos': Map<String, dynamic>.from(contenido),
    };
  }

  // Recupera el intento pendiente de esta cuenta.
  Future<Map<String, dynamic>?> obtener(String uid) async {
    final db = await _database;

    final filas = await db.query(
      'intentos_pedido',
      where: 'uid = ?',
      whereArgs: [uid],
      limit: 1,
    );

    if (filas.isEmpty) return null;

    return _leer(filas.first);
  }

  // Conserva el intento existente o registra uno nuevo.
  // Se guarda antes de comenzar el envío a Firebase.
  Future<Map<String, dynamic>> obtenerOCrear(
    String uid,
    Map<String, dynamic> datos,
  ) async {
    if (uid.isEmpty) {
      throw ArgumentError('No se pudo identificar al usuario.');
    }

    final db = await _database;

    return db.transaction((transaccion) async {
      final filas = await transaccion.query(
        'intentos_pedido',
        where: 'uid = ?',
        whereArgs: [uid],
        limit: 1,
      );

      if (filas.isNotEmpty) {
        return _leer(filas.first);
      }

      final id =
          DateTime.now().millisecondsSinceEpoch * 1000 +
          Random.secure().nextInt(1000);

      final contenido = jsonEncode(datos);

      await transaccion.insert('intentos_pedido', {
        'uid': uid,
        'id': id,
        'datos': contenido,
      });

      return {
        'id': id,
        'datos': Map<String, dynamic>.from(jsonDecode(contenido) as Map),
      };
    });
  }

  // Elimina únicamente el intento indicado.
  Future<void> eliminar(String uid, int id) async {
    final db = await _database;

    await db.delete(
      'intentos_pedido',
      where: 'uid = ? AND id = ?',
      whereArgs: [uid, id],
    );
  }
}
