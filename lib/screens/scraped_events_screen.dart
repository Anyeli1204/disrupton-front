import 'package:flutter/material.dart';
import '../models/scraped_event.dart';
import '../services/scraped_events_service.dart';
import 'scraped_event_detail_screen.dart';

class ScrapedEventsScreen extends StatefulWidget {
  const ScrapedEventsScreen({Key? key}) : super(key: key);

  @override
  _ScrapedEventsScreenState createState() => _ScrapedEventsScreenState();
}

class _ScrapedEventsScreenState extends State<ScrapedEventsScreen> {
  final ScrapedEventsService _service = ScrapedEventsService();
  List<ScrapedEvent> _allEvents = [];
  List<ScrapedEvent> _filteredEvents = [];
  List<String> _availableCategories = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = '';
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

      final events = await _service.getAllScrapedEvents();

      setState(() {
        _allEvents = events;
        _availableCategories = _service.getUniqueCategories(events);
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
    List<ScrapedEvent> filtered = List.from(_allEvents);

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = _service.searchEvents(filtered, _searchQuery);
    }

    // Filtrar por categoría
    if (_selectedCategory.isNotEmpty) {
      filtered = _service.filterEventsByCategory(filtered, _selectedCategory);
    }

    // Filtrar por eventos próximos/pasados
    if (_showOnlyUpcoming) {
      filtered = _service.getUpcomingEvents(filtered);
    }

    // Ordenar por fecha
    filtered = _service.sortEventsByDate(filtered, ascending: true);

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

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category == _selectedCategory ? '' : category;
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
        title: const Text('Eventos Culturales'),
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
              hintText: 'Buscar eventos culturales...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                        _onSearchChanged('');
                      },
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

          // Filtros por categorías
          if (_availableCategories.isNotEmpty) ...[
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
                itemCount: _availableCategories.length,
                itemBuilder: (context, index) {
                  final category = _availableCategories[index];
                  final isSelected = category == _selectedCategory;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) => _onCategorySelected(category),
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
                    _selectedCategory = '';
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
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _filteredEvents.length,
        itemBuilder: (context, index) {
          final event = _filteredEvents[index];
          return _buildEventCard(event);
        },
      ),
    );
  }

  Widget _buildEventCard(ScrapedEvent event) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToEventDetail(event),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 140,
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
                  child: event.imagenUrl != null && event.imagenUrl!.isNotEmpty
                      ? Image.network(
                          event.imagenUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderImage(event.categoria),
                        )
                      : _buildPlaceholderImage(event.categoria),
                ),
              ),

              // Contenido del evento
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Título
                      Text(
                        event.titulo,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
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
                            size: 14,
                            color:
                                event.isPastEvent ? Colors.grey : Colors.orange,
                          ),
                          const SizedBox(height: 4),
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
                                    fontSize: 11,
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
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.lugar,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontSize: 11,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Categoría y Precio
                      Row(
                        children: [
                          // Categoría
                          Chip(
                            label: Text(
                              event.categoria,
                              style: const TextStyle(fontSize: 9),
                            ),
                            backgroundColor: Colors.orange.withOpacity(0.1),
                            labelStyle: const TextStyle(color: Colors.orange),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          const SizedBox(width: 4),
                          // Precio
                          if (event.precio.isNotEmpty &&
                              event.precio.toLowerCase() != 'no especificado')
                            Expanded(
                              child: Text(
                                event.precio,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
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

  Widget _buildPlaceholderImage(String categoria) {
    IconData icon;
    Color color;

    switch (categoria.toLowerCase()) {
      case 'arte':
        icon = Icons.palette;
        color = Colors.purple;
        break;
      case 'música':
      case 'musica':
        icon = Icons.music_note;
        color = Colors.blue;
        break;
      case 'teatro':
        icon = Icons.theater_comedy;
        color = Colors.red;
        break;
      case 'danza':
        icon = Icons.person;
        color = Colors.pink;
        break;
      case 'literatura':
        icon = Icons.book;
        color = Colors.brown;
        break;
      case 'gastronomía':
      case 'gastronomia':
        icon = Icons.restaurant;
        color = Colors.orange;
        break;
      default:
        icon = Icons.event;
        color = Colors.grey;
    }

    return Container(
      color: color.withOpacity(0.1),
      child: Icon(
        icon,
        size: 48,
        color: color,
      ),
    );
  }

  void _navigateToEventDetail(ScrapedEvent event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScrapedEventDetailScreen(event: event),
      ),
    );
  }
}
