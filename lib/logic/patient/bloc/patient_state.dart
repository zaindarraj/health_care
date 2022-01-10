part of 'patient_bloc.dart';

abstract class PatientState extends Equatable {
  const PatientState();

  @override
  List<Object> get props => [];
}

class PatientInitial extends PatientState {}

class Home extends PatientState {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> list;
  Home({required this.list});
}

class ReportAdded extends PatientState {}

class LoggedOut extends PatientState {}

class Failed extends PatientState {}

class Reports extends PatientState {
  
}

class Loading extends PatientState {}

class Profile extends PatientState {
  Map<String, dynamic> data;
  Profile({required this.data});
}
