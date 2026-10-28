import '../../logica/autenticacion_service.dart';
import 'package:flutter/material.dart';

import '../estilos/styles.dart';
import 'registro.dart';
import 'cliente/inicio_cliente.dart';
import 'admin/inicio_admin.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final autenticacion = AutenticacionService();

  final correoController = TextEditingController();
  final passwordController = TextEditingController();

  bool ocultarPassword = true;
  bool cargando = false;
  bool cargandoGoogle = false;
  bool validarCampos = false;
  bool credencialesIncorrectas = false;

  String? errorCorreo;
  String? errorPassword;

  bool get ocupado => cargando || cargandoGoogle;

  @override
  void dispose() {
    correoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? _validarCorreo() {
    final correo = correoController.text.trim();

    if (correo.isEmpty) {
      return 'Ingresa tu correo electrónico';
    }

    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(correo)) {
      return 'Ingresa un correo válido, como nombre@correo.com';
    }

    return null;
  }

  String? _validarPassword() {
    if (passwordController.text.isEmpty) {
      return 'Ingresa tu contraseña';
    }

    return null;
  }

  void _alCambiarCorreo(String valor) {
    setState(() {
      if (credencialesIncorrectas) {
        credencialesIncorrectas = false;
        errorPassword = validarCampos ? _validarPassword() : null;
      }

      errorCorreo = validarCampos ? _validarCorreo() : null;
    });
  }

  void _alCambiarPassword(String valor) {
    setState(() {
      if (credencialesIncorrectas) {
        credencialesIncorrectas = false;
        errorCorreo = validarCampos ? _validarCorreo() : null;
      }

      errorPassword = validarCampos ? _validarPassword() : null;
    });
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.tarjetaClara,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.naranja),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  mensaje,
                  style: const TextStyle(
                    color: AppColors.crema,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  // LOGIN CON CORREO
  Future<void> iniciarSesionNormal() async {
    if (ocupado) return;

    setState(() {
      validarCampos = true;
      credencialesIncorrectas = false;
      errorCorreo = _validarCorreo();
      errorPassword = _validarPassword();
    });

    if (errorCorreo != null || errorPassword != null) return;

    final correo = correoController.text.trim();

    // La contraseña se envía tal como fue escrita, sin quitar espacios.
    final password = passwordController.text;

    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).clearSnackBars();

    setState(() {
      cargando = true;
    });

    try {
      final usuario = await autenticacion.iniciarConCorreo(correo, password);

      if (!mounted) return;

      if (usuario.rol == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const InicioAdmin()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const InicioCliente()),
        );
      }
    } on AutenticacionException catch (e) {
      if (!mounted) return;

      debugPrint('ERROR FIREBASE LOGIN: ${e.code}');

      const erroresCredenciales = {
        'user-not-found',
        'wrong-password',
        'invalid-credential',
        'invalid-login-credentials',
      };

      if (erroresCredenciales.contains(e.code)) {
        setState(() {
          credencialesIncorrectas = true;
          errorCorreo = 'Revisa tu correo y contraseña';
          errorPassword = 'Correo o contraseña incorrectos';
        });

        _mostrarMensaje('Correo o contraseña incorrectos');
      } else if (e.code == 'invalid-email') {
        setState(() {
          errorCorreo = 'El correo electrónico no es válido';
        });
      } else {
        String mensaje;

        switch (e.code) {
          case 'network-request-failed':
            mensaje = 'No se pudo conectar. Revisa tu conexión a Internet.';
            break;
          case 'too-many-requests':
            mensaje =
                'Demasiados intentos. Espera unos minutos e inténtalo de nuevo.';
            break;
          case 'user-disabled':
            mensaje = 'Esta cuenta ha sido deshabilitada.';
            break;
          case 'perfil-no-encontrado':
            mensaje = 'No se pudieron cargar los datos de tu cuenta.';
            break;
          case 'carrito-no-disponible':
            mensaje =
                'No se pudo cargar tu carrito. Revisa tu conexión e intenta nuevamente.';
            break;
          default:
            mensaje = 'No se pudo iniciar sesión. Intenta nuevamente.';
        }

        _mostrarMensaje(mensaje);
      }
    } catch (e) {
      if (!mounted) return;

      debugPrint('ERROR LOGIN: $e');

      _mostrarMensaje(
        'No se pudo iniciar sesión. Revisa tu conexión e intenta nuevamente.',
      );
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  // LOGIN CON GOOGLE
  Future<void> iniciarSesionGoogle() async {
    if (ocupado) return;

    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).clearSnackBars();

    setState(() {
      cargandoGoogle = true;
    });

    try {
      final usuario = await autenticacion.iniciarConGoogle();

      if (!mounted) return;

      if (usuario == null) {
        _mostrarMensaje('No se completó el inicio de sesión con Google');
        return;
      }

      if (usuario.rol == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const InicioAdmin()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const InicioCliente()),
        );
      }
    } on AutenticacionException catch (e) {
      if (!mounted) return;

      debugPrint('ERROR FIREBASE GOOGLE: ${e.code}');

      String mensaje;

      switch (e.code) {
        case 'account-exists-with-different-credential':
          mensaje =
              'Ya existe una cuenta con este correo. Usa el método con el que te registraste.';
          break;
        case 'credential-already-in-use':
          mensaje = 'Esta cuenta de Google ya está vinculada.';
          break;
        case 'invalid-credential':
          mensaje =
              'No se pudo validar el acceso con Google. Intenta nuevamente.';
          break;
        case 'network-request-failed':
          mensaje = 'Revisa tu conexión a Internet e intenta nuevamente.';
          break;
        case 'too-many-requests':
          mensaje = 'Demasiados intentos. Inténtalo más tarde.';
          break;
        case 'user-disabled':
          mensaje = 'Esta cuenta ha sido deshabilitada.';
          break;
        case 'carrito-no-disponible':
          mensaje =
              'No se pudo cargar tu carrito. Revisa tu conexión e intenta nuevamente.';
          break;
        case 'perfil-no-encontrado':
          mensaje = 'No se pudieron cargar los datos de tu cuenta.';
          break;
        default:
          mensaje = 'No se pudo iniciar sesión con Google.';
      }

      _mostrarMensaje(mensaje);
    } catch (e) {
      if (!mounted) return;

      debugPrint('ERROR LOGIN GOOGLE: $e');

      _mostrarMensaje(
        'No se pudo iniciar sesión con Google. Intenta nuevamente.',
      );
    } finally {
      if (mounted) {
        setState(() {
          cargandoGoogle = false;
        });
      }
    }
  }

  InputDecoration _decoracionCampo({
    required String titulo,
    required IconData icono,
    String? error,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: titulo,
      errorText: error,
      errorMaxLines: 3,
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
      labelStyle: const TextStyle(color: AppColors.textoSecundario),
      prefixIcon: Icon(
        icono,
        color: error == null ? AppColors.naranja : Colors.redAccent,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.fondo,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.borde),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.naranja, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'THEIA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.crema,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 7,
                  ),
                ),
                const SizedBox(height: 28),

                // TARJETA DE LOGIN
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
                  decoration: BoxDecoration(
                    color: AppColors.blanco,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.borde),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x18000000),
                        blurRadius: 15,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Login',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.crema,
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // CORREO
                      TextField(
                        controller: correoController,
                        enabled: !ocupado,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        enableSuggestions: false,
                        onChanged: _alCambiarCorreo,
                        style: const TextStyle(color: AppColors.crema),
                        decoration: _decoracionCampo(
                          titulo: 'Correo electrónico',
                          icono: Icons.email_outlined,
                          error: errorCorreo,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // CONTRASEÑA
                      TextField(
                        controller: passwordController,
                        enabled: !ocupado,
                        obscureText: ocultarPassword,
                        autocorrect: false,
                        enableSuggestions: false,
                        textInputAction: TextInputAction.done,
                        onChanged: _alCambiarPassword,
                        onSubmitted: (_) {
                          iniciarSesionNormal();
                        },
                        style: const TextStyle(color: AppColors.crema),
                        decoration: _decoracionCampo(
                          titulo: 'Contraseña',
                          icono: Icons.lock_outline,
                          error: errorPassword,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                ocultarPassword = !ocultarPassword;
                              });
                            },
                            icon: Icon(
                              ocultarPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textoSecundario,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // INICIAR SESIÓN
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: ocupado ? null : iniciarSesionNormal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.naranja,
                            foregroundColor: AppColors.crema,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: cargando
                              ? const SizedBox(
                                  width: 23,
                                  height: 23,
                                  child: CircularProgressIndicator(
                                    color: AppColors.crema,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'INICIAR SESIÓN',
                                  style: TextStyle(
                                    color: AppColors.crema,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // SEPARADOR
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(color: AppColors.borde),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'o continúa con',
                              style: AppStyles.textoNormal.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: AppColors.borde),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // GOOGLE
                      OutlinedButton.icon(
                        onPressed: ocupado ? null : iniciarSesionGoogle,
                        icon: cargandoGoogle
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.naranja,
                                ),
                              )
                            : const Icon(
                                Icons.g_mobiledata,
                                size: 30,
                                color: AppColors.naranja,
                              ),
                        label: Text(
                          cargandoGoogle
                              ? 'Conectando con Google...'
                              : 'Continuar con Google',
                          style: const TextStyle(color: AppColors.crema),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          side: const BorderSide(color: AppColors.borde),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // REGISTRO
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '¿No tienes cuenta?',
                            style: AppStyles.textoNormal,
                          ),
                          TextButton(
                            onPressed: ocupado
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const Registro(),
                                      ),
                                    );
                                  },
                            child: const Text(
                              'Regístrate',
                              style: TextStyle(
                                color: AppColors.naranja,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
