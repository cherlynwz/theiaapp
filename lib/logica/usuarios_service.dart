import '../datos/dao/usuario_dao.dart';
import '../modelos/usuario.dart';

class UsuariosService {
  final UsuarioDAO _dao = UsuarioDAO();

  Future<List<Usuario>> listarClientes() => _dao.listarClientes();

  Future<int> contarClientes() => _dao.contarClientes();
}
