import '../datos/dao/pedidos_dao.dart';
import '../modelos/pedido.dart';

class PedidosService {
  final PedidosDAO _dao = PedidosDAO();

  Future<int> insertarPedido(Pedido pedido) => _dao.insertarPedido(pedido);

  Future<List<Pedido>> obtenerPedidos() => _dao.obtenerPedidos();

  Future<List<Pedido>> obtenerPedidosUsuario(int usuarioId) => _dao.obtenerPedidosUsuario(usuarioId);

  Future<int> contarPedidos() => _dao.contarPedidos();

  Future<double> totalVentas() => _dao.totalVentas();

  Future<int> actualizarEstado(int id, String estado) => _dao.actualizarEstado(id, estado);
}
