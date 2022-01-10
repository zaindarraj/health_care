part of 'medical_navigation_bloc.dart';

abstract class MedicalNavigationEvent extends Equatable {
  const MedicalNavigationEvent();

  @override
  List<Object> get props => [];
}

class DeleteReport extends MedicalNavigationEvent {
  String rID;
  DeleteReport({required this.rID});
}

class GoProfile extends MedicalNavigationEvent {}

class GoPatientsList extends MedicalNavigationEvent {}

class GoReportsList extends MedicalNavigationEvent {}

class LogOut extends MedicalNavigationEvent {
  FirebaseAuth auth;
  LogOut({required this.auth});
}

class Update extends MedicalNavigationEvent {
  Map<String, String> update;
  String uID;
  Update({required this.update, required this.uID});
}
