import 'package:flutter/material.dart';

import '../Styles/styles.dart';
import '../Servicios/sesion.dart';
import '../login.dart';
import '../BaseDatos/productosDAO.dart';
import '../BaseDatos/usuarioDAO.dart';
import '../BaseDatos/pedidosDAO.dart';
import 'reportes.dart';
import 'usuarios.dart';
import 'productos.dart';
import 'pedidos.dart';

class InicioAdmin extends StatefulWidget {
  const InicioAdmin({super.key});

  @override
  State<InicioAdmin> createState() => _InicioAdminState();
}

class _InicioAdminState extends State<InicioAdmin> {
  int paginaActual = 0;

  late List<Widget> paginas;

  @override
  void initState() {
    super.initState();

    paginas = [
      _PanelAdmin(key: UniqueKey()),
      const ReportesAdmin(),
      const UsuariosAdmin(),
      const ProductosAdmin(),
      const PedidosAdmin(),
    ];
  }

  void refrescarPanel() {
    setState(() {
      paginas[0] = _PanelAdmin(key: UniqueKey());
    });
  }

  void cerrarSesion(BuildContext context) {
    Sesion.cerrarSesion();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,

      // =========================================================
      // MENÚ LATERAL
      // =========================================================
      endDrawer: Drawer(
        backgroundColor: AppColors.fondo,

        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 45),

              Text(
                Sesion.usuarioActual?.nombre ?? 'Administrador',
                style: const TextStyle(
                  color: AppColors.crema,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Administrador THEIA',
                style: TextStyle(color: AppColors.textoSecundario),
              ),

              const Divider(color: AppColors.borde, height: 45),

              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.naranja),

                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: AppColors.crema),
                ),

                onTap: () {
                  cerrarSesion(context);
                },
              ),
            ],
          ),
        ),
      ),

      // =========================================================
      // PÁGINAS
      // =========================================================
      body: IndexedStack(index: paginaActual, children: paginas),

      // =========================================================
      // NAVEGACIÓN INFERIOR
      // =========================================================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: paginaActual,

        onTap: (index) {
          setState(() {
            paginaActual = index;

            if (index == 0) {
              refrescarPanel();
            }
          });
        },

        type: BottomNavigationBarType.fixed,

        backgroundColor: AppColors.fondoSecundario,

        selectedItemColor: AppColors.naranja,

        unselectedItemColor: AppColors.textoSecundario,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Panel',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Reportes',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Clientes',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Productos',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Pedidos',
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// PANEL PRINCIPAL DEL ADMINISTRADOR
// ===============================================================

class _PanelAdmin extends StatefulWidget {
  const _PanelAdmin({super.key});

  @override
  State<_PanelAdmin> createState() => _PanelAdminState();
}

class _PanelAdminState extends State<_PanelAdmin> {
  final ProductoDAO productoDAO = ProductoDAO();

  final UsuarioDAO usuarioDAO = UsuarioDAO();

  final PedidosDAO pedidosDAO = PedidosDAO();

  int cantidadProductos = 0;

  int cantidadClientes = 0;

  int cantidadPedidos = 0;

  double ventasHoy = 0;

  @override
  void initState() {
    super.initState();

    cargarDatos();
  }

  // =============================================================
  // CARGAR DATOS
  // =============================================================

