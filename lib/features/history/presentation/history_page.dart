import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:noticus/features/history/domain/entities/history_entity.dart';
import 'package:noticus/features/rules/presentation/select_action_screen.dart';
import '../bloc/history_bloc.dart';

class HistoryPage extends StatefulWidget {
  @override
  HistoryPageState createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();

    // Fetch initial history using Bloc
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<HistoryBloc>().add(FetchHistoryEvent(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            if (state is HistoryLoaded && state.isSearching) {
              return TextField(
                autofocus: true,
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.yellow,
                decoration: InputDecoration(
                  hintText: "Search notifications...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                ),
                onChanged: (query) => context
                    .read<HistoryBloc>()
                    .add(SearchQueryChangedEvent(query, state.history)),
              );
            }
            return Text("History", style: TextStyle(color: Colors.white));
          },
        ),
        actions: [
          BlocBuilder<HistoryBloc, HistoryState>(
            builder: (context, state) {
              if (state is HistoryLoaded && !state.showDashboard) {
                return Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      tooltip: "Clear All",
                      onPressed: () {
                        final userId = FirebaseAuth.instance.currentUser?.uid;
                        if (userId != null) {
                          context
                              .read<HistoryBloc>()
                              .add(ClearAllNotificationsEvent(userId));
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        state.isSearching ? Icons.close : Icons.search,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (state.isSearching) {
                          context.read<HistoryBloc>().add(StopSearchEvent());
                        } else {
                          context
                              .read<HistoryBloc>()
                              .add(StartSearchEvent(state.history));
                        }
                      },
                    ),
                  ],
                );
              }
              return SizedBox.shrink();
            },
          ),
          BlocBuilder<HistoryBloc, HistoryState>(
            builder: (context, state) {
              if (state is HistoryLoaded) {
                return IconButton(
                  icon: Icon(
                    state.showDashboard ? Icons.list : Icons.dashboard,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    context.read<HistoryBloc>().add(ToggleDashboardEvent());
                  },
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
        elevation: 0,
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is HistoryLoaded) {
            return state.showDashboard
                ? buildDashboardView(state.history)
                : buildHistoryView(state.filteredHistory);
          } else if (state is HistoryError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: Colors.red),
              ),
            );
          }
          return Center(
            child: Text(
              "No history found",
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget buildDashboardView(List<HistoryEntity> history) {
    final stats = calculateStats(history);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildStatCard(
            title: "Total Notifications",
            value: stats['totalNotifications'].toString(),
            icon: Icons.notifications,
            color: Colors.yellow,
          ),
          SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: buildStatCard(
                  title: "Most Frequent App",
                  value: stats['mostFrequentApp'],
                  icon: Icons.app_settings_alt,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          buildStatCard(
            title: "Average Notifications/Day",
            value: stats['averagePerDay'].toString(),
            icon: Icons.bar_chart,
            color: Colors.green,
          ),
          SizedBox(height: 16.0),
          Text(
            "Notifications by Apps",
            style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Column(
            children: stats['notificationsByAppWithIcons']
                .map<Widget>((entry) => buildAppStatRow(entry['appName'],
                    entry['notificationCount'], entry['appIcon']))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget buildHistoryView(List<HistoryEntity> history) {
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (history.isEmpty) {
      return Center(
        child: Text(
          "No notifications match your search",
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final notification = history[index];
        return Dismissible(
          key: Key(notification.id),
          direction: DismissDirection.endToStart,
          background: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            alignment: Alignment.centerRight,
            color: Colors.red,
            child: Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            context
                .read<HistoryBloc>()
                .add(DeleteNotificationEvent(notification.id));
          },
          child: buildNotificationCard(notification),
        );
      },
    );
  }

  Widget buildAppStatRow(String appName, int count, Uint8List? appIcon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.0,
            backgroundColor: Colors.grey.shade800,
            backgroundImage: appIcon != null ? MemoryImage(appIcon) : null,
            child:
                appIcon == null ? Icon(Icons.apps, color: Colors.white) : null,
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: Text(
              "$appName: $count notifications",
              style: TextStyle(color: Colors.white, fontSize: 14.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.0,
            backgroundColor: color,
            child: Icon(icon, color: Colors.black),
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
                SizedBox(height: 4.0),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNotificationCard(HistoryEntity notification) {
    return GestureDetector(
      onLongPress: () {
        showContextMenu(notification);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.0,
              backgroundColor: Colors.grey.shade800,
              backgroundImage: notification.appIcon != null
                  ? MemoryImage(notification.appIcon!)
                  : null,
              child: notification.appIcon == null
                  ? Icon(Icons.notifications, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (notification.subtitle != null)
                    Text(
                      notification.subtitle!,
                      style: TextStyle(color: Colors.grey, fontSize: 14.0),
                    ),
                  Text(
                    formatDateTime(notification.timestamp),
                    style: TextStyle(color: Colors.grey, fontSize: 12.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showContextMenu(HistoryEntity notification) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.rule, color: Colors.white),
              title: Text(
                "Create Rule for this App",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectActionScreen(
                      appName: notification.appName,
                      packageName: notification.packageName,
                    ),
                  ),
                );
              },
            ),
            Divider(color: Colors.grey.shade700),
            ListTile(
              leading: Icon(Icons.cancel, color: Colors.red),
              title: Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final isToday = now.difference(dateTime).inDays == 0;
    final isYesterday = now.difference(dateTime).inDays == 1;

    if (isToday) {
      return "Today at ${DateFormat.jm().format(dateTime)}";
    } else if (isYesterday) {
      return "Yesterday at ${DateFormat.jm().format(dateTime)}";
    } else {
      return DateFormat('MMM dd, yyyy at h:mm a').format(dateTime);
    }
  }

  Map<String, dynamic> calculateStats(List<HistoryEntity> history) {
    final now = DateTime.now();
    final totalNotifications = history.length;

    final notificationsByApp = <String, Map<String, dynamic>>{};
    for (final notification in history) {
      if (!notificationsByApp.containsKey(notification.appName)) {
        notificationsByApp[notification.appName] = {
          'count': 0,
          'icon': notification.appIcon,
        };
      }
      notificationsByApp[notification.appName]!['count']++;
    }

    final mostFrequentAppEntry = notificationsByApp.entries.isNotEmpty
        ? notificationsByApp.entries
            .reduce((a, b) => a.value['count'] > b.value['count'] ? a : b)
        : null;
    final mostFrequentApp = mostFrequentAppEntry?.key ?? "None";

    final notificationsByAppWithIcons = notificationsByApp.entries
        .map((entry) => {
              'appName': entry.key,
              'notificationCount': entry.value['count'],
              'appIcon': entry.value['icon'],
            })
        .toList();

    final notificationsToday =
        history.where((n) => n.timestamp.day == now.day).length;
    final notificationsThisWeek =
        history.where((n) => now.difference(n.timestamp).inDays <= 7).length;
    final notificationsThisMonth =
        history.where((n) => now.difference(n.timestamp).inDays <= 30).length;

    final daysWithNotifications = history
        .map((e) => e.timestamp.toIso8601String().split('T').first)
        .toSet()
        .length;
    final averagePerDay = daysWithNotifications > 0
        ? (totalNotifications / daysWithNotifications).ceil()
        : 0;

    final peakPeriod = "9 AM - 10 AM";
    final longestQuietPeriod = "5 hours";

    return {
      'totalNotifications': totalNotifications,
      'notificationsByAppWithIcons': notificationsByAppWithIcons,
      'mostFrequentApp': mostFrequentApp,
      'notificationsToday': notificationsToday,
      'notificationsThisWeek': notificationsThisWeek,
      'notificationsThisMonth': notificationsThisMonth,
      'averagePerDay': averagePerDay,
      'peakPeriod': peakPeriod,
      'longestQuietPeriod': longestQuietPeriod,
    };
  }
}
