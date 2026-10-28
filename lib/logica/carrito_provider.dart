import 'dart:async';

import 'package:flutter/foundation.dart';

import '../datos/dao/carrito_dao.dart';

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'categoria': categoria,
      'descripcion': descripcion,
      'imagen': imagen,
      'precio': precio,
      'cantidad': cantidad,
    };
  }

  factory CarritoItem.fromMap(Map<String, dynamic> datos) {
    final idGuardado = datos['id'];
    final precioGuardado = double.tryParse(datos['precio']?.toString() ?? '');
    final cantidadGuardada = int.tryParse(datos['cantidad']?.toString() ?? '');

    if (precioGuardado == null ||
        !precioGuardado.isFinite ||
        precioGuardado < 0 ||
        cantidadGuardada == null ||
        cantidadGuardada <= 0) {
      throw const FormatException(
        'Un producto guardado en el carrito tiene datos inválidos.',
      );
    }

    return CarritoItem(
      id: idGuardado is num ? idGuardado.toInt() : null,
      nombre: datos['nombre']?.toString() ?? 'Producto',
      categoria: datos['categoria']?.toString() ?? '',
      descripcion: datos['descripcion']?.toString() ?? '',
      imagen: datos['imagen']?.toString() ?? '',
      precio: precioGuardado,
      cantidad: cantidadGuardada,
    );
  }
}

class CarritoProvider extends ChangeNotifier {
  static final CarritoProvider instance = CarritoProvider._internal();

  static const int maximoPorProducto = 15;
  static const String mensajeLimite =
      'Puedes comprar hasta 15 unidades de este producto por pedido.';

  CarritoProvider._internal();

  final CarritoDAO _dao = CarritoDAO();
  final List<CarritoItem> _productos = [];

  StreamSubscription<List<Map<String, dynamic>>>? _suscripcion;

  String? _uid;
  String? _mensajeError;

  bool _cargado = false;
  int _versionSesion = 0;
  int _guardadosPendientes = 0;

  List<CarritoItem> get productos => List.unmodifiable(_productos);
  String? get mensajeError => _mensajeError;
  bool get sincronizando => _guardadosPendientes > 0;

  bool get superaLimite =>
      _productos.any((producto) => producto.cantidad > maximoPorProducto);

  int _indiceProducto(Map<String, dynamic> datos) {
    final valorId = datos['id'];
    final int? id = valorId is num ? valorId.toInt() : null;
    final nombre = datos['nombre']?.toString() ?? 'Producto';
    final categoria = datos['categoria']?.toString() ?? '';

    return _productos.indexWhere((producto) {
      if (id != null && producto.id != null) {
        return producto.id == id;
      }
      return producto.nombre == nombre && producto.categoria == categoria;
    });
  }

  int cantidadEnCarrito(Map<String, dynamic> datos) {
    final indice = _indiceProducto(datos);
    return indice == -1 ? 0 : _productos[indice].cantidad;
  }

  int get totalProductos {
    return _productos.fold(0, (total, producto) => total + producto.cantidad);
  }

  double get subtotal {
    return _productos.fold(0, (total, producto) => total + producto.subtotal);
  }

  double get envio => _productos.isEmpty ? 0 : 50;
  double get total => subtotal + envio;

