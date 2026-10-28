import '../datos/dao/productos_dao.dart';
import '../modelos/producto.dart';

class ProductoDuplicadoException implements Exception {
  @override
  String toString() {
    return 'Ya existe otro producto con ese nombre.';
  }
}

class PrecioProductoException implements Exception {
  final String mensaje;

  PrecioProductoException(this.mensaje);

  @override
  String toString() => mensaje;
}

class ProductosService {
  static const double precioMinimo = 0.01;
  static const double precioMaximo = 2000.00;

  final ProductoDAO _dao = ProductoDAO();

  // Validación del texto escrito en las pantallas.
  // Permite punto o coma como separador decimal, sin separadores de miles.
  static String? validarPrecioTexto(String texto) {
    final valor = texto.trim();

    if (valor.isEmpty) {
      return 'Escribe el precio del producto.';
    }

    if (!RegExp(r'^[0-9]+([.,][0-9]{1,2})?$').hasMatch(valor)) {
      return 'Escribe un precio con máximo dos decimales, como 150.50.';
    }

    final precio = double.tryParse(valor.replaceAll(',', '.'));

    if (precio == null) {
      return 'Ingresa un precio válido.';
    }

    return validarPrecio(precio);
  }

  // Validación compartida antes de guardar en Firebase.
  static String? validarPrecio(num precio) {
    if (!precio.isFinite) {
      return 'Ingresa un precio válido.';
    }

    if (precio < precioMinimo || precio > precioMaximo) {
      return 'El precio debe estar entre \$0.01 y \$2,000.00 MXN.';
    }

    // Tolerancia pequeña para la representación decimal de double.
    final centavos = precio * 100;

    if ((centavos - centavos.round()).abs() > 0.00000001) {
      return 'El precio debe tener máximo dos decimales.';
    }

    return null;
  }

  void _validarPrecioProducto(Producto producto) {
    final error = validarPrecio(producto.precio);

    if (error != null) {
      throw PrecioProductoException(error);
    }
  }

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
      // Permite conservar el nombre del propio producto al editar.
      if (editando &&
          producto.id != null &&
          existente.id == producto.id) {
        return false;
      }

      return _normalizarNombre(existente.nombre) == nombre;
    });

    if (duplicado) {
      throw ProductoDuplicadoException();
    }
  }

  Future<int> insertarProducto(Producto producto) async {
    _validarPrecioProducto(producto);
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
    _validarPrecioProducto(producto);
    await _validarNombreDisponible(producto, editando: true);

    return _dao.actualizarProducto(producto);
  }

  Future<int> contarProductos() {
    return _dao.contarProductos();
  }
}