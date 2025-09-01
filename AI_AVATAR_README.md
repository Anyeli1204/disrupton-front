# 🤖 Avatar de IA - Documentación del Frontend

Esta funcionalidad agrega un avatar de IA interactivo a la pantalla de detalle de objetos culturales, permitiendo a los usuarios hacer preguntas sobre los objetos que están visualizando.

## 🚀 Características Implementadas

### ✅ Funcionalidades Completadas
- **Avatar flotante** en esquina inferior izquierda
- **Chat interactivo** que ocupa la mitad inferior de la pantalla
- **Recomendación automática** de avatar según el objeto cultural
- **Preguntas sugeridas** contextuales 
- **UI responsive** optimizada para móviles
- **Animaciones fluidas** con transiciones elegantes
- **Integración con backend** de Gemini AI
- **Manejo de errores** robusto

### 🎭 Tipos de Avatar

#### 🦙 Vicuña
- **Recomendado para:** Cultura andina, objetos de Cusco, textiles, objetos incas
- **Personalidad:** Elegante, sabia, conectada con la naturaleza andina
- **Especialidad:** Cultura andina, tradiciones quechuas

#### 🐕 Perro Peruano
- **Recomendado para:** Culturas preincaicas, cerámica, metalurgia, objetos antiguos
- **Personalidad:** Leal, sabio, guardián de tradiciones ancestrales  
- **Especialidad:** Civilizaciones preincaicas, historia antigua

#### 🐦 Gallito de las Rocas
- **Recomendado para:** Objetos amazónicos, ornamentos con plumas, biodiversidad
- **Personalidad:** Hermoso, orgulloso, representante de la biodiversidad
- **Especialidad:** Fauna peruana, naturaleza, Amazon

## 📱 Flujo de Usuario

1. **Entrada:** Usuario visualiza un objeto cultural en `/colecciones/departamento/objeto-id`
2. **Avatar:** Aparece automáticamente en esquina inferior izquierda
3. **Activación:** Usuario toca el avatar para abrir el chat
4. **Chat:** Se abre ocupando la mitad inferior de la pantalla
5. **Interacción:** Usuario puede hacer preguntas o usar preguntas sugeridas
6. **Contexto:** El objeto cultural permanece visible en la mitad superior
7. **Cierre:** Usuario puede cerrar el chat y volver al objeto completo

## 🏗️ Arquitectura Técnica

### Archivos Principales

```
lib/
├── models/
│   └── ai_chat_models.dart          # Modelos de datos para el chat
├── services/
│   └── ai_chat_service.dart         # Servicio para API de IA
├── widgets/
│   ├── floating_ai_avatar.dart      # Avatar flotante animado
│   └── ai_chat_widget.dart          # Interfaz completa del chat
└── screens/
    └── cultural_object_detail_screen.dart  # Pantalla modificada
```

### Modelos Principales

#### `AvatarType`
- Enum con los 3 tipos de avatar
- Incluye emoji, nombre y valor para backend

#### `ChatMessage`
- Representa mensajes del usuario y la IA
- Incluye timestamp, contenido y tipo de avatar

#### `AiChatResponse`
- Modelo para respuestas del backend de IA
- Maneja éxito, errores y metadatos

### Componentes UI

#### `FloatingAiAvatar`
- Widget del avatar flotante con animaciones
- Pulso sutil para indicar interactividad
- Estados activo/inactivo

#### `AiChatWidget`
- Chat completo con scroll automático
- Preguntas sugeridas contextuales
- Indicadores de carga y estado del servicio
- Input responsive con envío por Enter

## 🔧 Configuración

### Backend Requirements
El chat requiere que el microservicio de Gemini esté ejecutándose:

```bash
# En disrupton-back/gemini-service/
python run.py
```

### API Endpoints Utilizados
- `GET /health` - Verificar estado del servicio
- `POST /chat` - Enviar mensaje al avatar

### Configuración de Red
El servicio se conecta automáticamente según la configuración en `ApiConfig`:
- **Android Emulator:** `http://10.0.2.2:5001`
- **iOS Simulator:** `http://localhost:5001`  
- **Dispositivo físico:** `http://[TU_IP]:5001`

