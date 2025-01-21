import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:noticus/features/quick_actions/bloc/quick_actions_bloc.dart';
import 'package:noticus/features/quick_actions/presentation/quick_actions.dart';

void main() {
  group('QuickActionsPage Golden Tests', () {
    testGoldens('Default state of QuickActionsPage', (tester) async {
      await loadAppFonts();

      final QuickActionsState mockState = QuickActionsState(
        isDndEnabled: false,
        isNotificationPolicyAccessGranted: true,
        volumeValue: 0.5,
      );

      final bloc = QuickActionsBloc()..add(InitializeMockStateEvent(mockState));

      await tester.pumpWidgetBuilder(
        BlocProvider<QuickActionsBloc>(
          create: (_) => bloc,
          child: QuickActionsPage(),
        ),
        wrapper: materialAppWrapper(theme: ThemeData.dark()),
        surfaceSize: const Size(375, 812),
      );

      await screenMatchesGolden(tester, 'quick_actions_page_default');
    });

    testGoldens('DND enabled on QuickActionsPage', (tester) async {
      await loadAppFonts();

      final QuickActionsState mockState = QuickActionsState(
        isDndEnabled: true,
        isNotificationPolicyAccessGranted: true,
        volumeValue: 0.8,
      );

      final bloc = QuickActionsBloc()..add(InitializeMockStateEvent(mockState));

      await tester.pumpWidgetBuilder(
        BlocProvider<QuickActionsBloc>(
          create: (_) => bloc,
          child: QuickActionsPage(),
        ),
        wrapper: materialAppWrapper(theme: ThemeData.dark()),
        surfaceSize: const Size(375, 812),
      );

      await screenMatchesGolden(tester, 'quick_actions_page_dnd_enabled');
    });
  });
}
