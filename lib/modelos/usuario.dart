class Usuario {
  final int? id;

  final String nombre;

  final String correo;

  final String password;

  final String telefono;

  final String rol;

  Usuario({
    this.id,

    required this.nombre,

    required this.correo,

    required this.password,

    required this.telefono,

    required this.rol,
  });

  // Convertir objeto Usuario a mapa para SQLite

  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'nombre': nombre,

      'correo': correo,

      'password': password,

      'telefono': telefono,

      'rol': rol,
    };
  }

  // Convertir datos de SQLite a Usuario

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],

      nombre: map['nombre'],

      correo: map['correo'],

      password: map['password'],

      telefono: map['telefono'] ?? '',

      rol: map['rol'],
    );
  }
}
