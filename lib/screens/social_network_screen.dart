import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/social_post.dart';
import '../services/social_post_service.dart';
import '../widgets/social_post_card.dart';
import '../widgets/create_post_modal.dart';

class SocialNetworkScreen extends StatefulWidget {
  const SocialNetworkScreen({super.key});

  @override
  State<SocialNetworkScreen> createState() => _SocialNetworkScreenState();
}

class _SocialNetworkScreenState extends State<SocialNetworkScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  // Controllers y datos
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // Estado
  List<SocialPost> _feedPosts = [];
  List<SocialPost> _filteredPosts = [];
  List<String> _trendingTags = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 0;
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildAppBar(innerBoxIsScrolled),
          _buildTabBar(),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildFeedTab(),
            _buildExploreTab(),
            _buildTrendingTab(),
            _buildSavedTab(),
          ],
        ),
      ),
      floatingActionButton: _buildCreatePostFAB(),
    );
  }

  Widget _buildAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: AnimatedOpacity(
          opacity: innerBoxIsScrolled ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: const Text(
            'Red Cultural',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange.shade400,
                Colors.orange.shade600,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Red Cultural',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Comparte y descubre la riqueza cultural del Perú',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: _showSearch,
          icon: const Icon(Icons.search),
        ),
        IconButton(
          onPressed: _showNotifications,
          icon: const Icon(Icons.notifications_outlined),
        ),
        IconButton(
          onPressed: _showProfile,
          icon: const Icon(Icons.account_circle_outlined),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        minHeight: 50,
        maxHeight: 50,
        child: Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: Colors.orange,
            indicatorWeight: 3,
            tabs: const [
              Tab(
                icon: Icon(Icons.home, size: 20),
                text: 'Inicio',
              ),
              Tab(
                icon: Icon(Icons.explore, size: 20),
                text: 'Explorar',
              ),
              Tab(
                icon: Icon(Icons.trending_up, size: 20),
                text: 'Tendencias',
              ),
              Tab(
                icon: Icon(Icons.bookmark, size: 20),
                text: 'Guardados',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedTab() {
    if (_isLoading && _feedPosts.isEmpty) {
      return _buildLoadingView();
    }

    if (_feedPosts.isEmpty) {
      return _buildEmptyFeedView();
    }

    return RefreshIndicator(
      onRefresh: _refreshFeed,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _filteredPosts.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _filteredPosts.length) {
            return _buildLoadingMoreIndicator();
          }

          final post = _filteredPosts[index];
          return SocialPostCard(
            post: post,
            onLike: _handlePostLike,
            onSave: _handlePostSave,
            onComment: _handlePostComment,
            onShare: _handlePostShare,
            onUserTap: _handleUserTap,
            onTagTap: _handleTagTap,
          );
        },
      ),
    );
  }

  Widget _buildExploreTab() {
    return Column(
      children: [
        // Buscador
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar publicaciones, usuarios, tags...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            onSubmitted: _performSearch,
          ),
        ),

        // Filtros rápidos
        _buildQuickFilters(),

        // Resultados o contenido sugerido
        Expanded(
          child: _searchQuery.isEmpty
              ? _buildSuggestedContent()
              : _buildSearchResults(),
        ),
      ],
    );
  }

  Widget _buildTrendingTab() {
    return Column(
      children: [
        // Tags trending
        _buildTrendingTags(),

        // Posts trending
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _feedPosts.take(5).length,
            itemBuilder: (context, index) {
              final post = _feedPosts[index];
              return SocialPostCard(
                post: post,
                onLike: _handlePostLike,
                onSave: _handlePostSave,
                onComment: _handlePostComment,
                onShare: _handlePostShare,
                onUserTap: _handleUserTap,
                onTagTap: _handleTagTap,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSavedTab() {
    // TODO: Implementar posts guardados
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_outline,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No tienes publicaciones guardadas',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Guarda publicaciones tocando el ícono de bookmark',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePostFAB() {
    return FloatingActionButton.extended(
      onPressed: _showCreatePost,
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.add),
      label: const Text('Publicar'),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.orange),
          SizedBox(height: 16),
          Text('Cargando publicaciones...'),
        ],
      ),
    );
  }

  Widget _buildEmptyFeedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '¡Comparte tu primera experiencia cultural!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Sube fotos de artesanías, lugares históricos,\nevento culturales y mucho más',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreatePost,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Crear publicación'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(color: Colors.orange),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('Todos', 'all'),
          _buildFilterChip('Arte', 'arte'),
          _buildFilterChip('Turismo', 'turismo'),
          _buildFilterChip('Gastronomía', 'gastronomia'),
          _buildFilterChip('Tradiciones', 'tradiciones'),
          _buildFilterChip('Música', 'musica'),
          _buildFilterChip('Danza', 'danza'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? value : 'all';
            _applyFilters();
          });
        },
        selectedColor: Colors.orange.shade100,
        backgroundColor: Colors.grey.shade100,
        labelStyle: TextStyle(
          color: isSelected ? Colors.orange.shade800 : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSuggestedContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Explora contenido cultural',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Usa el buscador para encontrar publicaciones,\nusuarios o tags específicos',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    // TODO: Implementar resultados de búsqueda
    return const Center(
      child: Text('Resultados de búsqueda aparecerán aquí'),
    );
  }

  Widget _buildTrendingTags() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tags en tendencia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _trendingTags.map((tag) {
              return GestureDetector(
                onTap: () => _handleTagTap(tag),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Métodos de datos y lógica
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      final posts = await SocialPostService.getFeedPosts(page: 0, limit: 10);
      final tags = await SocialPostService.getTrendingTags(limit: 15);

      setState(() {
        _feedPosts = posts;
        _filteredPosts = posts;
        _trendingTags = tags;
        _hasMoreData = posts.length >= 10;
        _currentPage = 0;
      });
    } catch (e) {
      _showError('Error al cargar contenido: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshFeed() async {
    try {
      final posts = await SocialPostService.getFeedPosts(page: 0, limit: 10);
      setState(() {
        _feedPosts = posts;
        _filteredPosts = posts;
        _hasMoreData = posts.length >= 10;
        _currentPage = 0;
      });
      _applyFilters();
    } catch (e) {
      _showError('Error al actualizar: $e');
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() => _isLoadingMore = true);

    try {
      final newPosts = await SocialPostService.getFeedPosts(
        page: _currentPage + 1,
        limit: 10,
      );

      setState(() {
        _feedPosts.addAll(newPosts);
        _hasMoreData = newPosts.length >= 10;
        _currentPage++;
      });

      _applyFilters();
    } catch (e) {
      _showError('Error al cargar más posts: $e');
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  void _applyFilters() {
    List<SocialPost> filtered = List.from(_feedPosts);

    // Filtrar por categoría
    if (_selectedFilter != 'all') {
      filtered = filtered.where((post) {
        return post.tags.any(
            (tag) => tag.toLowerCase().contains(_selectedFilter.toLowerCase()));
      }).toList();
    }

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((post) {
        return post.description
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            post.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            post.tags.any((tag) =>
                tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    setState(() {
      _filteredPosts = filtered;
    });
  }

  // Métodos de eventos
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMorePosts();
    }
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  // Handlers de interacción
  void _handlePostLike(SocialPost post) {
    HapticFeedback.lightImpact();
    // El estado se actualiza en el widget card
  }

  void _handlePostSave(SocialPost post) {
    HapticFeedback.lightImpact();
    // El estado se actualiza en el widget card
  }

  void _handlePostComment(SocialPost post) {
    // TODO: Abrir pantalla de comentarios
    _showInfo('Función de comentarios próximamente');
  }

  void _handlePostShare(SocialPost post) {
    // TODO: Implementar compartir
    _showInfo('Función de compartir próximamente');
  }

  void _handleUserTap(String userId) {
    // TODO: Abrir perfil de usuario
    _showInfo('Perfil de usuario próximamente');
  }

  void _handleTagTap(String tag) {
    setState(() {
      _searchQuery = tag;
      _tabController.animateTo(1); // Ir a tab de explorar
    });
    _applyFilters();
  }

  // Métodos de UI
  void _showCreatePost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreatePostModal(
        onPostCreated: (post) {
          setState(() {
            _feedPosts.insert(0, post);
          });
          _applyFilters();
        },
      ),
    );
  }

  void _showSearch() {
    // TODO: Implementar búsqueda avanzada
    _showInfo('Búsqueda avanzada próximamente');
  }

  void _showNotifications() {
    // TODO: Implementar notificaciones
    _showInfo('Notificaciones próximamente');
  }

  void _showProfile() {
    // TODO: Implementar perfil
    _showInfo('Perfil próximamente');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

// Delegado personalizado para SliverPersistentHeader
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxExtent ||
        minHeight != oldDelegate.minExtent;
  }
}
