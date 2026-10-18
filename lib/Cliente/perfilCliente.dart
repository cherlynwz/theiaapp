import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Styles/styles.dart';
import '../Servicios/sesion.dart';
import '../login.dart';
import 'pedidos.dart';
import 'ubicacion.dart';

class PerfilCliente extends StatelessWidget {
  const PerfilCliente({super.key});

  // ============================================================
  // CONFIGURACIÓN
  // ============================================================

  // Número de WhatsApp de THEIA.
  // México +52 + número de 10 dígitos.
  static const String numeroWhatsApp = '527721464993';

  // Dirección de THEIA
  static const String direccionTheia =
      'Leona Vicario 72, San Antonio, 42300 Ixmiquilpan, Hgo.';

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

              onTap: () {
                _mostrarDatosPersonales(context);
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

  Future<void> _abrirGoogleMaps(BuildContext context) async {
    final Uri mapa = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query='
      'Leona%20Vicario%2072%2C%20San%20Antonio%2C%2042300%20Ixmiquilpan%2C%20Hgo.',
    );

    try {
      // Abrimos directamente Google Maps/navegador.
      // No usamos canLaunchUrl antes porque puede devolver false
      // aunque Android sí pueda manejar el enlace.

      final bool abierto = await launchUrl(
        mapa,
        mode: LaunchMode.externalApplication,
      );

      if (!abierto && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir Google Maps')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrió un error al abrir Google Maps')),
      );

      debugPrint('ERROR GOOGLE MAPS: $e');
    }
  }

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
  // DATOS PERSONALES
  // ============================================================

  void _mostrarDatosPersonales(BuildContext context) {
    final usuario = Sesion.usuarioActual;

    if (usuario == null) {
      _mensajeTemporal(context, 'No hay una sesión activa');

      return;
    }

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.tarjeta,

          title: const Text(
            'Datos personales',

            style: TextStyle(
              color: AppColors.crema,
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // NOMBRE
              // ==================================================
              const Text(
                'Nombre',

                style: TextStyle(
                  color: AppColors.naranja,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                usuario.nombre,

                style: const TextStyle(color: AppColors.crema),
              ),

              const SizedBox(height: 15),

              // ==================================================
              // CORREO
              // ==================================================
              const Text(
                'Correo',

                style: TextStyle(
                  color: AppColors.naranja,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                usuario.correo,

                style: const TextStyle(color: AppColors.crema),
              ),

              const SizedBox(height: 15),

              // ==================================================
              // TELÉFONO
              // ==================================================
              const Text(
                'Teléfono',

                style: TextStyle(
                  color: AppColors.naranja,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                usuario.telefono.isEmpty ? 'No registrado' : usuario.telefono,

                style: const TextStyle(color: AppColors.crema),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                'Cerrar',

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

  // ============================================================
  // MENSAJE TEMPORAL
  // ============================================================

  void _mensajeTemporal(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.tarjetaClara,

        content: Text(mensaje, style: const TextStyle(color: AppColors.crema)),
      ),
    );
  }

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
