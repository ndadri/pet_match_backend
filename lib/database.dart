import 'package:postgres/postgres.dart';

class Database {
  static final Database _instance = Database._internal();
  late PostgreSQLConnection connection;

  factory Database() {
    return _instance;
  }

  Database._internal() {
    connection = PostgreSQLConnection(
      'localhost', // Cambia si tu base está en otro host
      5432,        // Puerto por defecto de PostgreSQL
      'pet_match_db', // Nombre de tu base de datos
      username: 'adri', // Usuario de la base de datos
      password: '123456', // Contraseña de la base de datos
    );
  }

  Future<void> open() async {
    if (connection.isClosed) {
      await connection.open();
    }
  }

  // Otros métodos útiles para interactuar con la base de datos pueden ir aquí
}
