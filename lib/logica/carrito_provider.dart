import 'package:flutter/foundation.dart';

class CarritoItem {
  final int? id;
  final String nombre;
  final String categoria;
  final String descripcion;
  final String imagen;
  final double precio;
  int cantidad;

  CarritoItem({
    this.id,
    required this.nombre,
    required this.categoria,
    required this.descripcion,
    required this.imagen,
    required this.precio,
    required this.cantidad,
  });

  double get subtotal => precio * cantidad;
}

class CarritoProvider extends ChangeNotifier {
  static final CarritoProvider instance = CarritoProvider._internal();

  CarritoProvider._internal();

  final List<CarritoItem> _productos = [];

  List<CarritoItem> get productos => List.unmodifiable(_productos);

  int get totalProductos {
    return _productos.fold(0, (total, producto) => total + producto.cantidad);
  }

  double get subtotal {
    return _productos.fold(0, (total, producto) => total + producto.subtotal);
  }

  double get envio => _productos.isEmpty ? 0 : 50;

  double get total => subtotal + envio;

  // ==========================================================
  // AGREGAR PRODUCTO
  // ==========================================================

  void agregarProducto(Map<String, dynamic> datos, int cantidad) {
    final int? id = datos['id'];

    final String nombre = datos['nombre']?.toString() ?? 'Producto';

    final String categoria = datos['categoria']?.toString() ?? '';

    final String descripcion = datos['descripcion']?.toString() ?? '';

    final String imagen = datos['imagen']?.toString() ?? '';

    final double precio =
        double.tryParse(datos['precio']?.toString() ?? '0') ?? 0;

    // Si el producto ya existe, aumentamos su cantidad.
    final indice = _productos.indexWhere((producto) {
      if (id != null && producto.id != null) {
        return producto.id == id;
      }

      return producto.nombre == nombre && producto.categoria == categoria;
    });

    if (indice != -1) {
      _productos[indice].cantidad += cantidad;
    } else {
      _productos.add(
        CarritoItem(
          id: id,
          nombre: nombre,
          categoria: categoria,
          descripcion: descripcion,
          imagen: imagen,
          precio: precio,
          cantidad: cantidad,
        ),
      );
    }

    debugPrint('PRODUCTO AGREGADO: $nombre');

    debugPrint('TOTAL PRODUCTOS: $totalProductos');

    notifyListeners();
  }

  // ==========================================================
  // AUMENTAR
  // ==========================================================

  void aumentar(int index) {
    if (index < 0 || index >= _productos.length) {
      return;
    }

    _productos[index].cantidad++;

    notifyListeners();
  }

  // ==========================================================
  // DISMINUIR
  // ==========================================================

  void disminuir(int index) {
    if (index < 0 || index >= _productos.length) {
      return;
    }

    if (_productos[index].cantidad > 1) {
      _productos[index].cantidad--;
    } else {
      _productos.removeAt(index);
    }

    notifyListeners();
  }

  // ==========================================================
  // ELIMINAR
  // ==========================================================

  void eliminar(int index) {
    if (index < 0 || index >= _productos.length) {
      return;
    }

    _productos.removeAt(index);

    notifyListeners();
  }

  // ==========================================================
  // VACIAR
  // ==========================================================

  void vaciar() {
    _productos.clear();

    notifyListeners();
  }
}
