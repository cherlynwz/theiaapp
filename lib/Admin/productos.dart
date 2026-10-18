import 'package:flutter/material.dart';

import '../Styles/styles.dart';
import '../BaseDatos/productosDAO.dart';
import '../Modelos/producto.dart';

import 'agregarProducto.dart';
import 'editarProducto.dart';

class ProductosAdmin extends StatefulWidget {
  const ProductosAdmin({super.key});

  @override
  State<ProductosAdmin> createState() => _ProductosAdminState();
}

class _ProductosAdminState extends State<ProductosAdmin> {
  final ProductoDAO productoDAO = ProductoDAO();

  final TextEditingController buscarController = TextEditingController();

  List<Producto> productos = [];

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  // =====================================================
  // CARGAR PRODUCTOS
  // =====================================================

  Future<void> cargarProductos() async {
    final datos = await productoDAO.obtenerProductos();

    if (!mounted) return;

    setState(() {
      productos = datos;
    });
  }

  // =====================================================
  // FILTRAR PRODUCTOS
  // =====================================================

  List<Producto> get productosFiltrados {
    final texto = buscarController.text.trim().toLowerCase();

    if (texto.isEmpty) {
      return productos;
    }

    return productos.where((producto) {
      return producto.nombre.toLowerCase().contains(texto);
    }).toList();
  }

  // =====================================================
  // CONFIRMAR ELIMINACIÓN
  // =====================================================

  Future<void> confirmarEliminar(Producto producto) async {
    final confirmar = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.tarjeta,

          title: const Text(
            'Eliminar producto',
            style: TextStyle(
              color: AppColors.crema,
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Text(
            '¿Seguro que deseas eliminar "${producto.nombre}"?',
            style: const TextStyle(color: AppColors.textoSecundario),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textoSecundario),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },

              child: const Text(
                'Eliminar',
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

    if (confirmar != true) return;

    await productoDAO.eliminarProducto(producto.id!);

    await cargarProductos();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto eliminado correctamente')),
    );
  }

  @override
  void dispose() {
    buscarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,

      appBar: AppBar(
        backgroundColor: AppColors.fondo,
        foregroundColor: AppColors.crema,
        elevation: 0,

        title: const Text(
          'Productos',
          style: TextStyle(color: AppColors.crema, fontWeight: FontWeight.bold),
        ),
      ),

      // =====================================================
      // BOTÓN AGREGAR
      // =====================================================
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.naranja,
        foregroundColor: Colors.black,

        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AgregarProducto()),
          );

          if (resultado == true) {
            await cargarProductos();
          } else {
            await cargarProductos();
          }
        },

        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text('Catálogo', style: AppStyles.tituloGrande),

            const SizedBox(height: 8),

            const Text(
              'Administra los productos de THEIA',
              style: AppStyles.textoNormal,
            ),

            const SizedBox(height: 22),

            // =====================================================
            // BUSCADOR
            // =====================================================
            TextField(
              controller: buscarController,

              onChanged: (valor) {
                setState(() {});
              },

              style: const TextStyle(color: AppColors.crema),

              decoration: InputDecoration(
                hintText: 'Buscar producto...',

                hintStyle: const TextStyle(color: AppColors.textoSecundario),

                prefixIcon: const Icon(Icons.search, color: AppColors.naranja),

                filled: true,

                fillColor: AppColors.tarjeta,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),

                  borderSide: BorderSide(color: AppColors.borde),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),

                  borderSide: const BorderSide(
                    color: AppColors.naranja,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // =====================================================
            // LISTA DE PRODUCTOS
            // =====================================================
            Expanded(
              child: productosFiltrados.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 55,
                            color: AppColors.textoSecundario,
                          ),

                          SizedBox(height: 12),

                          Text(
                            'No hay productos registrados',
                            style: TextStyle(color: AppColors.textoSecundario),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: productosFiltrados.length,

                      itemBuilder: (context, index) {
                        final producto = productosFiltrados[index];

                        return _productoCard(producto);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // TARJETA DEL PRODUCTO
  // =====================================================

  Widget _productoCard(Producto producto) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: AppColors.tarjeta,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: AppColors.borde),
      ),

      child: Row(
        children: [
          // =====================================================
          // IMAGEN DEL PRODUCTO
          // =====================================================
          ClipRRect(
            borderRadius: BorderRadius.circular(15),

            child: SizedBox(
              width: 75,
              height: 75,

              child: _mostrarImagen(producto),
            ),
          ),

          const SizedBox(width: 15),

          // =====================================================
          // INFORMACIÓN
          // =====================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  producto.nombre,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: AppColors.crema,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  producto.categoria,

                  style: const TextStyle(
                    color: AppColors.textoSecundario,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '\$${producto.precio.toStringAsFixed(2)}',

                  style: const TextStyle(
                    color: AppColors.naranja,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),

          // =====================================================
          // EDITAR
          // =====================================================
          IconButton(
            tooltip: 'Editar',

            onPressed: () async {
              await Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (_) => EditarProducto(producto: producto),
                ),
              );

              await cargarProductos();
            },

            icon: const Icon(Icons.edit_outlined, color: AppColors.naranja),
          ),

          // =====================================================
          // ELIMINAR
          // =====================================================
          IconButton(
            tooltip: 'Eliminar',

            onPressed: () {
              confirmarEliminar(producto);
            },

            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // MOSTRAR IMAGEN LOCAL
  // =====================================================

  Widget _mostrarImagen(Producto producto) {
    final imagen = producto.imagen.trim();

    if (imagen.isEmpty) {
      return _imagenPredeterminada();
    }

    return Image.network(
      imagen,
      width: 75,
      height: 75,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.naranja,
            strokeWidth: 2,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _imagenPredeterminada();
      },
    );
  }

  // =====================================================
  // IMAGEN PREDETERMINADA
  // =====================================================

  Widget _imagenPredeterminada() {
    return Container(
      color: AppColors.tarjetaClara,

      child: const Center(
        child: Icon(Icons.cake_outlined, color: AppColors.naranja, size: 38),
      ),
    );
  }
}
