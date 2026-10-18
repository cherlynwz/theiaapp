import 'dart:io';
import '../datos/servicios/cloudinary_service.dart';

class ImagenesService {
  static Future<String> subirImagen(File imagen) =>
      CloudinaryService.subirImagen(imagen);
}
