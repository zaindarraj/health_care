import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health_care_app/logic/notification%20/cubit/notification_cubit.dart';
import 'package:health_care_app/logic/patient/bloc/patient_bloc.dart';
import 'package:health_care_app/logic/register/bloc/register_bloc.dart';
import 'package:health_care_app/ui/widgits.dart';

import 'first_screen.dart';
import 'map_screen.dart';

class Patient extends StatefulWidget {
  const Patient({Key? key}) : super(key: key);

  @override
  _PatientState createState() => _PatientState();
}

class _PatientState extends State<Patient> {
  TextEditingController reportText = TextEditingController();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> onSelectNotification(String? payload) async {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return BlocProvider(
        create: (context) => NotificationCubit(name: payload as String),
        child: const MapScreen(),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient"),
        centerTitle: true,
      ),
      body: bodyWidget(),
      drawer: drawerWidget(context),
    );
  }

  BlocConsumer<PatientBloc, PatientState> bodyWidget() {
    return BlocConsumer<PatientBloc, PatientState>(builder: (context, state) {
      if (state is ReportAdded) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.done,
                size: MediaQuery.of(context).textScaleFactor * 40,
                color: Colors.green,
              ),
              Text(
                "All Done",
                style: TextStyle(
                    fontSize: MediaQuery.of(context).textScaleFactor * 40,
                    color: Colors.green),
              )
            ],
          ),
        );
      }
      if (state is Home) {
        return homeWidget(state, context);
      } else if (state is Profile) {
        return profileWidget(context, state);
      } else if (state is Reports) {
        return reportWidget(context);
      }
      return const Center(
        child: CircularProgressIndicator(),
      );
    }, listener: (context, state) {
      if (state is Home) {
        int index = 0;
        state.list.isNotEmpty
            ? state.list.forEach((element) async {
                AndroidNotificationDetails androidChannelSpecifics =
                    AndroidNotificationDetails(
                  index.toString(),
                  index.toString(),
                );
                var initializationSettingsAndroid =
                    const AndroidInitializationSettings('@mipmap/ic_launcher');
                var initSetttings = InitializationSettings(
                    android: initializationSettingsAndroid);
                flutterLocalNotificationsPlugin.initialize(initSetttings,
                    onSelectNotification: onSelectNotification);
                await Future.delayed(Duration(seconds: 2));
                await flutterLocalNotificationsPlugin.show(
                    index,
                    "Nearby Patient !",
                    element.data()["FirstName"],
                    NotificationDetails(android: androidChannelSpecifics),
                    payload: element.data()["FirstName"]);
                index++;
              })
            : null;
      }
      if (state is LoggedOut) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BlocProvider(
                      create: (context) => RegisterBloc()..add(Check()),
                      child: const FirstScreen(),
                    )));
      }
    });
  }

  Center reportWidget(BuildContext context) {
    return Center(
      child: Container(
        decoration: boxDecoration(Colors.blue),
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                alignment: Alignment.center,
                child:
                    Title(color: Colors.blue, child: const Text("Add report"))),
            TextField(
              controller: reportText,
              maxLines: 10,
              keyboardType: TextInputType.multiline,
            ),
            TextButton(
                onPressed: () {
                  BlocProvider.of<PatientBloc>(context)
                      .add(AddReport(report: reportText.text));
                },
                child: const Text("Submit"))
          ],
        ),
      ),
    );
  }

  //widgets

  SafeArea drawerWidget(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                BlocProvider.of<PatientBloc>(context).add(GoHome());
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [Icon(Icons.home), Text("Home Screen")],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                BlocProvider.of<PatientBloc>(context).add(GoReports());
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [Icon(Icons.report), Text("Report Screen")],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                BlocProvider.of<PatientBloc>(context).add(GoProfile());
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [Icon(Icons.person), Text("Profile Screen")],
              ),
            )
          ],
        ),
      ),
    );
  }

  Center profileWidget(BuildContext context, Profile state) {
    return Center(
        child: Container(
      decoration: boxDecoration(Colors.blue),
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.height * 0.4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListTile(
            title: const Text("Name"),
            subtitle: Row(
              children: [
                Text(state.data["FirstName"] + " " + state.data["LastName"])
              ],
            ),
          ),
          ListTile(
            title: const Text("Email"),
            subtitle: Row(
              children: [Text(state.data["Email"])],
            ),
          ),
          ListTile(
            title: const Text("Health State"),
            subtitle: Row(
              children: [Text(state.data["Health State"])],
            ),
          ),
          TextButton(
              onPressed: () {
                print(BlocProvider.of<RegisterBloc>(context).auth);
                BlocProvider.of<PatientBloc>(context).add(
                    LogOut(auth: BlocProvider.of<RegisterBloc>(context).auth));
              },
              child: const Text("Log out"))
        ],
      ),
    ));
  }

  Center homeWidget(Home state, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Health Care App"),
          state.list.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Nearby patients : "),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: ListView.builder(
                          itemCount: state.list.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              dense: true,
                              title: const Text(
                                "Name and Health State",
                                style: TextStyle(color: Colors.blue),
                              ),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      child: Center(
                                        child: Text(state.list[index]
                                            .data()["FirstName"]),
                                      )),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: Center(
                                      child: Text(
                                        state.list[index]
                                            .data()["Health State"],
                                        style: TextStyle(
                                            color: state.list[index].data()[
                                                        "Health State"] ==
                                                    "healthy"
                                                ? Colors.green
                                                : Colors.red),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                    ),
                  ],
                )
              : const Text("No one in sight")
        ],
      ),
    );
  }
}
