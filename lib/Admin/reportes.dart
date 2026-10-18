import 'package:flutter/material.dart';

import '../Styles/styles.dart';
import '../BaseDatos/pedidosDAO.dart';
import '../Modelos/pedido.dart';

class ReportesAdmin extends StatefulWidget {
  const ReportesAdmin({super.key});

  @override
  State<ReportesAdmin> createState() => _ReportesAdminState();
}

class _ReportesAdminState extends State<ReportesAdmin> {
  final PedidosDAO pedidosDAO = PedidosDAO();

  String periodoSeleccionado = 'Hoy';

  final List<String> periodos = ['Hoy', 'Esta semana', 'Este mes'];

  bool cargando = true;

  List<Pedido> todosLosPedidos = [];
  List<Pedido> pedidosFiltrados = [];

  // ============================================================
  // INICIAR
  // ============================================================

  @override
  void initState() {
    super.initState();
    cargarPedidos();
  }

  // ============================================================
  // CARGAR PEDIDOS DESDE SQLITE
  // ============================================================

  Future<void> cargarPedidos() async {
    try {
      final pedidos = await pedidosDAO.obtenerPedidos();

      if (!mounted) return;

      setState(() {
        todosLosPedidos = pedidos;
        cargando = false;
      });

      filtrarPedidos();
    } catch (e) {
      debugPrint('ERROR AL CARGAR REPORTES: $e');

      if (!mounted) return;

      setState(() {
        cargando = false;
      });
    }
  }

  // ============================================================
  // CONVERTIR FECHA
  // ============================================================

