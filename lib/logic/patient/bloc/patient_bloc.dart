import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_care_app/database/database_helper.dart';
import 'package:latlong2/latlong.dart';

part 'patient_event.dart';
part 'patient_state.dart';

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  String? userId;
  DatabaseHelper databaseHelper = DatabaseHelper();

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> listData(
      String collection, String? field, String? value) async {
    QuerySnapshot<Map<String, dynamic>> data;

    if (field != null && value != null) {
      data = await FirebaseFirestore.instance
          .collection(collection)
          .where(field, isEqualTo: value)
          .get();
    } else {
      data = await FirebaseFirestore.instance.collection(collection).get();
    }
    return data.docs;
  }

  Future<DocumentReference<Map<String, dynamic>>> addReport(
      String report) async {
    return await FirebaseFirestore.instance
        .collection("Reports")
        .add({"report": report});
  }

  Future<void> signOut(FirebaseAuth auth) async {
    await auth.signOut();
    await databaseHelper.delete("UserC");
  }

  PatientBloc({this.userId}) : super(PatientInitial()) {
    on<PatientEvent>((event, emit) async {
      try {
        if (event is AddReport) {
          emit(Loading());
          await addReport(event.report);
          emit(ReportAdded());
        }

        if (event is LogOut) {
          emit(Loading());
          await signOut(event.auth);
          await databaseHelper.delete("Location");

          emit(LoggedOut());
        }
        if (event is GoReports) {
          emit(Reports());
        }
        if (event is GoProfile) {
          emit(Loading());

          List<QueryDocumentSnapshot<Map<String, dynamic>>> data =
              await listData("RegiesterData", "ID", userId);
          emit(Profile(data: data.first.data()));
        }

        if (event is GoHome) {
          List<Map<String, Object?>> mapList =
              await databaseHelper.queryLocationDetails();
          String latitude = mapList.first["latitude"].toString();
          String longitude = mapList.first["longitude"].toString();
          List<QueryDocumentSnapshot<Map<String, dynamic>>> list = [];
          List<QueryDocumentSnapshot<Map<String, dynamic>>> data =
              await listData("RegiesterData", "AccountType", "patient");
          data.forEach((element) {
            Distance distance = const Distance();
            final double meter = distance(
                LatLng(double.parse(latitude), double.parse(longitude)),
                LatLng(double.parse(element["latitude"]),
                    double.parse(element["longitude"])));
            if (meter < 20) {
              list.add(element);
            }
          });
          emit(Home(list: list));
        }
      } catch (e) {
        emit(Failed());
      }
    });
  }
}
