// Pantalla de Feed de Objetos Culturales (de Yeimi)
import 'package:flutter/material.dart';
import '../models/cultural_object.dart';
import '../widgets/cultural_object_list_tile.dart';
import '../services/cultural_object_service.dart';

class CulturalObjectsFeedScreen extends StatefulWidget {
  const CulturalObjectsFeedScreen({super.key});

  @override
  State<CulturalObjectsFeedScreen> createState() =>
      _CulturalObjectsFeedScreenState();
}

class _CulturalObjectsFeedScreenState extends State<CulturalObjectsFeedScreen>
    with AutomaticKeepAliveClientMixin {
  final List<CulturalObject> _culturalObjects = [];
  bool _isLoading = false;
  bool _hasMoreData = true;
  final CulturalObjectService _culturalObjectService = CulturalObjectService();
  final int _pageSize = 10;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchCulturalObjects();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
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
  bool get wantKeepAlive => true;

  Future<void> _fetchCulturalObjects() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final List<CulturalObject> newObjects =
          await _culturalObjectService.fetchCulturalObjects();

      setState(() {
        _culturalObjects.addAll(newObjects);
        _hasMoreData = newObjects.length >= _pageSize;
      });
    } catch (e) {
      setState(() {
        _hasMoreData = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar objetos culturales: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Objetos Culturales'),
        backgroundColor: Colors.deepPurple.shade600,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _culturalObjects.clear();
            _hasMoreData = true;
          });
          await _fetchCulturalObjects();
        },
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _culturalObjects.length + (_isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _culturalObjects.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return CulturalObjectListTile(
                culturalObject: _culturalObjects[index]);
          },
        ),
      ),
    );
  }
}
