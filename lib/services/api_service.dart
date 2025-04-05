import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:safar/models/user.dart';
import 'package:safar/models/itinerary.dart';
import 'package:safar/core/constants.dart';
import 'package:safar/services/storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  final String baseUrl = 'http://10.120.134.95:5000/api'; // Try your computer's IP address here
  final StorageService _storage = StorageService();
  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _storage.init();
  }

  // Helper method to get auth headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getString(StorageKeys.token);
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Authentication Methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Attempting to login with URL: $baseUrl/auth/login');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Login response status code: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.setString(StorageKeys.token, data['token']);
        await _storage.setString(StorageKeys.userInfo, jsonEncode(data['user']));
        return data;
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Login failed';
        print('Login error: $error');
        throw Exception(error);
      }
    } catch (e) {
      print('Login exception: $e');
      if (e is SocketException) {
        throw Exception('Cannot connect to server. Please check your internet connection and try again.');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await _storage.setString(StorageKeys.token, data['token']);
      await _storage.setString(StorageKeys.userInfo, jsonEncode(data['user']));
      return data;
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Registration failed');
    }
  }

  Future<void> logout() async {
    await _storage.setString(StorageKeys.token, '');
    await _storage.setString(StorageKeys.userInfo, '');
  }

  // Itinerary Methods
  Future<List<Itinerary>> getItineraries({String? filter}) async {
    try {
      final token = await _storage.getString(StorageKeys.token);
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/itineraries').replace(
          queryParameters: filter != null ? {'filter': filter} : null,
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Response data: $responseData'); // Debug print
        
        List<dynamic> itinerariesData;
        
        if (responseData is Map<String, dynamic>) {
          if (responseData['data'] is List) {
            itinerariesData = responseData['data'];
          } else if (responseData['data'] is Map && responseData['data']['itineraries'] is List) {
            itinerariesData = responseData['data']['itineraries'];
          } else {
            throw Exception('Invalid response format: data field is not in expected format');
          }
        } else {
          throw Exception('Invalid response format: root is not a Map');
        }

        return itinerariesData.map((json) {
          try {
            return Itinerary.fromJson(json);
          } catch (e) {
            print('Error parsing itinerary: $e');
            print('Invalid itinerary JSON: $json');
            rethrow;
          }
        }).toList();
      } else {
        throw Exception('Failed to load itineraries: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getItineraries: $e');
      rethrow;
    }
  }

  Future<Itinerary> getItineraryById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/itineraries/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Itinerary.fromJson(data['data']['itinerary']);
    } else {
      throw Exception('Failed to load itinerary');
    }
  }

  Future<List<Itinerary>> getPublicItineraries({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final headers = await _getHeaders();
      
      print('Fetching public itineraries from: ${Uri.parse('$baseUrl/itineraries/public').replace(queryParameters: queryParams)}');
      print('Using headers: $headers');
      
      final response = await http.get(
        Uri.parse('$baseUrl/itineraries/public').replace(queryParameters: queryParams),
        headers: headers,
      );

      print('Public itineraries response status: ${response.statusCode}');
      print('Response body: ${response.body.substring(0, min(100, response.body.length))}...');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        if (!responseData['success']) {
          throw Exception(responseData['message'] ?? 'Failed to load public itineraries');
        }
        
        if (responseData['data'] == null) {
          return [];
        }
        
        final List<dynamic> itinerariesJson = responseData['data'];
        
        final itineraries = <Itinerary>[];
        
        for (var json in itinerariesJson) {
          try {
            // Ensure all the nested objects are properly formatted
            Map<String, dynamic> itineraryMap = {};
            
            // Handle ID field
            itineraryMap['_id'] = json['_id'] ?? json['id'] ?? '';
            
            // Handle title
            itineraryMap['title'] = json['title'] ?? 'Untitled Itinerary';
            
            // Handle destination - could be a string or a map
            if (json['destination'] != null) {
              if (json['destination'] is Map) {
                itineraryMap['destination'] = json['destination'];
              } else {
                itineraryMap['destination'] = {'name': json['destination'].toString()};
              }
            } else {
              itineraryMap['destination'] = {'name': 'Unknown'};
            }
            
            // Handle dateRange
            if (json['dateRange'] != null) {
              if (json['dateRange'] is Map) {
                itineraryMap['dateRange'] = json['dateRange'];
              } else {
                // Set a default date range
                itineraryMap['dateRange'] = {
                  'start': DateTime.now().toIso8601String(),
                  'end': DateTime.now().add(const Duration(days: 7)).toIso8601String()
                };
              }
            }
            
            // Handle budget
            if (json['budget'] != null) {
              if (json['budget'] is Map) {
                itineraryMap['budget'] = json['budget'];
              }
            }
            
            // Handle transportation
            if (json['transportation'] != null) {
              if (json['transportation'] is Map) {
                itineraryMap['transportation'] = json['transportation'];
              } else {
                itineraryMap['transportation'] = {'mode': json['transportation'].toString()};
              }
            }
            
            // Handle isPrivate
            itineraryMap['isPrivate'] = json['isPrivate'] ?? false;
            
            // Handle days
            if (json['days'] != null && json['days'] is List) {
              itineraryMap['days'] = json['days'];
            } else {
              itineraryMap['days'] = [];
            }
            
            // Handle coverImage
            itineraryMap['coverImage'] = json['coverImage'] ?? 
                'https://images.unsplash.com/photo-1500835556837-99ac94a94552';
            
            // Handle notes
            itineraryMap['notes'] = json['notes'] ?? '';
            
            // Handle timestamps
            itineraryMap['createdAt'] = json['createdAt'] ?? DateTime.now().toIso8601String();
            itineraryMap['updatedAt'] = json['updatedAt'] ?? DateTime.now().toIso8601String();
            
            // Handle description
            itineraryMap['description'] = json['description'];
            
            // Handle owner
            if (json['owner'] != null) {
              itineraryMap['owner'] = json['owner'];
            }
            
            // Handle collaborators
            if (json['collaborators'] != null && json['collaborators'] is List) {
              itineraryMap['collaborators'] = json['collaborators'];
            }
            
            // Copy any other fields that weren't explicitly handled
            json.forEach((key, value) {
              if (!itineraryMap.containsKey(key)) {
                itineraryMap[key] = value;
              }
            });
            
            itineraries.add(Itinerary.fromJson(itineraryMap));
          } catch (e) {
            print('Error parsing itinerary: $e');
            print('Invalid JSON: ${json.toString().substring(0, min(500, json.toString().length))}...');
            // Skip this itinerary instead of failing the entire list
            continue;
          }
        }
        
        print('Successfully parsed ${itineraries.length} public itineraries');
        return itineraries;
      } else {
        if (response.statusCode == 401) {
          throw Exception('Authentication required. Please login again.');
        }
        throw Exception('Failed to load public itineraries: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getPublicItineraries: $e');
      rethrow;
    }
  }

  // User Methods
  Future<User> getCurrentUser() async {
    final userJson = await _storage.getString(StorageKeys.userInfo);
    if (userJson == null) throw Exception('No user logged in');
    print(userJson);
    return User.fromJson(jsonDecode(userJson));
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.getString(StorageKeys.token);
    return token != null && token.isNotEmpty;
  }
} 