import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';
import 'package:noticus/features/history/bloc/history_bloc.dart';

import 'package:noticus/features/history/presentation/history_page.dart';
import 'package:noticus/features/history/domain/entities/history_entity.dart';
import 'package:noticus/features/history/domain/usecases/fetch_history_usecase.dart';
import 'package:noticus/features/history/domain/repositories/histroy_repository.dart';

// Mock HistoryRepository and FetchHistoryUseCase
class MockHistoryRepository extends Mock implements HistoryRepository {}

class MockFetchHistoryUseCase extends FetchHistoryUseCase {
  MockFetchHistoryUseCase(MockHistoryRepository repository) : super(repository);

  @override
  Future<List<HistoryEntity>> call(String userId) async {
    return [];
  }
}

void main() {
  group('HistoryPage Golden Tests', () {
    late MockHistoryRepository mockRepository;
    late MockFetchHistoryUseCase mockFetchHistoryUseCase;

    setUp(() {
      mockRepository = MockHistoryRepository();
      mockFetchHistoryUseCase = MockFetchHistoryUseCase(mockRepository);
    });

    testGoldens('HistoryPage loading state', (WidgetTester tester) async {
      final historyBloc = HistoryBloc(fetchHistory: mockFetchHistoryUseCase);

      // Emit loading state
      historyBloc.add(FetchHistoryEvent("test_user"));

      final widget = BlocProvider<HistoryBloc>(
        create: (_) => historyBloc,
        child: MaterialApp(home: HistoryPage()),
      );

      await tester.pumpWidgetBuilder(widget);

      // Allow one frame for the CircularProgressIndicator to render
      await tester.pump();

      await screenMatchesGolden(tester, 'history_page_loading');
    });

    testGoldens('HistoryPage loaded state with notifications',
        (WidgetTester tester) async {
      final historyBloc = HistoryBloc(fetchHistory: mockFetchHistoryUseCase);

      // Sample notifications
      final notifications = [
        HistoryEntity(
          id: '1',
          appName: 'App A',
          packageName: 'com.example.app_a',
          title: 'Notification Title A',
          subtitle: 'Notification Subtitle A',
          timestamp: DateTime.now(),
          appIcon: null,
        ),
        HistoryEntity(
          id: '2',
          appName: 'App B',
          packageName: 'com.example.app_b',
          title: 'Notification Title B',
          subtitle: 'Notification Subtitle B',
          timestamp: DateTime.now().subtract(Duration(hours: 1)),
          appIcon: null,
        ),
      ];

      // Emit loaded state
      historyBloc.emit(HistoryLoaded(notifications));

      final widget = BlocProvider<HistoryBloc>(
        create: (_) => historyBloc,
        child: MaterialApp(home: HistoryPage()),
      );

      await tester.pumpWidgetBuilder(widget);
      await screenMatchesGolden(
          tester, 'history_page_loaded_with_notifications');
    });

    testGoldens('HistoryPage error state', (WidgetTester tester) async {
      final historyBloc = HistoryBloc(fetchHistory: mockFetchHistoryUseCase);

      // Emit error state
      historyBloc.emit(HistoryError('Failed to load history'));

      final widget = BlocProvider<HistoryBloc>(
        create: (_) => historyBloc,
        child: MaterialApp(home: HistoryPage()),
      );

      await tester.pumpWidgetBuilder(widget);
      await screenMatchesGolden(tester, 'history_page_error');
    });

    testGoldens('HistoryPage empty state', (WidgetTester tester) async {
      final historyBloc = HistoryBloc(fetchHistory: mockFetchHistoryUseCase);

      // Emit empty state
      historyBloc.emit(HistoryLoaded([]));

      final widget = BlocProvider<HistoryBloc>(
        create: (_) => historyBloc,
        child: MaterialApp(home: HistoryPage()),
      );

      await tester.pumpWidgetBuilder(widget);
      await screenMatchesGolden(tester, 'history_page_empty');
    });
  });
}
