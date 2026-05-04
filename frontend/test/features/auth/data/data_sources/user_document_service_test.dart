import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/user_document_service.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/user_document_service_impl.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

// ignore: subtype_of_sealed_class
class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class
class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocument;
  late UserDocumentService service;

  const user = AuthUserEntity(
    uid: 'uid-123',
    email: 'user@example.com',
    displayName: 'Test User',
    providerId: 'password',
    isAnonymous: false,
  );

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocument = MockDocumentReference();
    service = UserDocumentServiceImpl(mockFirestore);

    when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
    when(() => mockCollection.doc(any())).thenReturn(mockDocument);
    when(() => mockDocument.set(any(), any())).thenAnswer((_) async {});
  });

  group('UserDocumentService', () {
    test('upsertUser calls Firestore set with merge:true', () async {
      await service.upsertUser(user);

      verify(() => mockDocument.set(any(), any())).called(1);
    });

    test('upsertUser targets users/{uid} document', () async {
      await service.upsertUser(user);

      verify(() => mockCollection.doc('uid-123')).called(1);
    });

    test('upsertUser does not throw on Firestore success', () async {
      expect(() => service.upsertUser(user), returnsNormally);
    });
  });
}
