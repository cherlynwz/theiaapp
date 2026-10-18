import 'package:flutter/material.dart';

class AppColors {
  // Fondos
  static const fondo = Color(0xFFFBEDE3);
  static const fondoSecundario = Color(0xFFF2D8C7);

  // Tarjetas
  static const tarjeta = Color(0xFFFFFFFF);
  static const tarjetaClara = Color(0xFFFFF8F5);

  // Color principal / acentos
  static const naranja = Color(0xFFD99A88);
  static const naranjaOscuro = Color(0xFFB97865);

  // Textos
  static const crema = Color(0xFF70452F);
  static const textoSecundario = Color(0xFF8C756A);

  // Bordes
  static const borde = Color(0xFFE8D5CA);

  static const blanco = Colors.white;
  static const negro = Colors.black;
}

class AppStyles {
  static const tituloGrande = TextStyle(
    color: AppColors.crema,
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );

  static const titulo = TextStyle(
    color: AppColors.crema,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const textoNormal = TextStyle(
    color: AppColors.textoSecundario,
    fontSize: 14,
  );

  static const textoBoton = TextStyle(
    color: AppColors.crema,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}
