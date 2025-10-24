import 'package:equatable/equatable.dart';
import 'package:noteflow/core/domain/entities/notification_settings.dart';
abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}
class NotificationInitial extends NotificationState {}
class NotificationLoading extends NotificationState {}
class NotificationSuccess extends NotificationState {
  final NotificationSettings settings;
  const NotificationSuccess(this.settings);
  @override
  List<Object?> get props => [settings];
}
class NotificationFailure extends NotificationState {
  final String message;
  const NotificationFailure(this.message);
  @override
  List<Object?> get props => [message];
}
class NotificationUpdated extends NotificationState {
  final NotificationSettings settings;
  const NotificationUpdated(this.settings);
  @override
  List<Object?> get props => [settings];
}
