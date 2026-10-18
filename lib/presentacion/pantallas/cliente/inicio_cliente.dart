import 'dart:io';

import 'package:flutter/material.dart';

import '../../estilos/styles.dart';
import '../../../logica/sesion.dart';
import 'package:theiaapp/logica/productos_service.dart';
import '../../../modelos/producto.dart';

import 'carrito.dart';
import 'categorias.dart';
import 'perfil_cliente.dart';

class InicioCliente extends StatefulWidget {
  const InicioCliente({super.key});

  @override
  State<InicioCliente> createState() => _InicioClienteState();
}

class _InicioClienteState extends State<InicioCliente> {
  int paginaActual = 0;

  final List<Widget> paginas = const [
    _InicioContenido(),
    Categorias(),
    Carrito(),
    PerfilCliente(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,

      body: IndexedStack(index: paginaActual, children: paginas),

      // ===========================================================
      // NAVEGACIÓN INFERIOR
      // ===========================================================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.fondoSecundario,
          border: Border(top: BorderSide(color: AppColors.borde, width: 0.7)),
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: paginaActual,

            onTap: (index) {
              setState(() {
                paginaActual = index;
              });
            },

            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.fondoSecundario,
            elevation: 0,

            selectedItemColor: AppColors.naranja,
            unselectedItemColor: AppColors.textoSecundario,

            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),

            unselectedLabelStyle: const TextStyle(fontSize: 11),

            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_outlined),
                activeIcon: Icon(Icons.grid_view_rounded),
                label: 'Categorías',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined),
                activeIcon: Icon(Icons.shopping_bag),
                label: 'Carrito',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// CONTENIDO PRINCIPAL
// ===============================================================

class _InicioContenido extends StatefulWidget {
  const _InicioContenido();

  @override
  State<_InicioContenido> createState() => _InicioContenidoState();
}

class _InicioContenidoState extends State<_InicioContenido> {
  final ProductosService productosService = ProductosService();

  List<Producto> productos = [];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  // =============================================================
  // CARGAR PRODUCTOS DESDE SQLITE
  // =============================================================

