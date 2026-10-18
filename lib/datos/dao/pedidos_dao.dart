import 'package:cloud_firestore/cloud_firestore.dart';

import '../../modelos/pedido.dart';

class PedidosDAO {

  final CollectionReference<Map<String, dynamic>> _pedidos = FirebaseFirestore
      .instance
      .collection('pedidos');

  // =====================================================
  // INSERTAR PEDIDO
  // =====================================================

  Future<int> insertarPedido(Pedido pedido) async {
    // Generamos un ID numérico para conservar
    // la estructura actual del modelo Pedido.
    final int id = DateTime.now().millisecondsSinceEpoch;

    await _pedidos.doc(id.toString()).set({
      'id': id,
      'usuarioId': pedido.usuarioId,
      'productos': pedido.productos,
      'total': pedido.total,
      'estado': pedido.estado,
      'fecha': pedido.fecha,
      'clienteNombre': pedido.clienteNombre,
    });

    return id;
  }

  // =====================================================
  // OBTENER TODOS LOS PEDIDOS (ADMIN)
  // =====================================================

  Future<List<Pedido>> obtenerPedidos() async {
    final snapshot = await _pedidos.orderBy('id', descending: true).get();

    return snapshot.docs.map((documento) {
      final datos = documento.data();

      return Pedido.fromMap(datos);
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
      final datos = documento.data();

      return Pedido.fromMap(datos);
    }).toList();

    // Ordenamos por ID de mayor a menor.
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
