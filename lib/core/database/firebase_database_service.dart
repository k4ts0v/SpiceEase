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
    // Firebase initialization should be done at app startup
    _fs = FirebaseFirestore.instance;
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
    final docRef = await _fs!.collection(collectionPath).add(data);
    final snap = await docRef.get();
    return {'id': snap.id, ...snap.data()!};
  }

  /// Updates an existing document
  ///
  /// [path]: Full document path to update
  /// [data]: Fields to update (merge strategy)
  /// Returns: Updated document data
  @override
  Future<Map<String, dynamic>> updateDocument(
    String path,
    Map<String, dynamic> data,
  ) async {
    final docRef = _fs!.doc(path);
    await docRef.update(data);
    final snap = await docRef.get();
    return {'id': snap.id, ...snap.data()!};
  }

  /// Deletes a document from Firestore
  @override
  Future<void> deleteDocument(String path) async {
    await _fs!.doc(path).delete();
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
          final av = a[o.field];
          final bv = b[o.field];
          if (av is Comparable && bv is Comparable) {
            final cmp = av.compareTo(bv);
            if (cmp != 0) return o.descending ? -cmp : cmp;
          }
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
}
