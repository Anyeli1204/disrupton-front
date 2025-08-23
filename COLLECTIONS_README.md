# Colecciones - Feature Documentation

## Descripción
Implementación completa de la sección "Colecciones" para usuarios regulares (USER role) en la aplicación Disrupton. Esta funcionalidad permite explorar objetos culturales organizados por los 24 departamentos del Perú.

## Arquitectura

### Modelos (`lib/models/collection_models.dart`)
- **Department**: Representa un departamento del Perú con objetos culturales
- **CulturalObject**: Representa un objeto cultural específico con metadatos

### Servicios (`lib/services/collection_service.dart`)
- **CollectionService**: Maneja la lógica de negocio y comunicación con APIs
- Incluye datos de los 24 departamentos del Perú
- Genera objetos culturales de ejemplo para desarrollo
- Preparado para integración con Firebase Storage

### Providers (`lib/providers/collection_provider.dart`)
- **CollectionProvider**: Gestiona el estado global de colecciones
- Implementa caché para objetos culturales por departamento
- Maneja estados de carga, error y éxito

### Pantallas

#### 1. CollectionsScreen (`lib/screens/collections_screen.dart`)
- Grid de 24 departamentos del Perú
- Cards con imágenes de fondo y descripciones
- Pop-up con nombre del departamento al seleccionar
- Pull-to-refresh y manejo de errores
- Búsqueda integrada (preparada para implementación)

#### 2. DepartmentObjectsScreen (`lib/screens/department_objects_screen.dart`)
- Lista de objetos culturales por departamento
- Grid responsivo 2x2
- Header informativo del departamento
- Navegación a detalle de objeto
- Estados de carga y error

#### 3. CulturalObjectDetailScreen (`lib/screens/cultural_object_detail_screen.dart`)
- Vista detallada de objeto cultural
- SliverAppBar con imagen expandible
- Información completa y metadatos
- Botones de acción (AR, compartir, guardar)
- Diseño optimizado para mobile

## Flujo de Navegación

```
HomeScreen (Usuario selecciona "Colecciones")
    ↓
CollectionsScreen (Grid de 24 departamentos)
    ↓
DepartmentObjectsScreen (Objetos del departamento seleccionado)
    ↓
CulturalObjectDetailScreen (Detalle del objeto cultural)
```

## Integración

### En `main.dart`
- Agregado `CollectionProvider` al MultiProvider

### En `home_screen.dart`
- Agregada opción "Colecciones" para rol USER
- Navegación directa a CollectionsScreen

## Datos de los Departamentos

Los 24 departamentos incluidos:
1. Amazonas
2. Áncash
3. Apurímac
4. Arequipa
5. Ayacucho
6. Cajamarca
7. Callao
8. Cusco
9. Huancavelica
10. Huánuco
11. Ica
12. Junín
13. La Libertad
14. Lambayeque
15. Lima
16. Loreto
17. Madre de Dios
18. Moquegua
19. Pasco
20. Piura
21. Puno
22. San Martín
23. Tacna
24. Tumbes

## Características Implementadas

### ✅ Funcionalidades Completadas
- Grid responsivo de departamentos
- Navegación completa entre pantallas
- Estados de carga y error
- Pull-to-refresh
- Diseño mobile-first
- Pop-ups informativos
- Objetos culturales de ejemplo
- Vista detallada completa
- Botones de acción preparados

### 🚀 Preparado Para
- Integración con Firebase Storage
- Carga de imágenes reales
- API de backend para objetos culturales
- Funcionalidad de búsqueda
- Realidad Aumentada
- Sistema de favoritos
- Compartir contenido

## Uso

1. El usuario inicia sesión con rol "USER"
2. En la pantalla principal, selecciona "Colecciones"
3. Ve el grid de 24 departamentos del Perú
4. Selecciona un departamento (aparece pop-up con nombre)
5. Ve los objetos culturales de ese departamento
6. Selecciona un objeto para ver detalles completos
7. Puede interactuar con botones de acción (guardar, compartir, AR)

## Notas Técnicas

- Compatible con Android e iOS
- Implementación escalable y mantenible
- Separación clara entre UI y lógica de negocio
- Manejo robusto de errores
- Estados de carga optimizados
- Diseño consistente con el tema de la app

## Próximos Pasos

1. Integrar imágenes reales desde Firebase Storage
2. Conectar con API de backend para objetos culturales
3. Implementar funcionalidad de búsqueda
4. Agregar integración con motor de AR
5. Implementar sistema de favoritos
6. Agregar funcionalidad de compartir
