import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import 'event_detail_screen.dart';
import 'create_edit_event_screen.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({Key? key}) : super(key: key);

  @override
  _AdminEventsScreenState createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen>
    with TickerProviderStateMixin {
  final EventService _eventService = EventService();
  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  EventStats? _stats;
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _statusFilter = 'all'; // all, active, inactive
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final events = await _eventService.getAllEvents();
      final stats = await _eventService.getEventStats();

      setState(() {
        _allEvents = events;
        _stats = stats;
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

    // Filtrar por estado
    switch (_statusFilter) {
      case 'active':
        filtered = filtered.where((event) => event.isActive).toList();
        break;
      case 'inactive':
        filtered = filtered.where((event) => !event.isActive).toList();
        break;
      // 'all' no filtra
    }

    // Ordenar por fecha de creación (más recientes primero)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() {
      _filteredEvents = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Eventos'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        bottom: _tabController != null
            ? TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(icon: Icon(Icons.dashboard), text: 'Estadísticas'),
                  Tab(icon: Icon(Icons.list), text: 'Eventos'),
                  Tab(icon: Icon(Icons.analytics), text: 'Análisis'),
                ],
              )
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStatsTab(),
                    _buildEventsTab(),
                    _buildAnalyticsTab(),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewEvent,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Crear nuevo evento',
      ),
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
              'Error al cargar datos',
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
              onPressed: _loadData,
              child: const Text('Intentar nuevamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsTab() {
    if (_stats == null) {
      return const Center(child: Text('No hay estadísticas disponibles'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildStatsCards(),
          const SizedBox(height: 20),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Total Eventos',
          _stats!.totalEvents.toString(),
          Icons.event,
          Colors.blue,
        ),
        _buildStatCard(
          'Eventos Activos',
          _stats!.activeEvents.toString(),
          Icons.event_available,
          Colors.green,
        ),
        _buildStatCard(
          'Próximos',
          _stats!.upcomingEvents.toString(),
          Icons.upcoming,
          Colors.orange,
        ),
        _buildStatCard(
          'Finalizados',
          _stats!.pastEvents.toString(),
          Icons.history,
          Colors.grey,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones Rápidas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  'Crear Evento',
                  Icons.add,
                  Colors.green,
                  _createNewEvent,
                ),
                _buildActionButton(
                  'Ver Todos',
                  Icons.list,
                  Colors.blue,
                  () => _tabController?.animateTo(1),
                ),
                _buildActionButton(
                  'Actualizar',
                  Icons.refresh,
                  Colors.orange,
                  _loadData,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(icon, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEventsTab() {
    return Column(
      children: [
        _buildSearchAndFilters(),
        Expanded(
          child: _filteredEvents.isEmpty
              ? _buildEmptyEventsState()
              : _buildEventsList(),
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
                      onPressed: () {
                        setState(() => _searchQuery = '');
                        _applyFilters();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
              _applyFilters();
            },
          ),
          const SizedBox(height: 12),

          // Filtros de estado
          Row(
            children: [
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'all', label: Text('Todos')),
                    ButtonSegment(value: 'active', label: Text('Activos')),
                    ButtonSegment(value: 'inactive', label: Text('Inactivos')),
                  ],
                  selected: {_statusFilter},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _statusFilter = newSelection.first;
                    });
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyEventsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.event_busy,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No se encontraron eventos'
                  : 'No hay eventos aún',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Intenta ajustar los filtros de búsqueda'
                  : 'Crea tu primer evento para comenzar',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchQuery.isNotEmpty
                  ? () {
                      setState(() {
                        _searchQuery = '';
                        _statusFilter = 'all';
                      });
                      _applyFilters();
                    }
                  : _createNewEvent,
              child: Text(
                _searchQuery.isNotEmpty ? 'Limpiar filtros' : 'Crear evento',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    return RefreshIndicator(
      onRefresh: _loadData,
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

  Widget _buildEventCard(Event event) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewEventDetail(event),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header del evento
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        Text(
                          event.location,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Estado y acciones
                  Column(
                    children: [
                      _buildStatusChip(event),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _editEvent(event),
                            tooltip: 'Editar',
                          ),
                          IconButton(
                            icon: Icon(
                              event.isActive
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 20,
                            ),
                            onPressed: () => _toggleEventStatus(event),
                            tooltip: event.isActive ? 'Desactivar' : 'Activar',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                size: 20, color: Colors.red),
                            onPressed: () => _deleteEvent(event),
                            tooltip: 'Eliminar',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Información del evento
              Row(
                children: [
                  Icon(
                    event.isPastEvent ? Icons.history : Icons.schedule,
                    size: 16,
                    color: event.isPastEvent ? Colors.grey : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    event.isPastEvent ? 'Finalizado' : event.timeUntilEvent,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              event.isPastEvent ? Colors.grey : Colors.orange,
                        ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.people,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${event.attendeesCount} asistentes',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(Event event) {
    Color color;
    String label;

    if (!event.isActive) {
      color = Colors.red;
      label = 'Inactivo';
    } else if (event.isPastEvent) {
      color = Colors.grey;
      label = 'Finalizado';
    } else {
      color = Colors.green;
      label = 'Activo';
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w500),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildAnalyticsTab() {
    // Placeholder para análisis futuro
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Análisis Avanzado',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Gráficos y métricas detalladas\npronto disponibles',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Acciones

  void _createNewEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateEditEventScreen(),
      ),
    ).then((created) {
      if (created == true) {
        _loadData(); // Recargar datos si se creó un evento
      }
    });
  }

  void _viewEventDetail(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(event: event),
      ),
    );
  }

  void _editEvent(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEditEventScreen(eventToEdit: event),
      ),
    ).then((updated) {
      if (updated == true) {
        _loadData(); // Recargar datos si se actualizó un evento
      }
    });
  }

  void _toggleEventStatus(Event event) async {
    try {
      await _eventService.toggleEventStatus(event.id);
      _showSnackBar('Estado del evento cambiado exitosamente');
      _loadData(); // Recargar datos
    } catch (e) {
      _showSnackBar('Error al cambiar estado: $e');
    }
  }

  void _deleteEvent(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _eventService.deleteEvent(event.id);
                _showSnackBar('Evento eliminado exitosamente');
                _loadData(); // Recargar datos
              } catch (e) {
                _showSnackBar('Error al eliminar evento: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
