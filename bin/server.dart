// Archivo principal que ejecuta el servidor

import 'dart:convert'; // Importa el paquete 'dart:convert' para manejar la conversión de JSON.
import 'package:shelf/shelf.dart'; // Importa Shelf para crear el servidor web.
import 'package:shelf/shelf_io.dart' as shelf_io; // Importa la funcionalidad para crear el servidor HTTP.
import 'package:shelf_router/shelf_router.dart'; // Importa Shelf Router para manejar las rutas de las API.

void main() async {
  // Crea el router con Shelf Router.
  // Un 'Router' permite definir las rutas y sus manejadores (handlers).
  final router = Router()
    ..get('/api/pets', _getPets) // Ruta GET para obtener todas las mascotas
    ..get('/api/pet/<id>', _getPet) // Ruta GET para obtener una mascota por su ID
    ..post('/api/pet', _createPet); // Ruta POST para crear una nueva mascota

  // Crea un handler para manejar las peticiones usando Shelf.
  // Se añade un middleware para loggear las peticiones entrantes y luego se pasan las rutas a ser manejadas por el router.
  final handler = const Pipeline()
      .addMiddleware(logRequests()) // Middleware que loguea todas las peticiones entrantes
      .addHandler(router); // Asocia el router con el handler

  // Inicia el servidor en el puerto 8080, y sirve las peticiones que lleguen.
  await shelf_io.serve(handler, 'localhost', 8080);
  print('Servidor corriendo en http://localhost:8080'); // Imprime en consola que el servidor está corriendo.
}

// Función para manejar la solicitud de obtener todas las mascotas.
Response _getPets(Request request) {
  // Lista de ejemplo de mascotas.
  final pets = [
    {'id': 1, 'name': 'Luna', 'age': 3, 'type': 'Dog'},
    {'id': 2, 'name': 'Max', 'age': 2, 'type': 'Cat'}
  ];
  
  // Se responde con un status HTTP 200 OK y se envía la lista de mascotas en formato JSON.
  return Response.ok(jsonEncode(pets), headers: {'Content-Type': 'application/json'});
}

// Función para manejar la solicitud de obtener una mascota por ID.
Response _getPet(Request request, String id) {
  // Ejemplo de una mascota con el ID proporcionado
  final pet = {'id': id, 'name': 'Luna', 'age': 3, 'type': 'Dog'};
  
  // Se responde con un status HTTP 200 OK y se envía la mascota en formato JSON.
  return Response.ok(jsonEncode(pet), headers: {'Content-Type': 'application/json'});
}

// Función para manejar la creación de una nueva mascota.
Future<Response> _createPet(Request request) async {
  // Se lee el cuerpo de la solicitud (el contenido JSON que viene en el cuerpo de la petición)
  final payload = await request.readAsString();
  
  // Se decodifica el JSON recibido para obtener los datos de la mascota.
  final pet = jsonDecode(payload);
  
  // Aquí es donde iría la lógica para guardar la mascota en una base de datos.
  
  // Se responde con un status HTTP 200 OK y se devuelve un mensaje con los datos de la mascota creada.
  return Response.ok(jsonEncode({'message': 'Pet created', 'pet': pet}),
      headers: {'Content-Type': 'application/json'});
}
