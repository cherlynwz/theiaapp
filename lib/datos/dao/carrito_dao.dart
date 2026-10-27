import 'package:cloud_firestore/cloud_firestore.dart';

class CarritoDAO {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _referencia(String uid) {
    if (uid.isEmpty) {
      throw ArgumentError('El UID del usuario está vacío.');
    }

    return _db.collection('carritos').doc(uid);
  }

  // Escucha únicamente el carrito de la cuenta indicada.
  Stream<List<Map<String, dynamic>>> observarCarrito(String uid) {
    return _referencia(uid).snapshots().map((documento) {
      final datos = documento.data();

      if (datos == null) {
        return <Map<String, dynamic>>[];
      }

      final productos = datos['productos'];

      if (productos is! List) {
        throw const FormatException(
          'Los productos guardados en el carrito no son válidos.',
        );
      }

      return productos.map((producto) {
        if (producto is! Map) {
          throw const FormatException('Un producto del carrito no es válido.');
        }

        return Map<String, dynamic>.from(producto);
      }).toList();
    });
  }

  // Guarda los productos en el documento de su propietario.
  Future<void> guardarCarrito(
    String uid,
    List<Map<String, dynamic>> productos,
  ) {
    return _referencia(uid).set({
      'productos': productos,
      'actualizadoEn': FieldValue.serverTimestamp(),
    });
  }
}
