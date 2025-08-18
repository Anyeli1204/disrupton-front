class DestacadoComment {
  final String id;
  final String? culturalAgentId;
  final String? authorUserId;
  final String usuarioNombre;
  final String comentario;
  final double calificacion;
  final DateTime fecha;

  DestacadoComment({
    required this.id,
    this.culturalAgentId,
    this.authorUserId,
    required this.usuarioNombre,
    required this.comentario,
    required this.calificacion,
    required this.fecha,
  });

  factory DestacadoComment.fromJson(Map<String, dynamic> json) {
    return DestacadoComment(
      id: json['id'] as String? ?? '',
      culturalAgentId: json['culturalAgentId'] as String?,
      authorUserId: json['authorUserId'] as String?,
      usuarioNombre: json['usuarioNombre'] as String? ?? '',
      comentario: json['comentario'] as String? ?? '',
      calificacion: (json['calificacion'] as num?)?.toDouble() ?? 0.0,
      fecha: json['fecha'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['fecha']['seconds'] as int) * 1000)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'culturalAgentId': culturalAgentId,
      'authorUserId': authorUserId,
      'usuarioNombre': usuarioNombre,
      'comentario': comentario,
      'calificacion': calificacion,
      'fecha': {
        'seconds': fecha.millisecondsSinceEpoch ~/ 1000,
        'nanos': (fecha.microsecondsSinceEpoch % 1000) * 1000,
      },
    };
  }
}
