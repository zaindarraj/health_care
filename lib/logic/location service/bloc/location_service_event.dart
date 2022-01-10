part of 'location_service_bloc.dart';

abstract class LocationServiceEvent extends Equatable {
  const LocationServiceEvent();

  @override
  List<Object> get props => [];
}

class StartService extends LocationServiceEvent {}
class Update extends LocationServiceEvent {}

class CheckService extends LocationServiceEvent {}

class CatchError extends LocationServiceEvent {}
