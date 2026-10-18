import 'package:flutter/material.dart';

import '../Styles/styles.dart';
import '../Servicios/carrito_provider.dart';

class DetalleProducto extends StatefulWidget {
  final String categoria;

  // Producto real obtenido desde SQLite.
  final Map<String, dynamic>? productoData;

  const DetalleProducto({
    super.key,
    required this.categoria,
    this.productoData,
  });

  @override
  State<DetalleProducto> createState() => _DetalleProductoState();
}

class _DetalleProductoState extends State<DetalleProducto> {
  int cantidad = 1;

  // ============================================================
  // PRODUCTO
  // ============================================================

  Map<String, dynamic> get producto {
    if (widget.productoData != null) {
      final datos = Map<String, dynamic>.from(widget.productoData!);

      datos['icono'] ??= obtenerIconoCategoria(widget.categoria);

      return datos;
    }

    // ==========================================================
    // RESPALDO
    // ==========================================================

    switch (widget.categoria) {
      case 'Tartas':
        return {
          'nombre': 'Tarta de Chocolate',
          'precio': 350.0,
          'descripcion':
              'Deliciosa tarta artesanal de chocolate, preparada con una textura suave y cremosa.',
          'icono': Icons.cake_outlined,
        };

      case 'Cupcakes':
        return {
          'nombre': 'Cupcake de Chocolate',
          'precio': 45.0,
          'descripcion':
              'Cupcake artesanal de chocolate con betún cremoso y decoración especial de THEIA.',
          'icono': Icons.cake,
        };

      case 'Galletas':
        return {
          'nombre': 'Galletas Decoradas',
          'precio': 80.0,
          'descripcion':
              'Galletas horneadas artesanalmente y decoradas con detalles especiales.',
          'icono': Icons.cookie_outlined,
        };

      case 'Brownies':
        return {
          'nombre': 'Brownie de Chocolate',
          'precio': 55.0,
          'descripcion':
              'Brownie intenso de chocolate con interior suave y una cubierta ligeramente crujiente.',
          'icono': Icons.bakery_dining,
        };

      case 'Macarons':
        return {
          'nombre': 'Caja de Macarons',
          'precio': 120.0,
          'descripcion':
              'Selección de macarons artesanales con distintos sabores y rellenos.',
          'icono': Icons.circle_outlined,
        };

      case 'Bebidas':
        return {
          'nombre': 'Chocolate Caliente',
          'precio': 65.0,
          'descripcion':
              'Chocolate caliente cremoso, perfecto para acompañar tus postres favoritos.',
          'icono': Icons.local_cafe_outlined,
        };

      default:
        return {
          'nombre': 'Producto THEIA',
          'precio': 100.0,
          'descripcion': 'Producto artesanal preparado especialmente para ti.',
          'icono': Icons.cake_outlined,
        };
    }
  }

  // ============================================================
  // ICONO POR CATEGORÍA
  // ============================================================

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

  // ============================================================
  // PRECIO
  // ============================================================

