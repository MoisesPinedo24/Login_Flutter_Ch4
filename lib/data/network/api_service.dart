import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';

class ApiService {
  // Cambia esta URL por la de tu API de prueba (ej. JSONPlaceholder o MockAPI)
  final String _baseUrl = 'https://654321.mockapi.io/api/v1';

  Future<List<Task>> fetchTasks() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/tasks'));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        // Aquí es donde json_serializable hace su magia
        return body.map((item) => Task.fromJson(item)).toList();
      } else {
        throw Exception("Error al conectar con la API");
      }
    } catch (e) {
      // Si no hay internet, el BLoC capturará este error y usará SQLite
      rethrow;
    }
  }
}
