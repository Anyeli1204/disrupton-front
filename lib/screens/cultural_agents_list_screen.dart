import 'package:flutter/material.dart';
import '../models/cultural_agent.dart'; // Assuming this path based on previous steps
import '../services/cultural_object_service.dart';
import '../widgets/cultural_agent_list_tile.dart';

class CulturalAgentsListScreen extends StatefulWidget {
  const CulturalAgentsListScreen({Key? key}) : super(key: key);

  @override
  _CulturalAgentsListScreenState createState() => _CulturalAgentsListScreenState();
}

class _CulturalAgentsListScreenState extends State<CulturalAgentsListScreen> {
  List<CulturalAgent> _culturalAgents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCulturalAgents();
  }

  Future<void> _loadCulturalAgents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final service = CulturalObjectService(); // Or CulturalAgentService if created separately
      _culturalAgents = await service.fetchCulturalAgents();
    } catch (e) {
      // Handle error (e.g., show a Snackbar)
      print('Error fetching cultural agents: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cultural Agents'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _culturalAgents.length,
              itemBuilder: (context, index) {
                return CulturalAgentListTile(culturalAgent: _culturalAgents[index]);
              },
            ),
    );
  }
}