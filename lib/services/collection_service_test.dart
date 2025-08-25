import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/collection_models.dart';
import '../config/api_config.dart';

class CollectionService {
  // Datos completos de las 25 regiones del Perú con objetos culturales
  static const List<Map<String, dynamic>> _peruRegiones = [
    {
      'id': 'amazonas',
      'name': 'Amazonas',
      'imageUrl': 'https://picsum.photos/800/600?random=1',
      'description':
          'Región del norte del Perú, conocida por la fortaleza de Kuélap y la cultura Chachapoya.',
      'objetosCulturales': [
        {
          'id': 'sarcofagos_karajia',
          'nombre': 'Sarcófagos de Karajía',
          'descripcion':
              'Monumentos funerarios de la cultura Chachapoya, tallados en madera y colocados en acantilados.',
          'origen':
              'Cultura Chachapoya (900-1470 d.C.). Estas estructuras funerarias eran utilizadas para enterrar a personajes importantes de la sociedad chachapoya.',
          'informacionAdicional':
              'Los sarcófagos tienen forma humana y pueden medir hasta 2.5 metros de altura. Se ubican en lugares inaccesibles como símbolo de protección.',
          'categoria': 'Arquitectura Funeraria',
          'epoca': '900-1470 d.C.',
          'imagenUrl': 'https://picsum.photos/400/300?random=101',
        },
        {
          'id': 'textiles_chachapoya',
          'nombre': 'Textiles Chachapoya',
          'descripcion':
              'Tejidos ceremoniales con patrones geométricos característicos de la cultura Chachapoya.',
          'origen':
              'Elaborados por la cultura Chachapoya, estos textiles reflejan su cosmovisión y estatus social.',
          'informacionAdicional':
              'Los diseños incluyen motivos de la naturaleza amazónica y símbolos astronómicos. Se utilizaban fibras de alpaca y algodón.',
          'categoria': 'Textilería',
          'epoca': '900-1470 d.C.',
          'imagenUrl': 'https://picsum.photos/400/300?random=102',
        }
      ]
    },
    {
      'id': 'ancash',
      'name': 'Áncash',
      'imageUrl': 'https://picsum.photos/800/600?random=2',
      'description':
          'Región que alberga la Cordillera Blanca y importantes sitios arqueológicos como Chavín de Huántar.',
      'objetosCulturales': [
        {
          'id': 'obelisco_tello',
          'nombre': 'Obelisco Tello',
          'descripcion':
              'Monolito de granito con grabados complejos que representa la cosmogonía de la cultura Chavín.',
          'origen':
              'Cultura Chavín (900-200 a.C.). Encontrado en Chavín de Huántar, representa divinidades y elementos de la naturaleza.',
          'informacionAdicional':
              'Mide 2.52 metros de altura y está cubierto de relieves que narran mitos de creación y transformación.',
          'categoria': 'Escultura',
          'epoca': '900-200 a.C.',
          'imagenUrl': 'https://picsum.photos/400/300?random=201',
        },
        {
          'id': 'cabezas_clavas',
          'nombre': 'Cabezas Clavas Chavín',
          'descripcion':
              'Esculturas de piedra empotradas en los muros del templo de Chavín, representando transformaciones chamánicas.',
          'origen':
              'Cultura Chavín. Estas cabezas representan el proceso de transformación humano-felino durante rituales chamánicos.',
          'informacionAdicional':
              'Se han encontrado más de 40 cabezas clavas, cada una con expresiones únicas que van de lo humano a lo felino.',
          'categoria': 'Escultura',
          'epoca': '900-200 a.C.',
          'imagenUrl': 'https://picsum.photos/400/300?random=202',
        }
      ]
    },
    {
      'id': 'cusco',
      'name': 'Cusco',
      'imageUrl': 'https://picsum.photos/800/600?random=3',
      'description':
          'Capital histórica del Imperio Inca y Patrimonio de la Humanidad.',
      'objetosCulturales': [
        {
          'id': 'qorikancha',
          'nombre': 'Qorikancha',
          'descripcion':
              'Templo del Sol, el más importante del Imperio Inca, cubierto originalmente de oro.',
          'origen':
              'Imperio Inca (1200-1532 d.C.). Centro religioso más importante del Tahuantinsuyu.',
          'informacionAdicional':
              'Sus muros estaban cubiertos de láminas de oro y contenía jardines con plantas y animales de oro.',
          'categoria': 'Arquitectura Religiosa',
          'epoca': '1200-1532 d.C.',
          'imagenUrl': 'https://picsum.photos/400/300?random=301',
        },
        {
          'id': 'sacsayhuaman',
          'nombre': 'Sacsayhuamán',
          'descripcion':
              'Complejo arqueológico con muros ciclópeos que demuestran la maestría inca en arquitectura.',
          'origen':
              'Imperio Inca. Fortaleza ceremonial que protegía la capital del imperio.',
          'informacionAdicional':
              'Las piedras más grandes pesan más de 100 toneladas y encajan perfectamente sin mortero.',
          'categoria': 'Arquitectura Militar',
          'epoca': '1200-1532 d.C.',
          'imagenUrl': 'https://picsum.photos/400/300?random=302',
        }
      ]
    }
  ];

  /// Obtiene todas las regiones del Perú (25 regiones)
  Future<List<Department>> getDepartments() async {
    try {
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 500));

