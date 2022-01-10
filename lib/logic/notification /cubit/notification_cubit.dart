import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  String name;
  NotificationCubit({required this.name}) : super(NotificationInitial());

  void goMap() {
    emit(NotificationClicked(name: name));
  }
}
