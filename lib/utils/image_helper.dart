class ImageHelper {
  // Mapeo de departamentos a imágenes locales
  static const Map<String, String> _departmentImages = {
    'amazonas': 'assets/images/departamentos_images/amazonas.png',
    'ancash': 'assets/images/departamentos_images/ancash.png',
    'apurimac': 'assets/images/departamentos_images/apurimac.png',
    'arequipa': 'assets/images/departamentos_images/arequipa.png',
    'ayacucho': 'assets/images/departamentos_images/ayacucho.png',
    'cajamarca': 'assets/images/departamentos_images/cajamarca.png',
    'cusco': 'assets/images/departamentos_images/cusco.png',
    'huancavelica': 'assets/images/departamentos_images/huancavelica.png',
    'huanuco': 'assets/images/departamentos_images/huanuco.png',
    'ica': 'assets/images/departamentos_images/ica.png',
    'junin': 'assets/images/departamentos_images/junin.png',
    'la_libertad': 'assets/images/departamentos_images/la_libertad.png',
    'lambayeque': 'assets/images/departamentos_images/lambayeque.png',
    'lima': 'assets/images/departamentos_images/lima.png',
    'loreto': 'assets/images/departamentos_images/loreto.png',
    'madre_de_dios': 'assets/images/departamentos_images/madre_de_dios.png',
    'moquegua': 'assets/images/departamentos_images/moquegua.png',
    'pasco': 'assets/images/departamentos_images/pasco.png',
    'piura': 'assets/images/departamentos_images/piura.png',
    'puno': 'assets/images/departamentos_images/puno.png',
    'san_martin': 'assets/images/departamentos_images/san_martin.png',
    'tacna': 'assets/images/departamentos_images/tacna.png',
    'tumbes': 'assets/images/departamentos_images/tumbes.png',
    'ucayali': 'assets/images/departamentos_images/ucayali.png',
  };

  // Mapeo de departamentos a imágenes AR (nombres descriptivos)
  static const Map<String, List<String>> _departmentARImages = {
    'arequipa': [
      'assets/images/ar_images/arequipa_ar_images/batan_arequipeño.png',
      'assets/images/ar_images/arequipa_ar_images/disco_solar_arequipeño.png',
      'assets/images/ar_images/arequipa_ar_images/manto_arequipeño.png',
      'assets/images/ar_images/arequipa_ar_images/monolito_arequipeño.png',
      'assets/images/ar_images/arequipa_ar_images/tumis_arequipeños.png',
      'assets/images/ar_images/arequipa_ar_images/vasija_arequipeña.png',
    ],
    'cusco': [
      'assets/images/ar_images/cusco_ar_images/idolo_llamita.png',
      'assets/images/ar_images/cusco_ar_images/machete_incaico.png',
      'assets/images/ar_images/cusco_ar_images/musicos_incaicos.png',
      'assets/images/ar_images/cusco_ar_images/ofrenda_incaica.png',
      'assets/images/ar_images/cusco_ar_images/quipus_incaico.png',
      'assets/images/ar_images/cusco_ar_images/vasijas_incaicas.png',
    ],
    'ica': [
      'assets/images/ar_images/ica_ar_images/cantaro_paracas.png',
      'assets/images/ar_images/ica_ar_images/craneo_paracas.png',
      'assets/images/ar_images/ica_ar_images/cuchillo_ceremonial.png',
      'assets/images/ar_images/ica_ar_images/manto_paracas.png',
      'assets/images/ar_images/ica_ar_images/momia_paracas.png',
      'assets/images/ar_images/ica_ar_images/vaso_chincha.png',
    ],
    'lima': [
      'assets/images/ar_images/lima_ar_images/ataud_limeño.png',
      'assets/images/ar_images/lima_ar_images/cetro_cacique_limeño.png',
      'assets/images/ar_images/lima_ar_images/entierro_limeño.png',
      'assets/images/ar_images/lima_ar_images/idolos_limeños.png',
      'assets/images/ar_images/lima_ar_images/manto_limeño.png',
      'assets/images/ar_images/lima_ar_images/vasija_limeña.png',
    ],
    'loreto': [
      'assets/images/ar_images/loreto_ar_images/adornos_corporales_loreto.png',
      'assets/images/ar_images/loreto_ar_images/ceramica_loretana.png',
      'assets/images/ar_images/loreto_ar_images/figura_antropomorfa_amazonica.png',
      'assets/images/ar_images/loreto_ar_images/herramientas_amazonicas.png',
      'assets/images/ar_images/loreto_ar_images/herramientas_loretanas.png',
      'assets/images/ar_images/loreto_ar_images/olla_amazonica.png',
    ],
    'puno': [
      'assets/images/ar_images/puno_ar_images/chullpa_sillustani.png',
      'assets/images/ar_images/puno_ar_images/kero_colla.png',
      'assets/images/ar_images/puno_ar_images/monolito_pukara.png',
      'assets/images/ar_images/puno_ar_images/textil_colla.png',
      'assets/images/ar_images/puno_ar_images/tumi_puneño.png',
      'assets/images/ar_images/puno_ar_images/vasija_ceremonial_pukara.png',
    ],
  };

  // Imágenes de eventos (nombres descriptivos)
  static const List<String> eventImages = [
    'assets/images/event_images/aprendiendo_pisar_uva.jpeg',
    'assets/images/event_images/concurso_danza_de_las_tijeras.jpeg',
    'assets/images/event_images/concurso_nacional_de_marinera.jpeg',
    'assets/images/event_images/festividad_koillur_ritti.jpeg',
    'assets/images/event_images/inti_raymi.jpeg',
    'assets/images/event_images/procesion_señor_de_los_milagros.jpeg',
  ];

  // Imágenes de posts (nombres descriptivos)
  static const List<String> postImages = [
    'assets/images/post_images/aprendiendo_tejidos_andinos.jpeg',
    'assets/images/post_images/visita_andenes_cotabamba.jpeg',
    'assets/images/post_images/visita_kuelap.jpeg',
    'assets/images/post_images/visita_lineas_nazca.jpeg',
    'assets/images/post_images/visita_machu_picchu.jpeg',
    'assets/images/post_images/visita_plaza_cusco.jpeg',
  ];

  // Imágenes de productos (nombres descriptivos)
  static const List<String> productImages = [
    'assets/images/productos_images/ceramica_burilada.jpeg',
    'assets/images/productos_images/manto_andino.jpeg',
    'assets/images/productos_images/muñecas_andinas.jpeg',
    'assets/images/productos_images/plato_de_arcilla_andino.jpeg',
    'assets/images/productos_images/retablo.jpeg',
    'assets/images/productos_images/toro_pucara.jpeg',
  ];

  // Imágenes de servicios (nombres descriptivos)
  static const List<String> serviceImages = [
    'assets/images/servicios_images/clases_cocina_peruana.jpeg',
    'assets/images/servicios_images/clases_de_tejido_inca.jpeg',
    'assets/images/servicios_images/expedicion_huascaran.jpeg',
    'assets/images/servicios_images/expedicion_machu_picchu.jpeg',
    'assets/images/servicios_images/paseo_noturno_plaza_lima.jpeg',
    'assets/images/servicios_images/servicio_cata_de_vinos.jpeg',
  ];

  static const Map<String, String> _placeholderImages = {
    'default': 'assets/images/minkar.png',
  };

  /// Obtiene una imagen local para un departamento
  static String getDepartmentImage(String departmentId) {
    final normalizedId = departmentId.toLowerCase().trim();
    return _departmentImages[normalizedId] ?? _placeholderImages['default']!;
  }

  /// Obtiene imágenes AR para un departamento
  static List<String> getDepartmentARImages(String departmentId) {
    final normalizedId = departmentId.toLowerCase().trim();
    return _departmentARImages[normalizedId] ?? [];
  }

  /// Obtiene una imagen AR específica para un departamento por índice
  static String getDepartmentARImage(String departmentId, int index) {
    final images = getDepartmentARImages(departmentId);
    if (images.isEmpty) return _placeholderImages['default']!;
    return images[index % images.length];
  }

  /// Obtiene una imagen de evento por índice
  static String getEventImage(int index) {
    return eventImages[index % eventImages.length];
  }

  /// Obtiene una imagen de post por índice
  static String getPostImage(int index) {
    return postImages[index % postImages.length];
  }

  /// Obtiene una imagen de producto por índice
  static String getProductImage(int index) {
    return productImages[index % productImages.length];
  }

  /// Obtiene una imagen de servicio por índice
  static String getServiceImage(int index) {
    return serviceImages[index % serviceImages.length];
  }

  /// Obtiene una imagen por hash del ID (para distribución consistente)
  static String getImageByHash(List<String> images, String id) {
    if (images.isEmpty) return _placeholderImages['default']!;
    final hash = id.hashCode.abs();
    return images[hash % images.length];
  }

  /// Obtiene el placeholder por defecto
  static String getDefaultPlaceholder() {
    return _placeholderImages['default']!;
  }

  /// Verifica si un departamento tiene imágenes AR
  static bool hasARImages(String departmentId) {
    final normalizedId = departmentId.toLowerCase().trim();
    return _departmentARImages.containsKey(normalizedId);
  }

  /// Obtiene el nombre del evento por índice
  static String getEventName(int index) {
    const eventNames = [
      'Aprendiendo a Pisar Uva',
      'Concurso Danza de las Tijeras',
      'Concurso Nacional de Marinera',
      'Festividad Qoyllur Rit\'i',
      'Inti Raymi',
      'Procesión Señor de los Milagros',
    ];
    return eventNames[index % eventNames.length];
  }

  /// Obtiene el nombre del producto por índice
  static String getProductName(int index) {
    const productNames = [
      'Cerámica Burilada',
      'Manto Andino',
      'Muñecas Andinas',
      'Plato de Arcilla Andino',
      'Retablo Ayacuchano',
      'Toro de Pucará',
    ];
    return productNames[index % productNames.length];
  }

  /// Obtiene el nombre del servicio por índice
  static String getServiceName(int index) {
    const serviceNames = [
      'Clases de Cocina Peruana',
      'Clases de Tejido Inca',
      'Expedición Huascarán',
      'Expedición Machu Picchu',
      'Paseo Nocturno Plaza de Lima',
      'Cata de Vinos',
    ];
    return serviceNames[index % serviceNames.length];
  }

  /// Obtiene nombres descriptivos de objetos AR por departamento e índice
  static String getARObjectName(String departmentId, int imageIndex) {
    final normalizedId = departmentId.toLowerCase().trim();

    const arObjectNames = {
      'arequipa': [
        'Batán Arequipeño',
        'Disco Solar Arequipeño',
        'Manto Arequipeño',
        'Monolito Arequipeño',
        'Tumis Arequipeños',
        'Vasija Arequipeña',
      ],
      'cusco': [
        'Ídolo Llamita',
        'Machete Incaico',
        'Músicos Incaicos',
        'Ofrenda Incaica',
        'Quipus Incaico',
        'Vasijas Incaicas',
      ],
      'ica': [
        'Cántaro Paracas',
        'Cráneo Paracas',
        'Cuchillo Ceremonial',
        'Manto Paracas',
        'Momia Paracas',
        'Vaso Chincha',
      ],
      'lima': [
        'Ataúd Limeño',
        'Cetro Cacique Limeño',
        'Entierro Limeño',
        'Ídolos Limeños',
        'Manto Limeño',
        'Vasija Limeña',
      ],
      'loreto': [
        'Adornos Corporales',
        'Cerámica Loretana',
        'Figura Antropomorfa Amazónica',
        'Herramientas Amazónicas',
        'Herramientas Loretanas',
        'Olla Amazónica',
      ],
      'puno': [
        'Chullpa Sillustani',
        'Kero Colla',
        'Monolito Pukara',
        'Textil Colla',
        'Tumi Puneño',
        'Vasija Ceremonial Pukara',
      ],
    };

    final names = arObjectNames[normalizedId];
    if (names == null || names.isEmpty) return 'Objeto Cultural';
    return names[imageIndex % names.length];
  }

  /// Obtiene el nombre del departamento capitalizado
  static String getDepartmentDisplayName(String departmentId) {
    const departmentNames = {
      'arequipa': 'Arequipa',
      'cusco': 'Cusco',
      'ica': 'Ica',
      'lima': 'Lima',
      'loreto': 'Loreto',
      'puno': 'Puno',
    };
    return departmentNames[departmentId.toLowerCase()] ?? departmentId;
  }
}