## 🎨 Diseño UX/UI

### Principios de Diseño
- **No intrusivo:** El avatar es visible pero no molesta
- **Accesible:** Fácil de encontrar y activar
- **Contextual:** El objeto cultural nunca pierde protagonismo
- **Fluido:** Transiciones suaves entre estados
- **Informativo:** Feedback claro del estado del sistema

### Responsive Design
- **Móvil primero:** Optimizado para pantallas pequeñas
- **Chat 50/50:** División equilibrada entre objeto y chat
- **Texto legible:** Tamaños de fuente apropiados
- **Touch targets:** Botones del tamaño adecuado para dedos

### Accessibility
- **Contraste:** Colores con buen contraste
- **Feedback visual:** Estados claramente diferenciados  
- **Indicadores:** Íconos informativos
- **Error handling:** Mensajes de error claros

## 🚧 Características Avanzadas

### Inteligencia Contextual
- **Auto-recomendación:** Avatar elegido según el objeto
- **Preguntas inteligentes:** Sugerencias específicas por categoría
- **Contexto enriquecido:** Información del objeto incluida en prompts

### Estados del Sistema
- **Servicio saludable:** Chat completamente funcional
- **Servicio degradado:** Modo limitado con advertencia
- **Sin conexión:** Mensajes de error informativos

### Animaciones
- **Entrada:** Slide up del chat
- **Avatar:** Pulso sutil constante
- **Feedback:** Escalado al tocar
- **Loading:** Indicadores de escritura

## 📊 Métricas y Rendimiento

### Optimizaciones
- **Lazy loading:** Widgets cargados solo cuando necesario
- **Cache local:** Configuración de avatar persistente
- **Timeout:** 30 segundos para respuestas de IA
- **Scroll automático:** Smooth scroll a nuevos mensajes

### Experiencia Móvil
- **Teclado:** Input se ajusta cuando aparece teclado
- **Orientación:** Funciona en portrait y landscape
- **Performance:** 60fps en animaciones
- **Memoria:** Limpieza automática de mensajes antiguos

## 🔮 Futuras Mejoras

### Funcionalidades Planificadas
- [ ] **Chat persistente** entre objetos
- [ ] **Favoritos de chat** para preguntas frecuentes
- [ ] **Síntesis de voz** para respuestas del avatar
- [ ] **Modo offline** con respuestas básicas
- [ ] **Personalización** de avatar por usuario
- [ ] **Historia de chat** guardada localmente
- [ ] **Compartir conversaciones** 
- [ ] **Integración con AR** para preguntas en modo 3D

### Mejoras Técnicas
- [ ] **WebSocket** para chat en tiempo real
- [ ] **Caché inteligente** de respuestas comunes
- [ ] **Analytics** de uso y preferencias
- [ ] **A/B testing** de diferentes avatares
- [ ] **Modo dark** para el chat
- [ ] **Accesibilidad avanzada** (screen readers)

## 🐛 Troubleshooting

### Problemas Comunes

#### Avatar no aparece
- Verificar que el objeto cultural tenga datos válidos
- Comprobar que el widget esté en la pantalla correcta

#### Chat no responde
- Verificar conexión a internet
- Comprobar que el microservicio de Gemini esté ejecutándose
- Revisar logs del backend

#### Errores de UI
- Verificar que todos los imports estén correctos
- Comprobar que las dependencias estén instaladas
- Revisar la configuración de ApiConfig

### Logs Útiles
```dart
// En ai_chat_service.dart
print('Enviando mensaje: $message');
print('Respuesta recibida: ${response.statusCode}');

// En ai_chat_widget.dart  
print('Estado del chat: $_isLoading');
print('Mensajes: ${_messages.length}');
```

## 📄 Licencia

Esta implementación es parte del proyecto Disrupton y sigue la misma licencia del proyecto principal.

---

**Implementado con ❤️ para una experiencia cultural enriquecida**
