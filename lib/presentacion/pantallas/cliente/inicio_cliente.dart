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

  Widget _iconoActivo(IconData icono) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.naranja.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icono),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: IndexedStack(index: paginaActual, children: paginas),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.tarjeta,
          border: const Border(
            top: BorderSide(color: AppColors.borde, width: 0.7),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.crema.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 3),
            child: BottomNavigationBar(
              currentIndex: paginaActual,
              onTap: (index) {
                setState(() {
                  paginaActual = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.tarjeta,
              elevation: 0,
              selectedItemColor: AppColors.naranjaOscuro,
              unselectedItemColor: AppColors.textoSecundario,
              selectedFontSize: 11,
              unselectedFontSize: 11,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: _iconoActivo(Icons.home_rounded),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.grid_view_outlined),
                  activeIcon: _iconoActivo(Icons.grid_view_rounded),
                  label: 'Categorías',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.shopping_bag_outlined),
                  activeIcon: _iconoActivo(Icons.shopping_bag),
                  label: 'Carrito',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline_rounded),
                  activeIcon: _iconoActivo(Icons.person_rounded),
                  label: 'Perfil',
                ),
              ],
            ),
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
  String? errorCarga;

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  Future<void> cargarProductos() async {
    try {
      final datos = await productosService.obtenerProductos();

      if (!mounted) return;

      setState(() {
        productos = datos;
        cargando = false;
        errorCarga = null;
      });
    } catch (e) {
      debugPrint('ERROR AL CARGAR PRODUCTOS: $e');

      if (!mounted) return;

      setState(() {
        cargando = false;
        errorCarga = 'No se pudieron cargar los productos.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AppColors.naranjaOscuro,
        onRefresh: cargarProductos,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _encabezado(),
                  const SizedBox(height: 24),

                  _bannerTheia(),
                  const SizedBox(height: 30),

                  if (errorCarga != null) ...[
                    _avisoError(),
                    const SizedBox(height: 20),
                  ],

                  _tituloSeccion('Productos destacados'),
                  const SizedBox(height: 18),

                  _productosDestacados(),
                  const SizedBox(height: 30),

                  _especialDeHoy(),
                  const SizedBox(height: 30),

                  _tituloSeccion('Más pedidos'),
                  const SizedBox(height: 18),

                  _productosMasPedidos(),
                  const SizedBox(height: 28),

                  _cierreTheia(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =============================================================
  // SALUDO
  // =============================================================

  Widget _encabezado() {
    final nombreGuardado = Sesion.usuarioActual?.nombre.trim() ?? '';
    final nombre = nombreGuardado.isEmpty ? 'Cliente' : nombreGuardado;

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.tarjeta,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borde),
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            color: AppColors.naranjaOscuro,
            size: 25,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'QUÉ GUSTO VERTE',
                style: TextStyle(
                  color: AppColors.textoSecundario,
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Hola, $nombre',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.crema,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =============================================================
  // BANNER SIN FRANJAS LATERALES
  // =============================================================

  Widget _bannerTheia() {
    return Container(
      width: double.infinity,
      height: 180,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.tarjetaClara,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borde),
        boxShadow: [
          BoxShadow(
            color: AppColors.crema.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Image.asset(
        'assets/imagenes/theia.png',
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(
              Icons.bakery_dining_outlined,
              color: AppColors.naranjaOscuro,
              size: 48,
            ),
          );
        },
      ),
    );
  }

  // =============================================================
  // TÍTULOS CENTRADOS CON LÍNEAS
  // =============================================================

  Widget _tituloSeccion(String titulo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Expanded(child: Divider(color: AppColors.borde, thickness: 1)),
        const SizedBox(width: 12),
        Flexible(
          flex: 5,
          fit: FlexFit.loose,
          child: Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.crema,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Divider(color: AppColors.borde, thickness: 1)),
      ],
    );
  }

  // =============================================================
  // PRODUCTOS DESTACADOS
  // =============================================================

  Widget _productosDestacados() {
    if (cargando) return _cargandoProductos();

    final destacados = productos
        .where((producto) => producto.destacado == 1)
        .toList();

    if (destacados.isEmpty) {
      return _sinProductos(
        icono: Icons.cake_outlined,
        texto: 'Aún no hay productos destacados',
      );
    }

    return _listaProductos(destacados);
  }

  // =============================================================
  // PRODUCTOS MÁS PEDIDOS
  // =============================================================

  Widget _productosMasPedidos() {
    if (cargando) return _cargandoProductos();

    final masPedidos = productos
        .where((producto) => producto.masPedido == 1)
        .toList();

    if (masPedidos.isEmpty) {
      return _sinProductos(
        icono: Icons.shopping_bag_outlined,
        texto: 'Aún no hay productos en esta sección',
      );
    }

    return _listaProductos(masPedidos);
  }

  // =============================================================
  // LISTA CON TARJETAS MÁS ANCHAS
  // =============================================================

  Widget _listaProductos(List<Producto> lista) {
    // Reserva espacio según el tamaño de texto del dispositivo.
    final altoNombre = MediaQuery.textScalerOf(context).scale(16) * 1.25 * 2;
    final altoCategoria = MediaQuery.textScalerOf(context).scale(12) * 1.3;
    final altoPrecio = MediaQuery.textScalerOf(context).scale(19) * 1.25;

    final altoTarjeta =
        140 + 26 + altoNombre + 6 + altoCategoria + 14 + altoPrecio;

    return LayoutBuilder(
      builder: (context, constraints) {
        final anchoDisponible = constraints.maxWidth;

        final ancho = anchoDisponible < 600 ? anchoDisponible * 0.72 : 280.0;

        return SizedBox(
          height: altoTarjeta + 8,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: 8, right: 4),
            itemCount: lista.length,
            separatorBuilder: (context, index) {
              return const SizedBox(width: 15);
            },
            itemBuilder: (context, index) {
              return _ProductoInicio(producto: lista[index], ancho: ancho);
            },
          ),
        );
      },
    );
  }

  // =============================================================
  // ESPECIAL DE HOY
  // =============================================================

  Widget _especialDeHoy() {
    if (cargando || productos.isEmpty) {
      return const SizedBox.shrink();
    }

    final destacados = productos
        .where((producto) => producto.destacado == 1)
        .toList();

    final especial = destacados.isNotEmpty ? destacados.first : productos.first;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.tarjeta,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.naranja.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'ESPECIAL DE HOY',
                style: TextStyle(
                  color: AppColors.naranjaOscuro,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          AspectRatio(
            aspectRatio: 1.9,
            child: _ImagenProductoInicio(
              ruta: especial.imagen,
              tamanoIcono: 58,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  especial.categoria.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textoSecundario,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  especial.nombre,
                  style: const TextStyle(
                    color: AppColors.crema,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Una opción especial seleccionada para ti',
                  style: TextStyle(
                    color: AppColors.textoSecundario,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '\$${especial.precio.toStringAsFixed(2)} MXN',
                  style: const TextStyle(
                    color: AppColors.naranjaOscuro,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // CIERRE
  // =============================================================

  Widget _cierreTheia() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.tarjetaClara,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borde),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.bakery_dining_outlined,
            color: AppColors.naranjaOscuro,
            size: 26,
          ),
          SizedBox(height: 10),
          Text(
            'Hecho con cariño en THEIA',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.crema,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Un detalle dulce para tus momentos especiales.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textoSecundario,
              fontSize: 12,
              height: 1.5,
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
      child: Center(
        child: CircularProgressIndicator(color: AppColors.naranjaOscuro),
      ),
    );
  }

  // =============================================================
  // ERROR DE CARGA
  // =============================================================

  Widget _avisoError() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tarjeta,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            errorCarga!,
            style: const TextStyle(color: AppColors.crema, fontSize: 13),
          ),
          TextButton(
            onPressed: cargarProductos,
            child: const Text(
              'Reintentar',
              style: TextStyle(color: AppColors.naranjaOscuro),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // SIN PRODUCTOS
  // =============================================================

  Widget _sinProductos({required IconData icono, required String texto}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.tarjeta,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borde),
      ),
      child: Column(
        children: [
          Icon(icono, color: AppColors.textoSecundario, size: 30),
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
  final double ancho;

  const _ProductoInicio({required this.producto, required this.ancho});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ancho,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.tarjeta,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borde),
        boxShadow: [
          BoxShadow(
            color: AppColors.crema.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: 140,
            child: _ImagenProductoInicio(
              ruta: producto.imagen,
              tamanoIcono: 45,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.crema,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    producto.categoria,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textoSecundario,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                  const Spacer(),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '\$${producto.precio.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.naranjaOscuro,
                            fontWeight: FontWeight.w700,
                            fontSize: 19,
                            height: 1.25,
                          ),
                        ),
                        const TextSpan(
                          text: ' MXN',
                          style: TextStyle(
                            color: AppColors.textoSecundario,
                            fontSize: 10,
                            height: 1.25,
                          ),
                        ),
                      ],
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
}

// ===============================================================
// IMÁGENES DE PRODUCTOS
// ===============================================================

class _ImagenProductoInicio extends StatelessWidget {
  final String ruta;
  final double tamanoIcono;

  const _ImagenProductoInicio({required this.ruta, required this.tamanoIcono});

  Widget _predeterminada() {
    return Container(
      color: AppColors.tarjetaClara,
      alignment: Alignment.center,
      child: Icon(
        Icons.cake_outlined,
        color: AppColors.naranja,
        size: tamanoIcono,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagen = ruta.trim();

    if (imagen.isEmpty) {
      return _predeterminada();
    }

    if (imagen.startsWith('https://') || imagen.startsWith('http://')) {
      return Image.network(
        imagen,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _predeterminada();
        },
      );
    }

    final archivo = File(imagen);

    if (!archivo.existsSync()) {
      return _predeterminada();
    }

    return Image.file(
      archivo,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _predeterminada();
      },
    );
  }
}
