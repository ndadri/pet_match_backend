// Middleware de autenticación

import 'package:shelf/shelf.dart';

Middleware authMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || authHeader != 'Bearer YOUR_TOKEN') {
        return Response.forbidden('Acceso denegado');
      }
      return await innerHandler(request);
    };
  };
}
