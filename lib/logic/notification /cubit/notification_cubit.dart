import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  String jsonMap;
  NotificationCubit({required this.jsonMap}) : super(NotificationInitial());

  void goMap() {
    print(jsonMap);
    Map<String, dynamic> map = Map.castFrom(json.decode(jsonMap));
    print(map);
    emit(NotificationClicked(mapData: map));
  }
}
