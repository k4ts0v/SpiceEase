/// A database-agnostic service interface defining CRUD operations,
/// blueprint of all application collections, and advanced query support.
///
/// Swapping backends (Firestore REST/SDK, Mongo, etc.) is as simple
/// as changing a single provider flag—no changes to business/UI code.
abstract class DatabaseService {
  /// **Collection Name Blueprint**
  static const String users = 'users';
  static const String tasks = 'tasks';
  static const String subtasks = 'subtasks';
  static const String speedruns = 'speedruns';
  static const String habits = 'habits';
  static const String moodEntries = 'mood_entries';
  static const String energyEntries = 'energy_entries';
  static const String activities = 'activities';
  static const String timeBlocks = 'time_blocks';
  static const String flowmodoros = 'flowmodoros';
  static const String medications = 'medications';
  static const String symptoms = 'symptoms';
  static const String reports = 'reports';
  static const String settings = 'settings';

  /// Initialize the database client or REST adapter.
  Future<void> initialize();

  /// Generates a database-specific unique ID
  String generateId();

  /// Fetch a single document by full path (e.g. 'users/{id}').
  Future<Map<String, dynamic>?> getDocument(String path);

  /// Create a new document under [collectionPath], returning the created
  /// document (including generated ID).
  Future<Map<String, dynamic>> createDocument(
    String collectionPath,
    Map<String, dynamic> data,
  );

  /// Update an existing document at [path] with given data.
  Future<Map<String, dynamic>> updateDocument(
    String path,
    Map<String, dynamic> data,
  );

  /// Delete the document at the specified [path].
  Future<void> deleteDocument(String path);

  /// Advanced query support: combine filters with AND, OR, NOT;
  /// support comparison and substring operators; ordering and pagination.
  ///
  /// Example:
  /// ```dart
  /// final filters = [
  ///   QueryFilter.basic('status', QueryOperator.equal, 'active'),
  ///   QueryFilter.or([
  ///     QueryFilter.basic('age', QueryOperator.greaterThan, 18),
  ///     QueryFilter.basic('role', QueryOperator.equal, 'admin'),
  ///   ]),
  /// ];
  /// final results = await service.query(
  ///   collection: DatabaseService.users,
  ///   filters: filters,
  ///   orderBy: [QueryOrder('createdAt', descending: true)],
  ///   limit: 20,
  ///   startAfter: lastDocId,
  /// );
  /// ```
  Future<List<Map<String, dynamic>>> query({
    required String collection,
    List<QueryFilter>? filters,
    List<QueryOrder>? orderBy,
    int? limit,
    String? startAfter,
    String? endBefore,
  });

  /// Allows batch updating documents.
  Future<void> batchUpdate(List<Map<String, dynamic>> updates);
}

/// Abstract representation of a query filter: basic or logical.
abstract class QueryFilter {
  /// Field name for basic filters; null for composite filters.
  String? get field;

  /// Basic comparison filter.
  factory QueryFilter.basic(
    String field,
    QueryOperator op,
    dynamic value,
  ) = BasicFilter;

  /// Logical OR of sub-filters.
  factory QueryFilter.or(List<QueryFilter> filters) = OrFilter;

  /// Logical AND of sub-filters.
  factory QueryFilter.and(List<QueryFilter> filters) = AndFilter;

  /// Logical NOT of a filter.
  factory QueryFilter.not(QueryFilter filter) = NotFilter;

  /// Array contains filter.
  factory QueryFilter.arrayContains(String field, dynamic value) =
      ArrayContainsFilter;
}

/// Supported comparison and substring operators.
enum QueryOperator {
  equal,
  notEqual,
  lessThan,
  lessThanOrEqual,
  greaterThan,
  greaterThanOrEqual,
  arrayContains,
  contains, // substring or LIKE
  inList,
  notInList,
}

/// Simple field comparison filter.
class BasicFilter implements QueryFilter {
  @override
  final String field;
  final QueryOperator op;
  final dynamic value;

  const BasicFilter(this.field, this.op, this.value);
}

/// Composite OR filter.
class OrFilter implements QueryFilter {
  @override
  String? get field => null;
  final List<QueryFilter> filters;
  const OrFilter(this.filters);
}

/// Composite AND filter.
class AndFilter implements QueryFilter {
  @override
  String? get field => null;
  final List<QueryFilter> filters;
  const AndFilter(this.filters);
}

/// Negation filter.
class NotFilter implements QueryFilter {
  @override
  String? get field => null;
  final QueryFilter filter;
  const NotFilter(this.filter);
}

/// Array membership filter.
class ArrayContainsFilter implements QueryFilter {
  @override
  final String field;
  final dynamic value;

  const ArrayContainsFilter(this.field, this.value);
}

/// Defines ordering for queries.
class QueryOrder {
  final String field;
  final bool descending;
  const QueryOrder(this.field, {this.descending = false});
}
