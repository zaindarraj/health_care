import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_care_app/database/database_helper.dart';

part 'medical_navigation_event.dart';
part 'medical_navigation_state.dart';

class MedicalNavigationBloc
    extends Bloc<MedicalNavigationEvent, MedicalNavigationState> {
  String userId;
  DatabaseHelper databaseHelper = DatabaseHelper();

  Future<void> deleteReport(String rID) async {
    await FirebaseFirestore.instance.collection("Reports").doc(rID).delete();
  }

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

  Future<void> signOut(FirebaseAuth auth) async {
    await auth.signOut();
    await databaseHelper.delete("UserC");
    await databaseHelper.delete("Location");
  }

  MedicalNavigationBloc({required this.userId}) : super(Loading()) {
    on<MedicalNavigationEvent>((event, emit) async {
      try {
        if (event is DeleteReport) {
          emit(Loading());
          await deleteReport(event.rID);
          List<QueryDocumentSnapshot<Map<String, dynamic>>> list =
              await listData("Reports", null, null);
          emit(ReportsList(list: list));
        }
        if (event is LogOut) {
          emit(Loading());
          await signOut(event.auth);
          emit(LoggedOut());
        }

        if (event is GoReportsList) {
          emit(Loading());
          List<QueryDocumentSnapshot<Map<String, dynamic>>> list =
              await listData("Reports", null, null);
          emit(ReportsList(list: list));
        }

        if (event is GoProfile) {
          emit(Loading());

          List<QueryDocumentSnapshot<Map<String, dynamic>>> dataList =
              await listData("RegiesterData", "ID", userId);

          emit(Profile(
              accountType: dataList.first.data()["AccountType"],
              email: dataList.first.data()["Email"],
              fName: dataList.first.data()["FirstName"],
              lName: dataList.first.data()["LastName"]));
        } else if (event is GoPatientsList) {
          emit(Loading());
          List<QueryDocumentSnapshot<Map<String, dynamic>>> list =
              await listData("RegiesterData", "AccountType", "patient");
          emit(PatientsList(list: list));
        } else if (event is Update) {
          emit(Loading());
          final userData = await listData("RegiesterData", "ID", event.uID);
          userData.first.reference.update(event.update);
          final dataList =
              await listData("RegiesterData", "AccountType", "patient");
          emit(PatientsList(list: dataList));
        }
      } catch (e) {
        print(e);
      }
    });
  }
}