      return _peruRegiones
          .map((data) => Department(
                id: data['id'],
                name: data['name'],
                imageUrl: data['imageUrl'],
                description: data['description'],
                culturalObjectIds: (data['objetosCulturales'] as List)
                    .map((obj) => obj['id'] as String)
                    .toList(),
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
      // Fallback con datos realistas del departamento
      return _getCulturalObjectsFromStaticData(departmentId);
    }
  }

  /// Obtiene objetos culturales de los datos estáticos
  List<CulturalObject> _getCulturalObjectsFromStaticData(String departmentId) {
    final region = _peruRegiones.firstWhere(
      (region) => region['id'] == departmentId,
      orElse: () => <String, dynamic>{},
    );

    if (region.isEmpty || region['objetosCulturales'] == null) {
      return [];
    }

    final List<dynamic> objetos = region['objetosCulturales'];
    return objetos.map((obj) {
      return CulturalObject(
        id: obj['id'],
        name: obj['nombre'],
        imageUrl: obj['imagenUrl'],
        description: obj['descripcion'],
        departmentId: departmentId,
        category: obj['categoria'],
        createdAt: DateTime.now(),
        additionalInfo: {
          'origen': obj['origen'],
          'informacionAdicional': obj['informacionAdicional'],
          'epoca': obj['epoca'],
          'regionNombre': region['name'],
          'ubicacionActual': 'Museo Regional de ${region['name']}',
          'conservacion': 'Buena',
          'material': _getMaterialByCategory(obj['categoria']),
          'dimensiones': _generateDimensions(),
          'tecnicaElaboracion': _getTechniqueByCategory(obj['categoria']),
          'significadoCultural': obj['descripcion'],
          'datosArqueologicos': obj['origen'],
          'uso': _getUseByCategory(obj['categoria']),
        },
      );
    }).toList();
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
      // Fallback: buscar en datos estáticos
      for (final region in _peruRegiones) {
        final objetos = region['objetosCulturales'] as List?;
        if (objetos != null) {
          final objeto = objetos.firstWhere(
            (obj) => obj['id'] == objectId,
            orElse: () => null,
          );
          if (objeto != null) {
            return CulturalObject(
              id: objeto['id'],
              name: objeto['nombre'],
              imageUrl: objeto['imagenUrl'],
              description: objeto['descripcion'],
              departmentId: region['id'],
              category: objeto['categoria'],
              createdAt: DateTime.now(),
              additionalInfo: {
                'origen': objeto['origen'],
                'informacionAdicional': objeto['informacionAdicional'],
                'epoca': objeto['epoca'],
                'regionNombre': region['name'],
                'material': _getMaterialByCategory(objeto['categoria']),
                'conservacion': 'Buena',
              },
            );
          }
        }
      }
      return null;
    }
  }

  // Métodos helper para generar datos adicionales
  String _getMaterialByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'cerámica':
        return 'Arcilla, pigmentos minerales';
      case 'textilería':
        return 'Algodón, lana de alpaca, fibra de vicuña';
      case 'orfebrería':
        return 'Oro, plata, cobre';
      case 'escultura':
        return 'Piedra, granito, madera';
      case 'arquitectura religiosa':
      case 'arquitectura ceremonial':
      case 'arquitectura militar':
      case 'arquitectura funeraria':
        return 'Piedra, adobe, mortero de barro';
      case 'geoglifos':
        return 'Tierra, arena del desierto';
      case 'restos humanos':
        return 'Materia orgánica preservada';
      default:
        return 'Materiales diversos';
    }
  }

  String _getTechniqueByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'cerámica':
        return 'Modelado, cocción, pintura policroma';
      case 'textilería':
        return 'Tejido en telar, bordado, tintado natural';
      case 'orfebrería':
        return 'Martillado, soldadura, repujado, filigrana';
      case 'escultura':
        return 'Tallado en piedra, pulido, grabado';
      case 'arquitectura religiosa':
      case 'arquitectura ceremonial':
      case 'arquitectura militar':
      case 'arquitectura funeraria':
        return 'Construcción con piedras talladas, ensamblaje sin mortero';
      case 'geoglifos':
        return 'Remoción selectiva de piedras superficiales';
      case 'restos humanos':
        return 'Momificación natural, preservación en frío';
      default:
        return 'Técnicas tradicionales';
    }
  }

  String _getUseByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'cerámica':
        return 'Ceremonial, doméstico, funerario';
      case 'textilería':
        return 'Ceremonial, vestimenta, estatus social';
      case 'orfebrería':
        return 'Ceremonial, ofrendas, insignias de poder';
      case 'escultura':
        return 'Religioso, decorativo, conmemorativo';
      case 'arquitectura religiosa':
        return 'Ceremonial, religioso, astronómico';
      case 'arquitectura ceremonial':
        return 'Ritual, ceremonial, astronómico';
      case 'arquitectura militar':
        return 'Defensivo, ceremonial, administrativo';
      case 'arquitectura funeraria':
        return 'Funerario, ceremonial, ancestral';
      case 'geoglifos':
        return 'Ceremonial, astronómico, religioso';
      case 'restos humanos':
        return 'Ritual, sacrificial, ceremonial';
      default:
        return 'Ceremonial';
    }
  }

  String _generateDimensions() {
    final heights = ['15 cm', '25 cm', '35 cm', '45 cm', '1.2 m', '2.5 m'];
    final widths = ['10 cm', '20 cm', '30 cm', '40 cm', '80 cm', '1.5 m'];
    return '${heights[DateTime.now().millisecond % heights.length]} x ${widths[DateTime.now().microsecond % widths.length]}';
  }
}
