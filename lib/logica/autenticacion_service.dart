import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;

import '../datos/dao/autenticacion_dao.dart';
import '../modelos/usuario.dart';
import 'carrito_provider.dart';
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

      await _prepararSesion(usuario);

      return usuario;
    } on FirebaseAuthException catch (e) {
      throw AutenticacionException(e.code);
    }
  }

  Future<Usuario?> iniciarConGoogle() async {
    try {
      final usuario = await _dao.iniciarConGoogle();

      if (usuario != null) {
        await _prepararSesion(usuario);
      }

      return usuario;
    } on FirebaseAuthException catch (e) {
      throw AutenticacionException(e.code);
    }
  }

  // Carga el carrito de la cuenta antes de continuar al inicio.
  Future<void> _prepararSesion(Usuario usuario) async {
    Sesion.cerrarSesion();

    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null || uid.isEmpty) {
      throw AutenticacionException('usuario-no-autenticado');
    }

    try {
      await CarritoProvider.instance.conectarUsuario(uid);
    } catch (_) {
      Sesion.cerrarSesion();
      throw AutenticacionException('carrito-no-disponible');
    }

    Sesion.iniciarSesion(usuario);
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

  // RECUPERAR CONTRASEÑA
  Future<void> recuperarContrasena(String correo) async {
    final correoLimpio = correo.trim();

    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(correoLimpio)) {
      throw AutenticacionException('invalid-email');
    }

    try {
      await _dao.recuperarContrasena(correoLimpio);
    } on FirebaseAuthException catch (e) {
      // Mantiene una respuesta uniforme para correos no registrados.
      if (e.code == 'user-not-found') return;

      throw AutenticacionException(e.code);
    }
  }

  // VALIDAR NOMBRE DEL PERFIL
  static String? validarNombrePerfil(String valor) {
    final nombre = valor.trim().replaceAll(RegExp(r'\s+'), ' ');

    if (nombre.isEmpty) {
      return 'Ingresa tu nombre';
    }

    if (nombre.runes.length > 100) {
      return 'El nombre debe tener como máximo 100 caracteres';
    }

    final formato = RegExp(
      r"^\p{L}[\p{L}\p{M}]*(?:[ '\u2019\u002D]\p{L}[\p{L}\p{M}]*)*$",
      unicode: true,
    );

    if (!formato.hasMatch(nombre)) {
      return 'Usa letras, espacios, apóstrofos o guiones';
    }

    return null;
  }

  // VALIDAR TELÉFONO DEL PERFIL
  static String? validarTelefonoPerfil(String valor) {
    if (!RegExp(r'^[0-9]{10}$').hasMatch(valor.trim())) {
      return 'Ingresa un teléfono de exactamente 10 dígitos';
    }

    return null;
  }

  // GUARDAR PERFIL Y ACTUALIZAR LA SESIÓN
  Future<Usuario> actualizarPerfil({
    required String nombre,
    required String telefono,
  }) async {
    final nombreLimpio = nombre.trim().replaceAll(RegExp(r'\s+'), ' ');
    final telefonoLimpio = telefono.trim();

    if (validarNombrePerfil(nombreLimpio) != null) {
      throw AutenticacionException('nombre-invalido');
    }

    if (validarTelefonoPerfil(telefonoLimpio) != null) {
      throw AutenticacionException('telefono-invalido');
    }

    final usuarioActual = Sesion.usuarioActual;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (usuarioActual == null || uid == null) {
      throw AutenticacionException('usuario-no-autenticado');
    }

    try {
      await _dao.actualizarPerfil(
        nombre: nombreLimpio,
        telefono: telefonoLimpio,
      );

      // Evita modificar una sesión que haya cambiado durante el guardado.
      if (FirebaseAuth.instance.currentUser?.uid != uid ||
          !identical(Sesion.usuarioActual, usuarioActual)) {
        throw AutenticacionException('sesion-cambiada');
      }

      final actualizado = Usuario(
        id: usuarioActual.id,
        nombre: nombreLimpio,
        correo: usuarioActual.correo,
        password: usuarioActual.password,
        telefono: telefonoLimpio,
        rol: usuarioActual.rol,
      );

      Sesion.iniciarSesion(actualizado);

      return actualizado;
    } on FirebaseAuthException catch (e) {
      throw AutenticacionException(e.code);
    }
  }
}
