import 'package:dio/dio.dart';
import 'package:flutter_application_1/config.dart';

abstract class ApiRepository {
  Future<Map<String, dynamic>> getData();
  Future<Map<String, dynamic>> feedOrWater(String actionType);
}

class ApiRepositoryImpl implements ApiRepository {
  final Dio dio;

  ApiRepositoryImpl() : dio = Dio(BaseOptions(baseUrl: API_BASE_URL));

  @override
  Future<Map<String, dynamic>> getData() async {
    try {
      var response = await dio.get('/get-data');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
            "Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to fetch data: $e");
    }
  }

  @override
  Future<Map<String, dynamic>> feedOrWater(String actionType) async {
    try {
      var response = await dio.post(
        '/feed-or-water',
        queryParameters: {'action': actionType},
      );

      if (response.statusCode == 200) {
        if (response.data is String) {
          return {'message': response.data};
        } else if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        } else {
          throw Exception("Unexpected response format");
        }
      } else {
        throw Exception(
            "Failed to send data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to send data: $e");
    }
  }
}
