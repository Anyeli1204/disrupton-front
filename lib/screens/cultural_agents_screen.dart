import 'package:flutter/material.dart';
import '../models/cultural_agent.dart';
import '../services/cultural_agent_service.dart';

class CulturalAgentsScreen extends StatefulWidget {
  const CulturalAgentsScreen({super.key});

  @override
  State<CulturalAgentsScreen> createState() => _CulturalAgentsScreenState();
}

class _CulturalAgentsScreenState extends State<CulturalAgentsScreen> {
  String _selectedCategory = 'TODAS';
  String _searchQuery = '';
  bool _isLoading = false;
  List<CulturalAgent> _allAgents = [];
  List<CulturalAgent> _filteredAgents = [];

  final List<String> _categories = [
    'TODAS',
    'ARTISAN',
    'GUIDE',
    'CULTURAL_EXPERT',
  ];

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  Future<void> _loadAgents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Intentar cargar desde el backend
      final agents = await CulturalAgentService.getAllAgents();
      setState(() {
        _allAgents = agents;
        _filteredAgents = agents;
        _isLoading = false;
      });
    } catch (e) {
      // Si falla, usar datos de ejemplo
      setState(() {
        _allAgents = CulturalAgentService.getSampleAgents();
        _filteredAgents = _allAgents;
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usando datos de ejemplo: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _filterAgents() {
    setState(() {
      _filteredAgents = _allAgents.where((agent) {
        final matchesCategory = _selectedCategory == 'TODAS' || 
                               agent.category == _selectedCategory;
        final matchesSearch = _searchQuery.isEmpty ||
                             agent.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                             agent.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                             (agent.region?.toLowerCase() ?? '').contains(_searchQuery.toLowerCase());
        
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agentes Culturales'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filtros y búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Búsqueda
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar agentes...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterAgents();
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Filtros por categoría
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(_getCategoryDisplayName(category)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                              _filterAgents();
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: Colors.deepPurple[100],
                          checkmarkColor: Colors.deepPurple,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de agentes
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAgents.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No se encontraron agentes',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredAgents.length,
                        itemBuilder: (context, index) {
                          final agent = _filteredAgents[index];
                          return _buildAgentCard(agent);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentCard(CulturalAgent agent) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showAgentDetails(agent),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con imagen y verificación
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.deepPurple[100],
                    child: Text(
                      agent.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                agent.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (agent.isVerified)
                              const Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 20,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getCategoryDisplayName(agent.category),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Descripción
              Text(
                agent.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 16),
              
              // Información adicional
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    agent.region ?? 'Sin región',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.star, size: 16, color: Colors.amber[600]),
                  const SizedBox(width: 4),
                  Text(
                    agent.rating?.toStringAsFixed(1) ?? 'N/A',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${agent.reviewCount} reseñas)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Especialidades
              if (agent.specialties.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: agent.specialties.take(3).map((specialty) {
                    return Chip(
                      label: Text(
                        specialty,
                        style: const TextStyle(fontSize: 11),
                      ),
                      backgroundColor: Colors.deepPurple[50],
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
              
              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _contactAgent(agent),
                      icon: const Icon(Icons.contact_phone, size: 16),
                      label: const Text('Contactar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                        side: const BorderSide(color: Colors.deepPurple),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAgentDetails(agent),
                      icon: const Icon(Icons.info, size: 16),
                      label: const Text('Ver más'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'ARTISAN':
        return 'Artesano';
      case 'GUIDE':
        return 'Guía Local';
      case 'CULTURAL_EXPERT':
        return 'Experto Cultural';
      default:
        return category;
    }
  }

  void _showAgentDetails(CulturalAgent agent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAgentDetailsSheet(agent),
    );
  }

  Widget _buildAgentDetailsSheet(CulturalAgent agent) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.deepPurple[100],
                        child: Text(
                          agent.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              agent.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getCategoryDisplayName(agent.category),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            if (agent.isVerified) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.verified, color: Colors.blue),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Verificado',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Descripción
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    agent.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Información de contacto
                  if (agent.email != null || agent.phoneNumber != null) ...[
                    const Text(
                      'Información de Contacto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (agent.email != null) ...[
                      _buildContactItem(Icons.email, 'Email', agent.email!),
                      const SizedBox(height: 12),
                    ],
                    if (agent.phoneNumber != null) ...[
                      _buildContactItem(Icons.phone, 'Teléfono', agent.phoneNumber!),
                      const SizedBox(height: 12),
                    ],
                    if (agent.website != null) ...[
                      _buildContactItem(Icons.language, 'Sitio web', agent.website!),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 24),
                  ],
                  
                  // Ubicación
                  if (agent.address != null) ...[
                    const Text(
                      'Ubicación',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildContactItem(Icons.location_on, 'Dirección', agent.address!),
                    const SizedBox(height: 24),
                  ],
                  
                  // Especialidades
                  if (agent.specialties.isNotEmpty) ...[
                    const Text(
                      'Especialidades',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: agent.specialties.map((specialty) {
                        return Chip(
                          label: Text(specialty),
                          backgroundColor: Colors.deepPurple[50],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Idiomas
                  if (agent.languages.isNotEmpty) ...[
                    const Text(
                      'Idiomas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: agent.languages.map((language) {
                        return Chip(
                          label: Text(language),
                          backgroundColor: Colors.green[50],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Calificación
                  Row(
                    children: [
                      Icon(Icons.star, size: 24, color: Colors.amber[600]),
                      const SizedBox(width: 8),
                      Text(
                        agent.rating?.toStringAsFixed(1) ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${agent.reviewCount} reseñas)',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _contactAgent(agent),
                          icon: const Icon(Icons.contact_phone),
                          label: const Text('Contactar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _contactAgent(CulturalAgent agent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contactar a ${agent.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (agent.email != null) ...[
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(agent.email!),
                onTap: () {
                  // Aquí podrías abrir el email
                  Navigator.pop(context);
                },
              ),
            ],
            if (agent.phoneNumber != null) ...[
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Teléfono'),
                subtitle: Text(agent.phoneNumber!),
                onTap: () {
                  // Aquí podrías hacer la llamada
                  Navigator.pop(context);
                },
              ),
            ],
            if (agent.website != null) ...[
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Sitio web'),
                subtitle: Text(agent.website!),
                onTap: () {
                  // Aquí podrías abrir el sitio web
                  Navigator.pop(context);
                },
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
