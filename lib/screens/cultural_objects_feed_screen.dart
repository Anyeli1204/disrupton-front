import 'package:flutter/material.dart';
import 'models/cultural_object.dart'; // Import the CulturalObject model
import 'widgets/cultural_object_list_tile.dart'; // Import the CulturalObjectListTile widget
import 'services/cultural_object_service.dart'; // Import the CulturalObjectService

class CulturalObjectsFeedScreen extends StatefulWidget with AutomaticKeepAliveClientMixin<CulturalObjectsFeedScreen> {
  const CulturalObjectsFeedScreen({Key? key}) : super(key: key);

  @override
  _CulturalObjectsFeedScreenState createState() => _CulturalObjectsFeedScreenState();
}

class _CulturalObjectsFeedScreenState extends State<CulturalObjectsFeedScreen> with AutomaticKeepAliveClientMixin {
  final List<CulturalObject> _culturalObjects = [];
  bool _isLoading = false;
  int _page = 0;
  final CulturalObjectService _culturalObjectService = CulturalObjectService();
  final int _pageSize = 10; // Adjust based on your backend API

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchCulturalObjects();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _fetchCulturalObjects();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true; // Keep the state of the list when navigating

  Future<void> _fetchCulturalObjects() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final List<CulturalObject> newObjects = await _culturalObjectService.fetchCulturalObjects(); // Removed page and pageSize parameters for simplicity
      if (newObjects.isNotEmpty) {
        setState(() {
          _culturalObjects.addAll(newObjects);
          _page++; // Keep track of page for potential pagination later
          _isLoading = false;
        });
      }  else {
        // Handle server errors
        print('No more cultural objects to load.');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle network errors
      print('Error fetching cultural objects: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Add this line to wrap the content in a Scaffold
      appBar: AppBar(
        title: const Text('Cultural Objects Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () { print('Map button pressed'); }, // TODO: Navigate to map page
          ),
        ],
      ),
      body: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(), // Ensure scrolling even if list is small
        controller: _scrollController,
        itemCount: _culturalObjects.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) { // Remove unnecessary check
          if (index == _culturalObjects.length) { // Correct the index check
            // This is the loading indicator at the end of the list
            return _isLoading ? const Padding(padding: EdgeInsets.all(8.0), child: Center(child: CircularProgressIndicator())) : const SizedBox.shrink();
          } else { // Correct the else condition
            final object = _culturalObjects[index];
            return CulturalObjectListTile(
              culturalObject: object,
              onTap: () {
              },
            );
          }
        },
      ),
    );
  }
}
