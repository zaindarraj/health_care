part of 'notification_cubit.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationClicked extends NotificationState {
  Map<String, dynamic> mapData;
  NotificationClicked({required this.mapData});
}
