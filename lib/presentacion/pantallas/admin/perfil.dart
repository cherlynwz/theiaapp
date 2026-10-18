import 'package:flutter/material.dart';
import '../../estilos/styles.dart';

class PerfilAdmin extends StatelessWidget {
  const PerfilAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.fondo,
      body: Center(child: Text('Pedidos', style: AppStyles.tituloGrande)),
    );
  }
}
