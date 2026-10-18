import 'package:flutter/foundation.dart' show debugPrint;
import 'package:google_sign_in/google_sign_in.dart';

class GoogleService {
  static const String serverClientId =
      '442015090752-f2d5sbrjndolcc7u6ttgdorjlili17db.apps.googleusercontent.com';

  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static Future<void>? _inicializacion;

  static Future<void> inicializar() {
    return _inicializacion ??= _googleSignIn.initialize(
      serverClientId: serverClientId,
    );
  }

  static Future<GoogleSignInAccount?> iniciarSesion() async {
    try {
      await inicializar();

      if (!_googleSignIn.supportsAuthenticate()) {
        throw Exception(
          'Google Sign-In no está disponible en este dispositivo.',
        );
      }

      final cuenta = await _googleSignIn.authenticate();

      return cuenta;
    } catch (e) {
      debugPrint('ERROR GOOGLE: $e');
      rethrow;
    }
  }

  static Future<void> cerrarSesion() async {
    try {
      await inicializar();
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('ERROR AL CERRAR GOOGLE: $e');
    }
  }
}
