import '../datos/dao/productos_dao.dart';
import '../modelos/producto.dart';

class ProductosService {
  final ProductoDAO _dao = ProductoDAO();

  Future<int> insertarProducto(Producto producto) => _dao.insertarProducto(producto);

  Future<List<Producto>> obtenerProductos() => _dao.obtenerProductos();

  Future<int> eliminarProducto(int id) => _dao.eliminarProducto(id);

  Future<int> actualizarProducto(Producto producto) => _dao.actualizarProducto(producto);

  Future<int> contarProductos() => _dao.contarProductos();
}
