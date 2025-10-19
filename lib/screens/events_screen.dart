import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../utils/image_helper.dart';
import '../core/theme/app_colors.dart';
import 'event_detail_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventService _eventService = EventService();
  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  List<String> _availableTags = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedTag = '';
  bool _showOnlyUpcoming = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final events = await _eventService.getActiveEvents();

      if (mounted) {
        setState(() {
          _allEvents = events;
          _availableTags = _eventService.getUniqueTags(events);
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    List<Event> filtered = List.from(_allEvents);

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = _eventService.searchEvents(filtered, _searchQuery);
    }

    // Filtrar por tag
    if (_selectedTag.isNotEmpty) {
      filtered = _eventService.filterEventsByTag(filtered, _selectedTag);
    }

    // Filtrar por eventos próximos/pasados
    if (_showOnlyUpcoming) {
      filtered = _eventService.getUpcomingEvents(filtered);
    }

    // Ordenar por fecha
    filtered = _eventService.sortEventsByDate(filtered, ascending: true);

    setState(() {
      _filteredEvents = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _onTagSelected(String tag) {
    setState(() {
      _selectedTag = tag == _selectedTag ? '' : tag;
    });
    _applyFilters();
  }

  void _toggleShowUpcoming() {
    setState(() {
      _showOnlyUpcoming = !_showOnlyUpcoming;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Eventos Culturales',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black87,
            fontFamily: 'RobotoMono',
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showOnlyUpcoming
                  ? Icons.upcoming_outlined
                  : Icons.history_outlined,
              color: AppColors.primary,
            ),
            onPressed: _toggleShowUpcoming,
            tooltip: _showOnlyUpcoming
                ? 'Ver todos los eventos'
                : 'Solo próximos eventos',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _errorMessage != null
              ? _buildErrorWidget()
              : _buildEventsList(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Error al cargar eventos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                fontFamily: 'RobotoMono',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontFamily: 'RobotoMono',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadEvents,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text(
                'Intentar nuevamente',
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    return Column(
      children: [
        _buildSearchAndFilters(),
        Expanded(
          child:
              _filteredEvents.isEmpty ? _buildEmptyState() : _buildEventsGrid(),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar eventos culturales...',
              hintStyle: const TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 14,
                color: Colors.black38,
              ),
              prefixIcon:
                  const Icon(Icons.search_rounded, color: AppColors.primary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded,
                          color: Colors.black38),
                      onPressed: () => _onSearchChanged(''),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: const TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 14,
            ),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 16),

          // Filtros por tags
          if (_availableTags.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Categorías:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  fontFamily: 'RobotoMono',
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _availableTags.length,
                itemBuilder: (context, index) {
                  final tag = _availableTags[index];
                  final isSelected = tag == _selectedTag;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(
                        tag,
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected ? AppColors.primary : Colors.black54,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) => _onTagSelected(tag),
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.primary.withOpacity(0.15),
                      checkmarkColor: AppColors.primary,
                      side: BorderSide(
                        color:
                            isSelected ? AppColors.primary : Colors.grey[300]!,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _showOnlyUpcoming
                    ? Icons.event_busy_rounded
                    : Icons.search_off_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _showOnlyUpcoming
                  ? 'No hay eventos próximos'
                  : 'No se encontraron eventos',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                fontFamily: 'RobotoMono',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _showOnlyUpcoming
                  ? 'Intenta ver todos los eventos o revisa más tarde'
                  : 'Intenta ajustar los filtros de búsqueda',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontFamily: 'RobotoMono',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (_showOnlyUpcoming) {
                  _toggleShowUpcoming();
                } else {
                  setState(() {
                    _searchQuery = '';
                    _selectedTag = '';
                  });
                  _applyFilters();
                }
              },
              icon: Icon(
                _showOnlyUpcoming
                    ? Icons.calendar_month_rounded
                    : Icons.filter_alt_off_rounded,
                size: 20,
              ),
              label: Text(
                _showOnlyUpcoming ? 'Ver todos los eventos' : 'Limpiar filtros',
                style: const TextStyle(
                  fontFamily: 'RobotoMono',
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsGrid() {
    return RefreshIndicator(
      onRefresh: _loadEvents,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: _filteredEvents.length,
        itemBuilder: (context, index) {
          final event = _filteredEvents[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildEventCard(event, index),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(Event event, int index) {
    return GestureDetector(
      onTap: () => _navigateToEventDetail(event),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: AppColors.primary.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Imagen del evento
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: SizedBox(
                width: 120,
                height: double.infinity,
                child: Image.asset(
                  ImageHelper.getEventImage(index),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholderImage(),
                ),
              ),
            ),

            // Contenido del evento
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Título
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.black87,
                        fontFamily: 'RobotoMono',
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Información inferior
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fecha y estado
                        Row(
                          children: [
                            Icon(
                              event.isPastEvent
                                  ? Icons.history_rounded
                                  : Icons.event_rounded,
                              size: 15,
                              color: event.isPastEvent
                                  ? Colors.grey[500]
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                event.isPastEvent
                                    ? 'Evento pasado'
                                    : event.timeUntilEvent,
                                style: TextStyle(
                                  color: event.isPastEvent
                                      ? Colors.grey[600]
                                      : AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  fontFamily: 'RobotoMono',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Ubicación
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 15,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                event.location,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 12,
                                  fontFamily: 'RobotoMono',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Indicador visual a la derecha
            Container(
              width: 4,
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: event.isPastEvent ? Colors.grey[300] : AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: Icon(
        Icons.event_rounded,
        size: 48,
        color: AppColors.primary.withOpacity(0.4),
      ),
    );
  }

  void _navigateToEventDetail(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(event: event),
      ),
    );
  }
}
