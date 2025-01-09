import 'dart:async';
import 'dart:math';
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
  List<HistoryEntity> history_list = [];

  HistoryBloc({required this.fetchHistory}) : super(HistoryInitial()) {
    // Listen to global notification events
    NotificationEventBus().stream.listen((notification) {
      print("Inside add notification event");
      add(AddNotificationEvent(notification));
    });
    on<FetchHistoryEvent>((event, emit) async {
      emit(HistoryLoading());
      try {
        final history = await fetchHistory(event.userId);
        history_list = history;
        emit(HistoryLoaded(history));
      } catch (e) {
        emit(HistoryError("Failed to fetch history"));
      }
    });

    on<FetchLocalHistoryEvent>((event, emit) {
      emit(HistoryLoaded(history_list));
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

      // Create a new list with the new notification added
      final updatedHistoryList = List<HistoryEntity>.from(history_list)
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

      history_list = updatedHistoryList;
      emit(HistoryLoaded(updatedHistoryList));
    });
  }
}
