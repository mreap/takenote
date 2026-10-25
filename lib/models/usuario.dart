class Usuario {
  const Usuario({required this.id, required this.correo, required this.nombre});

  final int id;
  final String correo;
  final String nombre;

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    id: json['id'] as int,
    correo: json['correo'] as String,
    nombre: json['nombre'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'correo': correo,
    'nombre': nombre,
  };
}
