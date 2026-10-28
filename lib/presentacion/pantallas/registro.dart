import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../logica/autenticacion_service.dart';
import '../estilos/styles.dart';

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final _formKey = GlobalKey<FormState>();

  final nombreController = TextEditingController();
  final telefonoController = TextEditingController();
  final correoController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmarController = TextEditingController();

  bool ocultarPassword = true;
  bool ocultarConfirmacion = true;
  bool validarCampos = false;
  bool registrando = false;

  String? errorCorreoServidor;

  @override
  void dispose() {
    nombreController.dispose();
    telefonoController.dispose();
    correoController.dispose();
    passwordController.dispose();
    confirmarController.dispose();
    super.dispose();
  }

  String _normalizarNombre(String valor) {
    return valor.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String? _validarNombre(String? valor) {
    final nombre = _normalizarNombre(valor ?? '');

    if (nombre.isEmpty) {
      return 'Ingresa tu nombre';
    }

    if (nombre.runes.length > 100) {
      return 'El nombre debe tener como máximo 100 caracteres';
    }

    // Letras Unicode, acentos y marcas de acentuación.
    // Permite espacios, apóstrofos y guiones entre partes del nombre.
    final formatoNombre = RegExp(
      r"^\p{L}[\p{L}\p{M}]*(?:[ '\u2019\u002D]\p{L}[\p{L}\p{M}]*)*$",
      unicode: true,
    );

    if (!formatoNombre.hasMatch(nombre)) {
      return 'Usa solo letras. Puedes separar los nombres con '
          'espacios, apóstrofos o guiones';
    }

    return null;
  }

  Future<void> _registrar() async {
    if (registrando) return;

    setState(() {
      validarCampos = true;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      registrando = true;
    });

    try {
      await AutenticacionService().registrar(
        nombre: _normalizarNombre(nombreController.text),
        correo: correoController.text.trim(),
        password: passwordController.text,
        telefono: telefonoController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada correctamente')),
      );

      Navigator.pop(context);
    } on AutenticacionException catch (e) {
      if (!mounted) return;

      if (e.code == 'email-already-in-use' || e.code == 'invalid-email') {
        setState(() {
          errorCorreoServidor = e.code == 'email-already-in-use'
              ? 'Este correo ya está registrado'
              : 'El correo electrónico no es válido';
        });

        _formKey.currentState!.validate();
        return;
      }

      final mensaje = e.code == 'weak-password'
          ? 'La contraseña no cumple los requisitos de seguridad.'
          : 'No se pudo crear la cuenta';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrió un error al crear la cuenta')),
      );
    } finally {
      if (mounted) {
        setState(() {
          registrando = false;
        });
      }
    }
  }

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
          child: Form(
            key: _formKey,
            autovalidateMode: validarCampos
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            onChanged: () {
              if (validarCampos) {
                _formKey.currentState?.validate();
              }
            },
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

                // NOMBRE
                _campo(
                  controller: nombreController,
                  titulo: 'Nombre completo',
                  icono: Icons.person_outline,
                  capitalizacion: TextCapitalization.words,
                  validator: _validarNombre,
                ),
                const SizedBox(height: 16),

                // TELÉFONO
                _campo(
                  controller: telefonoController,
                  titulo: 'Teléfono',
                  icono: Icons.phone_outlined,
                  tipo: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (valor) {
                    final telefono = valor?.trim() ?? '';

                    if (telefono.isEmpty) {
                      return 'Ingresa tu teléfono';
                    }

                    if (!RegExp(r'^[0-9]{10}$').hasMatch(telefono)) {
                      return 'El teléfono debe tener exactamente 10 dígitos';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // CORREO
                _campo(
                  controller: correoController,
                  titulo: 'Correo electrónico',
                  icono: Icons.email_outlined,
                  tipo: TextInputType.emailAddress,
                  onChanged: (_) {
                    if (errorCorreoServidor != null) {
                      setState(() {
                        errorCorreoServidor = null;
                      });

                      _formKey.currentState?.validate();
                    }
                  },
                  validator: (valor) {
                    final correo = valor?.trim() ?? '';

                    if (correo.isEmpty) {
                      return 'Ingresa tu correo electrónico';
                    }

                    if (!RegExp(
                      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                    ).hasMatch(correo)) {
                      return 'Ingresa un correo válido, como nombre@correo.com';
                    }

                    return errorCorreoServidor;
                  },
                ),
                const SizedBox(height: 16),

                // CONTRASEÑA
                TextFormField(
                  controller: passwordController,
                  enabled: !registrando,
                  obscureText: ocultarPassword,
                  autocorrect: false,
                  enableSuggestions: false,
                  style: const TextStyle(color: AppColors.crema),
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Ingresa una contraseña';
                    }

                    return AutenticacionService.validarPassword(valor);
                  },
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
                const SizedBox(height: 8),
                const Text(
                  'Usa al menos 8 caracteres con mayúscula, minúscula, '
                  'número y símbolo. Evita tu nombre o datos personales.',
                  style: AppStyles.textoNormal,
                ),
                const SizedBox(height: 16),

                // CONFIRMAR CONTRASEÑA
                TextFormField(
                  controller: confirmarController,
                  enabled: !registrando,
                  obscureText: ocultarConfirmacion,
                  autocorrect: false,
                  enableSuggestions: false,
                  style: const TextStyle(color: AppColors.crema),
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Confirma tu contraseña';
                    }

                    if (valor != passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }

                    return null;
                  },
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

                // CREAR CUENTA
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: registrando ? null : _registrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.naranja,
                      foregroundColor: AppColors.negro,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: registrando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.naranja,
                            ),
                          )
                        : const Text(
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
                      onPressed: registrando
                          ? null
                          : () {
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
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String titulo,
    required IconData icono,
    TextInputType tipo = TextInputType.text,
    TextCapitalization capitalizacion = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !registrando,
      keyboardType: tipo,
      textCapitalization: capitalizacion,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
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
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
      errorMaxLines: 4,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.borde),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.naranja),
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
}
