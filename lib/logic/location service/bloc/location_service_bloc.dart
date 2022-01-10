import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocode/geocode.dart';
import 'package:health_care_app/database/database_helper.dart';
import 'package:location/location.dart';

part 'location_service_event.dart';
part 'location_service_state.dart';

class LocationServiceBloc
    extends Bloc<LocationServiceEvent, LocationServiceState> {
  Location location = Location();

  Future<PermissionStatus> checkPermissionStatus() async {
    return await location.hasPermission();
  }

  Future<bool> checkGps() async {
    return await location.serviceEnabled();
  }

  Future<PermissionStatus> requestPermission() async {
    return await location.requestPermission();
  }

  Future<bool> requestGps() async {
    return await location.requestService();
  }

  LocationServiceBloc() : super(LocationServiceInitial()) {
    bool gpsOn = true;
    PermissionStatus permissionStatus = PermissionStatus.denied;

    on<LocationServiceEvent>((event, emit) async {
      if (event is Update) {
        emit(Awaiting());
        Timer.periodic(Duration(seconds: 2), (timer) {
            emit(ServiceOn());
          
        });
      }
      if (event is CatchError) {
        emit(ServiceThrottled());
      }
      if (event is CheckService) {
        gpsOn = await checkGps();
        permissionStatus = await checkPermissionStatus();
        if (gpsOn == true && permissionStatus == PermissionStatus.granted) {
          emit(ServiceOn());
        } else {
          emit(ServiceOff());
        }
      } else {
        if (!gpsOn) {
          gpsOn = await requestGps();
        }
        if (permissionStatus != PermissionStatus.granted) {
          permissionStatus = await requestPermission();
        }

        if (gpsOn == true && permissionStatus == PermissionStatus.granted) {
          emit(ServiceOn());
        } else {
          emit(ServiceOffUser());
        }
      }
    });
  }
}
