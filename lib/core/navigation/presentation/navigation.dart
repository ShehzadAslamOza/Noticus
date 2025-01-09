import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noticus/core/navigation/bloc/navigation_bloc.dart';
import 'package:noticus/features/notification_listner/bloc/notification_listner_bloc.dart';
import 'package:noticus/features/history/presentation/history_page.dart';
import 'package:noticus/features/quick_actions/presentation/quick_actions.dart';
import 'package:noticus/features/rules/presentation/rules_page.dart';
import 'package:noticus/features/settings/presentation/settings_page.dart';

class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  // Pages for the bottom navigation
  final List<Widget> _pages = [
    RulesPage(),
    HistoryPage(),
    QuickActionsPage(),
    SettingsPage(),
  ];

  bool _isListenerStarted = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final userId = FirebaseAuth.instance.currentUser?.uid;

    // Start the notification listener only once
    if (userId != null && !_isListenerStarted) {
      context.read<NotificationListenerBloc>().add(StartListeningEvent(userId));
      print("Notification Listener started for user ID: $userId");
      _isListenerStarted = true; // Ensure it doesn't start multiple times
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationBloc(),
      child: Scaffold(
        body: BlocBuilder<NavigationBloc, NavigationState>(
          builder: (context, state) {
            return IndexedStack(
              index: state.currentIndex,
              children: _pages,
            );
          },
        ),
        bottomNavigationBar: BlocBuilder<NavigationBloc, NavigationState>(
          builder: (context, state) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color:
                    const Color(0xFF1a1c20), // Navigation bar background color
                border: Border(
                  top: BorderSide(
                    color: Colors.black,
                    width: 0,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    context: context,
                    icon: Icons.notifications,
                    label: 'Rules',
                    index: 0,
                    isActive: state.currentIndex == 0,
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.message,
                    label: 'History',
                    index: 1,
                    isActive: state.currentIndex == 1,
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.explore,
                    label: 'Quick Actions',
                    index: 2,
                    isActive: state.currentIndex == 2,
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.settings,
                    label: 'Settings',
                    index: 3,
                    isActive: state.currentIndex == 3,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
  }) {
    final activeColor = const Color(0xFFffee83); // Yellow color
    final inactiveColor = const Color(0xFF535559); // Light gray color
    final navBackgroundColor = const Color(0xFF1a1c20); // Nav bar background

    return GestureDetector(
      onTap: () {
        context.read<NavigationBloc>().add(NavigationTabChanged(index));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isActive ? activeColor : navBackgroundColor,
              borderRadius: BorderRadius.circular(40), // Pill shape
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Icon(
              icon,
              color: isActive ? navBackgroundColor : inactiveColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? activeColor : inactiveColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
