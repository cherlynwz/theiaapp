import 'package:flutter/material.dart';

import '../../estilos/styles.dart';
import 'package:theiaapp/logica/productos_service.dart';
import '../../../modelos/producto.dart';

import 'detalle_producto.dart';

class Categorias extends StatefulWidget {
  const Categorias({super.key});

  @override
  State<Categorias> createState() => _CategoriasState();
}

class _CategoriasState extends State<Categorias> {
  final TextEditingController buscarController = TextEditingController();

  final ProductosService productosService = ProductosService();

  String categoriaSeleccionada = 'Todos';

  // ==========================================================
  // CATEGORÍAS
  // ==========================================================

  final List<String> categorias = [
    'Todos',
    'Tartas',
    'Cupcakes',
    'Galletas',
    'Brownies',
    'Macarons',
  ];

  // ==========================================================
  // PRODUCTOS
  // ==========================================================

  List<Producto> productos = [];

  bool cargando = true;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    cargarProductos();
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    buscarController.dispose();

    super.dispose();
  }

  // ==========================================================
  // CARGAR PRODUCTOS DESDE FIRESTORE
  // ==========================================================

  Future<void> cargarProductos() async {
    if (mounted) {
      setState(() {
        cargando = true;
      });
    }

    try {
      final datos = await productosService.obtenerProductos();

      if (!mounted) return;

      setState(() {
        productos = datos;
        cargando = false;
      });
    } catch (e) {
      debugPrint('ERROR AL CARGAR PRODUCTOS: $e');

      if (!mounted) return;

      setState(() {
        productos = [];
        cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar los productos: $e')),
      );
    }
  }

  // ==========================================================
  // PRODUCTOS FILTRADOS
  // ==========================================================

  List<Producto> get productosFiltrados {
    final texto = buscarController.text.trim().toLowerCase();

    return productos.where((producto) {
      // ------------------------------------------------------
      // FILTRO POR CATEGORÍA
      // ------------------------------------------------------

      final coincideCategoria =
          categoriaSeleccionada == 'Todos' ||
          producto.categoria.trim().toLowerCase() ==
              categoriaSeleccionada.trim().toLowerCase();

      if (!coincideCategoria) {
        return false;
      }

      // ------------------------------------------------------
      // FILTRO POR BÚSQUEDA
      // ------------------------------------------------------

      if (texto.isEmpty) {
        return true;
      }

      final nombre = producto.nombre.toLowerCase();

      return nombre.contains(texto);
    }).toList();
  }

  // ==========================================================
  // ICONO DE CATEGORÍA
  // ==========================================================

  IconData obtenerIconoCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'tartas':
      case 'pasteles':
        return Icons.cake_outlined;

      case 'cupcakes':
        return Icons.cake;

      case 'galletas':
        return Icons.cookie_outlined;

      case 'brownies':
        return Icons.bakery_dining;

      case 'macarons':
        return Icons.circle_outlined;

      case 'bebidas':
        return Icons.local_cafe_outlined;

      default:
        return Icons.cake_outlined;
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,

      appBar: AppBar(
        backgroundColor: AppColors.fondo,
        foregroundColor: AppColors.crema,
        elevation: 0,

        title: const Text(
          'Categorías',
          style: TextStyle(color: AppColors.crema, fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 5, 18, 25),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // DESCRIPCIÓN
              // ==================================================
              const Text(
                'Explora los diferentes productos de THEIA.',
                style: AppStyles.textoNormal,
              ),

              const SizedBox(height: 25),

              // ==================================================
              // BUSCADOR
              // ==================================================
              _buscador(),

              const SizedBox(height: 18),

              // ==================================================
              // FILTROS
              // ==================================================
              _filtros(),

              const SizedBox(height: 30),

              // ==================================================
              // PRODUCTOS
              // ==================================================
              const Text('Productos', style: AppStyles.tituloGrande),

              const SizedBox(height: 18),

              _productos(),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // BUSCADOR
  // ==========================================================

  Widget _buscador() {
    return TextField(
      controller: buscarController,

      style: const TextStyle(color: AppColors.crema),

      onChanged: (valor) {
        setState(() {});
      },

      decoration: InputDecoration(
        hintText: '¿Qué se te antoja?',

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

          borderSide: const BorderSide(color: AppColors.borde),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),

          borderSide: const BorderSide(color: AppColors.naranja),
        ),
      ),
    );
  }

  // ==========================================================
  // FILTROS DE CATEGORÍAS
  // ==========================================================

  Widget _filtros() {
    return SizedBox(
      height: 42,

      child: ListView.separated(
        scrollDirection: Axis.horizontal,

        itemCount: categorias.length,

        separatorBuilder: (_, _) {
          return const SizedBox(width: 10);
        },

        itemBuilder: (context, index) {
          final filtro = categorias[index];

          final seleccionado = filtro == categoriaSeleccionada;

          return GestureDetector(
            onTap: () {
              setState(() {
                categoriaSeleccionada = filtro;
              });
            },

            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),

              alignment: Alignment.center,

              decoration: BoxDecoration(
                color: seleccionado ? AppColors.naranja : AppColors.tarjeta,

                borderRadius: BorderRadius.circular(20),

                border: Border.all(
                  color: seleccionado ? AppColors.naranja : AppColors.borde,
                ),
              ),

              child: Text(
                filtro,

                style: TextStyle(
                  color: seleccionado ? AppColors.negro : AppColors.crema,

                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================================
  // PRODUCTOS
  // ==========================================================

  Widget _productos() {
    if (cargando) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),

          child: CircularProgressIndicator(color: AppColors.naranja),
        ),
      );
    }

    final productosMostrar = productosFiltrados;

    if (productosMostrar.isEmpty) {
      return Container(
        width: double.infinity,

        padding: const EdgeInsets.all(30),

        decoration: BoxDecoration(
          color: AppColors.tarjeta,

          borderRadius: BorderRadius.circular(20),

          border: Border.all(color: AppColors.borde),
        ),

        child: const Column(
          children: [
            Icon(Icons.search_off, size: 50, color: AppColors.naranja),

            SizedBox(height: 15),

            Text(
              'No encontramos productos.',
              textAlign: TextAlign.center,

              style: TextStyle(
                color: AppColors.crema,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 6),

            Text(
              'Prueba con otra categoría o búsqueda.',
              textAlign: TextAlign.center,

              style: TextStyle(color: AppColors.textoSecundario),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

      itemCount: productosMostrar.length,

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,

        crossAxisSpacing: 14,

        mainAxisSpacing: 14,

        childAspectRatio: 0.72,
      ),

      itemBuilder: (context, index) {
        final producto = productosMostrar[index];

        return _productoCard(producto);
      },
    );
  }

  // ==========================================================
  // TARJETA DE PRODUCTO
  // ==========================================================

  Widget _productoCard(Producto producto) {
    final nombre = producto.nombre;

    final descripcion = producto.descripcion;

    final precio = producto.precio;

    final imagen = producto.imagen;

    final categoria = producto.categoria;

    return InkWell(
      borderRadius: BorderRadius.circular(20),

      onTap: () {
        Navigator.push(
          context,

          MaterialPageRoute(
            builder: (_) => DetalleProducto(
              categoria: categoria,

              productoData: producto.toMap(),
            ),
          ),
        );
      },

      child: Container(
        decoration: BoxDecoration(
          color: AppColors.tarjeta,

          borderRadius: BorderRadius.circular(20),

          border: Border.all(color: AppColors.borde),
        ),

        padding: const EdgeInsets.all(10),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // =================================================
            // IMAGEN
            // =================================================
            Expanded(
              child: Container(
                width: double.infinity,

                decoration: BoxDecoration(
                  color: AppColors.tarjetaClara,

                  borderRadius: BorderRadius.circular(16),
                ),

                clipBehavior: Clip.antiAlias,

                child: _mostrarImagenProducto(imagen, categoria),
              ),
            ),

            const SizedBox(height: 10),

            // =================================================
            // NOMBRE
            // =================================================
            Text(
              nombre,

              maxLines: 2,

              overflow: TextOverflow.ellipsis,

              style: const TextStyle(
                color: AppColors.crema,

                fontSize: 16,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            // =================================================
            // DESCRIPCIÓN
            // =================================================
            if (descripcion.isNotEmpty)
              Text(
                descripcion,

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

                style: const TextStyle(
                  color: AppColors.textoSecundario,

                  fontSize: 12,
                ),
              ),

            const SizedBox(height: 6),

            // =================================================
            // PRECIO
            // =================================================
            Text(
              '\$${precio.toStringAsFixed(2)}',

              style: const TextStyle(
                color: AppColors.naranja,

                fontSize: 17,

                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // MOSTRAR IMAGEN DESDE CLOUDINARY
  // ==========================================================

  Widget _mostrarImagenProducto(String imagen, String categoria) {
    final url = imagen.trim();

    // --------------------------------------------------------
    // SIN IMAGEN
    // --------------------------------------------------------

    if (url.isEmpty) {
      return _imagenPredeterminada(categoria);
    }

    // --------------------------------------------------------
    // IMAGEN DESDE CLOUDINARY
    // --------------------------------------------------------

    if (url.startsWith('https://') || url.startsWith('http://')) {
      return Image.network(
        url,

        width: double.infinity,

        height: double.infinity,

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
          return _imagenPredeterminada(categoria);
        },
      );
    }

    // --------------------------------------------------------
    // SI NO ES URL, MOSTRAMOS EL ICONO
    // --------------------------------------------------------
    //
    // Ya no usamos File ni Image.asset para productos.
    //
    // Las imágenes nuevas deben venir desde Cloudinary.
    // --------------------------------------------------------

    return _imagenPredeterminada(categoria);
  }

  // ==========================================================
  // IMAGEN PREDETERMINADA
  // ==========================================================

  Widget _imagenPredeterminada(String categoria) {
    return Center(
      child: Icon(
        obtenerIconoCategoria(categoria),

        size: 60,

        color: AppColors.naranja,
      ),
    );
  }
}
