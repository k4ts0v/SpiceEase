import 'dart:math';
import 'package:dio/dio.dart';
import 'package:spiceease/core/auth/auth_service.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'database_service.dart';

/// Firestore Database REST API implementation
///
/// Provides database operations using Firestore REST API instead of SDK
/// Features:
/// - Document CRUD operations
/// - Complex queries with filters and ordering
/// - Batch operations
/// - Proper error handling
/// - Authentication integration
class FirestoreDatabaseRestService implements DatabaseService {
  final Dio _dio;
  final AuthService _auth;
  final String projectId;
  final Uuid _uuid;

  FirestoreDatabaseRestService({
    required this.projectId,
    required AuthService authService,
    Dio? dio,
    Uuid? uuid,
  })  : _auth = authService,
        _uuid = uuid ?? const Uuid(),
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://firestore.googleapis.com/v1/',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 30),
              headers: {'Content-Type': 'application/json'},
            ));

  @override
  Future<void> initialize() async {
    print('Initializing Firestore REST service for project: $projectId');
    // Test connection with a simple request
    try {
      await _call('GET', 'projects/$projectId/databases/(default)');
      print('Firestore REST service initialized successfully');
    } catch (e) {
      print('Firestore REST service initialization failed: $e');
      // Don't throw - let the app continue and handle errors per operation
    }
  }

  /// Makes authenticated HTTP calls to Firestore REST API
  Future<dynamic> _call(
    String method,
    String url, {
    Map<String, dynamic>? data,
    Map<String, String>? queryParams,
  }) async {
    try {
      // Get the ID token (which serves as the access token for Firestore)
      final token = await _auth.getAccessToken();
      if (token == null) {
        throw Exception('No access token available');
      }

      final options = Options(
        method: method,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final response = await _dio.request(
        url,
        data: data,
        queryParameters: queryParams,
        options: options,
      );

      return response.data;
    } on DioException catch (e) {
      print('Firestore REST API error: ${e.response?.statusCode} ${e.message}');
      print('Error response: ${e.response?.data}');

      // More specific error handling
      switch (e.response?.statusCode) {
        case 401:
          throw Exception('Authentication failed - invalid or expired token');
        case 403:
          throw Exception('Permission denied - check Firestore security rules');
        case 404:
          return null;
        case 400:
          final errorMsg =
              e.response?.data?['error']?['message'] ?? 'Bad request';
          throw Exception('Invalid request: $errorMsg');
        default:
          rethrow;
      }
    }
  }

  @override
  Future<Map<String, dynamic>?> getDocument(String path) async {
    try {
      final response = await _call(
        'GET',
        'projects/$projectId/databases/(default)/documents/$path',
      );

      if (response == null) return null;

      return _decode(response as Map<String, dynamic>);
    } catch (e) {
      print('Error getting document $path: $e');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> createDocument(
    String collectionPath,
    Map<String, dynamic> data,
  ) async {
    try {
      final id = data['id'] ?? generateId();
      final path = '$collectionPath/$id';

      // Remove id from data before encoding (it's in the path)
      final dataToEncode = Map<String, dynamic>.from(data)..remove('id');

      // Convert any Timestamp objects to DateTime before encoding
      final cleanedData = _preprocessData(dataToEncode);

      final response = await _call(
        'PATCH',
        'projects/$projectId/databases/(default)/documents/$path?currentDocument.exists=false',
        data: {
          'fields': _encode(cleanedData),
        },
      );

      if (response == null) {
        throw Exception('Failed to create document - no response');
      }

      return _decode(response as Map<String, dynamic>);
    } catch (e) {
      print('Error creating document: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateDocument(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      final updateData = Map<String, dynamic>.from(data)
        ..remove('id')
        ..remove('created_at');

      if (updateData.isEmpty) {
        throw Exception('No valid fields to update');
      }

      // Convert any Timestamp objects to DateTime before encoding
      final cleanedData = _preprocessData(updateData);

      // Build valid field paths (handle nested fields properly)
      final updateMaskFields = _buildFieldPaths(cleanedData);

      // Create the URL with properly encoded field paths
      final baseUrl = 'projects/$projectId/databases/(default)/documents/$path';
      final fieldPathsQuery = updateMaskFields
          .map((field) => 'updateMask.fieldPaths=$field')
          .join('&');
      final fullUrl = '$baseUrl?$fieldPathsQuery';

      final response = await _call(
        'PATCH',
        fullUrl,
        data: {
          'fields': _encode(cleanedData),
        },
      );

      return _decode(response as Map<String, dynamic>);
    } catch (e) {
      print('Error updating document $path: $e');
      rethrow;
    }
  }

  @override
  Future<void> batchUpdate(List<Map<String, dynamic>> updates) async {
    try {
      if (updates.isEmpty) return;

      final writes = <Map<String, dynamic>>[];

      for (final update in updates) {
        final path = update['path'] as String?;
        final data = update['data'] as Map<String, dynamic>?;

        if (path == null || data == null) {
          throw Exception('Invalid batch update: missing path or data');
        }

        if (path.split('/').length != 2) {
          throw Exception('Invalid document path: $path');
        }

        // Remove read-only fields and preprocess data
        final updateData = Map<String, dynamic>.from(data)
          ..remove('id')
          ..remove('created_at');

        final cleanedData = _preprocessData(updateData);
        final fieldPaths = _buildFieldPaths(cleanedData);

        writes.add({
          'update': {
            'name': 'projects/$projectId/databases/(default)/documents/$path',
            'fields': _encode(cleanedData),
          },
          'updateMask': {
            'fieldPaths': fieldPaths,
          },
        });
      }

      await _call(
        'POST',
        'projects/$projectId/databases/(default)/documents:batchWrite',
        data: {'writes': writes},
      );

      print(
          'Successfully completed batch update of ${writes.length} documents');
    } catch (e) {
      print('Error in batch update: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteDocument(String path) async {
    try {
      await _call(
        'DELETE',
        'projects/$projectId/databases/(default)/documents/$path',
      );
      print('Successfully deleted document: $path');
    } catch (e) {
      print('Error deleting document $path: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> query({
    required String collection,
    List<QueryFilter>? filters,
    List<QueryOrder>? orderBy,
    int? limit,
    String? startAfter,
    String? endBefore,
  }) async {
    try {
      // Build structured query
      final structuredQuery = <String, dynamic>{
        'from': [
          {'collectionId': collection}
        ],
      };

      // Add filters if provided
      if (filters != null && filters.isNotEmpty) {
        structuredQuery['where'] = _buildFilter(filters);
      }

      // Add ordering if provided
      if (orderBy != null && orderBy.isNotEmpty) {
        structuredQuery['orderBy'] = orderBy.map(_orderToJson).toList();
      }

      // Add limit if provided
      if (limit != null) {
        structuredQuery['limit'] = limit;
      }

      // Add pagination if provided
      if (startAfter != null) {
        structuredQuery['startAt'] = {
          'values': [
            {'stringValue': startAfter}
          ]
        };
      }

      if (endBefore != null) {
        structuredQuery['endAt'] = {
          'values': [
            {'stringValue': endBefore}
          ]
        };
      }

      print('Executing query on collection: $collection');
      print('Query structure: ${structuredQuery.toString()}');

      final response = await _call(
        'POST',
        'projects/$projectId/databases/(default)/documents:runQuery',
        data: {'structuredQuery': structuredQuery},
      );

      if (response == null) {
        print('Query returned null response');
        return <Map<String, dynamic>>[];
      }

      // Handle empty response
      if (response is! List) {
        print('Query response is not a list: ${response.runtimeType}');
        return <Map<String, dynamic>>[];
      }

      final responseList = response as List<dynamic>;

      if (responseList.isEmpty) {
        print('Query returned empty results');
        return <Map<String, dynamic>>[];
      }

      // Process results
      final results = <Map<String, dynamic>>[];

      for (final item in responseList) {
        if (item is Map<String, dynamic> && item.containsKey('document')) {
          try {
            final decoded = _decode(item['document'] as Map<String, dynamic>);
            results.add(decoded);
          } catch (e) {
            print('Error decoding document: $e');
            // Skip this document but continue with others
          }
        }
      }

      print('Query returned ${results.length} documents');
      return results;
    } catch (e) {
      print('Error executing query on collection $collection: $e');
      // Return empty list instead of throwing to prevent app crashes
      return <Map<String, dynamic>>[];
    }
  }

  @override
  String generateId() {
    return _generateFirestoreId();
  }

  /// Preprocesses data to handle Firestore-specific types
  Map<String, dynamic> _preprocessData(Map<String, dynamic> data) {
    final processed = <String, dynamic>{};

    data.forEach((key, value) {
      processed[key] = _preprocessValue(value);
    });

    return processed;
  }

  /// Preprocesses a single value to handle Firestore types
  dynamic _preprocessValue(dynamic value) {
    if (value == null) {
      return null;
    } else if (value is Timestamp) {
      // Convert Firestore Timestamp to DateTime and normalize to date only
      return _normalizeDate(value.toDate());
    } else if (value is DateTime) {
      // Normalize DateTime to date only (remove time component)
      return _normalizeDate(value);
    } else if (value is List) {
      return value.map(_preprocessValue).toList();
    } else if (value is Map) {
      return _preprocessData(value.cast<String, dynamic>());
    } else {
      return value;
    }
  }

  /// Normalizes DateTime to date-only (removes time component) and ensures consistent format
  DateTime _normalizeDate(DateTime date) {
    // Create a date-only DateTime in local time to match UI expectations
    // The UI comparison logic expects local time, not UTC
    return DateTime(date.year, date.month, date.day);
  }

  /// Builds field paths for updateMask, handling nested fields properly
  List<String> _buildFieldPaths(Map<String, dynamic> data,
      [String prefix = '']) {
    final paths = <String>[];

    data.forEach((key, value) {
      final fieldPath = prefix.isEmpty ? key : '$prefix.$key';

      if (value is Map<String, dynamic>) {
        // For nested objects, we need to specify the exact field paths
        paths.addAll(_buildFieldPaths(value, fieldPath));
      } else {
        // For primitive values and arrays, add the field path directly
        paths.add(fieldPath);
      }
    });

    return paths;
  }

  /// Generates a Firestore-compatible document ID
  String _generateFirestoreId([int length = 20]) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)])
        .join();
  }

  /// Builds composite filters for Firestore queries
  Map<String, dynamic> _buildFilter(List<QueryFilter> filters) {
    if (filters.length == 1) {
      return _filterToJson(filters.first);
    }

    return {
      'compositeFilter': {
        'op': 'AND',
        'filters': filters.map(_filterToJson).toList(),
      }
    };
  }

  /// Converts QueryFilter to Firestore JSON format
  Map<String, dynamic> _filterToJson(QueryFilter filter) {
    if (filter is BasicFilter) {
      return {
        'fieldFilter': {
          'field': {'fieldPath': filter.field},
          'op': _operatorToFirestoreOp(filter.op),
          'value': _valueToJson(filter.value),
        }
      };
    } else if (filter is OrFilter) {
      return {
        'compositeFilter': {
          'op': 'OR',
          'filters': filter.filters.map(_filterToJson).toList(),
        }
      };
    } else if (filter is AndFilter) {
      return {
        'compositeFilter': {
          'op': 'AND',
          'filters': filter.filters.map(_filterToJson).toList(),
        }
      };
    } else if (filter is NotFilter) {
      return {
        'unaryFilter': {
          'op': 'IS_NOT_NULL',
          'field': {
            'fieldPath': 'dummy'
          }, // Firestore requires a field for unary filters
        }
      };
    }

    throw ArgumentError('Unsupported filter type: ${filter.runtimeType}');
  }

  /// Converts QueryOrder to Firestore JSON format
  Map<String, dynamic> _orderToJson(QueryOrder order) {
    return {
      'field': {'fieldPath': order.field},
      'direction': order.descending ? 'DESCENDING' : 'ASCENDING',
    };
  }

  /// Maps QueryOperator to Firestore operation strings
  String _operatorToFirestoreOp(QueryOperator op) {
    switch (op) {
      case QueryOperator.equal:
        return 'EQUAL';
      case QueryOperator.notEqual:
        return 'NOT_EQUAL';
      case QueryOperator.lessThan:
        return 'LESS_THAN';
      case QueryOperator.lessThanOrEqual:
        return 'LESS_THAN_OR_EQUAL';
      case QueryOperator.greaterThan:
        return 'GREATER_THAN';
      case QueryOperator.greaterThanOrEqual:
        return 'GREATER_THAN_OR_EQUAL';
      case QueryOperator.arrayContains:
        return 'ARRAY_CONTAINS';
      case QueryOperator.inList:
        return 'IN';
      case QueryOperator.notInList:
        return 'NOT_IN';
      case QueryOperator.contains:
        return 'ARRAY_CONTAINS';
    }
  }

  /// Converts values to Firestore JSON format
  Map<String, dynamic> _valueToJson(dynamic value) {
    if (value == null) return {'nullValue': null};
    if (value is String) return {'stringValue': value};
    if (value is int) return {'integerValue': value.toString()};
    if (value is double) return {'doubleValue': value};
    if (value is bool) return {'booleanValue': value};
    if (value is DateTime) {
      // Normalize date before storing and ensure proper format for Firestore
      final normalizedDate = _normalizeDate(value);
      // Convert to UTC and format as ISO string with Z suffix for Firestore compatibility
      return {'timestampValue': normalizedDate.toUtc().toIso8601String()};
    }
    if (value is Timestamp) {
      // Normalize date before storing and ensure proper format for Firestore
      final normalizedDate = _normalizeDate(value.toDate());
      // Convert to UTC and format as ISO string with Z suffix for Firestore compatibility
      return {'timestampValue': normalizedDate.toUtc().toIso8601String()};
    }

    if (value is List) {
      return {
        'arrayValue': {'values': value.map(_valueToJson).toList()}
      };
    }
    if (value is Map) {
      return {
        'mapValue': {'fields': _encode(value.cast<String, dynamic>())}
      };
    }

    throw ArgumentError('Unsupported query value type: ${value.runtimeType}');
  }

  /// Decodes Firestore document to Dart Map
  Map<String, dynamic> _decode(Map<String, dynamic> doc) {
    try {
      final fields = doc['fields'] as Map<String, dynamic>? ?? {};

      // Extract document ID from path
      final docName = doc['name'] as String? ?? '';
      final pathSegments = docName.split('/');
      final id = pathSegments.isNotEmpty ? pathSegments.last : '';

      final result = <String, dynamic>{'id': id};

      // Decode each field
      fields.forEach((fieldName, fieldValue) {
        if (fieldValue is Map<String, dynamic>) {
          result[fieldName] = _decodeValue(fieldValue);
        }
      });

      // Debug logging for completed_dates specifically
      if (result.containsKey('completed_dates')) {
        print('Document $id completed_dates: ${result['completed_dates']}');
      }

      return result;
    } catch (e) {
      print('Error decoding document: $e');
      return {'id': '', 'error': 'Failed to decode document'};
    }
  }

  /// Decodes a single Firestore value
  dynamic _decodeValue(Map<String, dynamic> valueMap) {
    final valueType = valueMap.keys.first;
    final rawValue = valueMap[valueType];

    switch (valueType) {
      case 'stringValue':
        return rawValue as String;
      case 'integerValue':
        return int.parse(rawValue as String);
      case 'doubleValue':
        return (rawValue as num).toDouble();
      case 'booleanValue':
        return rawValue as bool;
      case 'timestampValue':
        // Parse the timestamp and normalize to date only
        final parsedDate = DateTime.parse(rawValue as String);
        final normalized = _normalizeDate(parsedDate);
        // Debug logging
        print('Decoded timestamp: $rawValue -> $parsedDate -> $normalized');
        return normalized;
      case 'nullValue':
        return null;
      case 'arrayValue':
        final values = rawValue['values'] as List<dynamic>? ?? [];
        final decodedList =
            values.map((v) => _decodeValue(v as Map<String, dynamic>)).toList();
        // Debug logging for arrays (like completed_dates)
        if (decodedList.isNotEmpty && decodedList.first is DateTime) {
          print('Decoded DateTime array: $decodedList');
        }
        return decodedList;
      case 'mapValue':
        final fields = rawValue['fields'] as Map<String, dynamic>? ?? {};
        final result = <String, dynamic>{};
        fields.forEach((key, value) {
          result[key] = _decodeValue(value as Map<String, dynamic>);
        });
        return result;
      default:
        print('Unknown Firestore value type: $valueType');
        return rawValue;
    }
  }

  /// Encodes Dart Map to Firestore format
  Map<String, dynamic> _encode(Map<String, dynamic> data) {
    final encoded = <String, dynamic>{};

    data.forEach((key, value) {
      encoded[key] = _encodeValue(value);
    });

    return encoded;
  }

  /// Encodes a single value to Firestore format
  Map<String, dynamic> _encodeValue(dynamic value) {
    if (value == null) {
      return {'nullValue': null};
    } else if (value is String) {
      return {'stringValue': value};
    } else if (value is int) {
      return {'integerValue': value.toString()};
    } else if (value is double) {
      return {'doubleValue': value};
    } else if (value is bool) {
      return {'booleanValue': value};
    } else if (value is DateTime) {
      // Normalize date before encoding and ensure proper format for Firestore
      final normalizedDate = _normalizeDate(value);
      // Convert to UTC and format as ISO string with Z suffix for Firestore compatibility
      final isoString = normalizedDate.toUtc().toIso8601String();
      // Debug logging
      print('Encoding DateTime: $value -> $normalizedDate -> $isoString');
      return {'timestampValue': isoString};
    } else if (value is Timestamp) {
      // Normalize date before encoding and ensure proper format for Firestore
      final normalizedDate = _normalizeDate(value.toDate());
      // Convert to UTC and format as ISO string with Z suffix for Firestore compatibility
      final isoString = normalizedDate.toUtc().toIso8601String();
      // Debug logging
      print('Encoding Timestamp: $value -> $normalizedDate -> $isoString');
      return {'timestampValue': isoString};
    } else if (value is List) {
      final encodedList = value.map(_encodeValue).toList();
      // Debug logging for arrays (like completed_dates)
      if (value.isNotEmpty && value.first is DateTime) {
        print('Encoding DateTime array: $value -> encoded as array');
      }
      return {
        'arrayValue': {'values': encodedList}
      };
    } else if (value is Map) {
      return {
        'mapValue': {'fields': _encode(value.cast<String, dynamic>())}
      };
    }

    throw ArgumentError('Unsupported data type: ${value.runtimeType}');
  }
}
