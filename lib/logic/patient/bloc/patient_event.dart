part of 'patient_bloc.dart';

abstract class PatientEvent extends Equatable {
  const PatientEvent();

  @override
  List<Object> get props => [];
}

class SendReport extends PatientEvent {
  String report;
  SendReport({required this.report});
}


class GoHome extends PatientEvent {}

class GoReports extends PatientEvent {}

class GoProfile extends PatientEvent {}

class LogOut extends PatientEvent {
  FirebaseAuth auth;
  LogOut({required this.auth});
}

class AddReport extends PatientEvent {
  String report;
  AddReport({required this.report});
}
