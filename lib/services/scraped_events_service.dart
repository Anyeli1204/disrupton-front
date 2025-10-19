import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/scraped_event.dart';

/// Servicio para consumir eventos culturales del microservicio de scraping
class ScrapedEventsService {
  static const String _baseUrl = '${ApiConfig.baseUrl}/events/scraped';

  /// Obtiene todos los eventos culturales scrapeados
  Future<List<ScrapedEvent>> getAllScrapedEvents() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['events'] != null) {
          final List<dynamic> eventsJson = jsonResponse['events'];
          return eventsJson.map((json) => ScrapedEvent.fromJson(json)).toList();
        } else {
          throw Exception('Formato de respuesta inválido');
        }
      } else if (response.statusCode == 503) {
        throw Exception(
            'El servicio de eventos no está disponible. Por favor, intenta más tarde.');
      } else {
        throw Exception('Error al cargar eventos: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtiene un evento específico por ID
  Future<ScrapedEvent> getScrapedEventById(int eventId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$eventId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['event'] != null) {
          return ScrapedEvent.fromJson(jsonResponse['event']);
        } else {
          throw Exception('Evento no encontrado');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Evento no encontrado');
      } else if (response.statusCode == 503) {
        throw Exception(
            'El servicio de eventos no está disponible. Por favor, intenta más tarde.');
      } else {
        throw Exception('Error al cargar el evento: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtiene estadísticas de eventos por categoría
  Future<Map<String, dynamic>> getEventsStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          return {
            'total_events': jsonResponse['total_events'] ?? 0,
            'categories': jsonResponse['categories'] ?? {},
            'last_scrape': jsonResponse['last_scrape'] ?? '',
          };
        } else {
          throw Exception('Formato de respuesta inválido');
        }
      } else {
        throw Exception('Error al cargar estadísticas: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de conexión: $e');
    }
  }

  /// Verifica la salud del microservicio de scraping
  Future<bool> checkServiceHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ========================================
  // MÉTODOS DE UTILIDAD PARA FILTRADO
  // ========================================

  /// Filtra eventos por búsqueda de texto
  List<ScrapedEvent> searchEvents(List<ScrapedEvent> events, String query) {
    if (query.isEmpty) return events;

    final lowerQuery = query.toLowerCase();
    return events.where((event) {
      return event.titulo.toLowerCase().contains(lowerQuery) ||
          event.descripcion.toLowerCase().contains(lowerQuery) ||
          event.lugar.toLowerCase().contains(lowerQuery) ||
          event.categoria.toLowerCase().contains(lowerQuery) ||
          event.organizador.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Filtra eventos por categoría
  List<ScrapedEvent> filterEventsByCategory(
      List<ScrapedEvent> events, String category) {
    if (category.isEmpty) return events;
    return events
        .where(
            (event) => event.categoria.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// Obtiene solo eventos futuros
  List<ScrapedEvent> getUpcomingEvents(List<ScrapedEvent> events) {
    return events.where((event) => !event.isPastEvent).toList();
  }

  /// Obtiene solo eventos pasados
  List<ScrapedEvent> getPastEvents(List<ScrapedEvent> events) {
    return events.where((event) => event.isPastEvent).toList();
  }

  /// Ordena eventos por fecha
  List<ScrapedEvent> sortEventsByDate(List<ScrapedEvent> events,
      {bool ascending = true}) {
    final sorted = List<ScrapedEvent>.from(events);
    sorted.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.fecha);
        final dateB = DateTime.parse(b.fecha);
        return ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });
    return sorted;
  }

  /// Obtiene las categorías únicas de una lista de eventos
  List<String> getUniqueCategories(List<ScrapedEvent> events) {
    final categories = events.map((e) => e.categoria).toSet().toList();
    categories.sort();
    return categories;
  }

  /// Agrupa eventos por categoría
  Map<String, List<ScrapedEvent>> groupEventsByCategory(
      List<ScrapedEvent> events) {
    final Map<String, List<ScrapedEvent>> grouped = {};

    for (var event in events) {
      if (!grouped.containsKey(event.categoria)) {
        grouped[event.categoria] = [];
      }
      grouped[event.categoria]!.add(event);
    }

    return grouped;
  }

  /// Obtiene eventos en un rango de fechas
  List<ScrapedEvent> filterEventsByDateRange(
      List<ScrapedEvent> events, DateTime startDate, DateTime endDate) {
    return events.where((event) {
      try {
        final eventDate = DateTime.parse(event.fecha);
        return eventDate.isAfter(startDate) && eventDate.isBefore(endDate);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  /// Obtiene eventos del mes actual
  List<ScrapedEvent> getEventsThisMonth(List<ScrapedEvent> events) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return filterEventsByDateRange(events, startOfMonth, endOfMonth);
  }

  /// Obtiene eventos de esta semana
  List<ScrapedEvent> getEventsThisWeek(List<ScrapedEvent> events) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek =
        startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59));

    return filterEventsByDateRange(events, startOfWeek, endOfWeek);
  }
}
