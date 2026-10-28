import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../estilos/styles.dart';
import '../../../modelos/producto.dart';
import 'package:theiaapp/logica/productos_service.dart';
import 'package:theiaapp/logica/imagenes_service.dart';

class EditarProducto extends StatefulWidget {
  final Producto producto;

  const EditarProducto({super.key, required this.producto});

  @override
  State<EditarProducto> createState() => _EditarProductoState();
}

class _EditarProductoState extends State<EditarProducto> {
  final ProductosService productosService = ProductosService();

  late TextEditingController nombreController;
  late TextEditingController descripcionController;
  late TextEditingController precioController;

  late String categoria;
  late bool destacado;
  late bool masPedido;

  // Imagen nueva seleccionada desde la galería.
  // Si permanece null, se conserva la imagen actual.
  String? imagenNueva;

  bool guardando = false;

  final ImagePicker picker = ImagePicker();

  final categorias = ['Tartas', 'Cupcakes', 'Galletas', 'Brownies', 'Macarons'];

  @override
  void initState() {
    super.initState();

    nombreController = TextEditingController(text: widget.producto.nombre);

    descripcionController = TextEditingController(
      text: widget.producto.descripcion,
    );

    precioController = TextEditingController(
      text: widget.producto.precio.toString(),
    );

    categoria = widget.producto.categoria;

    destacado = widget.producto.destacado == 1;

    masPedido = widget.producto.masPedido == 1;
  }

  // =========================================================
  // SELECCIONAR NUEVA IMAGEN
  // =========================================================

