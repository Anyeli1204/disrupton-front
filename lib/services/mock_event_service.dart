import '../models/event.dart';

class MockEventService {
  static List<Event> getMockEvents() {
    return [
      Event(
        id: 'event_001',
        title: 'Festival de Arte Digital Peruano',
        description:
            'Explora la intersección entre el arte tradicional peruano y las nuevas tecnologías digitales. Este festival único presenta obras de arte interactivas, instalaciones de realidad aumentada y experiencias inmersivas que celebran nuestro patrimonio cultural.',
        imageUrl:
            'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=800&h=600&fit=crop&crop=center',
        dateTime: DateTime.parse('2025-09-15T18:00:00Z'),
        location: 'Centro Cultural UTEC, Lima',
        latitude: -12.0958,
        longitude: -77.0428,
        createdBy: 'admin_user_001',
        createdAt: DateTime.parse('2025-08-20T10:00:00Z'),
        updatedAt: DateTime.parse('2025-08-20T10:00:00Z'),
        isActive: true,
        tags: [
          'arte digital',
          'cultura peruana',
          'tecnología',
          'realidad aumentada'
        ],
        attendeesCount: 0,
        isPastEvent: false,
        timeUntilEvent: '22 días',
      ),
      Event(
        id: 'event_002',
        title: 'Exposición de Cerámica Moche Interactiva',
        description:
            'Descubre los secretos de la cerámica Moche a través de experiencias de realidad aumentada. Los visitantes podrán ver el proceso de creación en 3D y conocer las historias detrás de cada pieza arqueológica.',
        imageUrl:
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=600&fit=crop&crop=center',
        dateTime: DateTime.parse('2025-09-22T16:00:00Z'),
        location: 'Museo Arqueológico UTEC, Lima',
        latitude: -12.0975,
        longitude: -77.0435,
        createdBy: 'guide_user_001',
        createdAt: DateTime.parse('2025-08-21T14:30:00Z'),
        updatedAt: DateTime.parse('2025-08-21T14:30:00Z'),
        isActive: true,
        tags: ['arqueología', 'moche', 'cerámica', 'museo', 'historia'],
        attendeesCount: 15,
        isPastEvent: false,
        timeUntilEvent: '29 días',
      ),
      Event(
        id: 'event_003',
        title: 'Taller de Textiles Andinos con AR',
        description:
            'Aprende las técnicas ancestrales de tejido andino con la ayuda de guías virtuales en realidad aumentada. Los participantes crearán su propia pieza textil mientras aprenden sobre los símbolos y significados culturales.',
        imageUrl:
            'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800&h=600&fit=crop&crop=center',
        dateTime: DateTime.parse('2025-09-28T14:00:00Z'),
        location: 'Taller de Arte UTEC, Lima',
        latitude: -12.0965,
        longitude: -77.0440,
        createdBy: 'artisan_user_001',
        createdAt: DateTime.parse('2025-08-22T09:15:00Z'),
        updatedAt: DateTime.parse('2025-08-22T09:15:00Z'),
        isActive: true,
        tags: ['textiles', 'andino', 'taller', 'tradición', 'tejido'],
        attendeesCount: 8,
        isPastEvent: false,
        timeUntilEvent: '35 días',
      ),
      Event(
        id: 'event_004',
        title: 'Conferencia: Tecnología y Preservación Cultural',
        description:
            'Expertos internacionales discutirán cómo las nuevas tecnologías como AR, VR e IA están revolucionando la preservación y difusión del patrimonio cultural. Incluye demostraciones en vivo y casos de estudio.',
        imageUrl:
            'https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=800&h=600&fit=crop&crop=center',
        dateTime: DateTime.parse('2025-10-05T10:00:00Z'),
        location: 'Auditorio Principal UTEC, Lima',
        latitude: -12.0952,
        longitude: -77.0422,
        createdBy: 'admin_user_001',
        createdAt: DateTime.parse('2025-08-23T16:45:00Z'),
        updatedAt: DateTime.parse('2025-08-23T16:45:00Z'),
        isActive: true,
        tags: [
          'tecnología',
          'preservación',
          'conferencia',
          'patrimonio',
          'innovación'
        ],
        attendeesCount: 42,
        isPastEvent: false,
        timeUntilEvent: '42 días',
      ),
      Event(
        id: 'event_005',
        title: 'Recorrido Nocturno AR por el Campus',
        description:
            'Una experiencia única de realidad aumentada que transforma el campus universitario en un escenario de historias ancestrales peruanas. Los participantes seguirán rutas guiadas con narrativas inmersivas.',
        imageUrl:
            'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=800&h=600&fit=crop&crop=center',
        dateTime: DateTime.parse('2025-10-12T19:30:00Z'),
        location: 'Campus UTEC, Lima',
        latitude: -12.0960,
        longitude: -77.0430,
        createdBy: 'guide_user_002',
        createdAt: DateTime.parse('2025-08-24T11:20:00Z'),
        updatedAt: DateTime.parse('2025-08-24T11:20:00Z'),
        isActive: true,
        tags: ['recorrido', 'nocturno', 'campus', 'historias', 'inmersivo'],
        attendeesCount: 23,
        isPastEvent: false,
        timeUntilEvent: '49 días',
      ),
      Event(
        id: 'event_006',
        title: 'Muestra de Orfebrería Chavín',
        description:
            'Exhibición especial de réplicas de orfebrería Chavín con experiencias AR que muestran las técnicas de elaboración y el contexto histórico. Los visitantes podrán ver los procesos de metalurgia en 3D.',
        imageUrl:
            'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=800&h=600&fit=crop&crop=center',
        dateTime: DateTime.parse('2025-10-18T15:00:00Z'),
        location: 'Galería de Arte UTEC, Lima',
        latitude: -12.0970,
        longitude: -77.0445,
        createdBy: 'artisan_user_002',
        createdAt: DateTime.parse('2025-08-24T13:00:00Z'),
        updatedAt: DateTime.parse('2025-08-24T13:00:00Z'),
        isActive: true,
        tags: [
          'orfebrería',
          'chavín',
          'metalurgia',
          'arqueología',
          'técnicas ancestrales'
        ],
        attendeesCount: 12,
        isPastEvent: false,
        timeUntilEvent: '55 días',
      ),
      Event(
        id: 'event_007',
        title: 'Festival de Danzas Folclóricas Digitales',
        description:
            'Las tradicionales danzas peruanas cobran vida a través de hologramas y efectos de realidad aumentada. Un espectáculo que fusiona la tradición con la innovación tecnológica.',
        imageUrl:
            'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800&h=600&fit=crop&crop=center',
        dateTime: DateTime.parse('2025-10-25T17:00:00Z'),
        location: 'Plaza Central UTEC, Lima',
        latitude: -12.0955,
        longitude: -77.0425,
        createdBy: 'guide_user_003',
        createdAt: DateTime.parse('2025-08-24T15:30:00Z'),
        updatedAt: DateTime.parse('2025-08-24T15:30:00Z'),
        isActive: true,
        tags: [
          'danzas',
          'folclore',
          'tradición',
          'espectáculo',
          'cultura peruana'
        ],
        attendeesCount: 67,
        isPastEvent: false,
        timeUntilEvent: '62 días',
      ),
      Event(
        id: 'event_008',
        title: 'Seminario de Gastronomía Ancestral',
        description:
            'Descubre los ingredientes y técnicas culinarias de las culturas pre-incas a través de experiencias sensoriales y realidad aumentada. Incluye degustación de platos recreados históricamente.',
        imageUrl:
            'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=800&h=600&fit=crop&crop=center',
        dateTime: DateTime.parse('2025-11-02T12:00:00Z'),
        location: 'Laboratorio Gastronómico UTEC, Lima',
        latitude: -12.0963,
        longitude: -77.0438,
        createdBy: 'admin_user_002',
        createdAt: DateTime.parse('2025-08-24T17:00:00Z'),
        updatedAt: DateTime.parse('2025-08-24T17:00:00Z'),
        isActive: true,
        tags: [
          'gastronomía',
          'ancestral',
          'ingredientes',
          'degustación',
          'historia culinaria'
        ],
        attendeesCount: 28,
        isPastEvent: false,
        timeUntilEvent: '70 días',
      ),
      Event(
        id: 'event_009',
        title: 'Exhibición de Instrumentos Musicales Prehispánicos',
        description:
            'Una colección única de instrumentos musicales prehispánicos con experiencias auditivas inmersivas. Los visitantes podrán escuchar cómo sonaban estos instrumentos en su contexto original.',
        imageUrl:
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&h=600&fit=crop&crop=center',
        dateTime: DateTime.parse('2025-11-08T16:30:00Z'),
        location: 'Sala de Música UTEC, Lima',
        latitude: -12.0958,
        longitude: -77.0432,
        createdBy: 'artisan_user_003',
        createdAt: DateTime.parse('2025-08-24T18:15:00Z'),
        updatedAt: DateTime.parse('2025-08-24T18:15:00Z'),
        isActive: true,
        tags: [
          'instrumentos musicales',
          'prehispánico',
          'sonidos ancestrales',
          'música',
          'arqueología musical'
        ],
        attendeesCount: 19,
        isPastEvent: false,
        timeUntilEvent: '76 días',
      ),
      Event(
        id: 'event_010',
        title: 'Hackathon Cultural: Apps para el Patrimonio',
        description:
            'Competencia de 48 horas donde equipos multidisciplinarios desarrollarán aplicaciones móviles innovadoras para la preservación y difusión del patrimonio cultural peruano.',
        imageUrl:
            'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=800&h=600&fit=crop&crop=center',
        dateTime: DateTime.parse('2025-11-15T09:00:00Z'),
        location: 'Laboratorio de Innovación UTEC, Lima',
        latitude: -12.0967,
        longitude: -77.0441,
        createdBy: 'admin_user_003',
        createdAt: DateTime.parse('2025-08-24T19:30:00Z'),
        updatedAt: DateTime.parse('2025-08-24T19:30:00Z'),
        isActive: true,
        tags: [
          'hackathon',
          'aplicaciones',
          'patrimonio',
          'innovación',
          'competencia'
        ],
        attendeesCount: 85,
        isPastEvent: false,
        timeUntilEvent: '83 días',
      ),
    ];
  }
}
