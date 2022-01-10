import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_care_app/logic/medical%20staff%20navigation/bloc/medical_navigation_bloc.dart';
import 'package:health_care_app/logic/patient/bloc/patient_bloc.dart';
import 'package:health_care_app/logic/register/bloc/register_bloc.dart';
import 'package:health_care_app/ui/medical_staff.dart';
import 'package:health_care_app/ui/patient.dart';
import 'package:health_care_app/ui/widgits.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  List<bool> genderList = List.generate(2, (index) => false); //0:male
  List<bool> typeList = List.generate(2, (index) => false); //0:medical staff
  TextEditingController emailC = TextEditingController();
  TextEditingController passwordC = TextEditingController();
  TextEditingController fNameC = TextEditingController();
  TextEditingController lNameC = TextEditingController();
  String gender = "null";
  String aType = "null";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Register an account"),
      ),
      body: Center(
        child: BlocConsumer<RegisterBloc, RegisterState>(
            builder: (context, state) {
              if(state is Waiting){
                return const Center(child: CircularProgressIndicator(),);
              }
          return Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: boxDecoration(Colors.blue),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.65,
                  child: Column(
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
                      TextFormField(
                        controller: fNameC,
                        decoration: inputDecoration("First Name"),
                      ),
                      TextFormField(
                        controller: lNameC,
                        decoration: inputDecoration("Last Name"),
                      ),
                    ],
                  ),
                ),
                ToggleButtons(
                    selectedColor: Colors.blue,
                    onPressed: (index) {
                      setState(() {
                        typeList[index] = !typeList[index];
                        for (int i = 0; i <= 1; i++) {
                          if (i != index) {
                            typeList[i] = false;
                            if (index == 1) {
                              aType = "patient";
                            } else {
                              aType = "medical staff";
                            }
                          }
                        }
                      });
                    },
                    children: [
                      SizedBox(
                          width: (MediaQuery.of(context).size.width - 36) / 3,
                          child: const Center(child: Text("Medical Staff"))),
                      SizedBox(
                          width: (MediaQuery.of(context).size.width - 36) / 3,
                          child: const Center(child: Text("Patient")))
                    ],
                    isSelected: typeList),
                ToggleButtons(
                    selectedColor: Colors.blue,
                    onPressed: (index) {
                      setState(() {
                        genderList[index] = !genderList[index];
                        for (int i = 0; i <= 1; i++) {
                          if (i != index) {
                            genderList[i] = false;
                            if (index == 0) {
                              gender = "male";
                            } else {
                              gender = "female";
                            }
                          }
                        }
                      });
                    },
                    children: [
                      SizedBox(
                          width: (MediaQuery.of(context).size.width - 36) / 3,
                          child: const Center(child: Icon(Icons.male))),
                      SizedBox(
                          width: (MediaQuery.of(context).size.width - 36) / 3,
                          child: const Center(child: Icon(Icons.female)))
                    ],
                    isSelected: genderList),
                TextButton(
                    onPressed: () {
                      if (emailC.text.isNotEmpty &&
                          passwordC.text.isNotEmpty &&
                          fNameC.text.isNotEmpty &&
                          lNameC.text.isNotEmpty &&
                          gender != "null" &&
                          aType != "null") {
                        BlocProvider.of<RegisterBloc>(context).add(Regist(
                            accountType: aType,
                            gender: gender.replaceAll(RegExp(r"\s+"), ""),
                            lastName:
                                lNameC.text.replaceAll(RegExp(r"\s+"), ""),
                            firstName:
                                fNameC.text.replaceAll(RegExp(r"\s+"), ""),
                            password:
                                passwordC.text.replaceAll(RegExp(r"\s+"), ""),
                            email: emailC.text.replaceAll(RegExp(r"\s+"), "")));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Please fill all fields")));
                      }
                    },
                    child: const Text("Register"))
              ],
            ),
          );
        }, listener: (context, state) {
          if (state is ErrorState) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
            BlocProvider.of<RegisterBloc>(context).add(Await());
          }
          if (state is Registed) {
            if (aType != "patient") {
              try {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(providers: [
                              BlocProvider.value(
                                value: BlocProvider.of<RegisterBloc>(context),
                              ),
                              BlocProvider(
                                create: (context) => MedicalNavigationBloc(
                                    userId: state.user.uid)
                                  ..add(GoPatientsList()),
                              ),
                            ], child: const MedicalStaff())),
                    (route) => false);
              } catch (e) {
                print(e);
              }
            } else {
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
                                    PatientBloc(userId: state.user.uid)
                                      ..add(GoHome()),
                              ),
                            ], child: const Patient())),
                    (route) => false);
              } catch (e) {
                print(e);
              }
            }
          }
        }),
      ),
    );
  }

  InputDecoration inputDecoration(String label) => InputDecoration(
      labelText: label, floatingLabelBehavior: FloatingLabelBehavior.always);
}

String? validateEmail(String? value) {
  if (value != null) {
    if (value.length > 5 && value.contains('@') && value.endsWith('.com')) {
      return null;
    }
    return 'Enter a Valid Email Address';
  }
}
