import 'dart:io';
import 'package:flutter/material.dart';
import '../../estilos/styles.dart';
import '../../../logica/pedidos_service.dart';
import '../../../modelos/pedido.dart';
import '../../../logica/sesion.dart';
import '../../../logica/carrito_provider.dart';

class Carrito extends StatefulWidget {
  const Carrito({super.key});
  @override
  State<Carrito> createState() => _CarritoState();
}

class _CarritoState extends State<Carrito> {
  final PedidosService pedidosService = PedidosService();
  final CarritoProvider carrito = CarritoProvider.instance;
  bool realizandoPedido = false;
  bool consultandoIntento = true;
  bool hayIntentoPendiente = false;
  double get subtotal => carrito.subtotal;
  double get envio => carrito.envio;
  double get total => carrito.total;
  @override
  void initState() {
    super.initState();
    _consultarIntento();
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _consultarIntento() async {
    final usuario = Sesion.usuarioActual;
    try {
      final pendiente = await pedidosService.tieneIntentoPendiente().timeout(
        const Duration(seconds: 5),
      );
      if (!mounted || !identical(Sesion.usuarioActual, usuario)) {
        return;
      }
      setState(() {
        hayIntentoPendiente = pendiente;
      });
    } catch (_) {
      if (!mounted || !identical(Sesion.usuarioActual, usuario)) {
        return;
      }
      _mostrarMensaje(
        'No se pudo consultar el intento anterior. '
        'Lo comprobaremos antes de enviar un pedido.',
      );
    } finally {
      if (mounted) {
        setState(() {
          consultandoIntento = false;
        });
      }
    }
  }

  void aumentarCantidad(int index) {
    if (realizandoPedido) return;
    if (index < 0 || index >= carrito.productos.length) return;
    if (carrito.productos[index].cantidad >=
        CarritoProvider.maximoPorProducto) {
      _mostrarMensaje(CarritoProvider.mensajeLimite);
      return;
    }
    carrito.aumentar(index);
  }

  void disminuirCantidad(int index) {
    if (realizandoPedido) return;
    carrito.disminuir(index);
  }

  void eliminarProducto(int index) {
    if (realizandoPedido) return;
    carrito.eliminar(index);
  }

  // ============================================================
  // REALIZAR O VERIFICAR EL PEDIDO
  // ============================================================
  Future<void> realizarPedido() async {
    if (realizandoPedido || consultandoIntento) return;
    final usuario = Sesion.usuarioActual;
    if (usuario == null || usuario.id == null) {
      _mostrarMensaje('Inicia sesión para realizar tu pedido.');
      return;
    }
    final estabaPendiente = hayIntentoPendiente;
    setState(() {
      realizandoPedido = true;
    });
    try {
      // Se comprueba otra vez para contemplar operaciones que
      // terminaron después de mostrar un mensaje de espera.
      final pendiente = await pedidosService.tieneIntentoPendiente().timeout(
        const Duration(seconds: 5),
      );
      if (!mounted || !identical(Sesion.usuarioActual, usuario)) {
        return;
      }
      setState(() {
        hayIntentoPendiente = pendiente;
      });
      if (pendiente) {
        await pedidosService.retomarPedidoPendiente();
      } else {
        if (estabaPendiente) {
          _mostrarMensaje(
            'La operación anterior ya terminó. '
            'Consulta Mis pedidos para revisar el resultado.',
          );
          return;
        }
        if (carrito.productos.isEmpty) {
          _mostrarMensaje('No hay productos en el carrito.');
          return;
        }
        // Esperamos a que las cantidades del carrito se confirmen
        // antes de utilizarlas para crear un pedido nuevo.
        if (carrito.sincronizando) {
          _mostrarMensaje(
            'El carrito todavía tiene cambios por sincronizar. '
            'Comprueba tu conexión e inténtalo de nuevo.',
          );
          return;
        }
        if (carrito.mensajeError != null) {
          _mostrarMensaje(carrito.mensajeError!);
          return;
        }
        if (carrito.superaLimite) {
          _mostrarMensaje(
            'El máximo es de 15 unidades por producto. '
            'Reduce las cantidades que superen ese límite antes de continuar.',
          );
          return;
        }
        final productosPedido = carrito.productos
            .map((producto) => '${producto.nombre} x${producto.cantidad}')
            .join(', ');
        final pedido = Pedido(
          usuarioId: usuario.id!,
          productos: productosPedido,
          total: total,
          estado: 'Pendiente',
          fecha: DateTime.now().toString(),
          clienteNombre: usuario.nombre,
        );
        await pedidosService.insertarPedido(pedido);
      }
      if (!mounted || !identical(Sesion.usuarioActual, usuario)) {
        return;
      }
      // El servicio ya retiró en Firebase las cantidades enviadas.
      // El listener del carrito recibe ese cambio.
      setState(() {
        hayIntentoPendiente = false;
      });
      _mostrarMensaje('Pedido realizado correctamente.');
    } on PedidoException catch (error) {
      if (!mounted || !identical(Sesion.usuarioActual, usuario)) {
        return;
      }
      setState(() {
        hayIntentoPendiente = true;
      });
      _mostrarMensaje(error.mensaje);
    } catch (error) {
      debugPrint('ERROR AL REALIZAR PEDIDO: $error');
      if (!mounted || !identical(Sesion.usuarioActual, usuario)) {
        return;
      }
      setState(() {
        hayIntentoPendiente = true;
      });
      _mostrarMensaje(
        'No pudimos completar la verificación. '
        'Comprueba tu conexión y pulsa VERIFICAR PEDIDO.',
      );
    } finally {
      if (mounted) {
        setState(() {
          realizandoPedido = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        backgroundColor: AppColors.fondo,
        foregroundColor: AppColors.crema,
        elevation: 0,
        title: const Text(
          'Tu carrito',
          style: TextStyle(color: AppColors.crema, fontWeight: FontWeight.bold),
        ),
      ),
      body: AnimatedBuilder(
        animation: carrito,
        builder: (context, _) {
          if (carrito.productos.isEmpty) {
            return _carritoVacio();
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tu pedido', style: AppStyles.tituloGrande),
                const SizedBox(height: 6),
                const Text(
                  'Revisa tus productos antes de continuar.',
                  style: AppStyles.textoNormal,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Máximo 15 unidades del mismo producto por pedido.',
                  style: AppStyles.textoNormal,
                ),
                const SizedBox(height: 25),
                ...carrito.productos.asMap().entries.map((entry) {
                  final index = entry.key;
                  final producto = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: IgnorePointer(
                      ignoring: realizandoPedido,
                      child: _productoCarrito(
                        producto: producto,
                        disminuir: () => disminuirCantidad(index),
                        aumentar: () => aumentarCantidad(index),
                        eliminar: () => eliminarProducto(index),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 15),
                const Text('Resumen', style: AppStyles.titulo),
                const SizedBox(height: 15),
                _resumenPedido(),
                const SizedBox(height: 28),
                if (hayIntentoPendiente) ...[
                  const Text(
                    'Hay un intento anterior pendiente de verificar. '
                    'Se revisará ese mismo pedido antes de crear otro.',
                    style: AppStyles.textoNormal,
                  ),
                  const SizedBox(height: 14),
                ],
                _botonPedido(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // BOTÓN HACER O VERIFICAR PEDIDO
  // ============================================================
  Widget _botonPedido() {
    final ocupado = realizandoPedido || consultandoIntento;
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: ocupado ? null : realizarPedido,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.naranja,
          foregroundColor: Colors.black,
          disabledBackgroundColor: AppColors.textoSecundario,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: ocupado
            ? const SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 3,
                ),
              )
            : Text(
                hayIntentoPendiente ? 'VERIFICAR PEDIDO' : 'HACER PEDIDO',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }

  // ============================================================
  // CARRITO VACÍO
  // ============================================================
  Widget _carritoVacio() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              color: AppColors.naranja,
              size: 70,
            ),
            const SizedBox(height: 20),
            const Text(
              'Tu carrito está vacío',
              style: TextStyle(
                color: AppColors.crema,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Agrega productos para realizar un pedido.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textoSecundario, fontSize: 14),
            ),
            if (hayIntentoPendiente) ...[
              const SizedBox(height: 20),
              const Text(
                'Hay un intento de pedido pendiente de verificar.',
                textAlign: TextAlign.center,
                style: AppStyles.textoNormal,
              ),
              const SizedBox(height: 15),
              _botonPedido(),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // RESUMEN
  // ============================================================
  Widget _resumenPedido() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.tarjeta,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(color: AppColors.crema)),
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: const TextStyle(color: AppColors.crema),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Envío', style: TextStyle(color: AppColors.crema)),
              Text(
                '\$${envio.toStringAsFixed(2)}',
                style: const TextStyle(color: AppColors.crema),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.borde),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: AppColors.crema,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.naranja,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCTO
  // ============================================================
  Widget _productoCarrito({
    required CarritoItem producto,
    required VoidCallback disminuir,
    required VoidCallback aumentar,
    required VoidCallback eliminar,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tarjeta,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borde),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _imagenProducto(producto),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.crema,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '\$${producto.precio.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.naranja,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.fondo,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: disminuir,
                            icon: const Icon(Icons.remove, size: 18),
                            color: AppColors.crema,
                            constraints: const BoxConstraints(
                              minWidth: 35,
                              minHeight: 35,
                            ),
                          ),
                          Text(
                            producto.cantidad.toString(),
                            style: const TextStyle(
                              color: AppColors.crema,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: aumentar,
                            icon: const Icon(Icons.add, size: 18),
                            color: AppColors.crema,
                            constraints: const BoxConstraints(
                              minWidth: 35,
                              minHeight: 35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: eliminar,
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // IMÁGENES
  // ============================================================
  Widget _imagenProducto(CarritoItem producto) {
    final imagen = producto.imagen.trim();
    if (imagen.isEmpty) {
      return _imagenPredeterminada();
    }
    if (imagen.startsWith('http://') || imagen.startsWith('https://')) {
      return Image.network(
        imagen,
        width: 75,
        height: 75,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) {
          return _imagenPredeterminada();
        },
      );
    }
    final archivo = File(imagen);
    if (archivo.existsSync()) {
      return Image.file(
        archivo,
        width: 75,
        height: 75,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) {
          return _imagenPredeterminada();
        },
      );
    }
    return Image.asset(
      imagen,
      width: 75,
      height: 75,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) {
        return _imagenPredeterminada();
      },
    );
  }

  Widget _imagenPredeterminada() {
    return Container(
      width: 75,
      height: 75,
      color: AppColors.fondoSecundario,
      child: const Icon(
        Icons.cake_outlined,
        color: AppColors.naranja,
        size: 35,
      ),
    );
  }
}
