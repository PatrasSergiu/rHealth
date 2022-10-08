import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../constants.dart';
import "../../globals.dart" as globals;
import '../../globals.dart';
import '../../model/appUser.dart';
import '../screens/admin.dart';
import '../screens/doctor.dart';
import '../screens/pacient_screen.dart';

class CustomButton extends StatelessWidget {
  final int _iD;
  final String _btnText;

  // final String _inputUsername;
  // final String _inputPassword;
  const CustomButton(this._iD, this._btnText, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 45),
      width: double.infinity,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        color: Colors.white,
        child: Text(
          _btnText,
          style: TextStyle(fontSize: 16, color: accentColorC),
        ),
        onPressed: () async {
          if (_iD == 1) {
            try{
              final UserCredential? result = await FirebaseAuth.instance
                  .signInWithEmailAndPassword(
                  email: globals.inputEmail.toString(),
                  password: globals.inputPassword.toString());
              CollectionReference users = FirebaseFirestore.instance.collection('users');
              var document = await FirebaseFirestore.instance.collection('users').doc(result?.user?.uid).get();
              if (document.exists) {
                Map<String, dynamic>? data = document.data();
                final AppUser appUser = AppUser.fromMap({
                  'id': data?['id'],
                  'fullName': data?['fullName'],
                  'telefon': data?['telefon'],
                  'email': data?['email'],
                  'idDoctor': data?['idDoctor'],
                  'profilePic': data?['profilePic'],
                  'role': data?['role']
                });
                globals.loggedUser = appUser;
              }
              else {
                throw Exception("Cannot find user");
              }
              if(loggedUser?.role == 1) {
                Map<String, dynamic>? data = document.data();
                final AppUser appUser = AppUser.fromMapPatient({
                  'id': data?['id'],
                  'fullName': data?['fullName'],
                  'telefon': data?['telefon'],
                  'email': data?['email'],
                  'idDoctor': data?['idDoctor'],
                  'medicatie': data?['medicatie'],
                  'varsta': data?['varsta'],
                  'afectiuni': data?['afectiuni'],
                  'contraindicatii': data?['contraindicatii'],
                  'role': data?['role'],
                  'profilePic': data?['profilePic']
                });
                globals.loggedUser = appUser;

                Navigator.of(context)
                    .pushAndRemoveUntil(MaterialPageRoute(
                  builder: (context) => PacientScreen(),
                ), (Route<dynamic> route) => false);
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => const PatientScreen()));
              }
              else if(loggedUser?.role == 2) {
                Map<String, dynamic>? data = document.data();
                final AppUser appUser = AppUser.fromMapDoctor({
                  'id': data?['id'],
                  'fullName': data?['fullName'],
                  'telefon': data?['telefon'],
                  'email': data?['email'],
                  'role': data?['role'],
                  'profilePic': data?['profilePic']
                });
                globals.loggedUser = appUser;
                globals.descriereDoctor = data?['descriere'];

                Navigator.of(context)
                    .pushAndRemoveUntil(MaterialPageRoute(
                  builder: (context) =>  DoctorScreen(),
                ), (Route<dynamic> route) => false);
              }
              else {
                Navigator.of(context)
                    .pushAndRemoveUntil(MaterialPageRoute(
                  builder: (context) =>  AdminScreen(),
                ), (Route<dynamic> route) => false);
              }
            }
            on Exception catch(ex) {
              Fluttertoast.showToast(
                  msg: "Email sau parola incorecta",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red.withOpacity(0.3),
                  textColor: Colors.white,
                  fontSize: 16.0);
            }
          } else {
            print("here");
            try {
              final UserCredential? result = await FirebaseAuth.instance
                  .createUserWithEmailAndPassword(
                      email: globals.inputEmail.toString(),
                      password: globals.inputPassword.toString());

              final AppUser appUser = AppUser.fromMapPatient({
                'id': result?.user?.uid,
                'fullName': globals.inputFullName,
                'telefon': globals.inputPhoneNo,
                'email': result?.user?.email,
                'idDoctor': globals.doctorId,
                'medicatie': "necompletat",
                'varsta': int.parse(globals.inputVarsta!),
                'afectiuni': "necompletat",
                'contraindicatii': "necompletat",
                'profilePic': 'https://firebasestorage.googleapis.com/v0/b/licenta-7da46.appspot.com/o/istockphoto-1300845620-612x612.jpg?alt=media&token=02de0154-1ca6-41a7-88d6-c0f80e8451fe',
                'role': 1
              });
              await FirebaseFirestore.instance
                    .doc('users/${result?.user!.uid}')
                    .set(appUser.toMapPatient());
              loggedUser = appUser;
              Fluttertoast.showToast(
                  msg: "S-a creat contul cu succes!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0);
              Navigator.of(context)
                  .pushAndRemoveUntil(MaterialPageRoute(
                builder: (context) =>  PacientScreen(),
              ), (Route<dynamic> route) => false);
            } on Exception catch (ex) {
              Fluttertoast.showToast(
                  msg: "A aparut o problema in timpul inregistrarii",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red.withOpacity(0.3),
                  textColor: Colors.white,
                  fontSize: 16.0);
            }
          }
        },
      ),
    );
  }
}