  Future<void> cargarDatos() async {
    final productos = await productoDAO.contarProductos();

    final clientes = await usuarioDAO.contarClientes();

    final pedidos = await pedidosDAO.contarPedidos();

    final ventas = await pedidosDAO.totalVentas();

    print("PRODUCTOS: $productos");
    print("CLIENTES: $clientes");
    print("PEDIDOS: $pedidos");
    print("VENTAS: $ventas");

    if (!mounted) return;

    setState(() {
      cantidadProductos = productos;
      cantidadClientes = clientes;
      cantidadPedidos = pedidos;
      ventasHoy = ventas;
    });
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    final nombre = Sesion.usuarioActual?.nombre ?? 'Administrador';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ===================================================
            // MENÚ
            // ===================================================
            Builder(
              builder: (context) {
                return Align(
                  alignment: Alignment.centerRight,

                  child: IconButton(
                    icon: const Icon(Icons.menu, color: AppColors.crema),

                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  ),
                );
              },
            ),

            // ===================================================
            // SALUDO
            // ===================================================
            Text(
              'Hola, $nombre',

              style: const TextStyle(
                color: AppColors.crema,
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Este es el resumen general de THEIA',

              style: TextStyle(color: AppColors.textoSecundario, fontSize: 14),
            ),

            const SizedBox(height: 28),

            // ===================================================
            // VENTAS
            // ===================================================
            _tarjetaVentas(),

            const SizedBox(height: 16),

            // ===================================================
            // PEDIDOS
            // ===================================================
            _tarjetaDato(
              titulo: 'Pedidos',
              subtitulo: 'Pedidos registrados',
              valor: cantidadPedidos.toString(),
              icono: Icons.receipt_long_outlined,
            ),

            const SizedBox(height: 13),

            // ===================================================
            // PRODUCTOS
            // ===================================================
            _tarjetaDato(
              titulo: 'Productos',
              subtitulo: 'Productos disponibles',
              valor: cantidadProductos.toString(),
              icono: Icons.cake_outlined,
            ),

            const SizedBox(height: 13),

            // ===================================================
            // CLIENTES
            // ===================================================
            _tarjetaDato(
              titulo: 'Clientes',
              subtitulo: 'Clientes registrados',
              valor: cantidadClientes.toString(),
              icono: Icons.people_outline,
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // TARJETA PRINCIPAL DE VENTAS
  // =============================================================

  Widget _tarjetaVentas() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: AppColors.tarjeta,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: AppColors.borde),
      ),

      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,

            decoration: BoxDecoration(
              color: AppColors.tarjetaClara,

              borderRadius: BorderRadius.circular(17),
            ),

            child: const Icon(
              Icons.attach_money,
              color: AppColors.naranja,
              size: 30,
            ),
          ),

          const SizedBox(width: 17),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Ventas',

                  style: TextStyle(
                    color: AppColors.textoSecundario,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '\$${ventasHoy.toStringAsFixed(2)}',

                  style: const TextStyle(
                    color: AppColors.crema,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                const Text(
                  'Ventas registradas',

                  style: TextStyle(
                    color: AppColors.textoSecundario,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.trending_up, color: AppColors.naranja, size: 27),
        ],
      ),
    );
  }

  // =============================================================
  // TARJETAS DEL PANEL
  // =============================================================

  Widget _tarjetaDato({
    required String titulo,
    required String subtitulo,
    required String valor,
    required IconData icono,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),

      decoration: BoxDecoration(
        color: AppColors.tarjeta,

        borderRadius: BorderRadius.circular(19),

        border: Border.all(color: AppColors.borde),
      ),

      child: Row(
        children: [
          // =====================================================
          // ICONO
          // =====================================================
          Container(
            width: 50,
            height: 50,

            decoration: BoxDecoration(
              color: AppColors.tarjetaClara,

              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(icono, color: AppColors.naranja, size: 25),
          ),

          const SizedBox(width: 15),

          // =====================================================
          // TEXTO
          // =====================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  titulo,

                  style: const TextStyle(
                    color: AppColors.crema,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitulo,

                  style: const TextStyle(
                    color: AppColors.textoSecundario,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // =====================================================
          // VALOR
          // =====================================================
          Container(
            constraints: const BoxConstraints(minWidth: 48),

            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),

            decoration: BoxDecoration(
              color: AppColors.tarjetaClara,

              borderRadius: BorderRadius.circular(12),
            ),

            child: Text(
              valor,

              textAlign: TextAlign.center,

              style: const TextStyle(
                color: AppColors.naranja,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
