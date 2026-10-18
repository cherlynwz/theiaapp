import 'package:cloud_firestore/cloud_firestore.dart';
import '../Modelos/usuario.dart';

class UsuarioDAO {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Referencia a la colección usuarios
  CollectionReference get _usuarios => _firestore.collection('usuarios');

  // ============================================================
  // REGISTRAR USUARIO
  // ============================================================

  Future<int> insertarUsuario(Usuario usuario) async {
    try {
      // Generamos un ID numérico para el usuario
      final int id = DateTime.now().millisecondsSinceEpoch;

      await _usuarios.add({
        'id': id,
        'nombre': usuario.nombre,
        'correo': usuario.correo,
        'password': usuario.password,
        'telefono': usuario.telefono,
        'rol': usuario.rol,
      });

      return id;
    } catch (e) {
      print('ERROR AL REGISTRAR USUARIO EN FIRESTORE: $e');
      return 0;
    }
  }

  // ============================================================
  // BUSCAR USUARIO POR CORREO
  // ============================================================

  Future<Usuario?> buscarPorCorreo(String correo) async {
    try {
      final resultado = await _usuarios
          .where('correo', isEqualTo: correo)
          .limit(1)
          .get();

      if (resultado.docs.isNotEmpty) {
        final documento = resultado.docs.first;
        final datos = documento.data() as Map<String, dynamic>;

        return Usuario(
          id: datos['id'] is num ? (datos['id'] as num).toInt() : null,
          nombre: datos['nombre'] ?? '',
          correo: datos['correo'] ?? '',
          password: datos['password'] ?? '',
          telefono: datos['telefono'] ?? '',
          rol: datos['rol'] ?? 'cliente',
        );
      }

      return null;
    } catch (e) {
      print('ERROR AL BUSCAR USUARIO EN FIRESTORE: $e');
      return null;
    }
  }

  // ============================================================
  // VALIDAR INICIO DE SESIÓN
  // ============================================================

  Future<Usuario?> login(String correo, String password) async {
    try {
      final resultado = await _usuarios
          .where('correo', isEqualTo: correo)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (resultado.docs.isNotEmpty) {
        final documento = resultado.docs.first;
        final datos = documento.data() as Map<String, dynamic>;

        return Usuario(
          id: datos['id'] is num ? (datos['id'] as num).toInt() : null,
          nombre: datos['nombre'] ?? '',
          correo: datos['correo'] ?? '',
          password: datos['password'] ?? '',
          telefono: datos['telefono'] ?? '',
          rol: datos['rol'] ?? 'cliente',
        );
      }

      return null;
    } catch (e) {
      print('ERROR AL INICIAR SESIÓN EN FIRESTORE: $e');
      return null;
    }
  }

  // ============================================================
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
          password: datos['password'] ?? '',
          telefono: datos['telefono'] ?? '',
          rol: datos['rol'] ?? 'cliente',
        );
      }).toList();
    } catch (e) {
      print('ERROR AL LISTAR CLIENTES DE FIRESTORE: $e');
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
      print('ERROR AL CONTAR CLIENTES EN FIRESTORE: $e');
      return 0;
    }
  }
}
