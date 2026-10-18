import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppServicio {
  // CAMBIA ESTE NÚMERO POR EL REAL DE THEIA.
  // México: 52 + los 10 dígitos del número.
  // SIN +, SIN espacios y SIN guiones.
  //
  // Ejemplo:
  // 525512345678
  static const String numeroWhatsApp = '7721464993';

  static Future<void> abrirWhatsApp(BuildContext context) async {
    const String mensaje =
        'Hola, quiero información sobre los productos de THEIA.';

    final Uri url = Uri.parse(
      'https://wa.me/$numeroWhatsApp?text=${Uri.encodeComponent(mensaje)}',
    );

    try {
      final resultado = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!resultado && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp.')),
        );
      }
    } catch (e) {
      debugPrint('ERROR AL ABRIR WHATSAPP: $e');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir WhatsApp.')),
      );
    }
  }
}
