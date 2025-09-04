import 'package:flutter/material.dart';
import '../models/cultural_agent.dart';
import '../services/agente_cultural_service.dart';
import '../widgets/agent_card.dart';

class AgentesCulturalesScreen extends StatefulWidget {
  const AgentesCulturalesScreen({Key? key}) : super(key: key);

  @override
  State<AgentesCulturalesScreen> createState() =>
      _AgentesCulturalesScreenState();
}

class _AgentesCulturalesScreenState extends State<AgentesCulturalesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<CulturalAgent> _artesanos = [];
  List<CulturalAgent> _guias = [];
  List<CulturalAgent> _filteredArtesanos = [];
  List<CulturalAgent> _filteredGuias = [];

  bool _isLoadingArtesanos = false;
  bool _isLoadingGuias = false;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarDatos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    await Future.wait([
      _cargarArtesanos(),
      _cargarGuias(),
    ]);
  }

  Future<void> _cargarArtesanos() async {
    if (!mounted) return;

    setState(() {
      _isLoadingArtesanos = true;
    });

    try {
      final artesanos = await AgenteCulturalService.obtenerArtesanos();
      if (mounted) {
        setState(() {
          _artesanos = artesanos;
          _filteredArtesanos = artesanos;
          _isLoadingArtesanos = false;
        });
      }
    } catch (e) {
      print('Error cargando artesanos: $e');
      if (mounted) {
        setState(() {
          _isLoadingArtesanos = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar artesanos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cargarGuias() async {
    if (!mounted) return;

    setState(() {
      _isLoadingGuias = true;
    });

    try {
      final guias = await AgenteCulturalService.obtenerGuias();
      if (mounted) {
        setState(() {
          _guias = guias;
          _filteredGuias = guias;
          _isLoadingGuias = false;
        });
      }
    } catch (e) {
      print('Error cargando guías: $e');
      if (mounted) {
        setState(() {
          _isLoadingGuias = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar guías turísticos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filtrarAgentes(String searchTerm) {
    setState(() {
      _searchTerm = searchTerm.toLowerCase();

      _filteredArtesanos = _artesanos.where((agent) {
        return agent.name.toLowerCase().contains(_searchTerm) ||
            (agent.expertise?.toLowerCase().contains(_searchTerm) ?? false) ||
            (agent.region.toLowerCase().contains(_searchTerm)) ||
            (agent.specialties
                    ?.any((s) => s.toLowerCase().contains(_searchTerm)) ??
                false);
      }).toList();

      _filteredGuias = _guias.where((agent) {
        return agent.name.toLowerCase().contains(_searchTerm) ||
            (agent.expertise?.toLowerCase().contains(_searchTerm) ?? false) ||
            (agent.region.toLowerCase().contains(_searchTerm)) ||
            (agent.specialties
                    ?.any((s) => s.toLowerCase().contains(_searchTerm)) ??
                false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Agentes Culturales',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('🎨'),
                  SizedBox(width: 8),
                  Text('Artesanos'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('🗺️'),
                  SizedBox(width: 8),
                  Text('Guías Turísticos'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filtrarAgentes,
              decoration: InputDecoration(
                hintText: 'Buscar agentes culturales...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filtrarAgentes('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Contenido de las pestañas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildArtesanosTab(),
                _buildGuiasTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtesanosTab() {
    if (_isLoadingArtesanos) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.deepPurple),
            SizedBox(height: 16),
            Text('Cargando artesanos...'),
          ],
        ),
      );
    }

    if (_filteredArtesanos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.palette_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchTerm.isEmpty
                  ? 'No hay artesanos disponibles'
                  : 'No se encontraron artesanos',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            if (_searchTerm.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Intenta con otros términos de búsqueda',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return _buildAgentGrid(_filteredArtesanos);
  }

  Widget _buildGuiasTab() {
    if (_isLoadingGuias) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.teal),
            SizedBox(height: 16),
            Text('Cargando guías turísticos...'),
          ],
        ),
      );
    }

    if (_filteredGuias.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchTerm.isEmpty
                  ? 'No hay guías turísticos disponibles'
                  : 'No se encontraron guías turísticos',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            if (_searchTerm.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Intenta con otros términos de búsqueda',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return _buildAgentGrid(_filteredGuias);
  }

  Widget _buildAgentGrid(List<CulturalAgent> agents) {
    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getCrossAxisCount(),
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: agents.length,
          itemBuilder: (context, index) {
            final agent = agents[index];
            return AgentCard(
              agent: agent,
              onTap: () => _mostrarDetalleAgente(agent),
            );
          },
        ),
      ),
    );
  }

  int _getCrossAxisCount() {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  void _mostrarDetalleAgente(CulturalAgent agent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAgentDetailModal(agent),
    );
  }

  Widget _buildAgentDetailModal(CulturalAgent agent) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información básica del agente
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey.shade200,
                            child: agent.imageUrl.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      agent.imageUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(
                                          agent.type == AgentType.artisan
                                              ? Icons.palette
                                              : Icons.map,
                                          size: 30,
                                        );
                                      },
                                    ),
                                  )
                                : Icon(
                                    agent.type == AgentType.artisan
                                        ? Icons.palette
                                        : Icons.map,
                                    size: 30,
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  agent.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${agent.typeIcon} ${agent.typeLabel}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                if (agent.rating != null)
                                  Text(
                                    '⭐ ${agent.rating!.toStringAsFixed(1)} (${agent.totalRatings ?? 0} reseñas)',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.amber,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Descripción
                      if (agent.description != null &&
                          agent.description!.isNotEmpty) ...[
                        const Text(
                          'Descripción',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          agent.description!,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Especialidades
                      if (agent.specialties != null &&
                          agent.specialties!.isNotEmpty) ...[
                        const Text(
                          'Especialidades',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: agent.specialties!.map((specialty) {
                            return Chip(
                              label: Text(
                                specialty,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.grey.shade100,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Información de contacto
                      const Text(
                        'Contacto',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (agent.whatsapp != null && agent.whatsapp!.isNotEmpty)
                        ListTile(
                          leading:
                              const Icon(Icons.message, color: Colors.green),
                          title: const Text('WhatsApp'),
                          subtitle: Text(agent.whatsapp!),
                          onTap: () {
                            // Implementar apertura de WhatsApp
                          },
                        ),

                      if (agent.phone != null && agent.phone!.isNotEmpty)
                        ListTile(
                          leading: const Icon(Icons.phone, color: Colors.blue),
                          title: const Text('Teléfono'),
                          subtitle: Text(agent.phone!),
                          onTap: () {
                            // Implementar llamada
                          },
                        ),

                      if (agent.email != null && agent.email!.isNotEmpty)
                        ListTile(
                          leading:
                              const Icon(Icons.email, color: Colors.orange),
                          title: const Text('Email'),
                          subtitle: Text(agent.email!),
                          onTap: () {
                            // Implementar envío de email
                          },
                        ),

                      // Ubicación
                      ListTile(
                        leading:
                            const Icon(Icons.location_on, color: Colors.red),
                        title: const Text('Ubicación'),
                        subtitle: Text(agent.fullLocation),
                        onTap: () {
                          // Implementar navegación al mapa
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
