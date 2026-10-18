import 'package:flutter/material.dart';

import '../../estilos/styles.dart';
import 'package:theiaapp/logica/pedidos_service.dart';
import '../../../modelos/pedido.dart';
import '../../../logica/sesion.dart';

class PedidosCliente extends StatefulWidget {
  const PedidosCliente({super.key});

  @override
  State<PedidosCliente> createState() => _PedidosClienteState();
}

class _PedidosClienteState extends State<PedidosCliente> {
  final PedidosService pedidosService = PedidosService();

  List<Pedido> pedidos = [];

  @override
  void initState() {
    super.initState();

    cargarPedidos();
  }

  // ============================================================
  // CARGAR PEDIDOS
  // ============================================================

  Future<void> cargarPedidos() async {
    final usuario = Sesion.usuarioActual;

    if (usuario == null) {
      return;
    }

    final datos = await pedidosService.obtenerPedidosUsuario(usuario.id!);

    if (!mounted) return;

    setState(() {
      pedidos = datos;
    });
  }

  // ============================================================
  // CONFIRMAR CANCELACIÓN
  // ============================================================

  Future<void> confirmarCancelacion(Pedido pedido) async {
    final confirmar = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.tarjeta,

          title: const Text(
            'Cancelar pedido',
            style: TextStyle(
              color: AppColors.crema,
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Text(
            '¿Deseas cancelar el pedido #${pedido.id}?',

            style: const TextStyle(color: AppColors.textoSecundario),
          ),

          actions: [
            // ==================================================
            // NO CANCELAR
            // ==================================================
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text(
                'No',
                style: TextStyle(color: AppColors.textoSecundario),
              ),
            ),

            // ==================================================
            // CONFIRMAR
            // ==================================================
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },

              child: const Text(
                'Sí, cancelar',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    await cancelarPedido(pedido);
  }

  // ============================================================
  // CANCELAR PEDIDO
  // ============================================================

  Future<void> cancelarPedido(Pedido pedido) async {
    if (pedido.id == null) {
      return;
    }

    try {
      await pedidosService.actualizarEstado(pedido.id!, 'Cancelado');

      await cargarPedidos();

      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pedido cancelado correctamente'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('ERROR AL CANCELAR PEDIDO: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cancelar el pedido')),
      );
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

        elevation: 0,

        foregroundColor: AppColors.crema,

        title: const Text(
          'Mis pedidos',

          style: TextStyle(color: AppColors.crema, fontWeight: FontWeight.bold),
        ),
      ),

      body: pedidos.isEmpty
          ? const Center(
              child: Text(
                'Aún no tienes pedidos',

                style: TextStyle(
                  color: AppColors.textoSecundario,
                  fontSize: 16,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(18),

              itemCount: pedidos.length,

              itemBuilder: (context, index) {
                final pedido = pedidos[index];

                return _pedidoCard(pedido);
              },
            ),
    );
  }

  // ============================================================
  // TARJETA DEL PEDIDO
  // ============================================================

  Widget _pedidoCard(Pedido pedido) {
    final bool puedeCancelar = pedido.estado.toLowerCase() == 'pendiente';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.tarjeta,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: AppColors.borde),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ====================================================
          // PEDIDO Y TOTAL
          // ====================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                'Pedido #${pedido.id}',

                style: const TextStyle(
                  color: AppColors.crema,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                '\$${pedido.total.toStringAsFixed(2)}',

                style: const TextStyle(
                  color: AppColors.naranja,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // ====================================================
          // PRODUCTOS
          // ====================================================
          Text(
            pedido.productos,

            style: const TextStyle(color: AppColors.textoSecundario),
          ),

          const SizedBox(height: 12),

          // ====================================================
          // ESTADO Y FECHA
          // ====================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                'Estado: ${pedido.estado}',

                style: TextStyle(
                  color: pedido.estado.toLowerCase() == 'cancelado'
                      ? Colors.redAccent
                      : AppColors.naranja,

                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                pedido.fecha.length >= 10
                    ? pedido.fecha.substring(0, 10)
                    : pedido.fecha,

                style: const TextStyle(
                  color: AppColors.textoSecundario,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          // ====================================================
          // CANCELAR PEDIDO
          // SOLO SI ESTÁ PENDIENTE
          // ====================================================
          if (puedeCancelar) ...[
            const SizedBox(height: 16),

            const Divider(color: AppColors.borde),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,

              child: OutlinedButton.icon(
                onPressed: () {
                  confirmarCancelacion(pedido);
                },

                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,

                  side: const BorderSide(color: Colors.redAccent),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),

                icon: const Icon(Icons.cancel_outlined, size: 20),

                label: const Text(
                  'Cancelar pedido',

                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
