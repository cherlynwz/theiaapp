import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../estilos/styles.dart';
import '../../../logica/sesion.dart';
import '../login.dart';
import 'pedidos.dart';
import 'ubicacion.dart';
import 'editar_perfil.dart';

class PerfilCliente extends StatefulWidget {
  const PerfilCliente({super.key});

  @override
  State<PerfilCliente> createState() => _PerfilClienteState();
}

class _PerfilClienteState extends State<PerfilCliente> {
  // ============================================================
  // CONFIGURACIÓN
  // ============================================================

  // Número de WhatsApp de THEIA.
  // México +52 + número de 10 dígitos.
  static const String numeroWhatsApp = '527721464993';

  // Dirección de THEIA


  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final usuario = Sesion.usuarioActual;

    return Scaffold(
      backgroundColor: AppColors.fondo,

      appBar: AppBar(
        backgroundColor: AppColors.fondo,
        foregroundColor: AppColors.crema,
        elevation: 0,

        title: const Text(
          'Mi perfil',
          style: TextStyle(color: AppColors.crema, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==================================================
            // ENCABEZADO DEL PERFIL
            // ==================================================
            _encabezadoPerfil(),

            const SizedBox(height: 28),

            // ==================================================
            // MI CUENTA
            // ==================================================
            const Text('Mi cuenta', style: AppStyles.titulo),

            const SizedBox(height: 14),

            // ==================================================
            // MIS PEDIDOS
            // ==================================================
            _opcion(
              context: context,
              icono: Icons.receipt_long_outlined,
              titulo: 'Mis pedidos',
              subtitulo: 'Consulta el estado de tus compras',

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PedidosCliente()),
                );
              },
            ),

            const SizedBox(height: 12),

            // ==================================================

            // ==================================================
            // DATOS PERSONALES
            // ==================================================
            _opcion(
              context: context,
              icono: Icons.person_outline,
              titulo: 'Datos personales',

              subtitulo: usuario == null
                  ? 'Nombre, teléfono y correo'
                  : '${usuario.nombre} • ${usuario.correo}',

              onTap: () async {
                final actualizado = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const EditarPerfil()),
                );

                if (!context.mounted) return;

                if (actualizado == true) {
                  setState(() {});

                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.tarjetaClara,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        content: const Text(
                          'Perfil actualizado correctamente',
                          style: TextStyle(color: AppColors.crema),
                        ),
                      ),
                    );
                }
              },
            ),

            const SizedBox(height: 12),

            // ==================================================
            // DIRECCIÓN
            // ==================================================
            _opcion(
              context: context,
              icono: Icons.location_on_outlined,
              titulo: 'Dirección',
              subtitulo: 'Ver ubicación de THEIA en Google Maps',

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UbicacionScreen()),
                );
              },
            ),

            const SizedBox(height: 28),

            // ==================================================
            // AYUDA
            // ==================================================
            const Text('Ayuda', style: AppStyles.titulo),

            const SizedBox(height: 14),

            // ==================================================
            // WHATSAPP
            // ==================================================
            _opcion(
              context: context,
              icono: Icons.chat_outlined,
              titulo: 'Contactar por WhatsApp',
              subtitulo: 'Habla directamente con THEIA',

              onTap: () async {
                await _abrirWhatsApp(context);
              },
            ),

            const SizedBox(height: 12),

            // ==================================================

            // ==================================================
            // CERRAR SESIÓN
            // ==================================================
            SizedBox(
              width: double.infinity,
              height: 52,

              child: OutlinedButton.icon(
                onPressed: () {
                  _cerrarSesion(context);
                },

                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.naranja,

                  side: const BorderSide(color: AppColors.naranja),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),

                icon: const Icon(Icons.logout),

                label: const Text(
                  'CERRAR SESIÓN',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ENCABEZADO DEL PERFIL
  // ============================================================

  Widget _encabezadoPerfil() {
    final usuario = Sesion.usuarioActual;

    final String nombre = usuario != null && usuario.nombre.trim().isNotEmpty
        ? usuario.nombre
        : 'Usuario THEIA';

    final String correo = usuario != null && usuario.correo.trim().isNotEmpty
        ? usuario.correo
        : 'Sin correo';

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: AppColors.tarjeta,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: AppColors.borde),
      ),

      child: Row(
        children: [
          // ==================================================
          // ICONO DEL USUARIO
          // ==================================================
          Container(
            width: 78,
            height: 78,

            decoration: BoxDecoration(
              color: AppColors.tarjetaClara,

              shape: BoxShape.circle,

              border: Border.all(color: AppColors.naranja, width: 2),
            ),

            child: const Icon(Icons.person, color: AppColors.naranja, size: 45),
          ),

          const SizedBox(width: 17),

          // ==================================================
          // DATOS
          // ==================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  nombre,

                  style: const TextStyle(
                    color: AppColors.crema,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  correo,

                  style: const TextStyle(
                    color: AppColors.textoSecundario,
                    fontSize: 13,
                  ),

                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 9),

                const Text(
                  'Cliente THEIA',

                  style: TextStyle(
                    color: AppColors.naranja,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OPCIÓN DEL MENÚ
  // ============================================================

  Widget _opcion({
    required BuildContext context,
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(17),

      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(15),

        decoration: BoxDecoration(
          color: AppColors.tarjeta,

          borderRadius: BorderRadius.circular(17),

          border: Border.all(color: AppColors.borde),
        ),

        child: Row(
          children: [
            // ==================================================
            // ICONO
            // ==================================================
            Container(
              width: 47,
              height: 47,

              decoration: BoxDecoration(
                color: AppColors.tarjetaClara,

                borderRadius: BorderRadius.circular(13),
              ),

              child: Icon(icono, color: AppColors.naranja),
            ),

            const SizedBox(width: 14),

            // ==================================================
            // TEXTO
            // ==================================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    titulo,

                    style: const TextStyle(
                      color: AppColors.crema,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitulo,

                    style: const TextStyle(
                      color: AppColors.textoSecundario,
                      fontSize: 12,
                    ),

                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ==================================================
            // FLECHA
            // ==================================================
            const Icon(Icons.chevron_right, color: AppColors.naranja),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // GOOGLE MAPS
  // ============================================================

  // ============================================================
  // WHATSAPP
  // ============================================================

  Future<void> _abrirWhatsApp(BuildContext context) async {
    final String mensaje = Uri.encodeComponent(
      'Hola THEIA, quiero información sobre sus productos.',
    );

    // WhatsApp con número internacional de México.
    final Uri whatsapp = Uri.parse(
      'https://wa.me/$numeroWhatsApp?text=$mensaje',
    );

    try {
      final bool abierto = await launchUrl(
        whatsapp,
        mode: LaunchMode.externalApplication,
      );

      if (abierto) {
        return;
      }

      // Segundo intento: esquema directo de WhatsApp.
      final Uri whatsappApp = Uri.parse(
        'whatsapp://send?phone=$numeroWhatsApp&text=$mensaje',
      );

      final bool abiertoApp = await launchUrl(
        whatsappApp,
        mode: LaunchMode.externalApplication,
      );

      if (abiertoApp) {
        return;
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir WhatsApp')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir WhatsApp')),
      );

      debugPrint('ERROR WHATSAPP: $e');
    }
  }

  // ============================================================

  // ============================================================
  // CERRAR SESIÓN
  // ============================================================

  void _cerrarSesion(BuildContext context) {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.tarjeta,

          title: const Text(
            'Cerrar sesión',

            style: TextStyle(color: AppColors.crema),
          ),

          content: const Text(
            '¿Quieres cerrar tu sesión en THEIA?',

            style: TextStyle(color: AppColors.textoSecundario),
          ),

          actions: [
            // ==================================================
            // CANCELAR
            // ==================================================
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                'Cancelar',

                style: TextStyle(color: AppColors.textoSecundario),
              ),
            ),

            // ==================================================
            // CERRAR SESIÓN
            // ==================================================
            TextButton(
              onPressed: () {
                Sesion.cerrarSesion();

                Navigator.pushAndRemoveUntil(
                  context,

                  MaterialPageRoute(builder: (_) => const Login()),

                  (route) => false,
                );
              },

              child: const Text(
                'Cerrar sesión',

                style: TextStyle(
                  color: AppColors.naranja,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
