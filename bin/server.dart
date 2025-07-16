import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:pet_match_backend/database.dart'; // Asegúrate de que esta importación esté bien

Middleware corsHeaders() {
  return (Handler handler) {
    return (Request request) async {
      // Si es OPTIONS, responde con los headers CORS
      if (request.method == 'OPTIONS') {
        return Response.ok('',
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
          }
        );
      }
      // Para otros métodos, agrega los headers CORS a la respuesta
      final response = await handler(request);
      return response.change(headers: {
        ...response.headers,
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
      });
    };
  };
}

void main() async {
  final db = Database();

  final router = Router()
    ..get('/api/pets', (Request req) => _getPets(db))
    ..post('/api/pets', (Request req) => _createPet(db, req)) // <-- agrega esta línea
    ..get('/api/pet/<id>', (Request req, String id) => _getPet(db, id))
    ..post('/api/pet', (Request req) => _createPet(db, req))
    ..post('/api/login', (Request req) => _loginUsuario(db, req))
    ..post('/api/register', (Request req) => _registerUsuario(db, req));

  final handler = const Pipeline()
      .addMiddleware(corsHeaders()) // <-- Agrega este middleware primero
      .addMiddleware(logRequests())
      .addHandler(router);

  // Inicia el servidor en el puerto 8080
  await shelf_io.serve(handler, 'localhost', 8080);
  print('Servidor corriendo en http://localhost:8080/api/pets');
}

// Función para manejar la solicitud de obtener todas las mascotas
Future<Response> _getPets(Database db) async {
  final pets = await db.query('SELECT * FROM mascota');
  return Response.ok(jsonEncode(pets), headers: {'Content-Type': 'application/json'});
}

// Función para manejar la solicitud de obtener una mascota por ID
Future<Response> _getPet(Database db, String id) async {
  final pet = await db.query(
    'SELECT * FROM mascota WHERE id = @id',
    substitutionValues: {'id': int.parse(id)},
  );
  if (pet.isEmpty) {
    return Response.notFound('Pet not found');
  }
  return Response.ok(jsonEncode(pet), headers: {'Content-Type': 'application/json'});
}

// Función para manejar la creación de una nueva mascota
Future<Response> _createPet(Database db, Request request) async {
  final payload = await request.readAsString();
  final pet = jsonDecode(payload);
  await db.query(
    'INSERT INTO mascota (nombre, edad, tipo_animal, sexo, ciudad, foto_url, estado, id_usuario) VALUES (@nombre, @edad, @tipo_animal, @sexo, @ciudad, @foto_url, @estado, @id_usuario)',
    substitutionValues: {
      'nombre': pet['nombre'],
      'edad': pet['edad'],
      'tipo_animal': pet['tipo_animal'],
      'sexo': pet['sexo'],
      'ciudad': pet['ciudad'],
      'foto_url': pet['foto_url'],
      'estado': pet['estado'],
      'id_usuario': pet['id_usuario'],
    },
  );
  return Response.ok(jsonEncode({'message': 'Pet created', 'pet': pet}), headers: {'Content-Type': 'application/json'});
}

// Handler de login
Future<Response> _loginUsuario(Database db, Request request) async {
  final payload = await request.readAsString();
  final data = jsonDecode(payload);

  final username = data['username'];
  final password = data['password'];

  final result = await db.query(
    'SELECT * FROM usuarios WHERE username = @username AND password = @password',
    substitutionValues: {
      'username': username,
      'password': password,
    },
  );

  if (result.isNotEmpty) {
    return Response.ok(jsonEncode({'message': 'Login exitoso'}), headers: {'Content-Type': 'application/json'});
  } else {
    return Response.forbidden(jsonEncode({'error': 'Credenciales inválidas'}), headers: {'Content-Type': 'application/json'});
  }
}

// Handler de registro
Future<Response> _registerUsuario(Database db, Request request) async {
  final payload = await request.readAsString();
  final data = jsonDecode(payload);

  final username = data['username'];
  final password = data['password'];

  // Aquí deberías agregar validaciones y lógica para el registro del usuario

  return Response.ok(jsonEncode({'message': 'Registro exitoso'}), headers: {'Content-Type': 'application/json'});
}