  double obtenerPrecio(dynamic precio) {
    if (precio is num) {
      return precio.toDouble();
    }

    return double.tryParse(precio?.toString() ?? '0') ?? 0;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final datos = producto;

    final double precio = obtenerPrecio(datos['precio']);

    return Scaffold(
      backgroundColor: AppColors.fondo,

      appBar: AppBar(
        backgroundColor: AppColors.fondo,
        foregroundColor: AppColors.crema,
        elevation: 0,

        title: const Text(
          'Detalle',
          style: TextStyle(color: AppColors.crema, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            _imagenProducto(datos),

            const SizedBox(height: 25),

            // ==================================================
            // CATEGORÍA
            // ==================================================
            Text(
              widget.categoria.toUpperCase(),

              style: const TextStyle(
                color: AppColors.naranja,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 8),

            // ==================================================
            // NOMBRE
            // ==================================================
            Text(
              datos['nombre']?.toString() ?? 'Producto THEIA',
              style: AppStyles.tituloGrande,
            ),

            const SizedBox(height: 12),

            // ==================================================
            // PRECIO
            // ==================================================
            Row(
              children: [
                Text(
                  '\$${precio.toStringAsFixed(0)}',

                  style: const TextStyle(
                    color: AppColors.naranja,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                const Icon(Icons.star, color: AppColors.naranja, size: 20),

                const Icon(Icons.star, color: AppColors.naranja, size: 20),

                const Icon(Icons.star, color: AppColors.naranja, size: 20),

                const Icon(Icons.star, color: AppColors.naranja, size: 20),

                const Icon(Icons.star_half, color: AppColors.naranja, size: 20),

                const SizedBox(width: 5),

                const Text(
                  '4.8',
                  style: TextStyle(color: AppColors.textoSecundario),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ==================================================
            // DESCRIPCIÓN
            // ==================================================
            const Text('Descripción', style: AppStyles.titulo),

            const SizedBox(height: 10),

            Text(
              datos['descripcion']?.toString() ??
                  'Producto artesanal preparado especialmente para ti.',

              style: const TextStyle(
                color: AppColors.textoSecundario,
                fontSize: 15,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            // ==================================================
            // CANTIDAD
            // ==================================================
            Row(
              children: [
                const Text(
                  'Cantidad',

                  style: TextStyle(
                    color: AppColors.crema,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                _selectorCantidad(),
              ],
            ),

            const SizedBox(height: 30),

            // ==================================================
            // AGREGAR AL CARRITO
            // ==================================================
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: () {
                  _agregarCarrito(datos);
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.naranja,
                  foregroundColor: Colors.black,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),

                icon: const Icon(Icons.shopping_cart_outlined),

                label: const Text(
                  'AGREGAR AL CARRITO',

                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // IMAGEN DEL PRODUCTO
  // ============================================================

  Widget _imagenProducto(Map<String, dynamic> datos) {
    final String imagen = datos['imagen']?.toString() ?? '';

    return Container(
      width: double.infinity,
      height: 280,

      decoration: BoxDecoration(
        color: AppColors.tarjeta,

        borderRadius: BorderRadius.circular(25),

        border: Border.all(color: AppColors.borde),

        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [AppColors.tarjetaClara, AppColors.tarjeta],
        ),
      ),

      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),

              child: _mostrarImagenProducto(imagen, datos),
            ),
          ),

          Positioned(
            top: 18,
            left: 18,

            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),

              decoration: BoxDecoration(
                color: AppColors.naranja,

                borderRadius: BorderRadius.circular(20),
              ),

              child: const Text(
                'THEIA',

                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOSTRAR IMAGEN
  // ============================================================

  Widget _mostrarImagenProducto(String imagen, Map<String, dynamic> datos) {
    final url = imagen.trim();

    // ==========================================================
    // SIN IMAGEN
    // ==========================================================

    if (url.isEmpty) {
      return _iconoProducto(datos);
    }

    // ==========================================================
    // IMAGEN DESDE CLOUDINARY
    // ==========================================================

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
            child: CircularProgressIndicator(color: AppColors.naranja),
          );
        },

        errorBuilder: (context, error, stackTrace) {
          return _iconoProducto(datos);
        },
      );
    }

    // ==========================================================
    // IMAGEN NO VÁLIDA
    // ==========================================================
    //
    // Ya no utilizamos:
    // File()
    // Image.file()
    // Image.asset()
    //
    // Las imágenes de productos deben estar en Cloudinary.
    // ==========================================================

    return _iconoProducto(datos);
  }

  // ============================================================
  // ICONO
  // ============================================================

  Widget _iconoProducto(Map<String, dynamic> datos) {
    return Center(
      child: Icon(
        datos['icono'] as IconData? ?? obtenerIconoCategoria(widget.categoria),

        size: 125,

        color: AppColors.naranja,
      ),
    );
  }

  // ============================================================
  // SELECTOR CANTIDAD
  // ============================================================

  Widget _selectorCantidad() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.tarjeta,

        borderRadius: BorderRadius.circular(15),

        border: Border.all(color: AppColors.borde),
      ),

      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (cantidad > 1) {
                setState(() {
                  cantidad--;
                });
              }
            },

            icon: const Icon(Icons.remove, color: AppColors.naranja),
          ),

          SizedBox(
            width: 35,

            child: Text(
              cantidad.toString(),

              textAlign: TextAlign.center,

              style: const TextStyle(
                color: AppColors.crema,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          IconButton(
            onPressed: () {
              setState(() {
                cantidad++;
              });
            },

            icon: const Icon(Icons.add, color: AppColors.naranja),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCTOS RELACIONADOS
  // ============================================================

  Widget _productoRelacionado(String nombre, String precio, IconData icono) {
    return Container(
      width: 130,

      margin: const EdgeInsets.only(right: 12),

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: AppColors.tarjeta,

        borderRadius: BorderRadius.circular(17),

        border: Border.all(color: AppColors.borde),
      ),

      child: Column(
        children: [
          Expanded(child: Icon(icono, color: AppColors.naranja, size: 42)),

          Text(
            nombre,

            style: const TextStyle(
              color: AppColors.crema,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            precio,

            style: const TextStyle(
              color: AppColors.naranja,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AGREGAR AL CARRITO REAL
  // ============================================================

  void _agregarCarrito(Map<String, dynamic> datos) {
    // ============================================
    // AGREGAR AL CARRITO
    // NO SE CAMBIA SU FUNCIONAMIENTO
    // ============================================

    CarritoProvider.instance.agregarProducto(datos, cantidad);

    // Quitamos cualquier SnackBar anterior.
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    // Mostramos confirmación.
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.naranja),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                '$cantidad ${datos['nombre']} agregado al carrito',
                style: const TextStyle(
                  color: AppColors.crema,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        backgroundColor: AppColors.tarjetaClara,

        behavior: SnackBarBehavior.floating,

        margin: const EdgeInsets.only(left: 18, right: 18, bottom: 15),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

        duration: const Duration(milliseconds: 1500),
      ),
    );

    // Forzamos que desaparezca.
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });
  }
}
