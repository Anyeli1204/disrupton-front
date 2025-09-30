import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/onirix_config.dart';

class OnirixARView extends StatefulWidget {
  final String? sceneId;
  final String? accessToken;
  final Function()? onARLoaded;
  final Function(String)? onError;

  const OnirixARView({
    super.key,
    this.sceneId,
    this.accessToken,
    this.onARLoaded,
    this.onError,
  });

  @override
  OnirixARViewState createState() => OnirixARViewState();
}

class OnirixARViewState extends State<OnirixARView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Usar un Future.microtask para evitar el warning de async en initState
    Future.microtask(() => _initializeWebView());
  }

  Future<void> _initializeWebView() async {
    try {
      final url = OnirixConfig.getExperienceUrl(
        sceneId: widget.sceneId,
        accessToken: widget.accessToken,
      );

      debugPrint('Cargando URL de Onirix: $url');

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              debugPrint('Página cargando: $url');
            },
            onPageFinished: (String url) {
              debugPrint('Página cargada: $url');
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
              widget.onARLoaded?.call();
            },
            onWebResourceError: (error) {
              debugPrint('Error al cargar la página: ${error.description}');
              if (mounted) {
                setState(() {
                  _hasError = true;
                  _isLoading = false;
                });
              }
              widget.onError?.call('Error al cargar la experiencia AR: ${error.description}');
            },
            onNavigationRequest: (NavigationRequest request) {
              debugPrint('Navegación a: ${request.url}');
              return NavigationDecision.navigate;
            },
          ),
        )
        ..setBackgroundColor(Colors.white)
        ..setUserAgent('Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36');

      // Cargar la URL directamente primero
      await _controller.loadRequest(Uri.parse(url));
      
      // Luego inyectar los headers si es necesario
      await _controller.runJavaScript('''
        (function() {
          var xhr = new XMLHttpRequest();
          xhr.open('GET', '$url', true);
          xhr.setRequestHeader('Authorization', 'Bearer ${widget.accessToken ?? OnirixConfig.sdkToken}');
          xhr.setRequestHeader('Origin', 'https://studio.onirix.com');
          xhr.onload = function() {
            if (xhr.status >= 200 && xhr.status < 300) {
              document.open();
              document.write(xhr.responseText);
              document.close();
            }
          };
          xhr.onerror = function() {
            console.error('Error al cargar el recurso AR');
          };
          xhr.send();
        })();
      ''');
    } catch (e) {
      debugPrint('Error en _initializeWebView: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
      widget.onError?.call('Error al inicializar la vista AR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Vista WebView
          Positioned.fill(
            child: WebViewWidget(controller: _controller),
          ),
          
          // Indicador de carga
          if (_isLoading)
            const Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando experiencia AR...'),
                  ],
                ),
              ),
            ),
          
          // Mensaje de error
          if (_hasError && !_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, 
                          color: Colors.red, 
                          size: 64,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No se pudo cargar la experiencia de Realidad Aumentada',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Por favor verifica tu conexión a internet o inténtalo de nuevo más tarde.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () {
                            if (mounted) {
                              setState(() {
                                _isLoading = true;
                                _hasError = false;
                              });
                            }
                            _initializeWebView();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
