class ImageHelper {
  // Mapeo rápido de región -> términos de búsqueda icónicos
  static const Map<String, String> _regionQueries = {
    'amazonas': 'Kuelap,Chachapoyas,Peru',
    'ancash': 'Huascaran,Laguna Paron,Cordillera Blanca,Peru',
    'apurimac': 'Apurimac Canyon,Peru',
    'arequipa': 'Arequipa,Colca,Peru',
    'ayacucho': 'Ayacucho,Wari,Peru',
    'cajamarca': 'Cajamarca,Otuzco,Baños del Inca,Peru',
    'callao': 'Callao,Real Felipe,La Punta,Peru',
    'cusco': 'Cusco,Machu Picchu,Sacsayhuaman,Peru',
    'huancavelica': 'Huancavelica,Andes,Peru',
    'huanuco': 'Huanuco,Kotosh,Peru',
    'ica': 'Ica,Huacachina,Nazca,Peru',
    'junin': 'Junin,Lake,Valle del Mantaro,Peru',
    'la_libertad': 'La Libertad,Chan Chan,Huanchaco,Peru',
    'lambayeque': 'Lambayeque,Sipan,Tucume,Peru',
    'lima': 'Lima,Plaza Mayor,Miraflores,Peru',
    'loreto': 'Loreto,Amazon River,Iquitos,Peru',
    'madre_de_dios': 'Tambopata,Madre de Dios,Peru',
    'moquegua': 'Moquegua,Vineyards,Peru',
    'pasco': 'Huayllay,Pasco,Peru',
    'piura': 'Piura,Mancora,Catacaos,Peru',
    'puno': 'Puno,Lake Titicaca,Uros,Peru',
    'san_martin': 'San Martin,Tarapoto,Peru',
    'tacna': 'Tacna,Arco Parabolico,Peru',
    'tumbes': 'Tumbes,Manglares,Zorritos,Peru',
    'ucayali': 'Ucayali,Pucallpa,Yarinacocha,Peru',
  };
  static const Map<String, String> _fallbackImages = {
    'amazonas': 'assets/images/regions/amazonas.jpg',
    'ancash': 'assets/images/regions/ancash.jpg',
    'cusco': 'assets/images/regions/cusco.jpg',
    'ica': 'assets/images/regions/ica.jpg',
    'puno': 'assets/images/regions/puno.jpg',
    'arequipa': 'assets/images/regions/arequipa.jpg',
    'la_libertad': 'assets/images/regions/la_libertad.jpg',
    'lambayeque': 'assets/images/regions/lambayeque.jpg',
    'lima': 'assets/images/regions/lima.jpg',
    'loreto': 'assets/images/regions/loreto.jpg',
  };

  static const Map<String, String> _placeholderImages = {
    'arquitectura': 'assets/images/categories/arquitectura.jpg',
    'ceramica': 'assets/images/categories/ceramica.jpg',
    'textileria': 'assets/images/categories/textileria.jpg',
    'orfebreria': 'assets/images/categories/orfebreria.jpg',
    'escultura': 'assets/images/categories/escultura.jpg',
    'geoglifos': 'assets/images/categories/geoglifos.jpg',
    'default': 'assets/images/placeholder.jpg',
  };

  /// Obtiene una imagen de respaldo para una región
  static String getFallbackRegionImage(String regionId) {
    return _fallbackImages[regionId] ?? _placeholderImages['default']!;
  }

  /// Obtiene una imagen de respaldo para una categoría
  static String getFallbackCategoryImage(String category) {
    final key = category.toLowerCase().replaceAll(' ', '');
    if (key.contains('arquitectura'))
      return _placeholderImages['arquitectura']!;
    if (key.contains('cerámica')) return _placeholderImages['ceramica']!;
    if (key.contains('textil')) return _placeholderImages['textileria']!;
    if (key.contains('orfebrería')) return _placeholderImages['orfebreria']!;
    if (key.contains('escultura')) return _placeholderImages['escultura']!;
    if (key.contains('geoglifo')) return _placeholderImages['geoglifos']!;

    return _placeholderImages['default']!;
  }

  /// Obtiene URLs de imágenes que funcionan bien
  static List<String> getWorkingImageUrls() {
    // Usamos Unsplash Source para evitar IDs fijos y obtener fotos contextualizadas
    return [
      'https://source.unsplash.com/800x600/?Peru,Andes',
      'https://source.unsplash.com/800x600/?Peru,Amazon',
      'https://source.unsplash.com/800x600/?Peru,Coast',
      'https://source.unsplash.com/800x600/?Peru,Culture',
      'https://source.unsplash.com/800x600/?Peru,Archaeology',
      'https://source.unsplash.com/800x600/?Peru,Architecture',
      'https://source.unsplash.com/800x600/?Peru,Mountains',
      'https://source.unsplash.com/800x600/?Peru,Desert',
      'https://source.unsplash.com/800x600/?Peru,Lake',
      'https://source.unsplash.com/800x600/?Peru,Rainforest',
    ];
  }

  /// Obtiene una URL de imagen que funciona para una región específica
  static String getWorkingImageForRegion(String regionId) {
    final query = _regionQueries[regionId] ?? 'Peru,Nature';
    return 'https://source.unsplash.com/800x600/?$query';
  }
}
