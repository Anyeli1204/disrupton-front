import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/collection_models.dart';
import '../utils/image_helper.dart';
import '../core/theme/app_colors.dart';

class DepartmentObjectsScreen extends StatefulWidget {
  final Department department;

  const DepartmentObjectsScreen({
    super.key,
    required this.department,
  });

  @override
  State<DepartmentObjectsScreen> createState() =>
      _DepartmentObjectsScreenState();
}

class _DepartmentObjectsScreenState extends State<DepartmentObjectsScreen> {
  final ScrollController _scrollController = ScrollController();
  double _headerOpacity = 0.0;

  // Departamentos con AR disponibles
  static const _arDepartments = [
    'arequipa',
    'cusco',
    'ica',
    'lima',
    'loreto',
    'puno',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final opacity = (offset / 30).clamp(0.0, 1.0);

    if (_headerOpacity != opacity) {
      setState(() {
        _headerOpacity = opacity;
      });
    }
  }

  String _getDepartmentId() {
    return widget.department.name
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
  }

  bool _hasARContent() {
    final departmentId = _getDepartmentId();
    return _arDepartments.contains(departmentId);
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasARContent()) {
      return _buildNoARContentScreen();
    }

    final departmentId = _getDepartmentId();
    final arImages = ImageHelper.getDepartmentARImages(departmentId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // AppBar con fade effect
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white.withOpacity(_headerOpacity),
            elevation: _headerOpacity * 4,
            shadowColor: Colors.black.withOpacity(0.1),
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: _headerOpacity > 0.5 ? Colors.black87 : Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
              title: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _headerOpacity,
                child: Text(
                  widget.department.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.black87,
                    fontFamily: 'RobotoMono',
                  ),
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen de fondo del departamento
                  Image.asset(
                    ImageHelper.getDepartmentImage(departmentId),
                    fit: BoxFit.cover,
                  ),
                  // Gradiente oscuro
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Información del departamento
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            widget.department.name,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontFamily: 'RobotoMono',
                              letterSpacing: -1,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  offset: Offset(0, 2),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.view_in_ar_rounded,
                                color: Colors.white.withOpacity(0.9),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${arImages.length} Objetos en Realidad Aumentada',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.95),
                                  fontFamily: 'RobotoMono',
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
            ),
          ),

          // Grid de objetos AR
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildARObjectCard(departmentId, index);
                },
                childCount: arImages.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildARObjectCard(String departmentId, int index) {
    final imagePath = ImageHelper.getDepartmentARImage(departmentId, index);
    final objectName = ImageHelper.getARObjectName(departmentId, index);

    return GestureDetector(
      onTap: () => _showObjectDetailModal(departmentId, index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen del objeto AR
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.view_in_ar_rounded,
                    size: 60,
                    color: AppColors.primary.withOpacity(0.4),
                  ),
                ),
              ),
              // Gradiente en la parte inferior
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.4, 0.7, 1.0],
                  ),
                ),
              ),
              // Badge AR
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.view_in_ar_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                      SizedBox(width: 3),
                      Text(
                        'AR',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'RobotoMono',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Nombre del objeto
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        objectName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: 'RobotoMono',
                          letterSpacing: -0.3,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              offset: Offset(0, 1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Toca para más info',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.9),
                              fontFamily: 'RobotoMono',
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
        ),
      ),
    );
  }

  void _showObjectDetailModal(String departmentId, int index) {
    final imagePath = ImageHelper.getDepartmentARImage(departmentId, index);
    final objectName = ImageHelper.getARObjectName(departmentId, index);
    final departmentName = ImageHelper.getDepartmentDisplayName(departmentId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Contenido scrollable
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Imagen principal
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 280,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                imagePath,
                                fit: BoxFit.cover,
                              ),
                              // Gradiente sutil
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.3),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Título
                      Text(
                        objectName,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          fontFamily: 'RobotoMono',
                          letterSpacing: -0.8,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Origen
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  departmentName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    fontFamily: 'RobotoMono',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.view_in_ar_rounded,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'AR',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.amber,
                                    fontFamily: 'RobotoMono',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Descripción
                      Text(
                        'Acerca de este objeto',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          fontFamily: 'RobotoMono',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getObjectDescription(departmentId, objectName),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontFamily: 'RobotoMono',
                          height: 1.6,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Botón de acción
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Función AR próximamente disponible',
                                style: const TextStyle(
                                  fontFamily: 'RobotoMono',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.primary.withOpacity(0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.view_in_ar_rounded, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Ver en Realidad Aumentada',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'RobotoMono',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getObjectDescription(String departmentId, String objectName) {
    // Descripciones genéricas pero informativas para cada objeto
    final descriptions = {
      'arequipa': {
        'Batán Arequipeño': 'Instrumento ancestral de piedra utilizado para moler granos y preparar alimentos. Fundamental en la cocina tradicional andina.',
        'Disco Solar Arequipeño': 'Representación ceremonial del Sol, deidad principal de la cultura andina. Símbolo de poder y adoración.',
        'Manto Arequipeño': 'Textil ceremonial elaborado con técnicas milenarias. Representa el estatus social y la maestría textil de la región.',
        'Monolito Arequipeño': 'Escultura monumental en piedra que representa figuras antropomorfas o zoomorfas de la cultura preincaica.',
        'Tumis Arequipeños': 'Cuchillos ceremoniales de metal con forma característica. Utilizados en rituales y como símbolo de autoridad.',
        'Vasija Arequipeña': 'Cerámica utilitaria y ceremonial con diseños geométricos característicos de la región.',
      },
      'cusco': {
        'Ídolo Llamita': 'Figura votiva representando a la llama, animal sagrado en la cultura andina. Utilizada en ofrendas y rituales.',
        'Machete Incaico': 'Herramienta ceremonial y utilitaria del periodo Inca. Representa la tecnología metalúrgica avanzada de la época.',
        'Músicos Incaicos': 'Representación de músicos tocando instrumentos tradicionales. Evidencia de la importancia de la música en ceremonias.',
        'Ofrenda Incaica': 'Conjunto de objetos ceremoniales utilizados en rituales de agradecimiento a las deidades andinas.',
        'Quipus Incaico': 'Sistema de registro y contabilidad mediante cuerdas anudadas. Testimonio del avanzado sistema administrativo inca.',
        'Vasijas Incaicas': 'Cerámica fina con el característico diseño policromado del periodo Inca. Uso ceremonial y utilitario.',
      },
      'ica': {
        'Cántaro Paracas': 'Cerámica ceremonial de la cultura Paracas, reconocida por su forma característica y decoración incisa.',
        'Cráneo Paracas': 'Evidencia de la práctica de deformación craneal intencional, símbolo de estatus en la cultura Paracas.',
        'Cuchillo Ceremonial': 'Instrumento ritual elaborado en metal. Utilizado en ceremonias religiosas de la cultura Paracas-Nazca.',
        'Manto Paracas': 'Textil ceremonial excepcional con bordados complejos. Considerado entre los mejores textiles precolombinos.',
        'Momia Paracas': 'Fardo funerario que muestra las avanzadas técnicas de momificación y el culto a los ancestros.',
        'Vaso Chincha': 'Cerámica característica de la cultura Chincha, con diseños geométricos y formas distintivas.',
      },
      'lima': {
        'Ataúd Limeño': 'Receptáculo funerario que evidencia las complejas prácticas mortuorias de la cultura Lima.',
        'Cetro Cacique Limeño': 'Símbolo de autoridad y poder político de los líderes de la cultura Lima.',
        'Entierro Limeño': 'Representación de las prácticas funerarias que incluyen ofrendas y ajuar ceremonial.',
        'Ídolos Limeños': 'Figuras votivas utilizadas en rituales religiosos de la cultura Lima costeña.',
        'Manto Limeño': 'Textil ceremonial que demuestra la maestría textil de la cultura Lima.',
        'Vasija Limeña': 'Cerámica utilitaria y ceremonial con diseños característicos entrelazados.',
      },
      'loreto': {
        'Adornos Corporales': 'Ornamentos utilizados en ceremonias y como símbolo de identidad cultural amazónica.',
        'Cerámica Loretana': 'Alfarería tradicional de las culturas amazónicas con diseños zoomorfos y antropomorfos.',
        'Figura Antropomorfa Amazónica': 'Representación humana que refleja las creencias y cosmovisión de los pueblos amazónicos.',
        'Herramientas Amazónicas': 'Instrumentos utilizados en la vida cotidiana y actividades de subsistencia de la selva.',
        'Herramientas Loretanas': 'Utensilios especializados para la navegación, caza y pesca en el ambiente fluvial amazónico.',
        'Olla Amazónica': 'Recipiente cerámico utilizado para la preparación de alimentos y bebidas ceremoniales.',
      },
      'puno': {
        'Chullpa Sillustani': 'Torre funeraria preincaica donde se depositaban los restos de la élite de la cultura Colla.',
        'Kero Colla': 'Vaso ceremonial de madera utilizado para beber chicha en ceremonias importantes.',
        'Monolito Pukara': 'Escultura lítica de la cultura Pukara que representa figuras antropomorfas con atributos felínicos.',
        'Textil Colla': 'Tejido característico del altiplano con diseños geométricos y simbología andina.',
        'Tumi Puneño': 'Cuchillo ceremonial de metal con diseño característico utilizado en rituales.',
        'Vasija Ceremonial Pukara': 'Cerámica fina de la cultura Pukara con decoración incisa y pintada policromada.',
      },
    };

    return descriptions[departmentId]?[objectName] ??
        'Objeto cultural de gran valor histórico y patrimonial perteneciente a la rica herencia cultural del departamento de $departmentId.';
  }

  Widget _buildNoARContentScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.department.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: 'RobotoMono',
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.view_in_ar_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Contenido AR No Disponible',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  fontFamily: 'RobotoMono',
                  letterSpacing: -0.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Este departamento aún no cuenta con objetos en realidad aumentada.\n\nEstamos trabajando para agregar más contenido pronto.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'RobotoMono',
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.arrow_back, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Volver',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'RobotoMono',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
