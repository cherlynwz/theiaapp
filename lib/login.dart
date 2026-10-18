import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Styles/styles.dart';
import 'registro.dart';

import 'Cliente/inicioCliente.dart';
import 'Admin/inicioAdmin.dart';

import 'Modelos/usuario.dart';

import 'Servicios/sesion.dart';
import 'Servicios/Google.dart';

import 'BaseDatos/usuarioDAO.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final correoController = TextEditingController();
  final passwordController = TextEditingController();

  bool ocultarPassword = true;
  bool cargando = false;
  bool cargandoGoogle = false;

  @override
  void dispose() {
    correoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // =========================================================
  // LOGIN NORMAL CON FIREBASE
  // =========================================================

  Future<void> iniciarSesionNormal() async {
    String correo = correoController.text.trim();
    String password = passwordController.text.trim();

    if (correo.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );

      return;
    }

    setState(() {
      cargando = true;
    });

    try {
      // Iniciar sesión con Firebase Authentication
      UserCredential credencial = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: correo, password: password);

      final User? usuarioFirebase = credencial.user;

      if (usuarioFirebase == null) {
        throw Exception('No se pudo obtener el usuario');
      }

      // Obtener datos del usuario desde Firestore
      final documento = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuarioFirebase.uid)
          .get();

      if (!documento.exists) {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        setState(() {
          cargando = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontraron los datos del usuario'),
          ),
        );

        return;
      }

      final datos = documento.data()!;

      // =========================================================
      // OBTENER ID DEL USUARIO
      // =========================================================

      int? usuarioId;

      final idFirestore = datos['id'];
      debugPrint('==============================');
      debugPrint('DATOS FIRESTORE LOGIN: $datos');
      debugPrint('ID FIRESTORE: ${datos['id']}');
      debugPrint('TIPO ID: ${datos['id']?.runtimeType}');
      debugPrint('==============================');

      if (idFirestore is num) {
        usuarioId = idFirestore.toInt();
      }

      // Si el usuario todavía no tiene ID, generamos uno.
      if (usuarioId == null) {
        usuarioId = DateTime.now().millisecondsSinceEpoch;

        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(usuarioFirebase.uid)
            .set({'id': usuarioId}, SetOptions(merge: true));

        debugPrint('ID NUEVO GUARDADO EN FIRESTORE: $usuarioId');
      } else {
        debugPrint('ID LEÍDO DESDE FIRESTORE: $usuarioId');
      }

      // =========================================================
      // CREAR OBJETO USUARIO
      // =========================================================

      final usuario = Usuario(
        id: usuarioId,
        nombre: datos['nombre'] ?? '',
        correo: datos['correo'] ?? usuarioFirebase.email ?? '',
        password: '',
        telefono: datos['telefono'] ?? '',
        rol: datos['rol'] ?? 'cliente',
      );

      // Guardar sesión
      Sesion.iniciarSesion(usuario);

      // Redirección según el rol
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
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
      });

      String mensaje = 'Correo o contraseña incorrectos';

      if (e.code == 'user-not-found') {
        mensaje = 'No existe una cuenta con este correo';
      } else if (e.code == 'wrong-password') {
        mensaje = 'La contraseña es incorrecta';
      } else if (e.code == 'invalid-credential') {
        mensaje = 'Correo o contraseña incorrectos';
      } else if (e.code == 'invalid-email') {
        mensaje = 'El correo electrónico no es válido';
      } else if (e.code == 'user-disabled') {
        mensaje = 'Esta cuenta ha sido deshabilitada';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));

      debugPrint('ERROR FIREBASE LOGIN: ${e.code}');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al iniciar sesión: $e')));

      debugPrint('ERROR LOGIN: $e');
    }
  }

  // =========================================================
  // LOGIN CON GOOGLE
  // =========================================================

  Future<void> iniciarSesionGoogle() async {
    setState(() {
      cargandoGoogle = true;
    });

    try {
      // Iniciar sesión con Google
      final cuenta = await GoogleService.iniciarSesion();

      if (!mounted) return;

      if (cuenta == null) {
        setState(() {
          cargandoGoogle = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo iniciar sesión con Google')),
        );

        return;
      }

      // =====================================================
      // OBTENER TOKEN DE GOOGLE
      // =====================================================

      final googleAuth = cuenta.authentication;

      // =====================================================
      // CREAR CREDENCIAL PARA FIREBASE
      // =====================================================

      final credencialGoogle = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // =====================================================
      // INICIAR SESIÓN EN FIREBASE AUTHENTICATION
      // =====================================================

      final resultado = await FirebaseAuth.instance.signInWithCredential(
        credencialGoogle,
      );

      final User? usuarioFirebase = resultado.user;

      if (usuarioFirebase == null) {
        throw Exception('No se pudo obtener el usuario de Google');
      }

      // =====================================================
      // BUSCAR USUARIO EN FIRESTORE
      // =====================================================

      final referencia = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuarioFirebase.uid);

      final documento = await referencia.get();

      // =====================================================
      // SI ES NUEVO USUARIO
      // =====================================================

      if (!documento.exists) {
        await referencia.set({
          'nombre': usuarioFirebase.displayName ?? 'Usuario Google',
          'correo': usuarioFirebase.email ?? '',
          'telefono': '',
          'rol': 'cliente',
        });
      }

      // =====================================================
      // OBTENER DATOS ACTUALES DE FIRESTORE
      // =====================================================

      final documentoActual = await referencia.get();

      final datos = documentoActual.data()!;

      // =====================================================
      // CREAR OBJETO USUARIO
      // =====================================================

      // =====================================================
      // OBTENER ID DEL USUARIO
      // =====================================================

      int? usuarioId;

      final idFirestore = datos['id'];

      if (idFirestore is num) {
        usuarioId = idFirestore.toInt();
      }

      // Si no tiene ID, generamos uno y lo guardamos.
      if (usuarioId == null) {
        usuarioId = DateTime.now().millisecondsSinceEpoch;

        await referencia.set({'id': usuarioId}, SetOptions(merge: true));

        debugPrint('ID NUEVO GOOGLE GUARDADO: $usuarioId');
      } else {
        debugPrint('ID GOOGLE LEÍDO DESDE FIRESTORE: $usuarioId');
      }

      // =====================================================
      // CREAR OBJETO USUARIO
      // =====================================================

      final usuario = Usuario(
        id: usuarioId,
        nombre:
            datos['nombre'] ?? usuarioFirebase.displayName ?? 'Usuario Google',
        correo: datos['correo'] ?? usuarioFirebase.email ?? '',
        password: '',
        telefono: datos['telefono'] ?? '',
        rol: datos['rol'] ?? 'cliente',
      );

      if (!mounted) return;

      setState(() {
        cargandoGoogle = false;
      });

      // =====================================================
      // GUARDAR SESIÓN
      // =====================================================

      Sesion.iniciarSesion(usuario);

      // =====================================================
      // REDIRECCIÓN SEGÚN EL ROL
      // =====================================================

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
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        cargandoGoogle = false;
      });

      String mensaje = 'No se pudo iniciar sesión con Google';

      if (e.code == 'account-exists-with-different-credential') {
        mensaje = 'Ya existe una cuenta con este correo';
      } else if (e.code == 'credential-already-in-use') {
        mensaje = 'Esta cuenta de Google ya está vinculada';
      } else if (e.code == 'invalid-credential') {
        mensaje = 'La credencial de Google no es válida';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));

      debugPrint('ERROR FIREBASE GOOGLE: ${e.code}');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargandoGoogle = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar con Google: $e')),
      );

      debugPrint('ERROR LOGIN GOOGLE: $e');
    }
  }

  // =========================================================
  // INTERFAZ
  // =========================================================

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
                // =================================================
                // LOGO / NOMBRE
                // =================================================
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

                // =================================================
                // TARJETA DE LOGIN
                // =================================================
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
                      // =================================================
                      // TÍTULO LOGIN
                      // =================================================
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

                      // =================================================
                      // CORREO
                      // =================================================
                      TextField(
                        controller: correoController,
                        keyboardType: TextInputType.emailAddress,

                        style: const TextStyle(color: AppColors.crema),

                        decoration: InputDecoration(
                          labelText: 'Correo electrónico',

                          labelStyle: const TextStyle(
                            color: AppColors.textoSecundario,
                          ),

                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: AppColors.naranja,
                          ),

                          filled: true,

                          fillColor: AppColors.fondo,

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),

                            borderSide: const BorderSide(
                              color: AppColors.borde,
                            ),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),

                            borderSide: const BorderSide(
                              color: AppColors.naranja,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // =================================================
                      // CONTRASEÑA
                      // =================================================
                      TextField(
                        controller: passwordController,

                        obscureText: ocultarPassword,

                        style: const TextStyle(color: AppColors.crema),

                        decoration: InputDecoration(
                          labelText: 'Contraseña',

                          labelStyle: const TextStyle(
                            color: AppColors.textoSecundario,
                          ),

                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: AppColors.naranja,
                          ),

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

                          filled: true,

                          fillColor: AppColors.fondo,

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),

                            borderSide: const BorderSide(
                              color: AppColors.borde,
                            ),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),

                            borderSide: const BorderSide(
                              color: AppColors.naranja,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // =================================================
                      // BOTÓN LOGIN
                      // =================================================
                      SizedBox(
                        height: 52,

                        child: ElevatedButton(
                          onPressed: cargando || cargandoGoogle
                              ? null
                              : iniciarSesionNormal,

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

                      // =================================================
                      // SEPARADOR
                      // =================================================
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

                      // =================================================
                      // GOOGLE
                      // =================================================
                      OutlinedButton.icon(
                        onPressed: cargando || cargandoGoogle
                            ? null
                            : iniciarSesionGoogle,

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

                      // =================================================
                      // REGISTRO
                      // =================================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          const Text(
                            '¿No tienes cuenta?',

                            style: AppStyles.textoNormal,
                          ),

                          TextButton(
                            onPressed: () {
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