  Future<void> seleccionarImagen() async {
    try {
      final XFile? imagen = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (imagen == null) return;

      if (!mounted) return;

      setState(() {
        imagenNueva = imagen.path;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo seleccionar la imagen: $e')),
      );
    }
  }

  // =========================================================
  // GUARDAR CAMBIOS
  // =========================================================

  Future<void> guardarCambios() async {
    final nombre = nombreController.text.trim();
    final descripcion = descripcionController.text.trim();
    final precioTexto = precioController.text.trim();

    // =====================================================
    // VALIDACIONES
    // =====================================================

    if (nombre.isEmpty) {
      mostrarMensaje('Escribe el nombre del producto');
      return;
    }

    if (descripcion.isEmpty) {
      mostrarMensaje('Escribe una descripción');
      return;
    }

    if (precioTexto.isEmpty) {
      mostrarMensaje('Escribe el precio del producto');
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

    if (!mounted) return;

    setState(() {
      guardando = true;
    });

    try {
      // =====================================================
      // CONSERVAR IMAGEN ACTUAL
      // =====================================================

      String urlImagen = widget.producto.imagen;

      // =====================================================
      // SI SE SELECCIONÓ UNA NUEVA IMAGEN
      // =====================================================

      if (imagenNueva != null) {
        debugPrint('======================================');
        debugPrint('EDITAR PRODUCTO');
        debugPrint('PASO 1: nueva imagen seleccionada');
        debugPrint('======================================');

        final archivoImagen = File(imagenNueva!);

        debugPrint('PASO 2: subiendo imagen a Cloudinary...');

        urlImagen = await ImagenesService.subirImagen(archivoImagen);

        debugPrint('PASO 3: imagen subida correctamente');
        debugPrint('URL NUEVA: $urlImagen');
      } else {
        debugPrint('======================================');
        debugPrint('EDITAR PRODUCTO');
        debugPrint('No se seleccionó una nueva imagen.');
        debugPrint('Se conserva la imagen actual.');
        debugPrint('======================================');
      }

      // =====================================================
      // CREAR PRODUCTO ACTUALIZADO
      // =====================================================

      final productoActualizado = Producto(
        id: widget.producto.id,
        nombre: nombre,
        descripcion: descripcion,
        precio: precio,
        categoria: categoria,
        imagen: urlImagen,
        destacado: destacado ? 1 : 0,
        masPedido: masPedido ? 1 : 0,
      );

      debugPrint('PASO 4: producto actualizado creado');

      // =====================================================
      // ACTUALIZAR PRODUCTO
      // =====================================================

      debugPrint('PASO 5: actualizando producto...');

      await productosService.actualizarProducto(productoActualizado);

      debugPrint('PASO 6: PRODUCTO ACTUALIZADO CORRECTAMENTE');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cambios guardados correctamente')),
      );

      Navigator.pop(context, true);
    } catch (e, stackTrace) {
      debugPrint('======================================');
      debugPrint('ERROR AL EDITAR PRODUCTO');
      debugPrint('ERROR: $e');
      debugPrint('STACKTRACE:');
      debugPrint('$stackTrace');
      debugPrint('======================================');

      if (!mounted) return;

      setState(() {
        guardando = false;
      });

      final mensaje = e is ProductoDuplicadoException
          ? 'Ya existe otro producto con ese nombre.'
          : 'No se pudieron guardar los cambios. Intenta nuevamente.';

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
                    mensaje,
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
    }
  }

  // =========================================================
  // MOSTRAR MENSAJE
  // =========================================================

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // =========================================================
  // PANTALLA
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,

      appBar: AppBar(
        backgroundColor: AppColors.fondo,
        foregroundColor: AppColors.crema,
        elevation: 0,

        title: const Text(
          'Editar producto',
          style: TextStyle(color: AppColors.crema, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text('Modificar producto', style: AppStyles.tituloGrande),

            const SizedBox(height: 8),

            const Text(
              'Actualiza la información del producto',
              style: AppStyles.textoNormal,
            ),

            const SizedBox(height: 25),

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
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borde),
                ),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),

                  child: Stack(
                    fit: StackFit.expand,

                    children: [
                      // Imagen actual o nueva
                      _mostrarImagen(),

                      // Barra inferior
                      Align(
                        alignment: Alignment.bottomCenter,

                        child: Container(
                          height: 55,

                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                          ),

                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                Icon(
                                  Icons.photo_library_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),

                                SizedBox(width: 8),

                                Text(
                                  'Cambiar imagen',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // =====================================================
            // NOMBRE
            // =====================================================
            _campo(
              nombreController,
              'Nombre del producto',
              Icons.cake_outlined,
            ),

            const SizedBox(height: 15),

            // =====================================================
            // DESCRIPCIÓN
            // =====================================================
            _campo(
              descripcionController,
              'Descripción',
              Icons.description_outlined,
              maxLines: 3,
            ),

            const SizedBox(height: 15),

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
                helperText: 'De \$0.01 a \$2,000.00 MXN.',
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

            const SizedBox(height: 20),

            // =====================================================
            // CATEGORÍA
            // =====================================================
            const Text(
              'Categoría',
              style: TextStyle(
                color: AppColors.crema,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),

              decoration: BoxDecoration(
                color: AppColors.tarjeta,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.borde),
              ),

              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: categoria,

                  isExpanded: true,

                  dropdownColor: AppColors.tarjeta,

                  style: const TextStyle(color: AppColors.crema),

                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.naranja,
                  ),

                  items: categorias.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),

                  onChanged: (valor) {
                    if (valor == null) return;

                    setState(() {
                      categoria = valor;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =====================================================
            // OPCIONES
            // =====================================================
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

                    activeThumbColor: AppColors.naranja,

                    title: const Text(
                      'Producto destacado',
                      style: TextStyle(
                        color: AppColors.crema,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    subtitle: const Text(
                      'Aparecerá en productos destacados',
                      style: TextStyle(
                        color: AppColors.textoSecundario,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  Divider(height: 1, color: AppColors.borde),

                  SwitchListTile(
                    value: masPedido,

                    onChanged: (valor) {
                      setState(() {
                        masPedido = valor;
                      });
                    },

                    activeThumbColor: AppColors.naranja,

                    title: const Text(
                      'Producto más pedido',
                      style: TextStyle(
                        color: AppColors.crema,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    subtitle: const Text(
                      'Aparecerá en la sección de más pedidos',
                      style: TextStyle(
                        color: AppColors.textoSecundario,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // =====================================================
            // GUARDAR
            // =====================================================
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: guardando ? null : guardarCambios,

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.naranja,

                  foregroundColor: Colors.black,

                  disabledBackgroundColor: AppColors.naranja.withValues(
                    alpha: 0.5,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),

                child: guardando
                    ? const SizedBox(
                        width: 23,
                        height: 23,

                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'GUARDAR CAMBIOS',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // MOSTRAR IMAGEN
  // =========================================================

  Widget _mostrarImagen() {
    // =====================================================
    // 1. IMAGEN NUEVA SELECCIONADA
    // =====================================================

    if (imagenNueva != null) {
      return Image.file(
        File(imagenNueva!),

        fit: BoxFit.cover,

        errorBuilder: (context, error, stackTrace) {
          return _imagenPredeterminada();
        },
      );
    }

    // =====================================================
    // 2. IMAGEN ACTUAL
    // =====================================================

    final rutaActual = widget.producto.imagen.trim();

    if (rutaActual.isEmpty) {
      return _imagenPredeterminada();
    }

    // =====================================================
    // 3. IMAGEN DE CLOUDINARY
    // =====================================================

    if (rutaActual.startsWith('http://') || rutaActual.startsWith('https://')) {
      return Image.network(
        rutaActual,

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
          return _imagenPredeterminada();
        },
      );
    }

    // =====================================================
    // 4. COMPATIBILIDAD CON IMÁGENES LOCALES ANTIGUAS
    // =====================================================

    final archivo = File(rutaActual);

    if (!archivo.existsSync()) {
      return _imagenPredeterminada();
    }

    return Image.file(
      archivo,

      fit: BoxFit.cover,

      errorBuilder: (context, error, stackTrace) {
        return _imagenPredeterminada();
      },
    );
  }

  // =========================================================
  // IMAGEN PREDETERMINADA
  // =========================================================

  Widget _imagenPredeterminada() {
    return Container(
      color: AppColors.tarjetaClara,

      child: const Center(
        child: Icon(Icons.cake_outlined, color: AppColors.naranja, size: 60),
      ),
    );
  }

  // =========================================================
  // CAMPOS
  // =========================================================

  Widget _campo(
    TextEditingController controller,
    String texto,
    IconData icono, {
    int maxLines = 1,
    bool esPrecio = false,
  }) {
    return TextField(
      controller: controller,

      maxLines: maxLines,

      keyboardType: esPrecio
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,

      style: const TextStyle(color: AppColors.crema),

      decoration: InputDecoration(
        labelText: texto,

        labelStyle: const TextStyle(color: AppColors.textoSecundario),

        prefixIcon: Icon(icono, color: AppColors.naranja),

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

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    precioController.dispose();

    super.dispose();
  }
}
