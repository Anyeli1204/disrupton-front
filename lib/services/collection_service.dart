import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/collection_models.dart';
import '../config/api_config.dart';

class CollectionService {
  // Datos estáticos de los 24 departamentos del Perú
  static const List<Map<String, dynamic>> _peruDepartments = [
    {
      'id': 'amazonas',
      'name': 'Amazonas',
      // Kuélap / Chachapoyas - Paisaje montañoso
      'imageUrl':
          'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=800&h=600&fit=crop&crop=center',
      'description':
          'Conocido por sus paisajes montañosos y la fortaleza de Kuélap.',
    },
    {
      'id': 'ancash',
      'name': 'Áncash',
      // Huascarán / Cordillera Blanca - Montañas nevadas
      'imageUrl':
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=600&fit=crop&crop=center',
      'description':
          'Hogar del Parque Nacional Huascarán y culturas preincaicas.',
    },
    {
      'id': 'apurimac',
      'name': 'Apurímac',
      // Cañón del Apurímac - Paisaje andino
      'imageUrl':
          'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=800&h=600&fit=crop&crop=center',
      'description': 'Tierra de tradiciones andinas y paisajes montañosos.',
    },
    {
      'id': 'arequipa',
      'name': 'Arequipa',
      // Monasterio de Santa Catalina / Arequipa colonial
      'imageUrl':
          'https://images.unsplash.com/photo-1582562124811-c09040d0a901?w=800&h=600&fit=crop&crop=center',
      'description': 'La Ciudad Blanca, con arquitectura colonial única.',
    },
    {
      'id': 'ayacucho',
      'name': 'Ayacucho',
      // Iglesias coloniales / Tradiciones artesanales
      'imageUrl':
          'https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=800&h=600&fit=crop&crop=center',
      'description': 'Centro de la cultura Wari y tradiciones artesanales.',
    },
    {
      'id': 'cajamarca',
      'name': 'Cajamarca',
      // Ventanillas de Otuzco / Baños del Inca
      'imageUrl':
          'https://images.unsplash.com/photo-1586500036706-41963de24d8b?w=800&h=600&fit=crop&crop=center',
      'description':
          'Histórica ciudad donde se capturó al último emperador inca.',
    },
    {
      'id': 'callao',
      'name': 'Callao',
      // Real Felipe / La Punta - Puerto marítimo
      'imageUrl':
          'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800&h=600&fit=crop&crop=center',
      'description': 'Principal puerto del Perú con rica historia marítima.',
    },
    {
      'id': 'cusco',
      'name': 'Cusco',
      // Machu Picchu / Sacsayhuamán
      'imageUrl':
          'https://images.unsplash.com/photo-1526392060635-9d6019884377?w=800&h=600&fit=crop&crop=center',
      'description':
          'Antigua capital del Imperio Inca y Patrimonio de la Humanidad.',
    },
    {
      'id': 'huancavelica',
      'name': 'Huancavelica',
      // Paisaje andino de Huancavelica
      'imageUrl':
          'https://images.unsplash.com/photo-1464822759844-d150baec93d1?w=800&h=600&fit=crop&crop=center',
      'description': 'Rica en tradiciones mineras y cultura andina.',
    },
    {
      'id': 'huanuco',
      'name': 'Huánuco',
      // Templo de Kotosh / Paisaje amazónico
      'imageUrl':
          'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&h=600&fit=crop&crop=center',
      'description': 'Puerta de entrada a la Amazonía peruana.',
    },
    {
      'id': 'ica',
      'name': 'Ica',
      // Huacachina / Líneas de Nazca - Desierto
      'imageUrl':
          'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?w=800&h=600&fit=crop&crop=center',
      'description': 'Famosa por sus vinos, piscos y las líneas de Nazca.',
    },
    {
      'id': 'junin',
      'name': 'Junín',
      // Lago Junín / Valle del Mantaro
      'imageUrl':
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=600&fit=crop&crop=center',
      'description':
          'Centro de la minería y importantes batallas de independencia.',
    },
    {
      'id': 'la_libertad',
      'name': 'La Libertad',
      // Chan Chan / Huanchaco - Costa norte
      'imageUrl':
          'https://images.unsplash.com/photo-1583416750470-965b2707b355?w=800&h=600&fit=crop&crop=center',
      'description': 'Hogar de las culturas Moche y Chimú.',
    },
    {
      'id': 'lambayeque',
      'name': 'Lambayeque',
      // Museo Tumbas Reales de Sipán / Túcume
      'imageUrl':
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=600&fit=crop&crop=center',
      'description':
          'Cuna de la cultura Sicán y importantes hallazgos arqueológicos.',
    },
    {
      'id': 'lima',
      'name': 'Lima',
      // Plaza Mayor / Costa de Miraflores
      'imageUrl':
          'https://images.unsplash.com/photo-1531968455001-5c5272a41129?w=800&h=600&fit=crop&crop=center',
      'description': 'Capital del Perú con centro histórico colonial.',
    },
    {
      'id': 'loreto',
      'name': 'Loreto',
      // Amazonas / Iquitos / Belén
      'imageUrl':
          'https://images.unsplash.com/photo-1520637736862-4d197d17c75a?w=800&h=600&fit=crop&crop=center',
      'description': 'El departamento más grande, corazón de la Amazonía.',
    },
    {
      'id': 'madre_de_dios',
      'name': 'Madre de Dios',
      // Tambopata / Puerto Maldonado
      'imageUrl':
          'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&h=600&fit=crop&crop=center',
      'description': 'Biodiversidad amazónica y comunidades nativas.',
    },
    {
      'id': 'moquegua',
      'name': 'Moquegua',
      // Valle y viñedos de Moquegua
      'imageUrl':
          'https://images.unsplash.com/photo-1596142332133-327e2a4e4189?w=800&h=600&fit=crop&crop=center',
      'description': 'Valle de viñedos y tradición vitivinícola.',
    },
    {
      'id': 'pasco',
      'name': 'Pasco',
      // Bosque de Piedras de Huayllay
      'imageUrl':
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=600&fit=crop&crop=center',
      'description': 'Centro minero y paisajes de puna.',
    },
    {
      'id': 'piura',
      'name': 'Piura',
      // Máncora / Catacaos
      'imageUrl':
          'https://images.unsplash.com/photo-1439066615861-d1af74d74000?w=800&h=600&fit=crop&crop=center',
      'description': 'Playas del norte y cultura Vicús.',
    },
    {
      'id': 'puno',
      'name': 'Puno',
      // Lago Titicaca / Islas Uros
      'imageUrl':
          'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=800&h=600&fit=crop&crop=center',
      'description': 'Capital folklórica del Perú, a orillas del Titicaca.',
    },
    {
      'id': 'san_martin',
      'name': 'San Martín',
      // Tarapoto / Catarata Ahuashiyacu
      'imageUrl':
          'https://images.unsplash.com/photo-1520637836862-4d197d17c75a?w=800&h=600&fit=crop&crop=center',
      'description': 'Selva alta con rica biodiversidad.',
    },
    {
      'id': 'tacna',
      'name': 'Tacna',
      // Arco Parabólico de Tacna
      'imageUrl':
          'https://images.unsplash.com/photo-1574263867128-0876df75bfe4?w=800&h=600&fit=crop&crop=center',
      'description': 'Ciudad heroica con importante legado histórico.',
    },
    {
      'id': 'tumbes',
      'name': 'Tumbes',
      // Manglares de Tumbes / Zorritos
      'imageUrl':
          'https://images.unsplash.com/photo-1439066615861-d1af74d74000?w=800&h=600&fit=crop&crop=center',
      'description': 'Playas tropicales y manglares únicos.',
    },
    {
      'id': 'ucayali',
      'name': 'Ucayali',
      // Pucallpa / Yarinacocha
      'imageUrl':
          'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&h=600&fit=crop&crop=center',
      'description': 'Corazón de la Amazonía peruana con culturas vivas.',
    },
  ];

