import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../modelos/usuario.dart';
import '../servicios/google.dart';

class AutenticacionDAO {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Usuario> iniciarConCorreo(String correo, String password) async {
    final resultado = await _auth.signInWithEmailAndPassword(
      email: correo,
      password: password,
    );
    final usuario = resultado.user;
    if (usuario == null) throw Exception('No se pudo obtener el usuario');
    final referencia = _db.collection('usuarios').doc(usuario.uid);
    final documento = await referencia.get();
    if (!documento.exists) {
      await _auth.signOut();
      throw FirebaseAuthException(code: 'perfil-no-encontrado');
    }
    return _leerPerfil(usuario, referencia, documento.data()!);
  }

  Future<Usuario?> iniciarConGoogle() async {
    final cuenta = await GoogleService.iniciarSesion();
    if (cuenta == null) return null;
    final credencial = GoogleAuthProvider.credential(
      idToken: cuenta.authentication.idToken,
    );
    final resultado = await _auth.signInWithCredential(credencial);
    final usuario = resultado.user;
    if (usuario == null) {
      throw Exception('No se pudo obtener el usuario de Google');
    }
    final referencia = _db.collection('usuarios').doc(usuario.uid);
    final documento = await referencia.get();
    if (!documento.exists) {
      await referencia.set({
        'nombre': usuario.displayName ?? 'Usuario Google',
        'correo': usuario.email ?? '',
        'telefono': '',
        'rol': 'cliente',
      });
    }
    final actual = await referencia.get();
    return _leerPerfil(usuario, referencia, actual.data()!, esGoogle: true);
  }

  Future<Usuario> _leerPerfil(
    User usuario,
    DocumentReference<Map<String, dynamic>> referencia,
    Map<String, dynamic> datos, {
    bool esGoogle = false,
  }) async {
    final valor = datos['id'];
    final int id = valor is num
        ? valor.toInt()
        : DateTime.now().millisecondsSinceEpoch;
    if (valor is! num) {
      await referencia.set({'id': id}, SetOptions(merge: true));
    }
    return Usuario(
      id: id,
      nombre:
          datos['nombre'] ??
          (esGoogle ? usuario.displayName ?? 'Usuario Google' : ''),
      correo: datos['correo'] ?? usuario.email ?? '',
      password: '',
      telefono: datos['telefono'] ?? '',
      rol: datos['rol'] ?? 'cliente',
    );
  }

  Future<void> registrar({
    required String nombre,
    required String correo,
    required String password,
    required String telefono,
  }) async {
    final resultado = await _auth.createUserWithEmailAndPassword(
      email: correo,
      password: password,
    );
    final uid = resultado.user!.uid;
    await _db.collection('usuarios').doc(uid).set({
      'id': DateTime.now().millisecondsSinceEpoch,
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      'rol': 'cliente',
    });
  }

  // ENVIAR CORREO PARA RESTABLECER LA CONTRASEÑA
  Future<void> recuperarContrasena(String correo) async {
    await _auth.sendPasswordResetEmail(email: correo.trim());
  }

  // ACTUALIZAR NOMBRE Y TELÉFONO DEL USUARIO AUTENTICADO
  Future<void> actualizarPerfil({
    required String nombre,
    required String telefono,
  }) async {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw FirebaseAuthException(code: 'usuario-no-autenticado');
    }

    await _db.collection('usuarios').doc(usuario.uid).update({
      'nombre': nombre,
      'telefono': telefono,
    });
  }
}
