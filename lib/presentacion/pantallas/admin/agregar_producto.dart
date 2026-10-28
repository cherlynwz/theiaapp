import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../estilos/styles.dart';
import 'package:theiaapp/logica/productos_service.dart';
import '../../../modelos/producto.dart';
import 'package:theiaapp/logica/imagenes_service.dart';

class AgregarProducto extends StatefulWidget {
  const AgregarProducto({super.key});

  @override
  State<AgregarProducto> createState() => _AgregarProductoState();
}

class _AgregarProductoState extends State<AgregarProducto> {
  final ProductosService productosService = ProductosService();

  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final precioController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  // Ruta temporal de la imagen seleccionada desde la galería.
  String? imagenTemporal;

  String categoriaSeleccionada = 'Tartas';

  bool destacado = false;
  bool masPedido = false;
  bool guardando = false;

  final categorias = ['Tartas', 'Cupcakes', 'Galletas', 'Brownies', 'Macarons'];

  // =====================================================
  // SELECCIONAR IMAGEN DE LA GALERÍA
  // =====================================================

  Future<void> seleccionarImagen() async {
    try {
      final XFile? imagen = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (imagen == null) return;

      if (!mounted) return;

      setState(() {
        imagenTemporal = imagen.path;
      });
    } catch (e) {
      debugPrint('ERROR AL SELECCIONAR IMAGEN: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo seleccionar la imagen: $e')),
      );
    }
  }

  // =====================================================
  // GUARDAR PRODUCTO
  // =====================================================

  Future<void> guardarProducto() async {
    final nombre = nombreController.text.trim();
    final descripcion = descripcionController.text.trim();
    final precioTexto = precioController.text.trim();

    // ---------------- VALIDACIONES ----------------

    if (nombre.isEmpty || precioTexto.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Completa nombre y precio')));
      return;
    }

    final errorPrecio = ProductosService.validarPrecioTexto(precioTexto);

    if (errorPrecio != null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            backgroundColor: AppColors.tarjetaClara,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(18, 0, 18, 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            duration: const Duration(seconds: 2),
            content: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.naranja),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    errorPrecio,
                    style: const TextStyle(
                      color: AppColors.crema,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      return;
    }

    final precio = double.parse(precioTexto.replaceAll(',', '.'));

    if (imagenTemporal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una imagen del producto')),
      );
      return;
    }

    // =====================================================
    // VERIFICAR SI EL PRODUCTO YA EXISTE
    // =====================================================

    try {
      final productosExistentes = await productosService.obtenerProductos();

      final productoExiste = productosExistentes.any(
        (producto) =>
            producto.nombre.trim().toLowerCase() == nombre.trim().toLowerCase(),
      );

      if (productoExiste) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Este producto ya está registrado')),
        );

        return;
      }
    } catch (e) {
      debugPrint('ERROR AL CONSULTAR PRODUCTOS: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron consultar los productos: $e')),
      );

      return;
    }

    if (!mounted) return;

    setState(() {
      guardando = true;
    });

    try {
      // =====================================================
      // PASO 1: CREAR ARCHIVO DE IMAGEN
      // =====================================================

      debugPrint('PASO 1: preparando imagen...');

      final archivoImagen = File(imagenTemporal!);

      // =====================================================
      // PASO 2: SUBIR IMAGEN A CLOUDINARY
      // =====================================================

      debugPrint('PASO 2: subiendo imagen a Cloudinary...');

      final urlImagen = await ImagenesService.subirImagen(archivoImagen);

      debugPrint('PASO 3: imagen subida correctamente');
      debugPrint('URL IMAGEN: $urlImagen');

      // =====================================================
      // PASO 3: CREAR PRODUCTO
      // =====================================================

      final producto = Producto(
        nombre: nombre,
        descripcion: descripcion,
        precio: precio,
        categoria: categoriaSeleccionada,
        imagen: urlImagen,
        destacado: destacado ? 1 : 0,
        masPedido: masPedido ? 1 : 0,
      );

      debugPrint('PASO 4: objeto Producto creado');

      // =====================================================
      // PASO 4: GUARDAR PRODUCTO EN FIRESTORE
      // =====================================================

      debugPrint('PASO 5: guardando producto en Firestore...');

      await productosService.insertarProducto(producto);

      debugPrint('PASO 6: PRODUCTO GUARDADO CORRECTAMENTE');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto guardado correctamente')),
      );

      Navigator.pop(context, true);
    } catch (e, stackTrace) {
      debugPrint('======================================');
      debugPrint('ERROR REAL AL GUARDAR PRODUCTO');
      debugPrint('$e');
      debugPrint('STACKTRACE:');
      debugPrint('$stackTrace');
      debugPrint('======================================');

      if (!mounted) return;

      setState(() {
        guardando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo guardar el producto: $e'),
          duration: const Duration(seconds: 8),
        ),
      );
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    precioController.dispose();

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
          'Nuevo producto',
          style: TextStyle(color: AppColors.crema, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Información del producto',
              style: TextStyle(
                color: AppColors.crema,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Agrega los datos del nuevo producto.',
              style: TextStyle(color: AppColors.textoSecundario, fontSize: 14),
            ),

            const SizedBox(height: 22),

            // =====================================================
            // IMAGEN
            // =====================================================
            GestureDetector(
              onTap: seleccionarImagen,

              child: Container(
                width: double.infinity,
                height: 190,

                decoration: BoxDecoration(
                  color: AppColors.tarjeta,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borde),
                ),

                child: imagenTemporal == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            color: AppColors.naranja,
                            size: 52,
                          ),

                          SizedBox(height: 12),

                          Text(
                            'Seleccionar imagen',
                            style: TextStyle(
                              color: AppColors.crema,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            'Toca aquí para elegir desde tu galería',
                            style: TextStyle(
                              color: AppColors.textoSecundario,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(19),

                        child: Stack(
                          fit: StackFit.expand,

                          children: [
                            Image.file(
                              File(imagenTemporal!),
                              fit: BoxFit.cover,

                              errorBuilder: (context, error, stackTrace) {
                                return _imagenPredeterminada();
                              },
                            ),

                            Positioned(
                              right: 10,
                              bottom: 10,

                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(12),
                                ),

                                child: IconButton(
                                  onPressed: seleccionarImagen,

                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // =====================================================
            // NOMBRE
            // =====================================================
            _campo(
              controller: nombreController,
              texto: 'Nombre del producto',
              icono: Icons.cake_outlined,
            ),

            const SizedBox(height: 14),

            // =====================================================
            // DESCRIPCIÓN
            // =====================================================
            _campo(
              controller: descripcionController,
              texto: 'Descripción',
              icono: Icons.description_outlined,
              maxLines: 3,
            ),

            const SizedBox(height: 14),

            // =====================================================
            // PRECIO
            // =====================================================
            TextFormField(
              controller: precioController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (valor) {
                return ProductosService.validarPrecioTexto(valor ?? '');
              },
              maxLength: 7,
              style: const TextStyle(color: AppColors.crema),
              decoration: InputDecoration(
                labelText: 'Precio',
                helperText: 'De \$0.01 a \$2,000.00 MXN. Máximo 2 decimales.',
                helperMaxLines: 2,
                counterText: '',
                labelStyle: const TextStyle(color: AppColors.textoSecundario),
                helperStyle: const TextStyle(color: AppColors.textoSecundario),
                prefixIcon: const Icon(
                  Icons.attach_money,
                  color: AppColors.naranja,
                ),
                filled: true,
                fillColor: AppColors.tarjeta,
                errorMaxLines: 3,
                errorStyle: const TextStyle(color: Colors.redAccent),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: AppColors.borde),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: AppColors.naranja,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Colors.redAccent,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // =====================================================
            // CATEGORÍA
            // =====================================================
            const Text(
              'Categoría',
              style: TextStyle(
                color: AppColors.crema,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 9),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              decoration: BoxDecoration(
                color: AppColors.tarjeta,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.borde),
              ),

              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  dropdownColor: AppColors.tarjeta,

                  value: categoriaSeleccionada,

                  isExpanded: true,

                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.naranja,
                  ),

                  style: const TextStyle(color: AppColors.crema, fontSize: 16),

                  items: categorias.map((categoria) {
                    return DropdownMenuItem<String>(
                      value: categoria,
                      child: Text(categoria),
                    );
                  }).toList(),

                  onChanged: (valor) {
                    if (valor == null) return;

                    setState(() {
                      categoriaSeleccionada = valor;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 22),

            // =====================================================
            // OPCIONES
            // =====================================================
            const Text(
              'Opciones',
              style: TextStyle(
                color: AppColors.crema,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: AppColors.tarjeta,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borde),
              ),

              child: Column(
                children: [
                  SwitchListTile(
                    value: destacado,

                    onChanged: (valor) {
                      setState(() {
                        destacado = valor;
                      });
                    },

                    secondary: const Icon(
                      Icons.star_outline,
                      color: AppColors.naranja,
                    ),

                    title: const Text(
                      'Producto destacado',
                      style: TextStyle(
                        color: AppColors.crema,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    subtitle: const Text(
                      'Aparecerá en destacados del inicio',
                      style: TextStyle(
                        color: AppColors.textoSecundario,
                        fontSize: 12,
                      ),
                    ),

                    activeThumbColor: AppColors.naranja,
                  ),

                  Divider(height: 1, color: AppColors.borde),

                  SwitchListTile(
                    value: masPedido,

                    onChanged: (valor) {
                      setState(() {
                        masPedido = valor;
                      });
                    },

                    secondary: const Icon(
                      Icons.local_fire_department_outlined,
                      color: AppColors.naranja,
                    ),

                    title: const Text(
                      'Producto más pedido',
                      style: TextStyle(
                        color: AppColors.crema,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    subtitle: const Text(
                      'Aparecerá en la sección Más pedidos',
                      style: TextStyle(
                        color: AppColors.textoSecundario,
                        fontSize: 12,
                      ),
                    ),

                    activeThumbColor: AppColors.naranja,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // =====================================================
            // GUARDAR
            // =====================================================
            SizedBox(
              width: double.infinity,
              height: 56,

              child: ElevatedButton.icon(
                onPressed: guardando ? null : guardarProducto,

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.naranja,
                  foregroundColor: Colors.black,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),

                icon: guardando
                    ? const SizedBox(
                        width: 20,
                        height: 20,

                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(Icons.save_outlined),

                label: Text(
                  guardando ? 'GUARDANDO...' : 'GUARDAR PRODUCTO',

                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
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

  // =====================================================
  // CAMPO PERSONALIZADO
  // =====================================================

  Widget _campo({
    required TextEditingController controller,
    required String texto,
    required IconData icono,
    TextInputType? tipoTeclado,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,

      keyboardType: tipoTeclado,

      maxLines: maxLines,

      style: const TextStyle(color: AppColors.crema),

      decoration: InputDecoration(
        labelText: texto,

        alignLabelWithHint: maxLines > 1,

        labelStyle: const TextStyle(color: AppColors.textoSecundario),

        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 55 : 0),

          child: Icon(icono, color: AppColors.naranja),
        ),

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
          borderSide: const BorderSide(color: AppColors.naranja, width: 1.5),
        ),
      ),
    );
  }
}