  /// Obtiene todos los departamentos del Perú
  Future<List<Department>> getDepartments() async {
    try {
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 500));

      return _peruDepartments
          .map((data) => Department(
                id: data['id'],
                name: data['name'],
                imageUrl: data['imageUrl'],
                description: data['description'],
                culturalObjectIds: [], // Se llenarán desde el backend más adelante
              ))
          .toList();
    } catch (e) {
      throw Exception('Error al cargar departamentos: $e');
    }
  }

  /// Obtiene objetos culturales de un departamento específico
  Future<List<CulturalObject>> getCulturalObjectsByDepartment(
      String departmentId) async {
    try {
      final response = await http
          .get(
            Uri.parse(
                '${ApiConfig.baseUrl}/api/cultural-objects/department/$departmentId'),
            headers: ApiConfig.defaultHeaders,
          )
          .timeout(const Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CulturalObject.fromJson(json)).toList();
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback con datos de ejemplo para desarrollo
      return _generateSampleCulturalObjects(departmentId);
    }
  }

  /// Obtiene un objeto cultural específico por ID
  Future<CulturalObject?> getCulturalObjectById(String objectId) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/api/cultural-objects/$objectId'),
            headers: ApiConfig.defaultHeaders,
          )
          .timeout(const Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CulturalObject.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      // Fallback con datos de ejemplo
      return _generateSampleCulturalObject(objectId);
    }
  }

  /// Genera objetos culturales de ejemplo para desarrollo
  List<CulturalObject> _generateSampleCulturalObjects(String departmentId) {
    final samples = [
      {
        'name': 'Cerámica tradicional',
        'category': 'Cerámica',
        'imageUrl':
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop&crop=center',
      },
      {
        'name': 'Textiles ancestrales',
        'category': 'Textilería',
        'imageUrl':
            'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=400&h=300&fit=crop&crop=center',
      },
      {
        'name': 'Instrumentos musicales',
        'category': 'Música',
        'imageUrl':
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=300&fit=crop&crop=center',
      },
      {
        'name': 'Máscaras ceremoniales',
        'category': 'Ritual',
        'imageUrl':
            'https://images.unsplash.com/photo-1578928032765-0ad5ac882d2d?w=400&h=300&fit=crop&crop=center',
      },
      {
        'name': 'Joyas precolombinas',
        'category': 'Orfebrería',
        'imageUrl':
            'https://images.unsplash.com/photo-1506630448388-4e683c67ddb0?w=400&h=300&fit=crop&crop=center',
      },
      {
        'name': 'Utensilios de cocina',
        'category': 'Utensilio',
        'imageUrl':
            'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop&crop=center',
      },
      {
        'name': 'Herramientas agrícolas',
        'category': 'Herramienta',
        'imageUrl':
            'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400&h=300&fit=crop&crop=center',
      },
      {
        'name': 'Arte rupestre',
        'category': 'Arte',
        'imageUrl':
            'https://images.unsplash.com/photo-1539650116574-75c0c6d73f6e?w=400&h=300&fit=crop&crop=center',
      },
    ];

    return samples.asMap().entries.map((entry) {
      final index = entry.key;
      final sample = entry.value;

      return CulturalObject(
        id: '${departmentId}_object_$index',
        name: '${sample['name']} de ${_getDepartmentName(departmentId)}',
        imageUrl: sample['imageUrl']!,
        description:
            'Objeto cultural representativo de la región de ${_getDepartmentName(departmentId)}. '
            'Pieza única que refleja las tradiciones y el patrimonio cultural de la zona.',
        departmentId: departmentId,
        category: sample['category']!,
        createdAt: DateTime.now().subtract(Duration(days: index * 30)),
        additionalInfo: {
          'material': 'Diversos materiales tradicionales',
          'epoca': 'Época prehispánica - colonial',
          'uso': 'Ceremonial y cotidiano',
        },
      );
    }).toList();
  }

  /// Genera un objeto cultural de ejemplo específico
  CulturalObject _generateSampleCulturalObject(String objectId) {
    return CulturalObject(
      id: objectId,
      name: 'Objeto Cultural Ejemplo',
      // Imagen de cerámica peruana
      imageUrl:
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=600&h=400&fit=crop&crop=center',
      description: 'Descripción detallada del objeto cultural. '
          'Este es un ejemplo de objeto cultural con información relevante '
          'sobre su origen, uso y significado histórico.',
      departmentId: 'cusco',
      category: 'Cerámica',
      createdAt: DateTime.now(),
      additionalInfo: {
        'material': 'Arcilla cocida',
        'epoca': 'Época inca',
        'uso': 'Ceremonial',
        'conservacion': 'Buena',
      },
    );
  }

  /// Obtiene el nombre del departamento por ID
  String _getDepartmentName(String departmentId) {
    final dept = _peruDepartments.firstWhere(
      (d) => d['id'] == departmentId,
      orElse: () => {'name': 'Desconocido'},
    );
    return dept['name'];
  }
}
