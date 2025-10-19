import 'package:intl/intl.dart';

/// Modelo para eventos culturales obtenidos del microservicio de scraping
class ScrapedEvent {
  final int id;
  final String titulo;
  final String descripcion;
  final String fecha; // Formato: YYYY-MM-DD
  final String lugar;
  final String fuenteUrl;
  final String fechaScrapeo;
  final String? imagenUrl;
  final String categoria;
  final String precio;
  final String organizador;

  ScrapedEvent({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.lugar,
    required this.fuenteUrl,
    required this.fechaScrapeo,
    this.imagenUrl,
    required this.categoria,
    required this.precio,
    required this.organizador,
  });

  /// Convierte desde JSON del microservicio
  factory ScrapedEvent.fromJson(Map<String, dynamic> json) {
    return ScrapedEvent(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      fecha: json['fecha'] ?? '',
      lugar: json['lugar'] ?? '',
      fuenteUrl: json['fuente_url'] ?? '',
      fechaScrapeo: json['fecha_scrapeo'] ?? '',
      imagenUrl: json['imagen_url'],
      categoria: json['categoria'] ?? '',
      precio: json['precio'] ?? 'No especificado',
      organizador: json['organizador'] ?? '',
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha': fecha,
      'lugar': lugar,
      'fuente_url': fuenteUrl,
      'fecha_scrapeo': fechaScrapeo,
      'imagen_url': imagenUrl,
      'categoria': categoria,
      'precio': precio,
      'organizador': organizador,
    };
  }

  /// Obtiene la fecha como DateTime
  DateTime get fechaDateTime {
    try {
      return DateTime.parse(fecha);
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Obtiene la fecha formateada para mostrar
  String get fechaFormateada {
    try {
      final dt = DateTime.parse(fecha);
      return DateFormat('dd/MM/yyyy', 'es').format(dt);
    } catch (e) {
      return fecha;
    }
  }

  /// Obtiene el día del mes
  String get dia {
    try {
      final dt = DateTime.parse(fecha);
      return DateFormat('dd').format(dt);
    } catch (e) {
      return '00';
    }
  }

  /// Obtiene el mes abreviado
  String get mes {
    try {
      final dt = DateTime.parse(fecha);
      return DateFormat('MMM', 'es').format(dt).toUpperCase();
    } catch (e) {
      return 'MES';
    }
  }

  /// Verifica si el evento ya pasó
  bool get isPastEvent {
    try {
      final eventDate = DateTime.parse(fecha);
      return eventDate.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  /// Calcula el tiempo hasta el evento
  String get timeUntilEvent {
    try {
      final eventDate = DateTime.parse(fecha);
      final now = DateTime.now();
      final difference = eventDate.difference(now);

      if (difference.isNegative) {
        return 'Evento pasado';
      } else if (difference.inDays == 0) {
        return 'Hoy';
      } else if (difference.inDays == 1) {
        return 'Mañana';
      } else if (difference.inDays < 7) {
        return 'En ${difference.inDays} días';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return weeks == 1 ? 'En 1 semana' : 'En $weeks semanas';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return months == 1 ? 'En 1 mes' : 'En $months meses';
      } else {
        return 'En ${(difference.inDays / 365).floor()} años';
      }
    } catch (e) {
      return 'Fecha no disponible';
    }
  }

  /// Obtiene un tag basado en la categoría
  List<String> get tags {
    return [categoria];
  }

  /// Copia el evento con algunos campos modificados
  ScrapedEvent copyWith({
    int? id,
    String? titulo,
    String? descripcion,
    String? fecha,
    String? lugar,
    String? fuenteUrl,
    String? fechaScrapeo,
    String? imagenUrl,
    String? categoria,
    String? precio,
    String? organizador,
  }) {
    return ScrapedEvent(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
      lugar: lugar ?? this.lugar,
      fuenteUrl: fuenteUrl ?? this.fuenteUrl,
      fechaScrapeo: fechaScrapeo ?? this.fechaScrapeo,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      categoria: categoria ?? this.categoria,
      precio: precio ?? this.precio,
      organizador: organizador ?? this.organizador,
    );
  }

  @override
  String toString() {
    return 'ScrapedEvent{id: $id, titulo: $titulo, fecha: $fecha, categoria: $categoria}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ScrapedEvent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
