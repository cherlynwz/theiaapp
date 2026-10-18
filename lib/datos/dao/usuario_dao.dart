import 'package:flutter/foundation.dart' show debugPrint;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../modelos/usuario.dart';

class UsuarioDAO {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Referencia a la colección usuarios
  CollectionReference get _usuarios => _firestore.collection('usuarios');

  // OBTENER CLIENTES REGISTRADOS
  // ============================================================

  Future<List<Usuario>> listarClientes() async {
    try {
      final resultado = await _usuarios
          .where('rol', isEqualTo: 'cliente')
          .get();

      return resultado.docs.map((documento) {
        final datos = documento.data() as Map<String, dynamic>;

        return Usuario(
          id: datos['id'] is num ? (datos['id'] as num).toInt() : null,
          nombre: datos['nombre'] ?? '',
          correo: datos['correo'] ?? '',
          password: '',
          telefono: datos['telefono'] ?? '',
          rol: datos['rol'] ?? 'cliente',
        );
      }).toList();
    } catch (e) {
      debugPrint('ERROR AL LISTAR CLIENTES DE FIRESTORE: $e');
      return [];
    }
  }

  // ============================================================
  // CONTAR CLIENTES
  // ============================================================

  Future<int> contarClientes() async {
    try {
      final resultado = await _usuarios
          .where('rol', isEqualTo: 'cliente')
          .get();

      return resultado.docs.length;
    } catch (e) {
      debugPrint('ERROR AL CONTAR CLIENTES EN FIRESTORE: $e');
      return 0;
    }
  }
}
