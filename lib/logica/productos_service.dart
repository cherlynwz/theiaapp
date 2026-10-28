import '../datos/dao/productos_dao.dart';
import '../modelos/producto.dart';

class ProductoDuplicadoException implements Exception {
  @override
  String toString() {
    return 'Ya existe otro producto con ese nombre.';
  }
}

class ProductosService {
  final ProductoDAO _dao = ProductoDAO();

  String _normalizarNombre(String nombre) {
    return nombre.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
  }

  Future<void> _validarNombreDisponible(
    Producto producto, {
    bool editando = false,
  }) async {
    final nombre = _normalizarNombre(producto.nombre);

    if (nombre.isEmpty) {
      throw ArgumentError('Escribe el nombre del producto.');
    }

    final productos = await _dao.obtenerProductos();

    final duplicado = productos.any((existente) {
      // Al editar, el producto puede conservar su propio nombre.
      if (editando && producto.id != null && existente.id == producto.id) {
        return false;
      }

      return _normalizarNombre(existente.nombre) == nombre;
    });

    if (duplicado) {
      throw ProductoDuplicadoException();
    }
  }

  Future<int> insertarProducto(Producto producto) async {
    await _validarNombreDisponible(producto);
    return _dao.insertarProducto(producto);
  }

  Future<List<Producto>> obtenerProductos() {
    return _dao.obtenerProductos();
  }

  Future<int> eliminarProducto(int id) {
    return _dao.eliminarProducto(id);
  }

  Future<int> actualizarProducto(Producto producto) async {
    await _validarNombreDisponible(producto, editando: true);
    return _dao.actualizarProducto(producto);
  }

  Future<int> contarProductos() {
    return _dao.contarProductos();
  }
}
