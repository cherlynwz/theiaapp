class Producto {
  final int? id;

  final String nombre;

  final String descripcion;

  final double precio;

  final String categoria;

  final String imagen;

  final int destacado;

  final int masPedido;

  Producto({
    this.id,

    required this.nombre,

    required this.descripcion,

    required this.precio,

    required this.categoria,

    required this.imagen,

    required this.destacado,

    required this.masPedido,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'nombre': nombre,

      'descripcion': descripcion,

      'precio': precio,

      'categoria': categoria,

      'imagen': imagen,

      'destacado': destacado,

      'masPedido': masPedido,
    };
  }

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'],

      nombre: map['nombre'],

      descripcion: map['descripcion'] ?? '',

      precio: map['precio'],

      categoria: map['categoria'] ?? '',

      imagen: map['imagen'] ?? '',

      destacado: map['destacado'] ?? 0,

      masPedido: map['masPedido'] ?? 0,
    );
  }
}
