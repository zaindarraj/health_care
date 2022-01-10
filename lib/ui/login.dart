import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_care_app/logic/medical%20staff%20navigation/bloc/medical_navigation_bloc.dart';
import 'package:health_care_app/logic/patient/bloc/patient_bloc.dart';
import 'package:health_care_app/logic/register/bloc/register_bloc.dart';
import 'package:health_care_app/ui/medical_staff.dart';
import 'package:health_care_app/ui/password_reset.dart';
import 'package:health_care_app/ui/patient.dart';
import 'package:health_care_app/ui/register.dart';
import 'package:health_care_app/ui/widgits.dart';

class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  TextEditingController emailC = TextEditingController();
  TextEditingController passwordC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign In"),
        centerTitle: true,
      ),
      body:
          BlocConsumer<RegisterBloc, RegisterState>(listener: (context, state) {
        if (state is ErrorState) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
          BlocProvider.of<RegisterBloc>(context).add(Await());
        } else if (state is Registed) {
          if (state.aType == "medical staff") {
            try {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(providers: [
                            BlocProvider.value(
                              value: BlocProvider.of<RegisterBloc>(context),
                            ),
                            BlocProvider(
                              create: (context) =>
                                  MedicalNavigationBloc(userId: state.user.uid)
                                    ..add(GoPatientsList()),
                            ),
                          ], child: const MedicalStaff())),
                  (route) => false);
            } catch (e) {
              print(e);
            }
          } else {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(providers: [
                          BlocProvider.value(
                            value: BlocProvider.of<RegisterBloc>(context),
                          ),
                          BlocProvider(
                            create: (context) =>
                                PatientBloc(userId: state.user.uid)
                                  ..add(GoHome()),
                          ),
                        ], child: const Patient())),
                (route) => false);
          }
        }
      }, builder: (context, state) {
        if (state is Waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: boxDecoration(Colors.blue),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Form(
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.always,
                        validator: validateEmail,
                        controller: emailC,
                        decoration: inputDecoration("Email"),
                      ),
                    ),
                    TextFormField(
                      obscureText: true,
                      controller: passwordC,
                      decoration: inputDecoration("Password"),
                    ),
                    TextButton(
                        onPressed: () {
                          if (emailC.text.isNotEmpty &&
                              passwordC.text.isNotEmpty) {
                            BlocProvider.of<RegisterBloc>(context).add(
                                LogInEvent(
                                    email: emailC.text
                                        .replaceAll(RegExp(r"\s+"), ""),
                                    password: passwordC.text));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Please fill all fields")));
                          }
                        },
                        child: const Text("Sign In")),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                        value: BlocProvider.of<RegisterBloc>(
                                            context),
                                        child: const PasswordReset(),
                                      )));
                        },
                        child: const Text("Reset Password"))
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

InputDecoration inputDecoration(String label) => InputDecoration(
    labelText: label, floatingLabelBehavior: FloatingLabelBehavior.always);
