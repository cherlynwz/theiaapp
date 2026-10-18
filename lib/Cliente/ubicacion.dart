import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Styles/styles.dart';

class UbicacionScreen extends StatelessWidget {
  const UbicacionScreen({super.key});

  // 📍 Ubicación de THEIA
  static const LatLng ubicacionTheia = LatLng(20.4924682, -99.2116644);

  // Abrir Google Maps para obtener la ruta
  Future<void> abrirGoogleMaps(BuildContext context) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=20.4924682,-99.2116644'
      '&travelmode=driving',
    );

    try {
      final resultado = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!resultado && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir Google Maps')),
        );
      }
    } catch (e) {
      print('ERROR GOOGLE MAPS: $e');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir Google Maps')),
      );
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
        title: const Text(
          'Ubicación',
          style: TextStyle(color: AppColors.crema, fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        children: [
          // =========================
          // MAPA
          // =========================
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(18, 10, 18, 12),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.borde),
              ),
              child: FlutterMap(
                options: const MapOptions(
                  initialCenter: ubicacionTheia,
                  initialZoom: 16,
                ),

                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.theia.theiaapp',
                  ),

                  MarkerLayer(
                    markers: [
                      Marker(
                        point: ubicacionTheia,
                        width: 70,
                        height: 70,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 55,
                        ),
                      ),
                    ],
                  ),

                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors',
                        onTap: () {
                          launchUrl(
                            Uri.parse(
                              'https://www.openstreetmap.org/copyright',
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // =========================
          // TARJETA THEIA
          // =========================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
            decoration: BoxDecoration(
              color: AppColors.tarjeta,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    SizedBox(width: 10),
                    Text(
                      'THEIA',
                      style: TextStyle(
                        color: AppColors.crema,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                const Text(
                  'Visítanos en nuestra pastelería.',
                  style: TextStyle(
                    color: AppColors.textoSecundario,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      abrirGoogleMaps(context);
                    },
                    icon: const Icon(Icons.navigation),
                    label: const Text(
                      'CÓMO LLEGAR',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.naranja,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
