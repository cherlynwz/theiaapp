import 'dart:io';

import 'package:flutter/material.dart';

import '../../estilos/styles.dart';
import 'package:theiaapp/logica/pedidos_service.dart';
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

  // ============================================================
  // SUBTOTAL
  // ============================================================

  double get subtotal {
    return carrito.subtotal;
  }

  // ============================================================
  // ENVÍO
  // ============================================================

  double get envio {
    return carrito.envio;
  }

  // ============================================================
  // TOTAL
  // ============================================================

  double get total {
    return carrito.total;
  }

  // ============================================================
  // AUMENTAR CANTIDAD
  // ============================================================

  void aumentarCantidad(int index) {
    carrito.aumentar(index);
  }

  // ============================================================
  // DISMINUIR CANTIDAD
  // ============================================================

  void disminuirCantidad(int index) {
    carrito.disminuir(index);
  }

  // ============================================================
  // ELIMINAR PRODUCTO
  // ============================================================

  void eliminarProducto(int index) {
    carrito.eliminar(index);
  }

  // ============================================================
  // REALIZAR PEDIDO
  // ============================================================

  Future<void> realizarPedido() async {
    if (carrito.productos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay productos en el carrito')),
      );

      return;
    }

    final usuario = Sesion.usuarioActual;

    debugPrint('==============================');
    debugPrint('USUARIO EN CARRITO: $usuario');
    debugPrint('ID USUARIO: ${usuario?.id}');
    debugPrint('NOMBRE: ${usuario?.nombre}');
    debugPrint('ROL: ${usuario?.rol}');
    debugPrint('==============================');

    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La sesión del usuario está vacía')),
      );
      return;
    }

    if (usuario.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'El usuario existe, pero su ID es null. Usuario: ${usuario.nombre}',
          ),
        ),
      );
      return;
    }

    setState(() {
      realizandoPedido = true;
    });

    try {
      // ========================================================
      // CREAR LISTA DE PRODUCTOS
      // ========================================================

      final List<String> productosPedido = [];

      for (final producto in carrito.productos) {
        productosPedido.add('${producto.nombre} x${producto.cantidad}');
      }

      // ========================================================
      // CREAR PEDIDO
      // ========================================================

      final pedido = Pedido(
        usuarioId: usuario.id!,
        productos: productosPedido.join(', '),
        total: total,
        estado: 'Pendiente',
        fecha: DateTime.now().toString(),
        clienteNombre: usuario.nombre,
      );

      // ========================================================
      // GUARDAR EL PEDIDO
      // ========================================================

      await pedidosService.insertarPedido(pedido);

      // ========================================================
      // VACIAR CARRITO
      // ========================================================

      carrito.vaciar();

      if (!mounted) return;

      setState(() {
        realizandoPedido = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido realizado correctamente')),
      );
    } catch (e) {
      debugPrint('ERROR AL REALIZAR PEDIDO: $e');

      if (!mounted) return;

      setState(() {
        realizandoPedido = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al realizar pedido: $e')));
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

      // ========================================================
      // ESCUCHAR CAMBIOS DEL CARRITO
      // ========================================================
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

                const SizedBox(height: 25),

                // ==================================================
                // PRODUCTOS REALES DEL CARRITO
                // ==================================================
                ...carrito.productos.asMap().entries.map((entry) {
                  final index = entry.key;
                  final producto = entry.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),

                    child: _productoCarrito(
                      producto: producto,

                      disminuir: () {
                        disminuirCantidad(index);
                      },

                      aumentar: () {
                        aumentarCantidad(index);
                      },

                      eliminar: () {
                        eliminarProducto(index);
                      },
                    ),
                  );
                }),

                const SizedBox(height: 15),

                const Text('Resumen', style: AppStyles.titulo),

                const SizedBox(height: 15),

                _resumenPedido(),

                const SizedBox(height: 28),

                // ==================================================
                // BOTÓN HACER PEDIDO
                // ==================================================
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: realizandoPedido ? null : realizarPedido,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.naranja,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: AppColors.textoSecundario,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),

                    child: realizandoPedido
                        ? const SizedBox(
                            height: 25,
                            width: 25,

                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            'HACER PEDIDO',

                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // CARRITO VACÍO
  // ============================================================

  Widget _carritoVacio() {
    return Center(
      child: Padding(
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
          ],
        ),
      ),
    );
  }

  // ============================================================
  // RESUMEN DEL PEDIDO
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
          // ======================================================
          // SUBTOTAL
          // ======================================================
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

          // ======================================================
          // ENVÍO
          // ======================================================
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

          // ======================================================
          // TOTAL
          // ======================================================
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
  // PRODUCTO DEL CARRITO
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
          // ======================================================
          // IMAGEN
          // ======================================================
          ClipRRect(
            borderRadius: BorderRadius.circular(12),

            child: _imagenProducto(producto),
          ),

          const SizedBox(width: 14),

          // ======================================================
          // INFORMACIÓN
          // ======================================================
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

                // ==================================================
                // SELECTOR DE CANTIDAD
                // ==================================================
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

          // ======================================================
          // ELIMINAR
          // ======================================================
          IconButton(
            onPressed: eliminar,

            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // IMAGEN DEL PRODUCTO
  // ============================================================

  Widget _imagenProducto(CarritoItem producto) {
    final String imagen = producto.imagen.trim();

    // ==========================================================
    // SIN IMAGEN
    // ==========================================================

    if (imagen.isEmpty) {
      return _imagenPredeterminada();
    }

    // ==========================================================
    // IMAGEN DE INTERNET
    // ==========================================================

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

    // ==========================================================
    // IMAGEN LOCAL DEL TELÉFONO
    // ==========================================================

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

    // ==========================================================
    // IMAGEN DE ASSETS
    // ==========================================================

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

  // ============================================================
  // IMAGEN POR DEFECTO
  // ============================================================

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
