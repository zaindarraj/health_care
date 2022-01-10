import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_care_app/database/database_helper.dart';
import 'package:health_care_app/logic/register/bloc/register_bloc.dart';
import 'package:health_care_app/ui/first_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:health_care_app/ui/register.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print(e);
  }

  DatabaseHelper databaseHelper = DatabaseHelper();
  await databaseHelper.getDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (settings) {
        if (settings.name == "Register") {
          return MaterialPageRoute(builder: (context) => const Register());
        }
      },
      home: BlocProvider(
        create: (context) => RegisterBloc()..add(Check()),
        child: const FirstScreen(),
      ),
    );
  }
}
