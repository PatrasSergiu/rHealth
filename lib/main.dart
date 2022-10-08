import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:licenta_patras/services/chat_provider.dart';
import 'package:licenta_patras/services/home_provider.dart';
import 'package:licenta_patras/services/profile_provider.dart';
import 'package:licenta_patras/ui/auth/login/google_authentication.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'services/firebase_service.dart';
import 'ui/auth/login/login.dart';

// Future main() async{
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//
//   runApp(const MyApp());
//
// }
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(
  MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => GoogleSignInProvider(),
        ),
        Provider(
          create: (_) => FirebaseService(),
        ),
        Provider<ChatProvider>(
            create: (_) =>
                ChatProvider(
                    prefs: prefs,
                    firebaseFirestore: firebaseFirestore,
                    firebaseStorage: firebaseStorage)),
        Provider<ProfileProvider>(
            create: (_) =>
                ProfileProvider(
                    prefs: prefs,
                    firebaseFirestore: firebaseFirestore,
                    firebaseStorage: firebaseStorage)),
        Provider<HomeProvider>(
            create: (_) => HomeProvider(firebaseFirestore: firebaseFirestore))
      ],
      child: MaterialApp(
        home: MyApp(),
        debugShowCheckedModeBanner: false,
      ))
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 0), () async {
      await Firebase.initializeApp();
      // service.getUsersFromFirebase().then((value) => Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => LoginPage())));
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));

    });
    return MaterialApp(
      title: 'Licenta Patras Sergiu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        accentColor: accentColorC,
        primaryColor: primaryColorC,
        textTheme: GoogleFonts.nunitoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
    );
  }
}