  Future<void> cargarProductos() async {
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
        cargando = false;
      });
    }
  }

  // =============================================================
  // PANTALLA
  // =============================================================

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.naranja,
        onRefresh: cargarProductos,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(22, 30, 22, 35),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ===================================================
              // SALUDO
              // ===================================================
              _encabezado(),

              const SizedBox(height: 26),

              // ===================================================
              // BANNER THEIA
              // ===================================================
              _bannerTheia(),

              const SizedBox(height: 35),

              // ===================================================
              // PRODUCTOS DESTACADOS
              // ===================================================
              _tituloSeccion(
                titulo: 'Productos destacados',
                subtitulo: 'Selección especial de THEIA',
                icono: Icons.auto_awesome_rounded,
              ),

              const SizedBox(height: 17),

              _productosDestacados(),

              const SizedBox(height: 40),

              // ===================================================
              // ESPECIAL DE HOY
              // ===================================================
              _especialDeHoy(),

              const SizedBox(height: 40),

              // ===================================================
              // MÁS PEDIDOS
              // ===================================================
              _tituloSeccion(
                titulo: 'Más pedidos',
                subtitulo: 'Los favoritos de nuestros clientes',
                icono: Icons.local_fire_department_rounded,
              ),

              const SizedBox(height: 17),

              _productosMasPedidos(),

              const SizedBox(height: 42),

              // ===================================================
              // CIERRE THEIA
              // ===================================================
              _cierreTheia(),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================================
  // SALUDO
  // =============================================================

  Widget _encabezado() {
    final nombre = Sesion.usuarioActual?.nombre ?? 'Cliente';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.tarjeta,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borde),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.naranja,
              size: 20,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              'Hola, $nombre',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.crema,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // BANNER THEIA
  // =============================================================

  Widget _bannerTheia() {
    return Container(
      width: double.infinity,
      height: 180,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),

        border: Border.all(color: AppColors.borde),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),

        child: Image.asset(
          'assets/imagenes/theia.png',

          width: double.infinity,
          height: 180,

          fit: BoxFit.cover,

          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.tarjeta,

              child: const Center(
                child: Icon(
                  Icons.bakery_dining_outlined,
                  color: AppColors.naranja,
                  size: 55,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // =============================================================
  // TÍTULO DE SECCIONES
  // =============================================================

  Widget _tituloSeccion({
    required String titulo,
    required String subtitulo,
    required IconData icono,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: Container(height: 1, color: AppColors.borde)),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.crema,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Expanded(child: Container(height: 1, color: AppColors.borde)),
      ],
    );
  }

  // =============================================================
  // PRODUCTOS DESTACADOS
  // =============================================================

  Widget _productosDestacados() {
    if (cargando) {
      return _cargandoProductos();
    }

    final destacados = productos
        .where((producto) => producto.destacado == 1)
        .toList();

    if (destacados.isEmpty) {
      return _sinProductos(
        icono: Icons.auto_awesome_outlined,
        texto: 'Aún no hay productos destacados',
      );
    }

    return SizedBox(
      height: 255,

      child: ListView.separated(
        scrollDirection: Axis.horizontal,

        itemCount: destacados.length,

        separatorBuilder: (context, index) {
          return const SizedBox(width: 15);
        },

        itemBuilder: (context, index) {
          return _ProductoInicio(producto: destacados[index]);
        },
      ),
    );
  }

  // =============================================================
  // ESPECIAL DE HOY
  // =============================================================

  Widget _especialDeHoy() {
    if (cargando) {
      return const SizedBox.shrink();
    }

    final destacados = productos
        .where((producto) => producto.destacado == 1)
        .toList();

    // Si no hay destacados, usamos el primer producto disponible.
    Producto? especial;

    if (destacados.isNotEmpty) {
      especial = destacados.first;
    } else if (productos.isNotEmpty) {
      especial = productos.first;
    }

    if (especial == null) {
      return const SizedBox.shrink();
    }

    final productoEspecial = especial;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        // ETIQUETA
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),

            decoration: BoxDecoration(
              color: AppColors.naranja.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(30),

              border: Border.all(color: AppColors.naranja.withValues(alpha: 0.35)),
            ),

            child: const Row(
              mainAxisSize: MainAxisSize.min,

              children: [
                Icon(Icons.star_rounded, color: AppColors.naranja, size: 18),

                SizedBox(width: 7),

                Text(
                  'ESPECIAL DE HOY',

                  style: TextStyle(
                    color: AppColors.naranja,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                SizedBox(width: 7),

                Icon(Icons.star_rounded, color: AppColors.naranja, size: 18),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // TARJETA GRANDE
        Container(
          width: double.infinity,

          decoration: BoxDecoration(
            color: AppColors.tarjeta,
            borderRadius: BorderRadius.circular(24),

            border: Border.all(color: AppColors.borde),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 15,
                offset: const Offset(0, 7),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // IMAGEN
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                ),

                child: SizedBox(
                  width: double.infinity,
                  height: 190,

                  child: _imagenEspecial(productoEspecial),
                ),
              ),

              // INFORMACIÓN
              Padding(
                padding: const EdgeInsets.fromLTRB(19, 17, 19, 19),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,

                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            productoEspecial.nombre,

                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,

                            style: const TextStyle(
                              color: AppColors.crema,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            productoEspecial.categoria,

                            style: const TextStyle(
                              color: AppColors.textoSecundario,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            'Una opción especial seleccionada para ti',

                            style: TextStyle(
                              color: AppColors.textoSecundario,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    Text(
                      '\$${productoEspecial.precio.toStringAsFixed(2)}',

                      style: const TextStyle(
                        color: AppColors.naranja,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =============================================================
  // IMAGEN DEL ESPECIAL DE HOY
  // =============================================================

  Widget _imagenEspecial(Producto producto) {
    final ruta = producto.imagen.trim();

    if (ruta.isEmpty) {
      return _imagenEspecialPredeterminada();
    }

    // Compatibilidad con productos antiguos que tengan URL.
    if (ruta.startsWith('http://') || ruta.startsWith('https://')) {
      return Image.network(
        ruta,
        width: double.infinity,
        height: 190,
        fit: BoxFit.cover,

        errorBuilder: (context, error, stackTrace) {
          return _imagenEspecialPredeterminada();
        },
      );
    }

    final archivo = File(ruta);

    if (!archivo.existsSync()) {
      return _imagenEspecialPredeterminada();
    }

    return Image.file(
      archivo,
      width: double.infinity,
      height: 190,
      fit: BoxFit.cover,

      errorBuilder: (context, error, stackTrace) {
        return _imagenEspecialPredeterminada();
      },
    );
  }

  Widget _imagenEspecialPredeterminada() {
    return Container(
      width: double.infinity,
      height: 190,

      color: AppColors.tarjetaClara,

      child: const Center(
        child: Icon(Icons.cake_outlined, color: AppColors.naranja, size: 58),
      ),
    );
  }

  // =============================================================
  // PRODUCTOS MÁS PEDIDOS
  // =============================================================

  Widget _productosMasPedidos() {
    if (cargando) {
      return _cargandoProductos();
    }

    final masPedidos = productos
        .where((producto) => producto.masPedido == 1)
        .toList();

    if (masPedidos.isEmpty) {
      return _sinProductos(
        icono: Icons.shopping_bag_outlined,
        texto: 'Aún no hay productos en esta sección',
      );
    }

    return SizedBox(
      height: 255,

      child: ListView.separated(
        scrollDirection: Axis.horizontal,

        itemCount: masPedidos.length,

        separatorBuilder: (context, index) {
          return const SizedBox(width: 15);
        },

        itemBuilder: (context, index) {
          return _ProductoInicio(producto: masPedidos[index]);
        },
      ),
    );
  }

  // =============================================================
  // CIERRE VISUAL DE THEIA
  // =============================================================

  Widget _cierreTheia() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 25),

      decoration: BoxDecoration(
        color: AppColors.tarjeta,

        borderRadius: BorderRadius.circular(24),

        border: Border.all(color: AppColors.borde),
      ),

      child: Column(
        children: [
          // ICONOS DECORATIVOS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Icon(
                Icons.bakery_dining_outlined,
                color: AppColors.naranja.withValues(alpha: 0.75),
                size: 23,
              ),

              const SizedBox(width: 14),

              const Icon(
                Icons.favorite_rounded,
                color: AppColors.naranja,
                size: 21,
              ),

              const SizedBox(width: 14),

              Icon(
                Icons.cake_outlined,
                color: AppColors.naranja.withValues(alpha: 0.75),
                size: 23,
              ),
            ],
          ),

          const SizedBox(height: 15),

          const Text(
            'THEIA',

            style: TextStyle(
              color: AppColors.crema,
              fontSize: 19,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.5,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Preparado con dedicación para tus momentos dulces',

            textAlign: TextAlign.center,

            style: TextStyle(
              color: AppColors.textoSecundario,
              fontSize: 12,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 17),

          Container(
            width: 55,
            height: 2,

            decoration: BoxDecoration(
              color: AppColors.naranja.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // CARGANDO
  // =============================================================

  Widget _cargandoProductos() {
    return const SizedBox(
      height: 180,

      child: Center(child: CircularProgressIndicator(color: AppColors.naranja)),
    );
  }

  // =============================================================
  // SIN PRODUCTOS
  // =============================================================

  Widget _sinProductos({required IconData icono, required String texto}) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),

      decoration: BoxDecoration(
        color: AppColors.tarjeta,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borde),
      ),

      child: Column(
        children: [
          Icon(icono, color: AppColors.textoSecundario, size: 34),

          const SizedBox(height: 10),

          Text(
            texto,

            textAlign: TextAlign.center,

            style: const TextStyle(
              color: AppColors.textoSecundario,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// TARJETA DE PRODUCTO
// ===============================================================

class _ProductoInicio extends StatelessWidget {
  final Producto producto;

  const _ProductoInicio({required this.producto});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 178,

      decoration: BoxDecoration(
        color: AppColors.tarjeta,

        borderRadius: BorderRadius.circular(21),

        border: Border.all(color: AppColors.borde),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.13),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // =====================================================
          // IMAGEN
          // =====================================================
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),

            child: SizedBox(
              width: double.infinity,
              height: 135,

              child: _imagenProducto(),
            ),
          ),

          // =====================================================
          // INFORMACIÓN
          // =====================================================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(13, 11, 13, 12),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    producto.nombre,

                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      color: AppColors.crema,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    producto.categoria,

                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      color: AppColors.textoSecundario,
                      fontSize: 11,
                    ),
                  ),

                  const Spacer(),

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
          ),
        ],
      ),
    );
  }

  // =============================================================
  // MOSTRAR IMAGEN DEL PRODUCTO
  // =============================================================

  Widget _imagenProducto() {
    final ruta = producto.imagen.trim();

    // SIN IMAGEN
    if (ruta.isEmpty) {
      return _imagenPredeterminada();
    }

    // PRODUCTOS ANTIGUOS CON URL
    if (ruta.startsWith('http://') || ruta.startsWith('https://')) {
      return Image.network(
        ruta,

        width: double.infinity,
        height: 135,

        fit: BoxFit.cover,

        errorBuilder: (context, error, stackTrace) {
          return _imagenPredeterminada();
        },
      );
    }

    // PRODUCTOS CON IMAGEN LOCAL
    final archivo = File(ruta);

    if (!archivo.existsSync()) {
      return _imagenPredeterminada();
    }

    return Image.file(
      archivo,

      width: double.infinity,
      height: 135,

      fit: BoxFit.cover,

      errorBuilder: (context, error, stackTrace) {
        return _imagenPredeterminada();
      },
    );
  }

  // =============================================================
  // IMAGEN PREDETERMINADA
  // =============================================================

  Widget _imagenPredeterminada() {
    return Container(
      width: double.infinity,
      height: 135,

      color: AppColors.tarjetaClara,

      child: const Center(
        child: Icon(Icons.cake_outlined, color: AppColors.naranja, size: 45),
      ),
    );
  }
}
