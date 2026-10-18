import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'qexm5dcc';
  static const String uploadPreset = 'theia_productos';

  static Future<String> subirImagen(File imagen) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', url);

    request.fields['upload_preset'] = uploadPreset;

    request.files.add(await http.MultipartFile.fromPath('file', imagen.path));

    final respuesta = await request.send();

    final contenido = await respuesta.stream.bytesToString();

    if (respuesta.statusCode != 200) {
      throw Exception(
        'No se pudo subir la imagen a Cloudinary.\n'
        'Código: ${respuesta.statusCode}\n'
        '$contenido',
      );
    }

    final datos = jsonDecode(contenido);

    final String? urlImagen = datos['secure_url'];

    if (urlImagen == null || urlImagen.isEmpty) {
      throw Exception('Cloudinary no devolvió la URL de la imagen.');
    }

    return urlImagen;
  }
}
