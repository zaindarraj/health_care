part of 'register_bloc.dart';

// ignore: must_be_immutable
abstract class RegisterEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class Check extends RegisterEvent {}

class ResetPassword extends RegisterEvent {
  String email;
  ResetPassword({required this.email});
}

// ignore: must_be_immutable
class Regist extends RegisterEvent {
  String firstName, lastName, email, gender, password, accountType;

  Regist(
      {required this.accountType,
      required this.email,
      required this.firstName,
      required this.gender,
      required this.lastName,
      required this.password});
}

class Await extends RegisterEvent {}

class Done extends RegisterEvent {}

class LogInEvent extends RegisterEvent {
  String email;
  String password;
  LogInEvent({required this.email, required this.password});
}
