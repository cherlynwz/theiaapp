import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../logica/autenticacion_service.dart';
import '../../../logica/sesion.dart';
import '../../estilos/styles.dart';

class EditarPerfil extends StatefulWidget {
  const EditarPerfil({super.key});

  @override
  State<EditarPerfil> createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
  final _formKey = GlobalKey<FormState>();
  final _servicio = AutenticacionService();

  late final TextEditingController nombreController;
  late final TextEditingController telefonoController;

  bool guardando = false;
  bool validarCampos = false;
  String? mensajeError;

  @override
  void initState() {
    super.initState();

    final usuario = Sesion.usuarioActual;

    nombreController = TextEditingController(text: usuario?.nombre ?? '');

    telefonoController = TextEditingController(text: usuario?.telefono ?? '');
  }

  @override
  void dispose() {
    nombreController.dispose();
    telefonoController.dispose();
    super.dispose();
  }

  Future<void> guardarPerfil() async {
    if (guardando) return;

    setState(() {
      validarCampos = true;
      mensajeError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      guardando = true;
    });

    try {
      await _servicio.actualizarPerfil(
        nombre: nombreController.text,
        telefono: telefonoController.text,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } on AutenticacionException catch (e) {
      if (!mounted) return;

      String mensaje;

      switch (e.code) {
        case 'nombre-invalido':
          mensaje = 'Revisa el nombre ingresado.';
          break;
        case 'telefono-invalido':
          mensaje = 'El teléfono debe tener exactamente 10 dígitos.';
          break;
        case 'usuario-no-autenticado':
        case 'sesion-cambiada':
          mensaje = 'Tu sesión cambió. Vuelve a iniciar sesión.';
          break;
        case 'permission-denied':
          mensaje = 'No tienes permiso para actualizar estos datos.';
          break;
        case 'network-request-failed':
        case 'unavailable':
          mensaje = 'Revisa tu conexión a Internet e intenta nuevamente.';
          break;
        default:
          mensaje = 'No se pudo actualizar el perfil. Intenta nuevamente.';
      }

      setState(() {
        mensajeError = mensaje;
      });
    } catch (e) {
      if (!mounted) return;

      debugPrint('ERROR AL ACTUALIZAR PERFIL: $e');

      setState(() {
        mensajeError =
            'No se pudo guardar el perfil. Revisa tu conexión e intenta nuevamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          guardando = false;
        });
      }
    }
  }

  InputDecoration _decoracion(String titulo, IconData icono) {
    return InputDecoration(
      labelText: titulo,
      labelStyle: const TextStyle(color: AppColors.textoSecundario),
      prefixIcon: Icon(icono, color: AppColors.naranja),
      filled: true,
      fillColor: AppColors.tarjeta,
      errorMaxLines: 3,
      errorStyle: const TextStyle(color: Colors.redAccent),
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
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = Sesion.usuarioActual;

    return PopScope(
      canPop: !guardando,
      child: Scaffold(
        backgroundColor: AppColors.fondo,
        appBar: AppBar(
          backgroundColor: AppColors.fondo,
          foregroundColor: AppColors.crema,
          automaticallyImplyLeading: !guardando,
          title: const Text(
            'Editar perfil',
            style: TextStyle(
              color: AppColors.crema,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            autovalidateMode: validarCampos
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Datos personales', style: AppStyles.tituloGrande),
                const SizedBox(height: 8),
                const Text(
                  'Actualiza tu nombre y teléfono.',
                  style: AppStyles.textoNormal,
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: nombreController,
                  enabled: !guardando,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(color: AppColors.crema),
                  decoration: _decoracion(
                    'Nombre completo',
                    Icons.person_outline,
                  ),
                  validator: (valor) {
                    return AutenticacionService.validarNombrePerfil(
                      valor ?? '',
                    );
                  },
                ),
                const SizedBox(height: 18),

                TextFormField(
                  controller: telefonoController,
                  enabled: !guardando,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: const TextStyle(color: AppColors.crema),
                  decoration: _decoracion('Teléfono', Icons.phone_outlined),
                  validator: (valor) {
                    return AutenticacionService.validarTelefonoPerfil(
                      valor ?? '',
                    );
                  },
                ),
                const SizedBox(height: 22),

                const Text('Correo electrónico', style: AppStyles.titulo),
                const SizedBox(height: 8),
                Text(usuario?.correo ?? '', style: AppStyles.textoNormal),
                const SizedBox(height: 8),
                const Text(
                  'El correo no se modifica desde esta pantalla.',
                  style: AppStyles.textoNormal,
                ),

                if (mensajeError != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    mensajeError!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],

                const SizedBox(height: 28),
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: guardando ? null : guardarPerfil,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.naranja,
                      foregroundColor: AppColors.negro,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: guardando
                        ? const SizedBox(
                            width: 23,
                            height: 23,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.naranja,
                            ),
                          )
                        : const Text(
                            'GUARDAR CAMBIOS',
                            style: AppStyles.textoBoton,
                          ),
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
