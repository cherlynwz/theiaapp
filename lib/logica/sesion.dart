import '../modelos/usuario.dart';
import 'carrito_provider.dart';

class Sesion {
  static Usuario? usuarioActual;

  static void iniciarSesion(Usuario usuario) {
    usuarioActual = usuario;
  }

  static void cerrarSesion() {
    usuarioActual = null;

    // Limpia la memoria sin borrar los productos de Firebase.
    CarritoProvider.instance.desconectarUsuario();
  }
}