  // CONECTAR EL CARRITO DE UNA CUENTA
  Future<void> conectarUsuario(String uid) async {
    if (uid.isEmpty) {
      throw ArgumentError('No se pudo identificar al usuario.');
    }

    desconectarUsuario();
    final versionActual = _versionSesion;
    final primeraCarga = Completer<void>();
    _uid = uid;

    _suscripcion = _dao
        .observarCarrito(uid)
        .listen(
          (datos) {
            if (versionActual != _versionSesion) return;
            try {
              final productosGuardados = datos
                  .map(CarritoItem.fromMap)
                  .toList();
              // Conserva los cambios locales que todavía se están enviando.
              if (_guardadosPendientes == 0) {
                _productos
                  ..clear()
                  ..addAll(productosGuardados);
              }
              _cargado = true;
              _mensajeError = null;
              if (!primeraCarga.isCompleted) {
                primeraCarga.complete();
              }
              notifyListeners();
            } catch (error, stackTrace) {
              _mensajeError = 'No se pudo leer el carrito guardado.';
              if (!primeraCarga.isCompleted) {
                primeraCarga.completeError(error, stackTrace);
              }
              notifyListeners();
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            if (versionActual != _versionSesion) return;
            _mensajeError = 'No se pudo consultar el carrito.';
            if (!primeraCarga.isCompleted) {
              primeraCarga.completeError(error, stackTrace);
            }
            notifyListeners();
          },
        );

    try {
      await primeraCarga.future.timeout(const Duration(seconds: 15));
      if (versionActual != _versionSesion) {
        throw StateError('La cuenta cambió durante la carga del carrito.');
      }
    } catch (_) {
      if (versionActual == _versionSesion) {
        desconectarUsuario();
      }
      rethrow;
    }
  }

  // DESCONECTAR SIN BORRAR EL CARRITO GUARDADO
  void desconectarUsuario() {
    _versionSesion++;
    final suscripcionAnterior = _suscripcion;
    _suscripcion = null;
    if (suscripcionAnterior != null) {
      unawaited(suscripcionAnterior.cancel());
    }
    _uid = null;
    _cargado = false;
    _guardadosPendientes = 0;
    _mensajeError = null;
    _productos.clear();
    notifyListeners();
  }

  // GUARDAR LOS CAMBIOS EN FIREBASE
  Future<void> _guardarCambios() async {
    final uid = _uid;
    if (uid == null || !_cargado) return;
    final versionActual = _versionSesion;
    final datos = _productos.map((producto) => producto.toMap()).toList();
    _guardadosPendientes++;
    _mensajeError = null;
    notifyListeners();

    try {
      await _dao.guardarCarrito(uid, datos);
      if (versionActual != _versionSesion) return;
      _mensajeError = null;
    } catch (error) {
      if (versionActual != _versionSesion) return;
      _mensajeError =
          'No se pudieron guardar los cambios del carrito. '
          'Comprueba tu conexión y los permisos de acceso.';
      debugPrint('ERROR AL GUARDAR CARRITO: $error');
    } finally {
      if (versionActual == _versionSesion) {
        _guardadosPendientes--;
        notifyListeners();
      }
    }
  }

  bool _puedeModificar() {
    if (_uid != null && _cargado) return true;
    _mensajeError = 'El carrito de tu cuenta todavía no está disponible.';
    notifyListeners();
    return false;
  }

  // Devuelve si se aceptó el cambio local; el guardado sigue siendo asíncrono.
  bool agregarProducto(Map<String, dynamic> datos, int cantidad) {
    if (!_puedeModificar() || cantidad <= 0) return false;

    final valorId = datos['id'];
    final int? id = valorId is num ? valorId.toInt() : null;
    final String nombre = datos['nombre']?.toString() ?? 'Producto';
    final String categoria = datos['categoria']?.toString() ?? '';
    final String descripcion = datos['descripcion']?.toString() ?? '';
    final String imagen = datos['imagen']?.toString() ?? '';
    final double precio =
        double.tryParse(datos['precio']?.toString() ?? '0') ?? 0;
    if (!precio.isFinite || precio < 0) return false;

    final indice = _indiceProducto(datos);
    final cantidadActual = indice == -1 ? 0 : _productos[indice].cantidad;
    if (cantidadActual + cantidad > maximoPorProducto) return false;

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
    unawaited(_guardarCambios());
    return true;
  }

  void aumentar(int index) {
    if (!_puedeModificar()) return;
    if (index < 0 || index >= _productos.length) return;
    if (_productos[index].cantidad >= maximoPorProducto) return;
    _productos[index].cantidad++;
    unawaited(_guardarCambios());
  }

  void disminuir(int index) {
    if (!_puedeModificar()) return;
    if (index < 0 || index >= _productos.length) return;
    if (_productos[index].cantidad > 1) {
      _productos[index].cantidad--;
    } else {
      _productos.removeAt(index);
    }
    unawaited(_guardarCambios());
  }

  void eliminar(int index) {
    if (!_puedeModificar()) return;
    if (index < 0 || index >= _productos.length) return;
    _productos.removeAt(index);
    unawaited(_guardarCambios());
  }

  void vaciar() {
    if (!_puedeModificar()) return;
    _productos.clear();
    unawaited(_guardarCambios());
  }
}
