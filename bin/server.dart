import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

// Middleware para habilitar CORS
Middleware corsMiddleware() {
  return (Handler handler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type',
        });
      }

      final response = await handler(request);
      return response.change(headers: {
        ...response.headers,
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type',
      });
    };
  };
}

void main() async {
  final router = Router()
    ..get('/api/pets', _getPets)
    ..get('/api/pet/<id>', _getPet)
    ..post('/api/pet', _createPet)
    ..post('/api/login', _loginUsuario);

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware()) // Habilita CORS
      .addHandler(router);

  // Escuchar en todas las interfaces de red (para Chrome y dispositivos reales)
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080);

  print('✅ Servidor corriendo en http://localhost:8080/api/pets');
}

// Obtener todas las mascotas
Response _getPets(Request request) {
  final pets = [
    {'id': 1, 'name': 'Luna', 'age': 3, 'type': 'Dog'},
    {'id': 2, 'name': 'Max', 'age': 2, 'type': 'Cat'}
  ];
  return Response.ok(jsonEncode(pets), headers: {'Content-Type': 'application/json'});
}

// Obtener una mascota por ID
Response _getPet(Request request, String id) {
  final pet = {'id': id, 'name': 'Luna', 'age': 3, 'type': 'Dog'};
  return Response.ok(jsonEncode(pet), headers: {'Content-Type': 'application/json'});
}

Future<Response> _loginUsuario(Request request) async {
  final payload = await request.readAsString();
  final data = jsonDecode(payload);

  final username = data['username'];
  final password = data['password'];

  // ⚠️ Aquí va validación real, pero por ahora:
  if (username == 'admin' && password == '1234') {
    final response = {
      'status': 'ok',
      'user': {
        'id': 1,
        'username': username,
        'token': 'fake-jwt-token'
      }
    };
    return Response.ok(
      jsonEncode(response),
      headers: {'Content-Type': 'application/json'},
    );
  } else {
    return Response.forbidden(
      jsonEncode({'error': 'Credenciales inválidas'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}


// Crear una nueva mascota
Future<Response> _createPet(Request request) async {
  final payload = await request.readAsString();
  final pet = jsonDecode(payload);
  return Response.ok(
    jsonEncode({'message': 'Pet created', 'pet': pet}),
    headers: {'Content-Type': 'application/json'},
  );
}
