class Pedido {
  final int? id;

  final int usuarioId;

  final String productos;

  final double total;

  final String estado;

  final String fecha;

  final String clienteNombre;

  Pedido({
    this.id,

    required this.usuarioId,

    required this.productos,

    required this.total,

    required this.estado,

    required this.fecha,

    this.clienteNombre = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'usuarioId': usuarioId,

      'productos': productos,

      'total': total,

      'estado': estado,

      'fecha': fecha,
    };
  }

  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      id: map['id'],

      usuarioId: map['usuarioId'] ?? 0,

      productos: map['productos'] ?? '',

      total: (map['total'] ?? 0).toDouble(),

      estado: map['estado'] ?? 'Pendiente',

      fecha: map['fecha'] ?? '',

      clienteNombre: map['clienteNombre'] ?? '',
    );
  }
}
