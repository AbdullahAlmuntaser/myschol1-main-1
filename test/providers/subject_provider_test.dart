import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:myapp/database_helper.dart'; // Corrected import
import 'package:myapp/providers/subject_provider.dart'; // Corrected import
import 'package:myapp/subject_model.dart'; // Corrected import

import 'subject_provider_test.mocks.dart';

@GenerateMocks([DatabaseHelper])
void main() {
  // Initialize FFI for sqflite
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('SubjectProvider', () {
    late MockDatabaseHelper mockDatabaseHelper;
    late SubjectProvider subjectProvider;

    setUp(() {
      mockDatabaseHelper = MockDatabaseHelper();
      subjectProvider = SubjectProvider(databaseHelper: mockDatabaseHelper);
    });

    test('fetchSubjects should update the list of subjects', () async {
      final subjects = [
        Subject(id: 1, name: 'Mathematics', subjectId: 'MATH101'),
        Subject(id: 2, name: 'Science', subjectId: 'SCI101'),
      ];
      when(mockDatabaseHelper.getSubjects()).thenAnswer((_) async => subjects);

      await subjectProvider.fetchSubjects();

      expect(subjectProvider.subjects, subjects);
      verify(mockDatabaseHelper.getSubjects());
    });

    test(
      'searchSubjects should update the list of subjects based on a query',
      () async {
        final query = 'Math';
        final subjects = [
          Subject(id: 1, name: 'Mathematics', subjectId: 'MATH101'),
        ];
        when(
          mockDatabaseHelper.searchSubjects(query),
        ).thenAnswer((_) async => subjects);

        await subjectProvider.searchSubjects(query);

        expect(subjectProvider.subjects, subjects);
        verify(mockDatabaseHelper.searchSubjects(query));
      },
    );

    test(
      'searchSubjects should fetch all subjects when the query is empty',
      () async {
        final subjects = [
          Subject(id: 1, name: 'Mathematics', subjectId: 'MATH101'),
          Subject(id: 2, name: 'Science', subjectId: 'SCI101'),
        ];
        when(
          mockDatabaseHelper.getSubjects(),
        ).thenAnswer((_) async => subjects);

        await subjectProvider.searchSubjects('');

        expect(subjectProvider.subjects, subjects);
        verify(mockDatabaseHelper.getSubjects());
      },
    );

    test('addSubject should add a subject and refetch the list', () async {
      final newSubject = Subject(name: 'History', subjectId: 'HIST101');
      when(mockDatabaseHelper.getSubjectBySubjectId('HIST101')).thenAnswer((_) async => null);
      when(
        mockDatabaseHelper.createSubject(newSubject),
      ).thenAnswer((_) async => 1);
      when(mockDatabaseHelper.getSubjects()).thenAnswer(
        (_) async => [Subject(id: 1, name: 'History', subjectId: 'HIST101')],
      );

      await subjectProvider.addSubject(newSubject);

      verify(mockDatabaseHelper.createSubject(newSubject));
      verify(mockDatabaseHelper.getSubjects());
      expect(subjectProvider.subjects.length, 1);
      expect(subjectProvider.subjects.first.name, 'History');
    });

    test(
      'updateSubject should update a subject and refetch the list',
      () async {
        final updatedSubject = Subject(
          id: 1,
          name: 'Advanced Mathematics',
          subjectId: 'MATH201',
        );
        when(mockDatabaseHelper.getSubjectBySubjectId('MATH201')).thenAnswer((_) async => null);
        when(
          mockDatabaseHelper.updateSubject(updatedSubject),
        ).thenAnswer((_) async => 1);
        when(
          mockDatabaseHelper.getSubjects(),
        ).thenAnswer((_) async => [updatedSubject]);

        await subjectProvider.updateSubject(updatedSubject);

        verify(mockDatabaseHelper.updateSubject(updatedSubject));
        verify(mockDatabaseHelper.getSubjects());
        expect(subjectProvider.subjects.first, updatedSubject);
      },
    );

    test(
      'deleteSubject should delete a subject and refetch the list',
      () async {
        final subjectId = 1;
        when(
          mockDatabaseHelper.deleteSubject(subjectId),
        ).thenAnswer((_) async => 1);
        when(mockDatabaseHelper.getSubjects()).thenAnswer((_) async => []);

        await subjectProvider.deleteSubject(subjectId);

        verify(mockDatabaseHelper.deleteSubject(subjectId));
        verify(mockDatabaseHelper.getSubjects());
        expect(subjectProvider.subjects, isEmpty);
      },
    );
  });
}
