import 'package:cloud_firestore/cloud_firestore.dart';

import '../../modelos/pedido.dart';

class PedidosDAO {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _pedidos {
    return _db.collection('pedidos');
  }

  // =====================================================
  // INSERTAR O RECONOCER EL MISMO INTENTO DE PEDIDO
  // =====================================================

  Future<int> insertarPedido(Pedido pedido, {int? intentoId}) async {
    final int id = intentoId ?? DateTime.now().millisecondsSinceEpoch;

    final referencia = _pedidos.doc(id.toString());

    return _db.runTransaction<int>((transaccion) async {
      final documento = await transaccion.get(referencia);

      if (documento.exists) {
        final datos = documento.data()!;

        final mismoPedido =
            datos['usuarioId'] == pedido.usuarioId &&
            datos['productos'] == pedido.productos &&
            datos['total'] == pedido.total &&
            datos['fecha'] == pedido.fecha &&
            datos['clienteNombre'] == pedido.clienteNombre;

        if (!mismoPedido) {
          throw StateError('El identificador corresponde a otro pedido.');
        }

        return id;
      }

      transaccion.set(referencia, {
        'id': id,
        'usuarioId': pedido.usuarioId,
        'productos': pedido.productos,
        'total': pedido.total,
        'estado': pedido.estado,
        'fecha': pedido.fecha,
        'clienteNombre': pedido.clienteNombre,
      });

      return id;
    });
  }

  // =====================================================
  // FINALIZAR EL CARRITO DEL PEDIDO CONFIRMADO
  // =====================================================

  Future<void> finalizarCarrito(
    String uid,
    int pedidoId,
    List<Map<String, dynamic>> productosEnviados,
  ) async {
    final referenciaPedido = _pedidos.doc(pedidoId.toString());
    final referenciaCarrito = _db.collection('carritos').doc(uid);

    await _db.runTransaction<void>((transaccion) async {
      final documentoPedido = await transaccion.get(referenciaPedido);

      if (!documentoPedido.exists) {
        throw StateError('El pedido todavía no está confirmado.');
      }

      if (documentoPedido.data()?['carritoProcesado'] == true) {
        return;
      }

      final documentoCarrito = await transaccion.get(referenciaCarrito);

      final valor = documentoCarrito.data()?['productos'];

      if (valor != null && valor is! List) {
        throw const FormatException(
          'Los productos del carrito no son válidos.',
        );
      }

      final actuales = (valor as List? ?? [])
          .map((producto) => Map<String, dynamic>.from(producto as Map))
          .toList();

      for (final enviado in productosEnviados) {
        final indice = actuales.indexWhere((actual) {
          if (enviado['id'] != null && actual['id'] != null) {
            return actual['id'] == enviado['id'];
          }

          return actual['nombre'] == enviado['nombre'] &&
              actual['categoria'] == enviado['categoria'];
        });

        if (indice == -1) continue;

        final cantidadActual = (actuales[indice]['cantidad'] as num).toInt();

        final cantidadEnviada = (enviado['cantidad'] as num).toInt();

        final restante = cantidadActual - cantidadEnviada;

        if (restante > 0) {
          actuales[indice]['cantidad'] = restante;
        } else {
          actuales.removeAt(indice);
        }
      }

      transaccion.set(referenciaCarrito, {
        'productos': actuales,
        'actualizadoEn': FieldValue.serverTimestamp(),
      });

      transaccion.update(referenciaPedido, {'carritoProcesado': true});
    });
  }

  // =====================================================
  // CONSULTAR UN PEDIDO DIRECTAMENTE EN EL SERVIDOR
  // =====================================================

  Future<Pedido?> obtenerPedidoConfirmado(int id) async {
    final documento = await _pedidos
        .doc(id.toString())
        .get(const GetOptions(source: Source.server));

    if (!documento.exists) {
      return null;
    }

    return Pedido.fromMap(documento.data()!);
  }

  // =====================================================
  // OBTENER TODOS LOS PEDIDOS (ADMIN)
  // =====================================================

  Future<List<Pedido>> obtenerPedidos() async {
    final snapshot = await _pedidos.orderBy('id', descending: true).get();

    return snapshot.docs.map((documento) {
      return Pedido.fromMap(documento.data());
    }).toList();
  }

  // =====================================================
  // OBTENER PEDIDOS DE UN USUARIO (CLIENTE)
  // =====================================================

  Future<List<Pedido>> obtenerPedidosUsuario(int usuarioId) async {
    final snapshot = await _pedidos
        .where('usuarioId', isEqualTo: usuarioId)
        .get();

    final pedidos = snapshot.docs.map((documento) {
      return Pedido.fromMap(documento.data());
    }).toList();

    pedidos.sort((a, b) {
      final idA = a.id ?? 0;
      final idB = b.id ?? 0;

      return idB.compareTo(idA);
    });

    return pedidos;
  }

  // =====================================================
  // CONTAR PEDIDOS
  // =====================================================

  Future<int> contarPedidos() async {
    final snapshot = await _pedidos.get();

    return snapshot.docs.length;
  }

  // =====================================================
  // OBTENER VENTAS TOTALES
  // =====================================================

  Future<double> totalVentas() async {
    final snapshot = await _pedidos.get();

    double total = 0.0;

    for (final documento in snapshot.docs) {
      final datos = documento.data();
      final valor = datos['total'];

      if (valor is num) {
        total += valor.toDouble();
      }
    }

    return total;
  }

  // =====================================================
  // ACTUALIZAR ESTADO DEL PEDIDO
  // =====================================================

  Future<int> actualizarEstado(int id, String estado) async {
    final referencia = _pedidos.doc(id.toString());
    final documento = await referencia.get();

    if (!documento.exists) {
      return 0;
    }

    await referencia.update({'estado': estado});

    return 1;
  }
}
