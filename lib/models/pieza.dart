class Pieza {
  final String id;
  final String nombre;
  final String descripcion;
  final String urlModelo3D;
  final String urlImagen;
  final String categoria;
  final String epoca;
  final String ubicacion;
  final double escala;
  final List<double> posicionInicial;
  final List<double> rotacionInicial;
  final Map<String, dynamic> metadatos;
  final bool esInteractivo;
  final List<String> animaciones;
  final String audioDescripcion;

  Pieza({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.urlModelo3D,
    required this.urlImagen,
    required this.categoria,
    required this.epoca,
    required this.ubicacion,
    this.escala = 1.0,
    this.posicionInicial = const [0.0, 0.0, 0.0],
    this.rotacionInicial = const [0.0, 0.0, 0.0],
    this.metadatos = const {},
    this.esInteractivo = true,
    this.animaciones = const [],
    this.audioDescripcion = '',
  });

  factory Pieza.fromJson(Map<String, dynamic> json) {
    return Pieza(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      urlModelo3D: json['urlModelo3D'] ?? '',
      urlImagen: json['urlImagen'] ?? '',
      categoria: json['categoria'] ?? '',
      epoca: json['epoca'] ?? '',
      ubicacion: json['ubicacion'] ?? '',
      escala: json['escala']?.toDouble() ?? 1.0,
      posicionInicial: List<double>.from(json['posicionInicial'] ?? [0.0, 0.0, 0.0]),
      rotacionInicial: List<double>.from(json['rotacionInicial'] ?? [0.0, 0.0, 0.0]),
      metadatos: json['metadatos'] ?? {},
      esInteractivo: json['esInteractivo'] ?? true,
      animaciones: List<String>.from(json['animaciones'] ?? []),
      audioDescripcion: json['audioDescripcion'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'urlModelo3D': urlModelo3D,
      'urlImagen': urlImagen,
      'categoria': categoria,
      'epoca': epoca,
      'ubicacion': ubicacion,
      'escala': escala,
      'posicionInicial': posicionInicial,
      'rotacionInicial': rotacionInicial,
      'metadatos': metadatos,
      'esInteractivo': esInteractivo,
      'animaciones': animaciones,
      'audioDescripcion': audioDescripcion,
    };
  }

  Pieza copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? urlModelo3D,
    String? urlImagen,
    String? categoria,
    String? epoca,
    String? ubicacion,
    double? escala,
    List<double>? posicionInicial,
    List<double>? rotacionInicial,
    Map<String, dynamic>? metadatos,
    bool? esInteractivo,
    List<String>? animaciones,
    String? audioDescripcion,
  }) {
    return Pieza(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      urlModelo3D: urlModelo3D ?? this.urlModelo3D,
      urlImagen: urlImagen ?? this.urlImagen,
      categoria: categoria ?? this.categoria,
      epoca: epoca ?? this.epoca,
      ubicacion: ubicacion ?? this.ubicacion,
      escala: escala ?? this.escala,
      posicionInicial: posicionInicial ?? this.posicionInicial,
      rotacionInicial: rotacionInicial ?? this.rotacionInicial,
      metadatos: metadatos ?? this.metadatos,
      esInteractivo: esInteractivo ?? this.esInteractivo,
      animaciones: animaciones ?? this.animaciones,
      audioDescripcion: audioDescripcion ?? this.audioDescripcion,
    );
  }
}
