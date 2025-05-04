// Importing required packages. The `dio` package provides a powerful and easy-to-use HTTP client.
// The `auth_service.dart` handles user authentication.
// The `database_service.dart` defines an abstract interface for database operations.
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:spiceease/core/auth/auth_service.dart';
import 'package:uuid/uuid.dart';
import 'database_service.dart';

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
        _uuid = uuid ?? Uuid(),
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://firestore.googleapis.com/v1/',
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 10),
            ));

  @override
  Future<void> initialize() async {}

  Future<dynamic> _call(String method, String url,
      {Map<String, dynamic>? data}) async {
    final token = await _auth.getCurrentIdToken();
    try {
      final resp = await _dio.request<dynamic>(
        url,
        data: data,
        options: Options(
          method: method,
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );
      return resp.data;
    } on DioException catch (e) {
      print('Firestore error response data: ${e.response?.data}');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getDocument(String path) async {
    final raw = await _call(
      'GET',
      'projects/$projectId/databases/(default)/documents/$path',
    ) as Map<String, dynamic>?;

    if (raw == null || raw['fields'] == null) return null;
    return _decode(raw);
  }

  @override
  Future<Map<String, dynamic>> createDocument(
    String collectionPath,
    Map<String, dynamic> data,
  ) async {
    final id = data['id'] ?? generateId();
    final path = '$collectionPath/$id';

    final dataWithoutId = Map<String, dynamic>.from(data)..remove('id');

    final raw = await _call(
      'PATCH',
      'projects/$projectId/databases/(default)/documents/$path?currentDocument.exists=false',
      data: {
        'fields': _encode(dataWithoutId),
      },
    ) as Map<String, dynamic>;

    return _decode(raw);
  }

  // @override
  // Future<Map<String, dynamic>> updateDocument(
  //   String path,
  //   Map<String, dynamic> data,
  // ) async {
  //   final raw = await _call(
  //     'PATCH',
  //     'projects/$projectId/databases/(default)/documents/$path',
  //     data: {
  //       'fields': _encode(data),
  //       'mask': {'fieldPaths': data.keys.toList()},
  //     },
  //   ) as Map<String, dynamic>;

  //   return _decode(raw);
  // }

  @override
  Future<Map<String, dynamic>> updateDocument(
    String path,
    Map<String, dynamic> data,
  ) async {
    // Remove 'created_at' from data right before sending the request
    final filteredData = Map<String, dynamic>.from(data);
    // ..remove('created_at') // Make sure we remove it
    // ..remove('id') // Make sure we remove it
    // ..remove('user_id'); // Make sure we remove it

    // Encode the data excluding 'created_at'
    final requestBody = {
      'fields': _encode(filteredData),
    };

    print(
        'Firestore REST PATCH request to: projects/$projectId/databases/(default)/documents/$path');
    print('Request body: ${requestBody.toString()}');

    // Make the actual call to Firestore
    final raw = await _call(
      'PATCH',
      'projects/$projectId/databases/(default)/documents/$path',
      data: requestBody,
    ) as Map<String, dynamic>;

    return _decode(raw);
  }

  @override
  Future<void> deleteDocument(String path) async {
    await _call(
      'DELETE',
      'projects/$projectId/databases/(default)/documents/$path',
    );
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
    final structuredQuery = <String, dynamic>{
      'from': [
        {'collectionId': collection}
      ],
      if (filters != null && filters.isNotEmpty) 'where': _buildFilter(filters),
      if (orderBy != null) 'orderBy': orderBy.map(_orderToJson).toList(),
      if (limit != null) 'limit': limit,
      if (startAfter != null)
        'startAt': {
          'values': [
            {'stringValue': startAfter}
          ]
        },
      if (endBefore != null)
        'endAt': {
          'values': [
            {'stringValue': endBefore}
          ]
        },
    };

    final response = await _call(
      'POST',
      'projects/$projectId/databases/(default)/documents:runQuery',
      data: {'structuredQuery': structuredQuery},
    ) as List<dynamic>;

    return response
        .where((e) => e is Map && e['document'] != null)
        .map((e) => _decode(e['document'] as Map<String, dynamic>))
        .toList();
  }

  // Builds a composite filter for Firestore queries.
  Map<String, dynamic> _buildFilter(List<QueryFilter> filters) {
    if (filters.length == 1)
      return _filterToJson(filters.first); // Single filter.
    return {
      'compositeFilter': {
        'op': 'AND', // Combines multiple filters with an AND operation.
        'filters': filters.map(_filterToJson).toList(),
      }
    };
  }

  // Converts a QueryFilter object to Firestore's JSON format.
  Map<String, dynamic> _filterToJson(QueryFilter f) {
    if (f is BasicFilter) {
      return {
        'fieldFilter': {
          'field': {'fieldPath': f.field},
          'op': _operatorToFirestoreOp(
              f.op), // Translates operators (e.g., EQUAL, LESS_THAN).
          'value': _valueToJson(f.value), // Converts values to Firestore JSON.
        }
      };
    } else if (f is OrFilter) {
      return {
        'compositeFilter': {
          'op': 'OR',
          'filters': f.filters.map(_filterToJson).toList(),
        }
      };
    } else if (f is AndFilter) {
      return {
        'compositeFilter': {
          'op': 'AND',
          'filters': f.filters.map(_filterToJson).toList(),
        }
      };
    } else if (f is NotFilter) {
      return {
        'unaryFilter': {
          'op': 'NOT',
          'filter': _filterToJson(f.filter),
        }
      };
    }
    throw ArgumentError(
        'Unsupported filter type: $f'); // Handles unsupported filters.
  }

  // Encodes sorting order into Firestore's JSON format.
  Map<String, dynamic> _orderToJson(QueryOrder o) => {
        'field': {'fieldPath': o.field},
        'direction': o.descending ? 'DESCENDING' : 'ASCENDING',
      };

  // Maps QueryOperator enums to Firestore's supported operations.
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
        return 'ARRAY_CONTAINS'; // Substring matching is client-side.
    }
  }

  // Converts query values into Firestore-compatible JSON formats.
  // In FirestoreDatabaseRestService
  Map<String, dynamic> _valueToJson(dynamic v) {
    if (v == null) return {'nullValue': null};
    if (v is String) return {'stringValue': v};
    if (v is int) return {'integerValue': v.toString()};
    if (v is double) return {'doubleValue': v};
    if (v is bool) return {'booleanValue': v};

    // Handle both DateTime and Firestore Timestamp
    if (v is DateTime) {
      return {'timestampValue': v.toUtc().toIso8601String()};
    }
    if (v is Timestamp) {
      // Add Firestore SDK Timestamp support
      return {'timestampValue': v.toDate().toUtc().toIso8601String()};
    }

    throw ArgumentError('Unsupported query value: ${v.runtimeType}');
  }

  /// Decodes a Firestore document JSON structure into a Dart Map
  ///
  /// Firestore documents arrive in a complex nested format. This method:
  /// 1. Extracts the document ID from the full resource path
  /// 2. Converts Firestore's typed field values to native Dart types
  /// 3. Handles nested arrays and maps recursively
  /// 4. Returns a flat Map with native types for easy application use
  Map<String, dynamic> _decode(Map<String, dynamic> doc) {
    // Extract the main fields object containing all document data
    final fields = doc['fields'] as Map<String, dynamic>;

    // Extract document ID from the full resource path:
    // "projects/{project}/databases/{database}/documents/{collection}/{docId}"
    final pathSegments = (doc['name'] as String).split('/');
    final id = pathSegments.last;

    // Initialize result with document ID first
    final result = <String, dynamic>{'id': id};

    // Process each field in the Firestore document
    fields.forEach((String fieldName, dynamic fieldValue) {
      // Firestore fields are always wrapped in type objects
      // Example: {'stringValue': 'Hello'}, {'integerValue': '123'}
      final typeMap = fieldValue as Map<String, dynamic>;

      // Get the value type key and actual value
      final valueType = typeMap.keys.first;
      final rawValue = typeMap[valueType];

      // Convert based on Firestore type
      switch (valueType) {
        case 'stringValue':
          result[fieldName] = rawValue as String;
          break;
        case 'integerValue':
          result[fieldName] = int.parse(rawValue as String);
          break;
        case 'doubleValue':
          result[fieldName] = (rawValue as num).toDouble();
          break;
        case 'booleanValue':
          result[fieldName] = rawValue as bool;
          break;
        case 'timestampValue':
          result[fieldName] = DateTime.parse(rawValue as String);
          break;
        case 'nullValue':
          result[fieldName] = null;
          break;
        case 'arrayValue':
          // Arrays contain nested values that need recursive decoding
          result[fieldName] = _decodeArray(rawValue['values'] as List<dynamic>);
          break;
        case 'mapValue':
          // Maps become nested objects with their own fields
          result[fieldName] =
              _decode(rawValue['fields'] as Map<String, dynamic>);
          break;
        default:
          throw UnsupportedError('Unsupported Firestore type: $valueType');
      }
    });

    return result;
  }

  /// Recursively decodes Firestore array values to Dart Lists
  ///
  /// Handles:
  /// - Mixed type arrays
  /// - Nested arrays and maps
  /// - Type conversion for each element
  List<dynamic> _decodeArray(List<dynamic> firestoreArray) {
    return firestoreArray.map((dynamic element) {
      // Each array element is wrapped in a type object
      final elementMap = element as Map<String, dynamic>;
      final elementType = elementMap.keys.first;
      final elementValue = elementMap[elementType];

      switch (elementType) {
        case 'stringValue':
          return elementValue as String;
        case 'integerValue':
          return int.parse(elementValue as String);
        case 'doubleValue':
          return (elementValue as num).toDouble();
        case 'booleanValue':
          return elementValue as bool;
        case 'timestampValue':
          return DateTime.parse(elementValue as String);
        case 'nullValue':
          return null;
        case 'arrayValue':
          // Recursively decode nested arrays
          return _decodeArray(elementValue['values'] as List<dynamic>);
        case 'mapValue':
          // Recursively decode nested maps
          return _decode(elementValue['fields'] as Map<String, dynamic>);
        default:
          throw UnsupportedError(
              'Unsupported array element type: $elementType');
      }
    }).toList();
  }

  /// Encodes application data to Firestore-compatible JSON format
  ///
  /// Converts Dart types to Firestore type wrappers:
  /// - Handles null values
  /// - Recursively processes nested Lists and Maps
  /// - Converts special types like DateTime
  Map<String, dynamic> _encode(Map<String, dynamic> data) {
    final encoded = <String, dynamic>{};

    data.forEach((String key, dynamic value) {
      encoded[key] = _encodeValue(value);
    });

    return encoded;
  }

  /// Recursively encodes a single value to Firestore JSON format
  ///
  /// This is the core type conversion method that handles:
  /// - Basic Dart primitive types
  /// - Nested collection types (List/Map)
  /// - Special type handling for DateTime
  /// - Type checking for unsupported values
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
      return {'timestampValue': value.toUtc().toIso8601String()};
    } else if (value is Timestamp) {
      // Fix: handle Firestore Timestamp
      return {'timestampValue': value.toDate().toUtc().toIso8601String()};
    } else if (value is List) {
      return {
        'arrayValue': {'values': value.map(_encodeValue).toList()}
      };
    } else if (value is Map) {
      return {
        'mapValue': {'fields': _encode(value.cast<String, dynamic>())}
      };
    }
    throw ArgumentError('Unsupported data type for encoding: '
        '${value.runtimeType}');
  }

  String _generateFirestoreId([int length = 20]) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)])
        .join();
  }

  @override
  String generateId() {
    return _generateFirestoreId();
  }

  @override
  Future<void> batchUpdate(List<Map<String, dynamic>> updates) async {
    final writes = updates.map((update) {
      final path = update['path'] as String;
      final data = update['data'] as Map<String, dynamic>;

      if (path.split('/').length != 2) {
        throw Exception('Invalid document path: $path');
      }

      return {
        'update': {
          'name': 'projects/$projectId/databases/(default)/documents/$path',
          'fields': _encode(data),
          'updateMask': {'fieldPaths': data.keys.toList()},
        }
      };
    }).toList();

    await _call(
      'POST',
      'projects/$projectId/databases/(default)/documents:batchWrite',
      data: {'writes': writes},
    );
  }
}
