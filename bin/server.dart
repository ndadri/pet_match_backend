import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

void main() async {
  final router = Router()
    ..get('/api/pets', _getPets)  // Ruta correcta para obtener mascotas
    ..get('/api/pet/<id>', _getPet)  // Ruta correcta para obtener una mascota por ID
    ..post('/api/pet', _createPet);  // Ruta correcta para crear una nueva mascota

  // Middleware para los logs de las solicitudes
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router);

  // Inicia el servidor en el puerto 8080
  await shelf_io.serve(handler, 'localhost', 8080);
  print('Servidor corriendo en http://localhost:8080/api/pets');
}

// Función para manejar la solicitud de obtener todas las mascotas
Response _getPets(Request request) {
  final pets = [
    {'id': 1, 'name': 'Luna', 'age': 3, 'type': 'Dog'},
    {'id': 2, 'name': 'Max', 'age': 2, 'type': 'Cat'}
  ];
  return Response.ok(jsonEncode(pets), headers: {'Content-Type': 'application/json'});
}

// Función para manejar la solicitud de obtener una mascota por ID
Response _getPet(Request request, String id) {
  final pet = {'id': id, 'name': 'Luna', 'age': 3, 'type': 'Dog'};
  return Response.ok(jsonEncode(pet), headers: {'Content-Type': 'application/json'});
}

// Función para manejar la creación de una nueva mascota
Future<Response> _createPet(Request request) async {
  final payload = await request.readAsString();
  final pet = jsonDecode(payload);
  // Aquí puedes agregar la lógica para guardar la mascota en una base de datos
  return Response.ok(jsonEncode({'message': 'Pet created', 'pet': pet}), headers: {'Content-Type': 'application/json'});
}