  DateTime? convertirFecha(String fecha) {
    try {
      return DateTime.parse(fecha);
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // FILTRAR POR PERIODO
  // ============================================================

  void filtrarPedidos() {
    final ahora = DateTime.now();

    List<Pedido> resultado = [];

    if (periodoSeleccionado == 'Hoy') {
      resultado = todosLosPedidos.where((pedido) {
        final fecha = convertirFecha(pedido.fecha);

        if (fecha == null) {
          return false;
        }

        return fecha.year == ahora.year &&
            fecha.month == ahora.month &&
            fecha.day == ahora.day;
      }).toList();
    }

    if (periodoSeleccionado == 'Esta semana') {
      final inicioSemana = DateTime(
        ahora.year,
        ahora.month,
        ahora.day,
      ).subtract(Duration(days: ahora.weekday - 1));

      final finSemana = inicioSemana.add(const Duration(days: 7));

      resultado = todosLosPedidos.where((pedido) {
        final fecha = convertirFecha(pedido.fecha);

        if (fecha == null) {
          return false;
        }

        return !fecha.isBefore(inicioSemana) && fecha.isBefore(finSemana);
      }).toList();
    }

    if (periodoSeleccionado == 'Este mes') {
      resultado = todosLosPedidos.where((pedido) {
        final fecha = convertirFecha(pedido.fecha);

        if (fecha == null) {
          return false;
        }

        return fecha.year == ahora.year && fecha.month == ahora.month;
      }).toList();
    }

    setState(() {
      pedidosFiltrados = resultado;
    });
  }

  // ============================================================
  // AGRUPAR PEDIDOS POR DÍA
  // ============================================================

  Map<String, List<Pedido>> agruparPedidosPorDia() {
    final Map<String, List<Pedido>> grupos = {};

    for (final pedido in pedidosFiltrados) {
      final fecha = convertirFecha(pedido.fecha);

      if (fecha == null) {
        continue;
      }

      final clave =
          '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';

      if (!grupos.containsKey(clave)) {
        grupos[clave] = [];
      }

      grupos[clave]!.add(pedido);
    }

    return grupos;
  }

  // ============================================================
  // TOTAL DEL PERIODO
  // ============================================================

  double get totalPeriodo {
    double total = 0;

    for (final pedido in pedidosFiltrados) {
      total += pedido.total;
    }

    return total;
  }

  // ============================================================
  // FORMATEAR FECHA
  // ============================================================

  String formatearFecha(String fechaTexto) {
    final fecha = DateTime.tryParse(fechaTexto);

    if (fecha == null) {
      return fechaTexto;
    }

    const meses = [
      '',
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    return '${fecha.day} de ${meses[fecha.month]} de ${fecha.year}';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final grupos = agruparPedidosPorDia();

    final fechas = grupos.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: AppColors.fondo,

      appBar: AppBar(
        backgroundColor: AppColors.fondo,
        foregroundColor: AppColors.crema,
        elevation: 0,

        title: const Text(
          'Reportes',
          style: TextStyle(color: AppColors.crema, fontWeight: FontWeight.bold),
        ),
      ),

      body: cargando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.naranja),
            )
          : RefreshIndicator(
              onRefresh: cargarPedidos,
              color: AppColors.naranja,

              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),

                padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Historial de ventas',
                      style: AppStyles.tituloGrande,
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Consulta los movimientos de THEIA',
                      style: AppStyles.textoNormal,
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // SELECTOR DE PERIODO
                    // ==================================================
                    _selectorPeriodo(),

                    const SizedBox(height: 28),

                    // ==================================================
                    // HISTORIAL
                    // ==================================================
                    const Text(
                      'Movimientos del periodo',
                      style: AppStyles.titulo,
                    ),

                    const SizedBox(height: 15),

                    if (pedidosFiltrados.isEmpty)
                      _sinMovimientos()
                    else
                      ...fechas.map((fecha) {
                        final pedidosDia = grupos[fecha]!;

                        double totalDia = 0;

                        for (final pedido in pedidosDia) {
                          totalDia += pedido.total;
                        }

                        return _tarjetaDia(
                          fecha: fecha,
                          cantidadPedidos: pedidosDia.length,
                          total: totalDia,
                        );
                      }),

                    const SizedBox(height: 25),

                    // ==================================================
                    // RESUMEN DEL PERIODO
                    // ==================================================
                    _resumenPeriodo(),
                  ],
                ),
              ),
            ),
    );
  }

  // ============================================================
  // SELECTOR DE PERIODO
  // ============================================================

  Widget _selectorPeriodo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),

      decoration: BoxDecoration(
        color: AppColors.tarjeta,

        borderRadius: BorderRadius.circular(15),

        border: Border.all(color: AppColors.borde),
      ),

      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: periodoSeleccionado,

          dropdownColor: AppColors.tarjeta,

          isExpanded: true,

          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.naranja),

          style: const TextStyle(color: AppColors.crema, fontSize: 15),

          items: periodos.map((periodo) {
            return DropdownMenuItem<String>(
              value: periodo,

              child: Text(periodo),
            );
          }).toList(),

          onChanged: (valor) {
            if (valor == null) {
              return;
            }

            setState(() {
              periodoSeleccionado = valor;
            });

            filtrarPedidos();
          },
        ),
      ),
    );
  }

  // ============================================================
  // TARJETA DE UN DÍA
  // ============================================================

  Widget _tarjetaDia({
    required String fecha,
    required int cantidadPedidos,
    required double total,
  }) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 13),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: AppColors.tarjeta,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: AppColors.borde),
      ),

      child: Row(
        children: [
          // ======================================================
          // ICONO
          // ======================================================
          Container(
            width: 50,
            height: 50,

            decoration: BoxDecoration(
              color: AppColors.tarjetaClara,

              borderRadius: BorderRadius.circular(14),
            ),

            child: const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.naranja,
              size: 24,
            ),
          ),

          const SizedBox(width: 15),

          // ======================================================
          // INFORMACIÓN
          // ======================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  formatearFecha(fecha),

                  style: const TextStyle(
                    color: AppColors.crema,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  cantidadPedidos == 1
                      ? '1 pedido realizado'
                      : '$cantidadPedidos pedidos realizados',

                  style: const TextStyle(
                    color: AppColors.textoSecundario,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Total vendido: \$${total.toStringAsFixed(2)}',

                  style: const TextStyle(
                    color: AppColors.naranja,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SIN MOVIMIENTOS
  // ============================================================

  Widget _sinMovimientos() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),

      decoration: BoxDecoration(
        color: AppColors.tarjeta,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: AppColors.borde),
      ),

      child: const Column(
        children: [
          Icon(Icons.receipt_long_outlined, color: AppColors.naranja, size: 45),

          SizedBox(height: 14),

          Text(
            'Sin movimientos',

            style: TextStyle(
              color: AppColors.crema,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 6),

          Text(
            'No hay pedidos registrados en este periodo.',

            textAlign: TextAlign.center,

            style: TextStyle(color: AppColors.textoSecundario, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RESUMEN DEL PERIODO
  // ============================================================

  Widget _resumenPeriodo() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: AppColors.tarjeta,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: AppColors.borde),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Row(
            children: [
              Icon(Icons.assessment_outlined, color: AppColors.naranja),

              SizedBox(width: 10),

              Text(
                'Resumen del periodo',

                style: TextStyle(
                  color: AppColors.crema,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              const Text(
                'Pedidos realizados',

                style: TextStyle(color: AppColors.textoSecundario),
              ),

              Text(
                pedidosFiltrados.length.toString(),

                style: const TextStyle(
                  color: AppColors.crema,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Divider(color: AppColors.borde),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              const Text(
                'Total vendido',

                style: TextStyle(color: AppColors.textoSecundario),
              ),

              Text(
                '\$${totalPeriodo.toStringAsFixed(2)}',

                style: const TextStyle(
                  color: AppColors.naranja,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
