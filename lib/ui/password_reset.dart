import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_care_app/logic/register/bloc/register_bloc.dart';
import 'package:health_care_app/ui/login.dart';
import 'package:health_care_app/ui/widgits.dart';

class PasswordReset extends StatefulWidget {
  const PasswordReset({Key? key}) : super(key: key);

  @override
  _PasswordResetState createState() => _PasswordResetState();
}

class _PasswordResetState extends State<PasswordReset> {
  TextEditingController editingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Password Reset"),
        ),
        body: BlocBuilder<RegisterBloc,RegisterState>(builder: (context, state) {
          if (state is Finished) {
            return Center(
              child: Text("All done, please check your email."),
            );
          } else {
           return  bodyWidget(context);
          }
        }));
  }

  Container bodyWidget(BuildContext context) {
    return Container(
      decoration: boxDecoration(Colors.blue),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
                "Please enter your email and wait for the password reset."),
            TextField(
              controller: editingController,
              decoration: inputDecoration("Email"),
            ),
            TextButton(
                onPressed: () {
                  BlocProvider.of<RegisterBloc>(context).add(ResetPassword(
                      email: editingController.text
                          .replaceAll(RegExp(r"\s+"), "")));
                },
                child: const Text("Submit"))
          ],
        ),
      ),
    );
  }
}
