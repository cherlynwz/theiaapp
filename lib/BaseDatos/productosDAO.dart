import 'package:cloud_firestore/cloud_firestore.dart';

import '../Modelos/producto.dart';

class ProductoDAO {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference<Map<String, dynamic>> _productos = FirebaseFirestore
      .instance
      .collection('productos');

  // =====================================================
  // INSERTAR PRODUCTO
  // =====================================================

  Future<int> insertarProducto(Producto producto) async {
    // Generamos un ID numérico para conservar
    // la estructura actual del modelo Producto.
    final int id = DateTime.now().millisecondsSinceEpoch;

    await _productos.doc(id.toString()).set({
      'id': id,
      'nombre': producto.nombre,
      'descripcion': producto.descripcion,
      'precio': producto.precio,
      'categoria': producto.categoria,
      'imagen': producto.imagen,
      'destacado': producto.destacado,
      'masPedido': producto.masPedido,
    });

    return id;
  }

  // =====================================================
  // OBTENER TODOS LOS PRODUCTOS
  // =====================================================

  Future<List<Producto>> obtenerProductos() async {
    final snapshot = await _productos.get();

    return snapshot.docs.map((documento) {
      final datos = documento.data();

      return Producto.fromMap(datos);
    }).toList();
  }

  // =====================================================
  // ELIMINAR PRODUCTO
  // =====================================================

  Future<int> eliminarProducto(int id) async {
    final documento = await _productos.doc(id.toString()).get();

    if (!documento.exists) {
      return 0;
    }

    await _productos.doc(id.toString()).delete();

    return 1;
  }

  // =====================================================
  // ACTUALIZAR PRODUCTO
  // =====================================================

  Future<int> actualizarProducto(Producto producto) async {
    if (producto.id == null) {
      return 0;
    }

    final referencia = _productos.doc(producto.id.toString());

    final documento = await referencia.get();

    if (!documento.exists) {
      return 0;
    }

    await referencia.update({
      'id': producto.id,
      'nombre': producto.nombre,
      'descripcion': producto.descripcion,
      'precio': producto.precio,
      'categoria': producto.categoria,
      'imagen': producto.imagen,
      'destacado': producto.destacado,
      'masPedido': producto.masPedido,
    });

    return 1;
  }

  // =====================================================
  // CONTAR PRODUCTOS
  // =====================================================

  Future<int> contarProductos() async {
    final snapshot = await _productos.get();

    return snapshot.docs.length;
  }
}
