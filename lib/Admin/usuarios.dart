import 'package:flutter/material.dart';

import '../Styles/styles.dart';

import '../BaseDatos/usuarioDAO.dart';

import '../Modelos/usuario.dart';

class UsuariosAdmin extends StatefulWidget {
  const UsuariosAdmin({super.key});

  @override
  State<UsuariosAdmin> createState() => _UsuariosAdminState();
}

class _UsuariosAdminState extends State<UsuariosAdmin> {
  final TextEditingController buscarController = TextEditingController();

  final UsuarioDAO usuarioDAO = UsuarioDAO();

  List<Usuario> usuarios = [];

  @override
  void initState() {
    super.initState();

    cargarUsuarios();
  }

  Future<void> cargarUsuarios() async {
    final datos = await usuarioDAO.listarClientes();

    setState(() {
      usuarios = datos;
    });
  }

  List<Usuario> get usuariosFiltrados {
    String texto = buscarController.text.toLowerCase();

    if (texto.isEmpty) {
      return usuarios;
    }

    return usuarios.where((usuario) {
      return usuario.nombre.toLowerCase().contains(texto) ||
          usuario.correo.toLowerCase().contains(texto);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,

      appBar: AppBar(
        backgroundColor: AppColors.fondo,

        elevation: 0,

        title: const Text(
          'Usuarios registrados',

          style: TextStyle(color: AppColors.crema, fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text('Clientes', style: AppStyles.tituloGrande),

            const SizedBox(height: 8),

            const Text(
              'Lista de usuarios registrados en THEIA',

              style: AppStyles.textoNormal,
            ),

            const SizedBox(height: 25),

            TextField(
              controller: buscarController,

              onChanged: (valor) {
                setState(() {});
              },

              style: const TextStyle(color: AppColors.crema),

              decoration: InputDecoration(
                hintText: 'Buscar usuario...',

                hintStyle: const TextStyle(color: AppColors.textoSecundario),

                prefixIcon: const Icon(Icons.search, color: AppColors.naranja),

                filled: true,

                fillColor: AppColors.tarjeta,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),

                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 25),

            Expanded(
              child: ListView.builder(
                itemCount: usuariosFiltrados.length,

                itemBuilder: (context, index) {
                  final usuario = usuariosFiltrados[index];

                  return _usuarioCard(usuario);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _usuarioCard(Usuario usuario) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.tarjeta,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: AppColors.borde),
      ),

      child: Row(
        children: [
          Container(
            width: 55,

            height: 55,

            decoration: BoxDecoration(
              color: AppColors.tarjetaClara,

              shape: BoxShape.circle,
            ),

            child: const Icon(Icons.person, color: AppColors.naranja, size: 30),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  usuario.nombre,

                  style: const TextStyle(
                    color: AppColors.crema,

                    fontSize: 17,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  usuario.correo,

                  style: const TextStyle(
                    color: AppColors.textoSecundario,

                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  usuario.telefono,

                  style: const TextStyle(
                    color: AppColors.textoSecundario,

                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
