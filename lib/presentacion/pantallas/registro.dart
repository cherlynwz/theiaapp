import '../../logica/autenticacion_service.dart';
import 'package:flutter/material.dart';

import '../estilos/styles.dart';

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final nombreController = TextEditingController();
  final telefonoController = TextEditingController();
  final correoController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmarController = TextEditingController();

  bool ocultarPassword = true;
  bool ocultarConfirmacion = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,

      appBar: AppBar(
        backgroundColor: AppColors.fondo,
        foregroundColor: AppColors.crema,
        elevation: 0,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 10, 28, 35),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              const Text('Crear cuenta', style: AppStyles.tituloGrande),

              const SizedBox(height: 8),

              const Text(
                'Regístrate para disfrutar de THEIA',
                style: AppStyles.textoNormal,
              ),

              const SizedBox(height: 30),

              _campo(
                controller: nombreController,
                titulo: 'Nombre completo',
                icono: Icons.person_outline,
              ),

              const SizedBox(height: 16),

              _campo(
                controller: telefonoController,
                titulo: 'Teléfono',
                icono: Icons.phone_outlined,
                tipo: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              _campo(
                controller: correoController,
                titulo: 'Correo electrónico',
                icono: Icons.email_outlined,
                tipo: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText: ocultarPassword,
                style: const TextStyle(color: AppColors.crema),
                decoration: _decoracion('Contraseña', Icons.lock_outline)
                    .copyWith(
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

              const SizedBox(height: 16),

              TextField(
                controller: confirmarController,
                obscureText: ocultarConfirmacion,
                style: const TextStyle(color: AppColors.crema),
                decoration:
                    _decoracion(
                      'Confirmar contraseña',
                      Icons.lock_outline,
                    ).copyWith(
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            ocultarConfirmacion = !ocultarConfirmacion;
                          });
                        },
                        icon: Icon(
                          ocultarConfirmacion
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textoSecundario,
                        ),
                      ),
                    ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                height: 55,

                child: ElevatedButton(
                  onPressed: () async {
                    String nombre = nombreController.text.trim();
                    String telefono = telefonoController.text.trim();
                    String correo = correoController.text.trim();
                    String password = passwordController.text.trim();
                    String confirmar = confirmarController.text.trim();

                    if (nombre.isEmpty ||
                        telefono.isEmpty ||
                        correo.isEmpty ||
                        password.isEmpty ||
                        confirmar.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Completa todos los campos'),
                        ),
                      );

                      return;
                    }

                    if (password != confirmar) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Las contraseñas no coinciden'),
                        ),
                      );

                      return;
                    }

                    try {
                      await AutenticacionService().registrar(
                        nombre: nombre, correo: correo,
                        password: password, telefono: telefono,
                      );

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cuenta creada correctamente'),
                        ),
                      );

                      Navigator.pop(context);
                    } on AutenticacionException catch (e) {
                      String mensaje = 'No se pudo crear la cuenta';

                      if (e.code == 'email-already-in-use') {
                        mensaje = 'Este correo ya está registrado';
                      } else if (e.code == 'invalid-email') {
                        mensaje = 'El correo electrónico no es válido';
                      } else if (e.code == 'weak-password') {
                        mensaje = 'La contraseña es demasiado débil';
                      }

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(mensaje)));
                    } catch (e) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ocurrió un error al crear la cuenta'),
                        ),
                      );
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.naranja,
                    foregroundColor: AppColors.negro,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),

                  child: const Text(
                    'CREAR CUENTA',
                    style: AppStyles.textoBoton,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  const Text(
                    '¿Ya tienes una cuenta?',
                    style: AppStyles.textoNormal,
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    child: const Text(
                      'Inicia sesión',

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
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String titulo,
    required IconData icono,
    TextInputType tipo = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: tipo,

      style: const TextStyle(color: AppColors.crema),

      decoration: _decoracion(titulo, icono),
    );
  }

  InputDecoration _decoracion(String titulo, IconData icono) {
    return InputDecoration(
      labelText: titulo,

      labelStyle: const TextStyle(color: AppColors.textoSecundario),

      prefixIcon: Icon(icono, color: AppColors.naranja),

      filled: true,
      fillColor: AppColors.tarjeta,

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),

        borderSide: const BorderSide(color: AppColors.borde),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),

        borderSide: const BorderSide(color: AppColors.naranja),
      ),
    );
  }
}
