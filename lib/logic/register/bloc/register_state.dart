part of 'register_bloc.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object> get props => [];
}

class InitialRegisterState extends RegisterState {}

class Registed extends RegisterState {
  User user;
  String aType;
  Registed({required this.user, required this.aType});
}

class Waiting extends RegisterState {}

class Finished extends RegisterState{}

class ErrorState extends RegisterState {
  String message;
  ErrorState({required this.message});
}
