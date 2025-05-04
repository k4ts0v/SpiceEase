import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_service.dart';

/// Firestore SDK implementation of [DatabaseService]
///
/// Handles CRUD operations and complex queries with:
/// - Composite filters (AND/OR/NOT)
/// - Server-side and client-side filtering
/// - Pagination and ordering
/// - Mixed query capabilities
///
/// Note: Some operations are handled client-side due to Firestore limitations
class FirebaseDatabaseService implements DatabaseService {
  FirebaseFirestore? _fs;

  /// Initializes Firestore connection
  ///
  /// Requires Firebase to be initialized elsewhere in the application
  @override
  Future<void> initialize() async {
    // Firebase initialization should be Done at app startup
    _fs = FirebaseFirestore.instance;
  }

  /// Generates the ID of the document using Firestore's native ID generation.
  @override
  String generateId() {
    return _fs!.collection('_id_generator').doc().id;
  }

  /// Retrieves a single document from Firestore
  ///
  /// [path]: Full document path (e.g. 'collection/documentId')
  /// Returns: Document data with ID or null if not exists
  @override
  Future<Map<String, dynamic>?> getDocument(String path) async {
    final snap = await _fs!.doc(path).get();
    if (!snap.exists) return null;
    return {'id': snap.id, ...snap.data()!};
  }

  /// Creates a new document in specified collection
  ///
  /// [collectionPath]: Target collection path
  /// [data]: Document data to create
  /// Returns: Created document with generated ID
  @override
  Future<Map<String, dynamic>> createDocument(
    String collectionPath,
    Map<String, dynamic> data,
  ) async {
    // Create the document reference first
    final docRef = _fs!.collection(collectionPath).doc();

    // Write data with Firestore doc ID embedded as 'id'
    final dataWithId = {
      ...data,
      'id': docRef.id,
    };

    await docRef.set(dataWithId);

    final snap = await docRef.get();
    return {'id': snap.id, ...snap.data()!};
  }

  /// Updates an existing document
  ///
  /// [path]: Full document path to update
  /// [data]: Fields to update (merge strategy)
  /// Returns: Updated document data
  @override
  @override
  Future<Map<String, dynamic>> updateDocument(
    String path,
    Map<String, dynamic> data,
  ) async {
    final parts = path.split('/');
    if (parts.length != 2) {
      throw Exception('Invalid path "$path"');
    }

    final collection = parts[0];
    final docId = parts[1];

    final docRef = _fs!.collection(collection).doc(docId);

    // Firestore will throw if the document does not exist
    await docRef.update(data);

    final updatedSnapshot = await docRef.get();
    return {'id': updatedSnapshot.id, ...updatedSnapshot.data()!};
  }

  /// Updates an existing document
  ///
  /// [path]: Full document path to delete
  /// [data]: Fields to delete (merge strategy)
  @override
  Future<void> deleteDocument(String path) async {
    final parts = path.split('/');
    if (parts.length != 2) {
      throw Exception('Invalid path "$path"');
    }

    final collection = parts[0];
    final docId = parts[1];

    final docRef = _fs!.collection(collection).doc(docId);
    await docRef.delete();
  }

