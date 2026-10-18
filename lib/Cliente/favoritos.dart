import 'package:flutter/material.dart';
import '../Styles/styles.dart';
import 'detalleProducto.dart';

class Favoritos extends StatefulWidget {
  const Favoritos({super.key});

  @override
  State<Favoritos> createState() => _FavoritosState();
}

class _FavoritosState extends State<Favoritos> {
  final List<Map<String, dynamic>> favoritos = [
    {
      'nombre': 'Tarta de Chocolate',
      'precio': 350.0,
      'categoria': 'Tartas',
      'icono': Icons.cake_outlined,
    },
    {
      'nombre': 'Brownie de Chocolate',
      'precio': 55.0,
      'categoria': 'Brownies',
      'icono': Icons.bakery_dining,
    },
    {
      'nombre': 'Cupcake de Chocolate',
      'precio': 45.0,
      'categoria': 'Cupcakes',
      'icono': Icons.cake,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        backgroundColor: AppColors.fondo,
        foregroundColor: AppColors.crema,
        elevation: 0,
        title: const Text(
          'Favoritos',
          style: TextStyle(color: AppColors.crema, fontWeight: FontWeight.bold),
        ),
      ),
      body: favoritos.isEmpty
          ? _favoritosVacios()
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tus favoritos', style: AppStyles.tituloGrande),

                  const SizedBox(height: 6),

                  const Text(
                    'Aquí encontrarás los productos que más te gustan.',
                    style: AppStyles.textoNormal,
                  ),

                  const SizedBox(height: 25),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: favoritos.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.72,
                        ),
                    itemBuilder: (context, index) {
                      final producto = favoritos[index];

                      return _productoFavorito(producto, index);
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _productoFavorito(Map<String, dynamic> producto, int index) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetalleProducto(categoria: producto['categoria']),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.tarjeta,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borde),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.tarjetaClara,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(19),
                      ),
                    ),
                    child: Icon(
                      producto['icono'],
                      size: 70,
                      color: AppColors.naranja,
                    ),
                  ),

                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.fondo.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            favoritos.removeAt(index);
                          });
                        },
                        icon: const Icon(
                          Icons.favorite,
                          color: AppColors.naranja,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto['categoria'],
                    style: const TextStyle(
                      color: AppColors.textoSecundario,
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    producto['nombre'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.crema,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '\$${producto['precio'].toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppColors.naranja,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _favoritosVacios() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, color: AppColors.naranja, size: 80),

            SizedBox(height: 20),

            Text(
              'Aún no tienes favoritos',
              textAlign: TextAlign.center,
              style: AppStyles.titulo,
            ),

            SizedBox(height: 10),

            Text(
              'Los productos que marques con corazón aparecerán aquí.',
              textAlign: TextAlign.center,
              style: AppStyles.textoNormal,
            ),
          ],
        ),
      ),
    );
  }
}
