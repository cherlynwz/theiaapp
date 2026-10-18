import 'package:flutter/material.dart';
import '../../estilos/styles.dart';
import 'package:theiaapp/logica/pedidos_service.dart';
import '../../../modelos/pedido.dart';

class PedidosAdmin extends StatefulWidget {
  const PedidosAdmin({super.key});

  @override
  State<PedidosAdmin> createState() => _PedidosAdminState();
}

class _PedidosAdminState extends State<PedidosAdmin> {
  final PedidosService pedidosService = PedidosService();

  List<Pedido> pedidos = [];

  @override
  void initState() {
    super.initState();

    cargarPedidos();
  }

  Future<void> cargarPedidos() async {
    final datos = await pedidosService.obtenerPedidos();

    debugPrint("PEDIDOS ADMIN: ${datos.length}");

    for (var pedido in datos) {
      debugPrint(
        "ID:${pedido.id} CLIENTE:${pedido.clienteNombre} PRODUCTOS:${pedido.productos} TOTAL:${pedido.total}",
      );
    }

    if (!mounted) return;

    setState(() {
      pedidos = datos;
    });
  }

  void seleccionarEstado(Pedido pedido) {
    final estados = ['Pendiente', 'Preparando', 'Entregado', 'Cancelado'];

    showModalBottomSheet(
      context: context,

      backgroundColor: AppColors.fondo,

      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              const Text(
                'Cambiar estado del pedido',

                style: TextStyle(
                  color: AppColors.crema,

                  fontSize: 20,

                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              ...estados.map((estado) {
                return ListTile(
                  title: Text(
                    estado,

                    style: const TextStyle(color: AppColors.crema),
                  ),

                  trailing: pedido.estado == estado
                      ? const Icon(Icons.check, color: AppColors.naranja)
                      : null,

                  onTap: () async {
                    await pedidosService.actualizarEstado(pedido.id!, estado);

                    if (!context.mounted) return;
                    Navigator.pop(context);

                    cargarPedidos();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,

      appBar: AppBar(
        backgroundColor: AppColors.fondo,

        elevation: 0,

        title: const Text(
          'Pedidos',

          style: TextStyle(color: AppColors.crema, fontWeight: FontWeight.bold),
        ),
      ),

      body: pedidos.isEmpty
          ? const Center(
              child: Text(
                'No hay pedidos registrados',

                style: TextStyle(color: AppColors.textoSecundario),
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

  Widget _pedidoCard(Pedido pedido) {
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

                  fontSize: 18,

                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            pedido.clienteNombre.isEmpty
                ? 'Cliente no registrado'
                : 'Cliente: ${pedido.clienteNombre}',

            style: const TextStyle(
              color: AppColors.crema,

              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            pedido.productos,

            style: const TextStyle(color: AppColors.textoSecundario),
          ),

          const SizedBox(height: 8),

          Text(
            'Fecha: ${pedido.fecha}',

            style: const TextStyle(color: AppColors.textoSecundario),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                pedido.estado,

                style: const TextStyle(
                  color: AppColors.naranja,

                  fontWeight: FontWeight.bold,
                ),
              ),

              ElevatedButton(
                onPressed: () {
                  seleccionarEstado(pedido);
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.naranja,

                  foregroundColor: Colors.black,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                child: const Text('Cambiar estado'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
