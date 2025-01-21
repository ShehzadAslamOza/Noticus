part of 'quick_actions_bloc.dart';

class QuickActionsState extends Equatable {
  final bool isDndEnabled;
  final bool isNotificationPolicyAccessGranted;
  final double volumeValue;

  const QuickActionsState({
    required this.isDndEnabled,
    required this.isNotificationPolicyAccessGranted,
    required this.volumeValue,
  });

  QuickActionsState copyWith({
    bool? isDndEnabled,
    bool? isNotificationPolicyAccessGranted,
    double? volumeValue,
  }) {
    return QuickActionsState(
      isDndEnabled: isDndEnabled ?? this.isDndEnabled,
      isNotificationPolicyAccessGranted: isNotificationPolicyAccessGranted ??
          this.isNotificationPolicyAccessGranted,
      volumeValue: volumeValue ?? this.volumeValue,
    );
  }

  @override
  List<Object?> get props =>
      [isDndEnabled, isNotificationPolicyAccessGranted, volumeValue];
}
