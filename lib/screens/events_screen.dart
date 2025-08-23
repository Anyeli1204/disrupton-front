import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';
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

      setState(() {
        _allEvents = events;
        _availableTags = _eventService.getUniqueTags(events);
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
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
      appBar: AppBar(
        title: const Text('Eventos'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showOnlyUpcoming ? Icons.upcoming : Icons.history),
            onPressed: _toggleShowUpcoming,
            tooltip: _showOnlyUpcoming
                ? 'Ver todos los eventos'
                : 'Solo próximos eventos',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : _buildEventsList(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar eventos',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEvents,
              child: const Text('Intentar nuevamente'),
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
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar eventos...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _onSearchChanged(''),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 12),

          // Filtros por tags
          if (_availableTags.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Categorías:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _availableTags.length,
                itemBuilder: (context, index) {
                  final tag = _availableTags[index];
                  final isSelected = tag == _selectedTag;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (_) => _onTagSelected(tag),
                      backgroundColor: Colors.white,
                      selectedColor: Colors.orange.withOpacity(0.2),
                      checkmarkColor: Colors.orange,
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
            Icon(
              _showOnlyUpcoming ? Icons.event_busy : Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _showOnlyUpcoming
                  ? 'No hay eventos próximos'
                  : 'No se encontraron eventos',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _showOnlyUpcoming
                  ? 'Intenta ver todos los eventos o revisa más tarde'
                  : 'Intenta ajustar los filtros de búsqueda',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
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
              child: Text(
                _showOnlyUpcoming ? 'Ver todos los eventos' : 'Limpiar filtros',
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
      child: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 2.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _filteredEvents.length,
        itemBuilder: (context, index) {
          final event = _filteredEvents[index];
          return _buildEventCard(event);
        },
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToEventDetail(event),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey[50]!,
              ],
            ),
          ),
          child: Row(
            children: [
              // Imagen del evento
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Container(
                  width: 120,
                  height: double.infinity,
                  child: event.imageUrl != null
                      ? Image.network(
                          event.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                ),
              ),

              // Contenido del evento
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        event.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Fecha y tiempo restante
                      Row(
                        children: [
                          Icon(
                            event.isPastEvent ? Icons.history : Icons.schedule,
                            size: 16,
                            color:
                                event.isPastEvent ? Colors.grey : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.isPastEvent
                                  ? 'Evento pasado'
                                  : event.timeUntilEvent,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: event.isPastEvent
                                        ? Colors.grey
                                        : Colors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Ubicación
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Tags
                      if (event.tags.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          children: event.tags
                              .take(2)
                              .map((tag) => Chip(
                                    label: Text(
                                      tag,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    backgroundColor:
                                        Colors.orange.withOpacity(0.1),
                                    labelStyle:
                                        const TextStyle(color: Colors.orange),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ))
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ),

              // Indicador de más detalles
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.event,
        size: 48,
        color: Colors.grey,
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