  /// Executes a complex query with multiple filters and ordering
  ///
  /// Handles:
  /// - AND filters (server-side)
  /// - OR filters (client-side union)
  /// - NOT filters (client-side exclusion)
  /// - Contains filters (client-side)
  /// - Multi-field ordering
  /// - Pagination using document IDs
  @override
  Future<List<Map<String, dynamic>>> query({
    required String collection,
    List<QueryFilter>? filters,
    List<QueryOrder>? orderBy,
    int? limit,
    String? startAfter,
    String? endBefore,
  }) async {
    // Base query starts with collection reference
    Query<Map<String, dynamic>> baseQuery = _fs!.collection(collection);

    // Categorize filters into different types
    final basicAnds = <BasicFilter>[];
    final orFilters = <OrFilter>[];
    final notFilters = <NotFilter>[];

    // Filter categorization
    if (filters != null) {
      for (final f in filters) {
        if (f is BasicFilter) {
          basicAnds.add(f);
        } else if (f is AndFilter) {
          basicAnds.addAll(f.filters.whereType<BasicFilter>());
        } else if (f is OrFilter) {
          orFilters.add(f);
        } else if (f is NotFilter) {
          notFilters.add(f);
        }
      }
    }

    // Apply server-side AND filters
    for (final f in basicAnds) {
      switch (f.op) {
        case QueryOperator.equal:
          baseQuery = baseQuery.where(f.field, isEqualTo: f.value);
          break;
        case QueryOperator.notEqual:
          baseQuery = baseQuery.where(f.field, isNotEqualTo: f.value);
          break;
        case QueryOperator.lessThan:
          baseQuery = baseQuery.where(f.field, isLessThan: f.value);
          break;
        case QueryOperator.lessThanOrEqual:
          baseQuery = baseQuery.where(f.field, isLessThanOrEqualTo: f.value);
          break;
        case QueryOperator.greaterThan:
          baseQuery = baseQuery.where(f.field, isGreaterThan: f.value);
          break;
        case QueryOperator.greaterThanOrEqual:
          baseQuery = baseQuery.where(f.field, isGreaterThanOrEqualTo: f.value);
          break;
        case QueryOperator.arrayContains:
          baseQuery = baseQuery.where(f.field, arrayContains: f.value);
          break;
        case QueryOperator.inList:
          baseQuery = baseQuery.where(f.field, whereIn: f.value);
          break;
        case QueryOperator.notInList:
          baseQuery = baseQuery.where(f.field, whereNotIn: f.value);
          break;
        case QueryOperator.contains:
          // Client-side filtering for contains (substring match)
          break;
      }
    }

    // Result collection using map to prevent duplicates
    final Map<String, Map<String, dynamic>> resultsMap = {};

    // Handle OR filters as union of multiple queries
    if (orFilters.isEmpty) {
      // Simple case: no OR filters
      final snaps = await baseQuery.get();
      for (final doc in snaps.docs) {
        resultsMap[doc.id] = {'id': doc.id, ...doc.data()};
      }
    } else {
      // Complex case: union of OR filter results
      for (final orf in orFilters) {
        for (final sub in orf.filters.whereType<BasicFilter>()) {
          Query<Map<String, dynamic>> subQuery = baseQuery;
          switch (sub.op) {
            case QueryOperator.equal:
              subQuery = subQuery.where(sub.field, isEqualTo: sub.value);
              break;
            // Handle other operators as needed
            default:
              subQuery = subQuery.where(sub.field, isEqualTo: sub.value);
          }
          final snaps = await subQuery.get();
          for (final doc in snaps.docs) {
            resultsMap[doc.id] = {'id': doc.id, ...doc.data()};
          }
        }
      }
    }

    // Apply NOT filters client-side
    for (final nf in notFilters) {
      if (nf.filter is BasicFilter) {
        final bf = nf.filter as BasicFilter;
        resultsMap.removeWhere((_, data) => data[bf.field] == bf.value);
      }
    }

    // Convert to list for client-side processing
    var results = resultsMap.values.toList();

    // Client-side substring filtering
    if (filters != null) {
      for (final f in filters
          .where((f) => f is BasicFilter && f.op == QueryOperator.contains)
          .cast<BasicFilter>()) {
        results = results
            .where((data) =>
                data[f.field]?.toString().contains(f.value.toString()) ?? false)
            .toList();
      }
    }

    // Client-side multi-field sorting
    if (orderBy != null) {
      results.sort((a, b) {
        for (final o in orderBy) {
          var av = a[o.field];
          var bv = b[o.field];

          // 1) Firestore Timestamp → DateTime
          if (av is Timestamp) av = av.toDate();
          if (bv is Timestamp) bv = bv.toDate();

          // 2) ISO-8601 string → DateTime
          if (av is String && bv is String) {
            final da = DateTime.tryParse(av);
            final db = DateTime.tryParse(bv);
            if (da != null && db != null) {
              final cmp = da.compareTo(db);
              if (cmp != 0) return o.descending ? -cmp : cmp;
              continue; // equal—move to next ordering field
            }
          }

          // 3) Compare other Comparables (but skip raw strings)
          if (av is Comparable &&
              bv is Comparable &&
              av.runtimeType != String &&
              bv.runtimeType != String) {
            final cmp = av.compareTo(bv);
            if (cmp != 0) return o.descending ? -cmp : cmp;
          }

          // otherwise, equal or non-comparable: try next field
        }
        return 0;
      });
    }

    // Pagination handling
    if (startAfter != null) {
      final idx = results.indexWhere((d) => d['id'] == startAfter);
      if (idx >= 0 && idx < results.length - 1) {
        results = results.sublist(idx + 1);
      }
    }
    if (endBefore != null) {
      final idx = results.indexWhere((d) => d['id'] == endBefore);
      if (idx > 0) results = results.sublist(0, idx);
    }
    if (limit != null && results.length > limit) {
      results = results.sublist(0, limit);
    }

    return results;
  }

  /// Performs a batch update on multiple documents.
  ///
  /// [updates]: A list of updates, where each update is a map containing:
  /// - `path`: The document path (e.g., 'collection/documentId').
  /// - `data`: A map of key-value pairs to update in the document.
  @override
  Future<void> batchUpdate(List<Map<String, dynamic>> updates) async {
    final batch = _fs!.batch();

    for (final update in updates) {
      final path = update['path'] as String;
      final data = update['data'] as Map<String, dynamic>;

      final parts = path.split('/');
      if (parts.length != 2) {
        throw Exception('Invalid document path: $path');
      }

      final docRef = _fs!.collection(parts[0]).doc(parts[1]);
      batch.update(docRef, data);
    }

    await batch.commit();
  }
}
