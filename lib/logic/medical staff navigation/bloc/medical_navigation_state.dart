part of 'medical_navigation_bloc.dart';

abstract class MedicalNavigationState extends Equatable {
  const MedicalNavigationState();

  @override
  List<Object> get props => [];
}

class PatientsList extends MedicalNavigationState {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> list;
  PatientsList({required this.list});
}

class LoggedOut extends MedicalNavigationState {}
class Error extends MedicalNavigationState {}

class Profile extends MedicalNavigationState {
  String fName;
  String lName;
  String email;
  String accountType;
  Profile(
      {required this.accountType,
      required this.email,
      required this.fName,
      required this.lName});
}

class ReportsList extends MedicalNavigationState {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> list;
  ReportsList({required this.list});
}

class Loading extends MedicalNavigationState {}
