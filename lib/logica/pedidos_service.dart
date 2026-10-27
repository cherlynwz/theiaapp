import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../datos/dao/intentos_pedido_dao.dart';
import '../datos/dao/pedidos_dao.dart';
import '../modelos/pedido.dart';
import 'carrito_provider.dart';

class PedidoException implements Exception {
  final String mensaje;

  PedidoException(this.mensaje);

  @override
  String toString() => mensaje;
}

class PedidosService {
  final PedidosDAO _dao = PedidosDAO();
  final IntentosPedidoDAO _intentos = IntentosPedidoDAO();

  // Evita iniciar dos operaciones simultáneas para la misma cuenta.
  static final Map<String, Future<int>> _operaciones = {};

  String _obtenerUid() {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null || uid.isEmpty) {
      throw PedidoException('Inicia sesión para realizar tu pedido.');
    }

    return uid;
  }

  void _comprobarCuenta(String uid) {
    if (FirebaseAuth.instance.currentUser?.uid != uid) {
      throw PedidoException(
        'La cuenta cambió. Vuelve a entrar para verificar tu pedido.',
      );
    }
  }

  Pedido _leerPedido(Map<String, dynamic> datos) {
    return Pedido(
      usuarioId: (datos['usuarioId'] as num).toInt(),
      productos: datos['productos'] as String,
      total: (datos['total'] as num).toDouble(),
      estado: datos['estado'] as String,
      fecha: datos['fecha'] as String,
      clienteNombre: datos['clienteNombre'] as String,
    );
  }

  Future<bool> tieneIntentoPendiente() async {
    final uid = _obtenerUid();
    final intento = await _intentos.obtener(uid);

    _comprobarCuenta(uid);

    return intento != null;
  }

  Future<int> insertarPedido(Pedido pedido) {
    final uid = _obtenerUid();

    return _ejecutar(uid, () => _crearORecuperarIntento(uid, pedido));
  }

  Future<int> retomarPedidoPendiente() {
    final uid = _obtenerUid();

    return _ejecutar(uid, () async {
      final intento = await _intentos.obtener(uid);

      if (intento == null) {
        throw PedidoException('No hay un pedido pendiente de verificar.');
      }

      return _procesarIntento(uid, intento);
    });
  }

  Future<int> _ejecutar(String uid, Future<int> Function() accion) async {
    var operacion = _operaciones[uid];

    if (operacion == null) {
      final nuevaOperacion = accion();
      _operaciones[uid] = nuevaOperacion;
      operacion = nuevaOperacion;

      void terminar() {
        if (identical(_operaciones[uid], nuevaOperacion)) {
          _operaciones.remove(uid);
        }
      }

      // Mantiene registrada la operación hasta que termine realmente,
      // incluso si dejamos de esperar en la pantalla.
      unawaited(
        nuevaOperacion.then<void>(
          (_) => terminar(),
          onError: (Object error, StackTrace stackTrace) {
            terminar();
          },
        ),
      );
    }

    try {
      return await operacion.timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw PedidoException(
        'No pudimos confirmar tu pedido todavía. '
        'Revisa tu conexión y vuelve a verificar. '
        'Se conservará el mismo intento para evitar duplicados.',
      );
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        throw PedidoException(
          'No se pudo completar la operación por un problema de permisos. '
          'Tu intento de pedido se conserva.',
        );
      }

      throw PedidoException(
        'No pudimos confirmar tu pedido. '
        'Comprueba tu conexión y vuelve a verificar. '
        'Tu carrito y el intento de pedido se conservan.',
      );
    }
  }

  Future<int> _crearORecuperarIntento(String uid, Pedido pedido) async {
    _comprobarCuenta(uid);

    final productos = CarritoProvider.instance.productos
        .map((producto) => producto.toMap())
        .toList();

    final intento = await _intentos.obtenerOCrear(uid, {
      'pedido': {
        'usuarioId': pedido.usuarioId,
        'productos': pedido.productos,
        'total': pedido.total,
        'estado': pedido.estado,
        'fecha': pedido.fecha,
        'clienteNombre': pedido.clienteNombre,
      },
      'productosCarrito': productos,
    });

    return _procesarIntento(uid, intento);
  }

  Future<int> _procesarIntento(String uid, Map<String, dynamic> intento) async {
    _comprobarCuenta(uid);

    final id = intento['id'] as int;
    final datos = Map<String, dynamic>.from(intento['datos'] as Map);

    final pedido = _leerPedido(
      Map<String, dynamic>.from(datos['pedido'] as Map),
    );

    final productosEnviados = (datos['productosCarrito'] as List)
        .map((producto) => Map<String, dynamic>.from(producto as Map))
        .toList();

    await _dao.insertarPedido(pedido, intentoId: id);

    _comprobarCuenta(uid);

    // Retira solo las cantidades de este pedido.
    // La operación se puede repetir sin descontarlas dos veces.
    await _dao.finalizarCarrito(uid, id, productosEnviados);

    await _intentos.eliminar(uid, id);

    return id;
  }

  Future<List<Pedido>> obtenerPedidos() => _dao.obtenerPedidos();

  Future<List<Pedido>> obtenerPedidosUsuario(int usuarioId) {
    return _dao.obtenerPedidosUsuario(usuarioId);
  }

  Future<int> contarPedidos() => _dao.contarPedidos();

  Future<double> totalVentas() => _dao.totalVentas();

  Future<int> actualizarEstado(int id, String estado) {
    return _dao.actualizarEstado(id, estado);
  }
}
