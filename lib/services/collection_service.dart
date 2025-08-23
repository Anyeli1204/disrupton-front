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
      'imageUrl': 'https://example.com/amazonas.jpg',
      'description':
          'Conocido por sus paisajes montañosos y la fortaleza de Kuélap.',
    },
    {
      'id': 'ancash',
      'name': 'Áncash',
      'imageUrl': 'https://example.com/ancash.jpg',
      'description':
          'Hogar del Parque Nacional Huascarán y culturas preincaicas.',
    },
    {
      'id': 'apurimac',
      'name': 'Apurímac',
      'imageUrl': 'https://example.com/apurimac.jpg',
      'description': 'Tierra de tradiciones andinas y paisajes montañosos.',
    },
    {
      'id': 'arequipa',
      'name': 'Arequipa',
      'imageUrl': 'https://example.com/arequipa.jpg',
      'description': 'La Ciudad Blanca, con arquitectura colonial única.',
    },
    {
      'id': 'ayacucho',
      'name': 'Ayacucho',
      'imageUrl': 'https://example.com/ayacucho.jpg',
      'description': 'Centro de la cultura Wari y tradiciones artesanales.',
    },
    {
      'id': 'cajamarca',
      'name': 'Cajamarca',
      'imageUrl': 'https://example.com/cajamarca.jpg',
      'description':
          'Histórica ciudad donde se capturó al último emperador inca.',
    },
    {
      'id': 'callao',
      'name': 'Callao',
      'imageUrl': 'https://example.com/callao.jpg',
      'description': 'Principal puerto del Perú con rica historia marítima.',
    },
    {
      'id': 'cusco',
      'name': 'Cusco',
      'imageUrl': 'https://example.com/cusco.jpg',
      'description':
          'Antigua capital del Imperio Inca y Patrimonio de la Humanidad.',
    },
    {
      'id': 'huancavelica',
      'name': 'Huancavelica',
      'imageUrl': 'https://example.com/huancavelica.jpg',
      'description': 'Rica en tradiciones mineras y cultura andina.',
    },
    {
      'id': 'huanuco',
      'name': 'Huánuco',
      'imageUrl': 'https://example.com/huanuco.jpg',
      'description': 'Puerta de entrada a la Amazonía peruana.',
    },
    {
      'id': 'ica',
      'name': 'Ica',
      'imageUrl': 'https://example.com/ica.jpg',
      'description': 'Famosa por sus vinos, piscos y las líneas de Nazca.',
    },
    {
      'id': 'junin',
      'name': 'Junín',
      'imageUrl': 'https://example.com/junin.jpg',
      'description':
          'Centro de la minería y importantes batallas de independencia.',
    },
    {
      'id': 'la_libertad',
      'name': 'La Libertad',
      'imageUrl': 'https://example.com/la_libertad.jpg',
      'description': 'Hogar de las culturas Moche y Chimú.',
    },
    {
      'id': 'lambayeque',
      'name': 'Lambayeque',
      'imageUrl': 'https://example.com/lambayeque.jpg',
      'description':
          'Cuna de la cultura Sicán y importantes hallazgos arqueológicos.',
    },
    {
      'id': 'lima',
      'name': 'Lima',
      'imageUrl': 'https://example.com/lima.jpg',
      'description': 'Capital del Perú con centro histórico colonial.',
    },
    {
      'id': 'loreto',
      'name': 'Loreto',
      'imageUrl': 'https://example.com/loreto.jpg',
      'description': 'El departamento más grande, corazón de la Amazonía.',
    },
    {
      'id': 'madre_de_dios',
      'name': 'Madre de Dios',
      'imageUrl': 'https://example.com/madre_de_dios.jpg',
      'description': 'Biodiversidad amazónica y comunidades nativas.',
    },
    {
      'id': 'moquegua',
      'name': 'Moquegua',
      'imageUrl': 'https://example.com/moquegua.jpg',
      'description': 'Valle de viñedos y tradición vitivinícola.',
    },
    {
      'id': 'pasco',
      'name': 'Pasco',
      'imageUrl': 'https://example.com/pasco.jpg',
      'description': 'Centro minero y paisajes de puna.',
    },
    {
      'id': 'piura',
      'name': 'Piura',
      'imageUrl': 'https://example.com/piura.jpg',
      'description': 'Playas del norte y cultura Vicús.',
    },
    {
      'id': 'puno',
      'name': 'Puno',
      'imageUrl': 'https://example.com/puno.jpg',
      'description': 'Capital folklórica del Perú, a orillas del Titicaca.',
    },
    {
      'id': 'san_martin',
      'name': 'San Martín',
      'imageUrl': 'https://example.com/san_martin.jpg',
      'description': 'Selva alta con rica biodiversidad.',
    },
    {
      'id': 'tacna',
      'name': 'Tacna',
      'imageUrl': 'https://example.com/tacna.jpg',
      'description': 'Ciudad heroica con importante legado histórico.',
    },
    {
      'id': 'tumbes',
      'name': 'Tumbes',
      'imageUrl': 'https://example.com/tumbes.jpg',
      'description': 'Playas tropicales y manglares únicos.',
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
      'Cerámica tradicional',
      'Textiles ancestrales',
      'Instrumentos musicales',
      'Máscaras ceremoniales',
      'Joyas precolombinas',
      'Utensilios de cocina',
      'Herramientas agrícolas',
      'Arte rupestre',
    ];

    return samples.asMap().entries.map((entry) {
      final index = entry.key;
      final name = entry.value;

      return CulturalObject(
        id: '${departmentId}_object_$index',
        name: '$name de ${_getDepartmentName(departmentId)}',
        imageUrl: 'https://picsum.photos/400/300?random=${departmentId}_$index',
        description:
            'Objeto cultural representativo de la región de ${_getDepartmentName(departmentId)}. '
            'Pieza única que refleja las tradiciones y el patrimonio cultural de la zona.',
        departmentId: departmentId,
        category: 'Artesanía',
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
      imageUrl: 'https://picsum.photos/600/400?random=$objectId',
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
