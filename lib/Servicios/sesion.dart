import '../Modelos/usuario.dart';
import '../Cliente/inicioCliente.dart';
class Sesion {
  static Usuario? usuarioActual;

  static void iniciarSesion(Usuario usuario) {
    usuarioActual = usuario;
  }

  static void cerrarSesion() {
    usuarioActual = null;
  }
}
