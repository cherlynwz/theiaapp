import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;

import '../datos/dao/autenticacion_dao.dart';
import '../modelos/usuario.dart';
import 'sesion.dart';

class AutenticacionException implements Exception {
  final String code;

  AutenticacionException(this.code);

  @override
  String toString() => code;
}

class AutenticacionService {
  final AutenticacionDAO _dao = AutenticacionDAO();

  Future<Usuario> iniciarConCorreo(String correo, String password) async {
    try {
      final usuario = await _dao.iniciarConCorreo(correo, password);
      Sesion.iniciarSesion(usuario);
      return usuario;
    } on FirebaseAuthException catch (e) {
      throw AutenticacionException(e.code);
    }
  }

  Future<Usuario?> iniciarConGoogle() async {
    try {
      final usuario = await _dao.iniciarConGoogle();

      if (usuario != null) {
        Sesion.iniciarSesion(usuario);
      }

      return usuario;
    } on FirebaseAuthException catch (e) {
      throw AutenticacionException(e.code);
    }
  }

  static String? validarPassword(String password) {
    if (password.runes.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'La contraseña debe incluir al menos una mayúscula.';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'La contraseña debe incluir al menos una minúscula.';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'La contraseña debe incluir al menos un número.';
    }

    if (!RegExp(r'[^a-zA-Z0-9\s]').hasMatch(password)) {
      return 'La contraseña debe incluir al menos un símbolo, como @, # o !.';
    }

    return null;
  }

  Future<void> registrar({
    required String nombre,
    required String correo,
    required String password,
    required String telefono,
  }) async {
    if (validarPassword(password) != null) {
      throw AutenticacionException('weak-password');
    }

    try {
      await _dao.registrar(
        nombre: nombre,
        correo: correo,
        password: password,
        telefono: telefono,
      );
    } on FirebaseAuthException catch (e) {
      throw AutenticacionException(e.code);
    }
  }
}
