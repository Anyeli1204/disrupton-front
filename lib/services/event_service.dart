import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/event.dart';

class EventService {
  static const String _baseUrl = '${ApiConfig.baseUrl}/events';

  // Obtener token de autenticación
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Headers para peticiones autenticadas
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  // Obtener todos los eventos activos (para usuarios)
  Future<List<Event>> getActiveEvents() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Event.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al cargar eventos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener todos los eventos incluyendo inactivos (para admin)
  Future<List<Event>> getAllEvents() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl?all=true'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Event.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para ver todos los eventos.');
      } else {
        throw Exception('Error al cargar eventos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener evento por ID
  Future<Event> getEventById(String eventId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/$eventId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Event.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Evento no encontrado.');
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al cargar evento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear evento (solo admin)
  Future<Event> createEvent(EventCreateRequest request) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Event.fromJson(jsonData);
      } else if (response.statusCode == 400) {
        throw Exception('Datos inválidos para crear el evento.');
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para crear eventos.');
      } else {
        throw Exception('Error al crear evento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar evento (solo admin)
  Future<Event> updateEvent(String eventId, EventUpdateRequest request) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/$eventId'),
        headers: headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Event.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Evento no encontrado.');
      } else if (response.statusCode == 400) {
        throw Exception('Datos inválidos para actualizar el evento.');
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para actualizar eventos.');
      } else {
        throw Exception('Error al actualizar evento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Eliminar evento (solo admin)
  Future<void> deleteEvent(String eventId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/$eventId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 404) {
        throw Exception('Evento no encontrado.');
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para eliminar eventos.');
      } else {
        throw Exception('Error al eliminar evento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Cambiar estado del evento (solo admin)
  Future<Event> toggleEventStatus(String eventId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/$eventId/toggle-status'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Event.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Evento no encontrado.');
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      } else if (response.statusCode == 403) {
        throw Exception(
            'No tienes permisos para cambiar el estado de eventos.');
      } else {
        throw Exception(
            'Error al cambiar estado del evento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener estadísticas de eventos (solo admin)
  Future<EventStats> getEventStats() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return EventStats.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para ver estadísticas de eventos.');
      } else {
        throw Exception('Error al cargar estadísticas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Filtrar eventos por tag
  List<Event> filterEventsByTag(List<Event> events, String tag) {
    if (tag.isEmpty) return events;
    return events
        .where((event) => event.tags.any(
            (eventTag) => eventTag.toLowerCase().contains(tag.toLowerCase())))
        .toList();
  }

  // Filtrar eventos por búsqueda de texto
  List<Event> searchEvents(List<Event> events, String query) {
    if (query.isEmpty) return events;
    final lowerQuery = query.toLowerCase();
    return events
        .where((event) =>
            event.title.toLowerCase().contains(lowerQuery) ||
            event.description.toLowerCase().contains(lowerQuery) ||
            event.location.toLowerCase().contains(lowerQuery) ||
            event.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)))
        .toList();
  }

  // Obtener eventos próximos (no pasados)
  List<Event> getUpcomingEvents(List<Event> events) {
    return events.where((event) => !event.isPastEvent).toList();
  }

  // Obtener eventos pasados
  List<Event> getPastEvents(List<Event> events) {
    return events.where((event) => event.isPastEvent).toList();
  }

  // Ordenar eventos por fecha
  List<Event> sortEventsByDate(List<Event> events, {bool ascending = true}) {
    final sortedEvents = List<Event>.from(events);
    sortedEvents.sort((a, b) {
      final comparison = a.dateTime.compareTo(b.dateTime);
      return ascending ? comparison : -comparison;
    });
    return sortedEvents;
  }

  // Obtener tags únicos de una lista de eventos
  List<String> getUniqueTags(List<Event> events) {
    final Set<String> tagsSet = {};
    for (final event in events) {
      tagsSet.addAll(event.tags);
    }
    final tags = tagsSet.toList();
    tags.sort();
    return tags;
  }

  // Validar datos de evento antes de enviar
  String? validateEventData(EventCreateRequest request) {
    if (request.title.trim().isEmpty) {
      return 'El título es obligatorio';
    }
    if (request.title.length < 3) {
      return 'El título debe tener al menos 3 caracteres';
    }
    if (request.description.trim().isEmpty) {
      return 'La descripción es obligatoria';
    }
    if (request.description.length < 10) {
      return 'La descripción debe tener al menos 10 caracteres';
    }
    if (request.location.trim().isEmpty) {
      return 'La ubicación es obligatoria';
    }
    if (request.dateTime.isBefore(DateTime.now())) {
      return 'La fecha del evento no puede ser en el pasado';
    }

    return null; // No hay errores
  }
}
