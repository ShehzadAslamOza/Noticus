import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:noticus/core/utils/StreamController.dart';
import 'package:noticus/features/history/domain/entities/history_entity.dart';
import 'package:noticus/features/history/domain/usecases/fetch_history_usecase.dart';
import 'package:noticus/features/notification_listner/domain/entities/notification_entity.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final FetchHistoryUseCase fetchHistory;
  List<HistoryEntity> historyList = [];

  HistoryBloc({required this.fetchHistory}) : super(HistoryInitial()) {
    // Listen to global notification events
    NotificationEventBus().stream.listen((notification) {
      add(AddNotificationEvent(notification));
    });

    on<FetchHistoryEvent>((event, emit) async {
      emit(HistoryLoading());
      try {
        final history = await fetchHistory(event.userId);
        historyList = history;
        emit(HistoryLoaded(
          history: history,
          filteredHistory: history,
        ));
      } catch (e) {
        emit(HistoryError("Failed to fetch history"));
      }
    });

    on<FetchLocalHistoryEvent>((event, emit) {
      emit(HistoryLoaded(
        history: historyList,
        filteredHistory: historyList,
      ));
    });

    on<AddNotificationEvent>((event, emit) async {
      Uint8List? appIcon;
      String appName = '';
      try {
        final AppInfo? appInfo =
            await InstalledApps.getAppInfo(event.notification.packageName);
        appIcon = appInfo?.icon;
        appName = appInfo?.name ?? '';
      } catch (e) {
        appIcon = null;
      }

      final updatedHistoryList = List<HistoryEntity>.from(historyList)
        ..add(
          HistoryEntity(
            id: event.notification.id,
            appName: appName.isNotEmpty ? appName : 'Unknown App',
            title: event.notification.title ?? 'No Title',
            packageName: event.notification.packageName,
            subtitle: event.notification.content,
            timestamp: event.notification.timestamp.toLocal(),
            appIcon: appIcon,
          ),
        );

      historyList = updatedHistoryList;
      emit(HistoryLoaded(
        history: updatedHistoryList,
        filteredHistory: updatedHistoryList,
      ));
    });

    on<StartSearchEvent>((event, emit) {
      if (state is HistoryLoaded) {
        final currentState = state as HistoryLoaded;
        emit(currentState.copyWith(
          isSearching: true,
          searchQuery: '',
          filteredHistory: event.history,
        ));
      }
    });

    on<StopSearchEvent>((event, emit) {
      if (state is HistoryLoaded) {
        final currentState = state as HistoryLoaded;
        emit(currentState.copyWith(
          isSearching: false,
          searchQuery: '',
        ));
      }
    });

    on<SearchQueryChangedEvent>((event, emit) {
      if (state is HistoryLoaded) {
        final currentState = state as HistoryLoaded;
        final filtered = event.history.where((notification) {
          final title = notification.title.toLowerCase();
          final subtitle = (notification.subtitle ?? '').toLowerCase();
          final appName = notification.appName.toLowerCase();
          return title.contains(event.query.toLowerCase()) ||
              subtitle.contains(event.query.toLowerCase()) ||
              appName.contains(event.query.toLowerCase());
        }).toList();

        emit(currentState.copyWith(
          searchQuery: event.query,
          filteredHistory: filtered,
        ));
      }
    });

    on<ToggleDashboardEvent>((event, emit) {
      if (state is HistoryLoaded) {
        final currentState = state as HistoryLoaded;
        emit(currentState.copyWith(
          showDashboard: !currentState.showDashboard,
        ));
      }
    });

    on<ClearAllNotificationsEvent>((event, emit) async {
      try {
        // Clear notifications from Firebase (mocking for now)
        await clearNotificationsFromFirebase(event.userId);
        historyList.clear();
        emit(HistoryLoaded(
          history: [],
          filteredHistory: [],
        ));
      } catch (e) {
        emit(HistoryError("Failed to clear notifications"));
      }
    });

    on<DeleteNotificationEvent>((event, emit) async {
      try {
        // Delete notification from Firebase (mocking for now)
        await deleteNotificationFromFirebase(event.notificationId);
        final updatedHistoryList = historyList
            .where((notification) => notification.id != event.notificationId)
            .toList();
        historyList = updatedHistoryList;
        emit(HistoryLoaded(
          history: updatedHistoryList,
          filteredHistory: updatedHistoryList,
        ));
      } catch (e) {
        emit(HistoryError("Failed to delete notification"));
      }
    });
  }

  Future<void> clearNotificationsFromFirebase(String userId) async {
    // Implement Firebase clearing logic
  }

  Future<void> deleteNotificationFromFirebase(String notificationId) async {
    // Implement Firebase delete logic
  }
}
