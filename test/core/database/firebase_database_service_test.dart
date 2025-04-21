// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:spiceease/core/database/firebase_database_service.dart';

// // Generate mocks
// @GenerateMocks([
//   FirebaseFirestore,
// ], customMocks: [
//   MockSpec<CollectionReference<Map<String, dynamic>>>(as: #MockCollectionRef),
// ])
// import 'firebase_database_service_test.mocks.dart';

// void main() {
//   // Initialize binding once at the start
//   TestWidgetsFlutterBinding.ensureInitialized();

//   late FirebaseDatabaseService firebaseService;
//   late MockFirebaseFirestore mockFirestore;
//   late MockCollectionRef mockCollection;

//   setUp(() {
//     mockFirestore = MockFirebaseFirestore();
//     mockCollection = MockCollectionRef();

//     firebaseService = FirebaseDatabaseService();
//     firebaseService.setTestFirestore(mockFirestore);

//     // Configure collection mock
//     when(mockCollection.path).thenReturn('mock_path');
//     when(mockFirestore.collection(any)).thenReturn(mockCollection);
//   });

//   group('Singleton', () {
//     test('returns same instance', () {
//       final instance1 = FirebaseDatabaseService();
//       final instance2 = FirebaseDatabaseService();
//       expect(instance1, same(instance2));
//     });
//   });

//   group('Initialization', () {
//     test('sets firestore via test configuration', () {
//       expect(firebaseService.firestore, mockFirestore);
//     });
//   });

//   group('Configuration', () {
//     test('setTestFirestore configure the service', () {
//       final service = FirebaseDatabaseService();
//       service.setTestFirestore(mockFirestore);
      
//       expect(service.firestore, mockFirestore);
//     });

//     test('resetForTest() clears all services', () {
//       firebaseService.resetForTest();
//       expect(() => firebaseService.firestore, throwsStateError);
//     });
//   });

//   group('Collections', () {
//     test('return correct paths', () {
//       when(mockCollection.path).thenReturn('users');
//       expect(firebaseService.users.path, 'users');
//       verify(mockFirestore.collection('users')).called(1);

//       when(mockCollection.path).thenReturn('tasks');
//       expect(firebaseService.tasks.path, 'tasks');
//       verify(mockFirestore.collection('tasks')).called(1);

//       when(mockCollection.path).thenReturn('subtasks');
//       expect(firebaseService.subtasks.path, 'subtasks');
//       verify(mockFirestore.collection('subtasks')).called(1);

//       when(mockCollection.path).thenReturn('speedruns');
//       expect(firebaseService.speedruns.path, 'speedruns');
//       verify(mockFirestore.collection('speedruns')).called(1);

//       when(mockCollection.path).thenReturn('habits');
//       expect(firebaseService.habits.path, 'habits');
//       verify(mockFirestore.collection('habits')).called(1);

//       when(mockCollection.path).thenReturn('mood_entries');
//       expect(firebaseService.moodEntries.path, 'mood_entries');
//       verify(mockFirestore.collection('mood_entries')).called(1);

//       when(mockCollection.path).thenReturn('energy_entries');
//       expect(firebaseService.energyEntries.path, 'energy_entries');
//       verify(mockFirestore.collection('energy_entries')).called(1);

//       when(mockCollection.path).thenReturn('activities');
//       expect(firebaseService.activities.path, 'activities');
//       verify(mockFirestore.collection('activities')).called(1);

//       when(mockCollection.path).thenReturn('time_blocks');
//       expect(firebaseService.timeBlocks.path, 'time_blocks');
//       verify(mockFirestore.collection('time_blocks')).called(1);

//       when(mockCollection.path).thenReturn('flowmodoros');
//       expect(firebaseService.flowmodoros.path, 'flowmodoros');
//       verify(mockFirestore.collection('flowmodoros')).called(1);

//       when(mockCollection.path).thenReturn('achievements');
//       expect(firebaseService.achievements.path, 'achievements');
//       verify(mockFirestore.collection('achievements')).called(1);

//       when(mockCollection.path).thenReturn('medications');
//       expect(firebaseService.medications.path, 'medications');
//       verify(mockFirestore.collection('medications')).called(1);

//       when(mockCollection.path).thenReturn('health_measurements');
//       expect(firebaseService.healthMeasurements.path, 'health_measurements');
//       verify(mockFirestore.collection('health_measurements')).called(1);

//       when(mockCollection.path).thenReturn('symptoms');
//       expect(firebaseService.symptoms.path, 'symptoms');
//       verify(mockFirestore.collection('symptoms')).called(1);

//       when(mockCollection.path).thenReturn('symptom_categories');
//       expect(firebaseService.symptomCategories.path, 'symptom_categories');
//       verify(mockFirestore.collection('symptom_categories')).called(1);

//       when(mockCollection.path).thenReturn('reports');
//       expect(firebaseService.reports.path, 'reports');
//       verify(mockFirestore.collection('reports')).called(1);

//       when(mockCollection.path).thenReturn('settings');
//       expect(firebaseService.settings.path, 'settings');
//       verify(mockFirestore.collection('settings')).called(1);
//     });
//   });

//   group('Error Handling', () {
//     test('throws when accessing uninitialized service', () {
//       final uninitialized = FirebaseDatabaseService();
//       uninitialized.resetForTest();
//       expect(() => uninitialized.firestore, throwsStateError);
//       expect(() => uninitialized.users, throwsStateError);
//     });

//     test('propagates Firebase exceptions', () {
//       when(mockFirestore.collection('users')).thenThrow(FirebaseException(plugin: 'firestore'));
//       expect(() => firebaseService.users, throwsA(isA<FirebaseException>()));
//     });
//   });

//   group('Concurrency', () {
//     test('handles concurrent access safely', () async {
//       final futures = [
//         Future(() => firebaseService.users),
//         Future(() => firebaseService.tasks),
//       ];
      
//       await expectLater(Future.wait(futures), completes);
//     });
//   });

//   group('Type Safety', () {
//     test('collections return correct type', () {
//       expect(firebaseService.users, isA<CollectionReference<Map<String, dynamic>>>());
//       expect(firebaseService.tasks, isA<CollectionReference<Map<String, dynamic>>>());
//     });
//   });
// }