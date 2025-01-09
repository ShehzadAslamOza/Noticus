import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:noticus/features/auth/presentation/login_page.dart';
import 'package:noticus/features/notification_listner/bloc/notification_listner_bloc.dart';
import 'package:noticus/features/settings/presentation/settings_page.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockNotificationListenerBloc extends Mock
    implements NotificationListenerBloc {}

void main() {
  group('SettingsPage Golden Tests', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();

      // Stub user email
      when(mockUser.email).thenReturn('testuser@example.com');
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    });

    testGoldens('SettingsPage static golden', (WidgetTester tester) async {
      final widget = MaterialApp(
        home: SettingsPage(),
      );

      await tester.pumpWidgetBuilder(
        widget,
        surfaceSize: const Size(375, 667),
      );

      await screenMatchesGolden(tester, 'settings_page_static');
    });
  });
}
