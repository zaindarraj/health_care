import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health_care_app/logic/medical%20staff%20navigation/bloc/medical_navigation_bloc.dart';
import 'package:health_care_app/logic/register/bloc/register_bloc.dart';
import 'package:health_care_app/ui/first_screen.dart';
import 'package:health_care_app/ui/widgits.dart';

class MedicalStaff extends StatefulWidget {
  const MedicalStaff({Key? key}) : super(key: key);

  @override
  _MedicalStaffState createState() => _MedicalStaffState();
}

class _MedicalStaffState extends State<MedicalStaff> {
  int currentIndex = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.blue,
          currentIndex: currentIndex,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.group), label: "patients list"),
            BottomNavigationBarItem(
                icon: Icon(Icons.report), label: "reports list"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "profile")
          ],
          onTap: (index) {
            currentIndex = index;
            setState(() {});

            if (index == 2) {
              BlocProvider.of<MedicalNavigationBloc>(context).add(GoProfile());
            } else if (index == 0) {
              BlocProvider.of<MedicalNavigationBloc>(context)
                  .add(GoPatientsList());
            } else {
              BlocProvider.of<MedicalNavigationBloc>(context)
                  .add(GoReportsList());
            }
          },
        ),
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Medical Staff"),
        ),
        body: BlocConsumer<MedicalNavigationBloc, MedicalNavigationState>(
          listener: (context, state) {
            if (state is LoggedOut) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BlocProvider(
                            create: (context) => RegisterBloc()..add(Check()),
                            child: const FirstScreen(),
                          )));
            }
          },
          builder: (context, state) {
            return BlocConsumer<MedicalNavigationBloc, MedicalNavigationState>(
              listener: (context, state) {},
              builder: (context, state) {
                if (state is Error) {
                  return const Center(
                    child: Text("you are off line"),
                  );
                }
                if (state is PatientsList) {
                  return state.list.isNotEmpty
                      ? Center(child: patientListWidget(state))
                      : const Center(child: Text("no patients"));
                } else if (state is ReportsList) {
                  return state.list.isNotEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: MediaQuery.of(context).size.height * 0.9,
                              child: Center(
                                child: ListView.builder(
                                    itemCount: state.list.length,
                                    itemBuilder: (context, index) {
                                      return Center(
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                            decoration:
                                                boxDecoration(Colors.red),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Report",
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .textScaleFactor *
                                                            20),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                      state.list[index]
                                                          .data()["report"],
                                                      style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .textScaleFactor *
                                                              20)),
                                                  TextButton(
                                                    onPressed: () {
                                                      BlocProvider.of<
                                                                  MedicalNavigationBloc>(
                                                              context)
                                                          .add(DeleteReport(
                                                              rID: state
                                                                  .list[index]
                                                                  .id));
                                                    },
                                                    child: Text("Delete",
                                                        style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .textScaleFactor *
                                                                20)),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                          ),
                        )
                      : const Center(
                          child: Text("No Reports"),
                        );
                } else if (state is Profile) {
                  return profileWidget(context, state);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            );
          },
        ));
  }

  Center profileWidget(BuildContext context, Profile state) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.50,
        height: MediaQuery.of(context).size.height * 0.40,
        decoration: boxDecoration(Colors.blue),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ListTile(
              title: const Text(
                "Email",
                style: TextStyle(color: Colors.blue),
              ),
              subtitle: Text(state.email),
            ),
            ListTile(
              title: const Text(
                "First Name",
                style: TextStyle(color: Colors.blue),
              ),
              subtitle: Text(state.fName),
            ),
            ListTile(
              title: const Text(
                "Last Name",
                style: TextStyle(color: Colors.blue),
              ),
              subtitle: Text(state.lName),
            ),
            TextButton(
                onPressed: () {
                  BlocProvider.of<MedicalNavigationBloc>(context).add(LogOut(
                      auth: BlocProvider.of<RegisterBloc>(context).auth));
                },
                child: const Text("Sign Out"))
          ],
        ),
      ),
    );
  }

  ListView patientListWidget(PatientsList state) {
    return ListView.builder(
        itemCount: state.list.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              BlocProvider.of<MedicalNavigationBloc>(context)
                  .add(Update(update: {
                'Health State':
                    state.list[index].data()["Health State"] == "healthy"
                        ? "patient"
                        : "healthy"
              }, uID: state.list[index].data()["ID"]));
            },
            title: const Text(
              "Name and Health State",
              style: TextStyle(color: Colors.blue),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(state.list[index].data()["FirstName"]),
                  Text(
                    state.list[index].data()["Health State"],
                    style: TextStyle(
                        color:
                            state.list[index].data()["Health State"] == "healthy"
                                ? Colors.green
                                : Colors.red),
                  )
                ],
              ),
            ),
          );
        });
  }
}
