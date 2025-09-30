class OnirixConfig {
  static const String projectId = '9fa82249f539476481b6a42dc1535a4a';
  static const String defaultSceneId = 'e3c1813bd3ab4b8c8ab9900ce7f263a2';
  static const String baseUrl = 'https://studio.onirix.com/webar';
  static const String sdkToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjc2ODQ5LCJwcm9qZWN0SWQiOjEyNDAyMSwicm9sZSI6MywiaWF0IjoxNzU5MDMxMzg5fQ.p3bL68IkSTfVbZDEvHEr5ohpS5moyI4JOSBoEC9u6hk'; // <-- Añade esto
  
  static String getExperienceUrl({String? sceneId, String? accessToken}) {
    final scene = sceneId ?? defaultSceneId;
    var url = '$baseUrl/$projectId/$scene';
    
    // Usa el SDK Token si está disponible
    final tokenToUse = accessToken ?? sdkToken;
    if (tokenToUse.isNotEmpty) {
      url += '?accessToken=$tokenToUse';
    }
    
    return url;
  }
}