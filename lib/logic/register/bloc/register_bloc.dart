import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:health_care_app/database/database_helper.dart';
part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  FirebaseDatabase database = FirebaseDatabase.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  final storage = const FlutterSecureStorage();
  String? userId;
  Future<dynamic> register(String fname, String lastname, String accountType,
      String gender, String email, String password) async {
    try {
      DatabaseHelper databaseHelper = DatabaseHelper();
      List<Map<String, Object?>> list =
          await databaseHelper.queryLocationDetails();
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (userCredential.user != null) {
        if (accountType != "medical staff") {
          DocumentReference<Map<String, dynamic>> documentReference =
              await FirebaseFirestore.instance.collection("RegiesterData").add({
            "FirstName": fname,
            "LastName": lastname,
            "AccountType": accountType,
            "Health State": "healthy",
            "Gender": gender,
            "Email": email,
            "ID": userCredential.user!.uid,
            "latitude": list.first["latitude"],
            "longitude": list.first["longitude"]
          });
          return {"doc": documentReference, "userC": userCredential};
        } else {
          DocumentReference<Map<String, dynamic>> documentReference =
              await FirebaseFirestore.instance.collection("RegiesterData").add({
            "FirstName": fname,
            "LastName": lastname,
            "AccountType": accountType,
            "Gender": gender,
            "Email": email,
            "ID": userCredential.user!.uid,
            "latitude": list.first["latitude"],
            "longitude": list.first["longitude"]
          });
          return {"doc": documentReference, "userC": userCredential};
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return "Password too weak";
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
    } catch (e) {
      return "error";
    }
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> listData(
      String field, String value) async {
    QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance
        .collection("RegiesterData")
        .where(field, isEqualTo: value)
        .get();

    return data.docs;
  }

  Future<dynamic> logIn(String email, String password) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      return await auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (e) {
      return "error";
    }
  }

  RegisterBloc() : super(InitialRegisterState()) {
    on<RegisterEvent>((event, emit) async {
      try {
        if (event is ResetPassword) {
          emit(Waiting());
          await auth.sendPasswordResetEmail(email: event.email);
          emit(Finished());
        }

        if (event is Check) {
          emit(Waiting());
          final database = await databaseHelper.getDatabase();
          if (database.isOpen) {
            List<Map<String, Object?>> list = await database.query("UserC");
            if (list.isNotEmpty) {
              dynamic result = await logIn(
                  list.last["Email"] as String,
                  await storage.read(key: list.last["Email"] as String)
                      as String);
              if (result is UserCredential) {
                List<QueryDocumentSnapshot<Map<String, dynamic>>> data =
                    await listData("Email", result.user!.email as String);

                Map<String, dynamic> dataMap = data.first.data();
                emit(Registed(
                    user: result.user as User, aType: dataMap["AccountType"]));
              } else {
                emit(ErrorState(message: result));
              }
            } else {
              emit(Finished());
            }
          }
        }

        if (event is LogInEvent) {
          emit(Waiting());

          dynamic result = await logIn(event.email, event.password);

          List<QueryDocumentSnapshot<Map<String, dynamic>>> data =
              await listData("Email", event.email);

          Map<String, dynamic> dataMap = data.first.data();
          if (result is UserCredential) {
            await storage.write(key: dataMap["Email"], value: event.password);
            databaseHelper.insert("UserC", {
              "Email": dataMap["Email"],
              "AccountType": dataMap["AccountType"]
            });
            emit(Registed(
                user: result.user as User, aType: dataMap["AccountType"]));
          } else {
            emit(ErrorState(message: result.toString()));
          }
        }
        if (event is Regist) {
          emit(Waiting());

          dynamic result = await register(event.firstName, event.lastName,
                  event.accountType, event.gender, event.email, event.password)
              .timeout(
            const Duration(seconds: 18),
            onTimeout: () => "error",
          );
          if (result is Map<String, Object>) {
            UserCredential user = result["userC"] as UserCredential;
            userId = user.user!.uid;
            await storage.write(
                key: user.user!.email as String, value: event.password);
            await databaseHelper.insert("UserC",
                {"Email": user.user!.email, "AccountType": event.accountType});
            emit(Registed(user: user.user as User, aType: event.accountType));
          } else {
            emit(ErrorState(message: "Check your interent connection"));
          }
        }
      } catch (e) {
        emit(ErrorState(message: e.toString()));
      }
    });
  }
}
