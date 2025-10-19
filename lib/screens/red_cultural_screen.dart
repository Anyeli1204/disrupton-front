import 'package:flutter/material.dart';
import '../models/simple_social_post.dart';
import '../core/theme/app_colors.dart';
import '../widgets/create_post_modal.dart';

class RedCulturalScreen extends StatefulWidget {
  const RedCulturalScreen({Key? key}) : super(key: key);

  @override
  _RedCulturalScreenState createState() => _RedCulturalScreenState();
}

class _RedCulturalScreenState extends State<RedCulturalScreen> {
  final ScrollController _scrollController = ScrollController();
  List<SimpleSocialPost> _feedPosts = [];
  List<SimpleSocialPost> _filteredPosts = [];
  bool _isLoading = false;
  String _selectedCategory = 'Todos';
  double _scrollOffset = 0.0;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Todos', 'icon': Icons.grid_view_rounded},
    {'name': 'Festividades', 'icon': Icons.celebration_outlined},
    {'name': 'Danza', 'icon': Icons.music_note_outlined},
    {'name': 'Gastronomía', 'icon': Icons.restaurant_outlined},
    {'name': 'Arte', 'icon': Icons.palette_outlined},
    {'name': 'Turismo', 'icon': Icons.landscape_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMockData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  void _loadMockData() {
    setState(() {
      _isLoading = true;
    });

    _feedPosts = [
      SimpleSocialPost(
        id: '1',
        userId: 'user1',
        userName: 'María Rodriguez',
        userAvatar: '',
        content:
            'Aprendiendo el arte ancestral del tejido andino 🧵✨ Cada hilo cuenta una historia, cada patrón representa nuestra identidad. La tradición textil peruana es patrimonio vivo que debemos preservar.',
        imageUrl: 'assets/images/post_images/aprendiendo_tejidos_andinos.jpeg',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 234,
        comments: 45,
        shares: 12,
        isLiked: false,
        isSaved: false,
        tags: ['#Textiles', '#Artesanía', '#Andino', '#Patrimonio'],
      ),
      SimpleSocialPost(
        id: '2',
        userId: 'user2',
        userName: 'Carlos Mendoza',
        userAvatar: '',
        content:
            'Los andenes de Cotabamba: ingeniería agrícola milenaria 🌾⛰️ Estos sistemas de terrazas pre-incas siguen siendo productivos hoy. Un ejemplo de sostenibilidad y armonía con la naturaleza.',
        imageUrl: 'assets/images/post_images/visita_andenes_cotabamba.jpeg',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 456,
        comments: 78,
        shares: 34,
        isLiked: true,
        isSaved: false,
        tags: ['#Andenes', '#Agricultura', '#Apurímac', '#Inca'],
      ),
      SimpleSocialPost(
        id: '3',
        userId: 'user3',
        userName: 'Ana Flores',
        userAvatar: '',
        content:
            'Kuélap: La majestuosa fortaleza en las nubes 🏛️☁️ Esta ciudadela de los Chachapoyas a 3,000 msnm es tan impresionante como Machu Picchu. Un tesoro arqueológico que merece ser conocido.',
        imageUrl: 'assets/images/post_images/visita_kuelap.jpeg',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        likes: 389,
        comments: 56,
        shares: 28,
        isLiked: false,
        isSaved: true,
        tags: ['#Kuélap', '#Chachapoyas', '#Amazonas', '#Arqueología'],
      ),
      SimpleSocialPost(
        id: '4',
        userId: 'user4',
        userName: 'Pedro Quispe',
        userAvatar: '',
        content:
            'Las enigmáticas Líneas de Nazca desde el mirador 🛸✨ Figuras trazadas hace más de 1,500 años que siguen fascinando al mundo. ¿Astronomía? ¿Ritual? El misterio perdura.',
        imageUrl: 'assets/images/post_images/visita_lineas_nazca.jpeg',
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        likes: 567,
        comments: 92,
        shares: 45,
        isLiked: true,
        isSaved: true,
        tags: ['#Nazca', '#Geoglifos', '#Patrimonio', '#Misterio'],
      ),
      SimpleSocialPost(
        id: '5',
        userId: 'user5',
        userName: 'Sofia Huamán',
        userAvatar: '',
        content:
            'Machu Picchu al amanecer: magia pura 🌄 La ciudadela inca entre montañas envuelta en niebla es un espectáculo místico. Cada visita es única y conmovedora. Patrimonio de la humanidad.',
        imageUrl: 'assets/images/post_images/visita_machu_picchu.jpeg',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        likes: 892,
        comments: 134,
        shares: 78,
        isLiked: true,
        isSaved: false,
        tags: ['#MachuPicchu', '#Cusco', '#Inca', '#PatrimonioMundial'],
      ),
      SimpleSocialPost(
        id: '6',
        userId: 'user6',
        userName: 'Luis Torres',
        userAvatar: '',
        content:
            'La Plaza de Armas del Cusco: corazón del Tahuantinsuyo ⛪🏛️ Rodeada de arquitectura colonial sobre cimientos incas. Cada piedra aquí respira historia. El ombligo del mundo.',
        imageUrl: 'assets/images/post_images/visita_plaza_cusco.jpeg',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        likes: 1234,
        comments: 203,
        shares: 156,
        isLiked: false,
        isSaved: true,
        tags: ['#Cusco', '#PlazaArmas', '#Historia', '#Colonial'],
      ),
    ];

    _filteredPosts = List.from(_feedPosts);
    setState(() {
      _isLoading = false;
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'Todos') {
        _filteredPosts = List.from(_feedPosts);
      } else {
        _filteredPosts = _feedPosts.where((post) {
          return post.tags
              .any((tag) => tag.toLowerCase().contains(category.toLowerCase()));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final headerOpacity = (_scrollOffset / 100).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildModernAppBar(headerOpacity),
          _buildCategoryBar(),
          _buildPostsFeed(),
        ],
      ),
      floatingActionButton: _buildCreatePostFAB(),
    );
  }

  Widget _buildModernAppBar(double headerOpacity) {
    return SliverAppBar(
      // Reduced height since icon and text are now in one line
      expandedHeight: 85,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white.withOpacity(headerOpacity),
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: EdgeInsets.zero,
        title: AnimatedOpacity(
          opacity: headerOpacity,
          duration: const Duration(milliseconds: 200),
          child: Container(
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.only(left: 20, bottom: 16),
            child: const Text(
              'Red',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 22,
                fontFamily: 'RobotoMono',
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.95),
                AppColors.primary,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Ícono y texto en la misma línea
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.forum_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Texto al lado del ícono
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Red Cultural',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'RobotoMono',
                                letterSpacing: -0.4,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'Descubre y comparte',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.88),
                                fontSize: 11,
                                fontFamily: 'RobotoMono',
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Botones de acción
                      IconButton(
                        onPressed: _showSearch,
                        padding: EdgeInsets.all(6),
                        constraints: BoxConstraints(),
                        icon: const Icon(Icons.search_rounded,
                            color: Colors.white, size: 20),
                        tooltip: 'Buscar',
                      ),
                      IconButton(
                        onPressed: _showNotifications,
                        padding: EdgeInsets.all(6),
                        constraints: BoxConstraints(),
                        icon: const Icon(Icons.notifications_outlined,
                            color: Colors.white, size: 20),
                        tooltip: 'Notificaciones',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _CategoryBarDelegate(
        minHeight: 70,
        maxHeight: 70,
        child: Container(
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
              const SizedBox(height: 12),
              SizedBox(
                height: 58,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category['name'];
                    return _buildCategoryChip(
                      category['name'] as String,
                      category['icon'] as IconData,
                      isSelected,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, IconData icon, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => _filterByCategory(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontFamily: 'RobotoMono',
                  fontSize: 13,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostsFeed() {
    if (_isLoading) {
      return SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (_filteredPosts.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final post = _filteredPosts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildModernPostCard(post),
            );
          },
          childCount: _filteredPosts.length,
        ),
      ),
    );
  }

  Widget _buildModernPostCard(SimpleSocialPost post) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    post.userName[0].toUpperCase(),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'RobotoMono',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          fontFamily: 'RobotoMono',
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        _formatTimestamp(post.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontFamily: 'RobotoMono',
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showPostOptions(post),
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                post.content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  fontFamily: 'RobotoMono',
                  letterSpacing: -0.2,
                ),
              ),
            ),
          const SizedBox(height: 12),
          if (post.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                post.imageUrl,
                width: double.infinity,
                // Reduced image height to make cards more compact
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 320,
                    color: Colors.grey.shade200,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 12),
          if (post.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: post.tags.take(4).map((tag) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'RobotoMono',
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Flexible(
                  child: _buildActionButton(
                    icon:
                        post.isLiked ? Icons.favorite : Icons.favorite_outline,
                    label: '${post.likes}',
                    color: post.isLiked ? Colors.red : AppColors.textSecondary,
                    onTap: () => _handlePostLike(post),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: _buildActionButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: '${post.comments}',
                    color: AppColors.textSecondary,
                    onTap: () => _handlePostComment(post),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: _buildActionButton(
                    icon: Icons.share_outlined,
                    label: '${post.shares}',
                    color: AppColors.textSecondary,
                    onTap: () => _handlePostShare(post),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _handlePostSave(post),
                  icon: Icon(
                    post.isSaved ? Icons.bookmark : Icons.bookmark_outline,
                    color: post.isSaved
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  fontFamily: 'RobotoMono',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
                Icons.forum_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay publicaciones',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sé el primero en compartir\nuna experiencia cultural',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showCreatePost,
              icon: const Icon(Icons.add_rounded, size: 22),
              label: const Text(
                'Crear Publicación',
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatePostFAB() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _showCreatePost,
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          'Publicar',
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _handlePostLike(SimpleSocialPost post) {
    setState(() {
      post.isLiked = !post.isLiked;
      post.likes += post.isLiked ? 1 : -1;
    });
  }

  void _handlePostSave(SimpleSocialPost post) {
    setState(() {
      post.isSaved = !post.isSaved;
    });
    _showInfo(post.isSaved ? 'Guardado' : 'Eliminado de guardados');
  }

  void _handlePostComment(SimpleSocialPost post) {
    _showInfo('Comentarios próximamente');
  }

  void _handlePostShare(SimpleSocialPost post) {
    _showInfo('Compartir próximamente');
  }

  void _showPostOptions(SimpleSocialPost post) {
    _showInfo('Opciones de publicación');
  }

  void _showCreatePost() {
    print('🔥 _showCreatePost() called');
    print('Context available: context exists');
    print('Mounted: $mounted');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white, // Temporalmente no transparente
      builder: (context) {
        print('🔥 Modal builder called');
        return CreatePostModal(
          onPostCreated: (post) {
            print('🔥 Post created callback called');
            // Aquí podrías actualizar la lista de posts si lo necesitas
            _showInfo('¡Publicación creada exitosamente!');
            // Opcional: recargar los posts
            // _loadMockData();
          },
        );
      },
    ).then((result) {
      print('🔥 Modal closed with result: $result');
    });
  }

  void _showSearch() {
    _showInfo('Búsqueda próximamente');
  }

  void _showNotifications() {
    _showInfo('Notificaciones próximamente');
  }

  void _showInfo(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(message, style: const TextStyle(fontFamily: 'RobotoMono')),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}

class _CategoryBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _CategoryBarDelegate({
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
  bool shouldRebuild(_CategoryBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
