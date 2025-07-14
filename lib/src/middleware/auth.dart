// Middleware de autenticación

// Importa el paquete 'shelf' para usar sus funcionalidades de middleware y manejo de solicitudes HTTP.
import 'package:shelf/shelf.dart';

// Esta función devuelve un middleware de autenticación. El middleware intercepta las solicitudes antes de llegar a la ruta real.
Middleware authMiddleware() {
  return (Handler innerHandler) {
    // 'innerHandler' es el manejador que pasará la solicitud si la autenticación es válida.
    return (Request request) async {
      // Obtiene el encabezado de autorización de la solicitud HTTP.
      final authHeader = request.headers['Authorization'];

      // Si el encabezado no existe o el token no es el esperado, se devuelve un error '403 Forbidden'.
      if (authHeader == null || authHeader != 'Bearer YOUR_TOKEN') {
        return Response.forbidden('Acceso denegado');
      }

      // Si la autenticación es válida, pasa la solicitud al siguiente manejador (innerHandler).
      return await innerHandler(request);
    };
  };
}
