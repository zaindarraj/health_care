import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_care_app/logic/location%20service/bloc/location_service_bloc.dart'
    as location;
import 'package:health_care_app/logic/medical%20staff%20navigation/bloc/medical_navigation_bloc.dart'
    as med;
import 'package:health_care_app/logic/patient/bloc/patient_bloc.dart';
import 'package:health_care_app/logic/register/bloc/register_bloc.dart';
import 'package:health_care_app/ui/login.dart';
import 'package:health_care_app/ui/medical_staff.dart';
import 'package:health_care_app/ui/patient.dart';
import 'package:health_care_app/ui/register.dart';
import 'package:health_care_app/ui/widgits.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({Key? key}) : super(key: key);

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is Registed) {
          if (state.aType == "medical staff") {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(providers: [
                          BlocProvider.value(
                            value: BlocProvider.of<RegisterBloc>(context),
                          ),
                          BlocProvider(
                            create: (context) => med.MedicalNavigationBloc(
                                userId: state.user.uid)
                              ..add(med.GoPatientsList()),
                          ),
                        ], child: const MedicalStaff())),
                (route) => false);
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
      },
      builder: (context, state) {
        return Scaffold(
            appBar: AppBar(
              title: const Center(child: Text("Health Care")),
            ),
            body: BlocProvider(
              create: (_) =>
                  location.LocationServiceBloc()..add(location.CheckService()),
              child: Center(
                child: BlocConsumer<RegisterBloc, RegisterState>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    if (state is location.Awaiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (state is Finished) {
                      return BlocConsumer<location.LocationServiceBloc,
                              location.LocationServiceState>(
                          builder: (context, state) {
                            if (state is Waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (state is location.ServiceOn) {
                              return serviceOnWidget(state);
                            } else if (state is location.ServiceOff) {
                              return const ServiceOffWidgit();
                            } else if (state is location.ServiceOffUser) {
                              return const ServiceOffUserWidgit();
                            } else if (state is location.ServiceThrottled) {
                              return (const Text(
                                  "Too many requests to get location, try again later"));
                            } else {
                              return Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  Text("Lodading..."),
                                  LinearProgressIndicator(),
                                ],
                              ));
                            }
                          },
                          listener: (context, state) {});
                    }
                    return const CircularProgressIndicator();
                  },
                ),
              ),
            ));
      },
    );
  }

  Center serviceOnWidget(location.ServiceOn state) {
    double fontSize = MediaQuery.of(context).textScaleFactor;
    return Center(
        child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FutureBuilder(
            future: state.getLocation(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.90,
                      height: MediaQuery.of(context).size.height * 0.25,
                      decoration: boxDecoration(Colors.blue),
                      child: snapshot.data != "error"
                          ? Center(
                              child: Text(
                                "Your City : " + snapshot.data.toString(),
                                style: TextStyle(fontSize: fontSize * 20),
                              ),
                            )
                          : const Center(
                              child: Text("Please try again later.")),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                    snapshot.data != "error"
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => BlocProvider(
                                                  create: (_) => RegisterBloc(),
                                                  child: const LogIn(),
                                                )));
                                  },
                                  child: const Text("Log in")),
                              TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => BlocProvider(
                                                  create: (_) => RegisterBloc(),
                                                  child: const Register(),
                                                )));
                                  },
                                  child: const Text("Create a new account")),
                            ],
                          )
                        : TextButton(
                            onPressed: () {
                              BlocProvider.of<location.LocationServiceBloc>(
                                      context)
                                  .add(location.Update());
                            },
                            child: const Text("try again"))
                  ],
                );
              }
              return const CircularProgressIndicator();
            },
          ),
        ],
      ),
    ));
  }
}

class ServiceOffUserWidgit extends StatelessWidget {
  const ServiceOffUserWidgit({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double fontSize = MediaQuery.of(context).textScaleFactor;

    return Center(
      child: Container(
        decoration: boxDecoration(Colors.red),
        width: MediaQuery.of(context).size.width * 0.94,
        height: MediaQuery.of(context).size.height * 0.25,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.not_listed_location_rounded),
            Text(
              "Looks like you denied location permissions or turned GPS off.",
              style: TextStyle(
                fontSize: fontSize * 15,
              ),
            ),
            Text(
              "Press this button to make sure everything runs well.",
              style: TextStyle(
                fontSize: fontSize * 15,
              ),
            ),
            TextButton(
                onPressed: () {
                  BlocProvider.of<location.LocationServiceBloc>(context)
                      .add(location.StartService());
                },
                child: const Text("Turn Service On"))
          ],
        ),
      ),
    );
  }
}

class ServiceOffWidgit extends StatelessWidget {
  const ServiceOffWidgit({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double fontSize = MediaQuery.of(context).textScaleFactor;
    return Center(
      child: Container(
        decoration: boxDecoration(Colors.red),
        width: MediaQuery.of(context).size.width * 0.94,
        height: MediaQuery.of(context).size.height * 0.25,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.location_searching),
            Text(
              "App functionality depends on GPS services and location permissions.",
              style: TextStyle(
                fontSize: fontSize * 15,
              ),
            ),
            Text(
              "Please press the button to turn them on",
              style: TextStyle(
                fontSize: fontSize * 15,
              ),
            ),
            TextButton(
                onPressed: () {
                  BlocProvider.of<location.LocationServiceBloc>(context)
                      .add(location.StartService());
                },
                child: const Text("Turn On"))
          ],
        ),
      ),
    );
  }
}
