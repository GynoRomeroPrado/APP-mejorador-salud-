import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exercise.dart';

class ExerciseDBApi {
  final String apiKey;
  final String baseUrl = 'https://exercisedb.p.rapidapi.com';

  ExerciseDBApi({required this.apiKey});

  /// Headers comunes para todas las requests
  Map<String, String> get _headers => {
        'X-RapidAPI-Key': apiKey,
        'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
      };

  /// Obtiene todos los ejercicios (limitado a 1000)
  Future<List<Exercise>> getAllExercises({int limit = 1000}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/exercises?limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Exercise.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener ejercicios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  /// Obtiene un ejercicio por ID
  Future<Exercise> getExerciseById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/exercises/exercise/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Exercise.fromJson(data);
      } else {
        throw Exception('Ejercicio no encontrado');
      }
    } catch (e) {
      throw Exception('Error al obtener ejercicio: $e');
    }
  }

  /// Obtiene ejercicios por parte del cuerpo
  Future<List<Exercise>> getExercisesByBodyPart(String bodyPart) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/exercises/bodyPart/$bodyPart'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Exercise.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener ejercicios por bodyPart');
      }
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  /// Obtiene ejercicios por equipamiento
  Future<List<Exercise>> getExercisesByEquipment(String equipment) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/exercises/equipment/$equipment'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Exercise.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener ejercicios por equipment');
      }
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  /// Obtiene ejercicios por músculo objetivo
  Future<List<Exercise>> getExercisesByTarget(String target) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/exercises/target/$target'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Exercise.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener ejercicios por target');
      }
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  /// Obtiene lista de partes del cuerpo disponibles
  Future<List<String>> getBodyPartList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/exercises/bodyPartList'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e.toString()).toList();
      } else {
        throw Exception('Error al obtener lista de bodyParts');
      }
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  /// Obtiene lista de equipamiento disponible
  Future<List<String>> getEquipmentList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/exercises/equipmentList'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e.toString()).toList();
      } else {
        throw Exception('Error al obtener lista de equipment');
      }
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  /// Obtiene lista de músculos objetivo disponibles
  Future<List<String>> getTargetList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/exercises/targetList'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e.toString()).toList();
      } else {
        throw Exception('Error al obtener lista de targets');
      }
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  /// Busca ejercicios por nombre
  Future<List<Exercise>> searchExercisesByName(String name) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/exercises/name/$name'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Exercise.fromJson(json)).toList();
      } else {
        throw Exception('No se encontraron ejercicios');
      }
    } catch (e) {
      throw Exception('Error de búsqueda: $e');
    }
  }
}
