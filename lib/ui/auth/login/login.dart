import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:licenta_patras/globals.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../model/UserRole.dart';
import '../../../model/appUser.dart';
import '../../components/custom_button.dart';
import '../../components/custom_textfield.dart';
import '../../screens/pacient_screen.dart';
import '../signup/google_splash_screen.dart';
import '../signup/sign_up_screen.dart';
import 'google_authentication.dart';




class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}



class _LoginPageState extends State<LoginPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: primaryColorC,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: 0.0,
              ),
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                    height: 80,
                  ),
                  Text(
                    'Autentificare',
                    style: TextStyle(fontSize: 30, color: textColor),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 50, right: 5, top: 40),
                      child: Text(
                        'Email',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 5, right: 5, top: 5),
                    child: Column(
                      children: [
                        CustomTextInput(
                          3,
                          'Introduceti adresa de email',
                          false,
                          Icons.person,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 50, right: 5, top: 18),
                      child: Text(
                        'Parola',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 5, right: 5, top: 5),
                    child: CustomTextInput(
                      4,
                      'Introduceti parola',
                      true,
                      Icons.vpn_key,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: CustomButton(1, 'Intra in cont'),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    '- SAU -',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  Text(
                    'Autentificare cu',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          minWidth: 10,
                          color: Colors.white,
                          onPressed: () async {
                            try {
                              final provider = Provider.of<
                                  GoogleSignInProvider>(context, listen: false);
                              await provider.googleLogIn();
                              loggedUser = AppUser();
                              loggedUser?.id = FirebaseAuth.instance.currentUser!.uid;
                              loggedUser?.email = FirebaseAuth.instance.currentUser!.email;
                              var document = await FirebaseFirestore.instance.collection('users').doc(loggedUser?.id).get();
                              print(document);
                              if(document.exists)     {
                                Map<String, dynamic>? data = document.data();
                                final AppUser appUser = AppUser.fromMapPatient({
                                  'id': data?['id'],
                                  'fullName': data?['fullName'],
                                  'telefon': data?['telefon'],
                                  'email': data?['email'],
                                  'idDoctor': data?['idDoctor'],
                                  'role': data?['role'],
                                  'contraindicatii': data?['contraindicatii'],
                                  'varsta': data?['varsta'],
                                  'afectiuni': data?['afectiuni'],
                                  'medicatie': data?['medicatie'],
                                  'profilePic': data?['profilePic']
                                });
                                loggedUser = appUser;
                                Fluttertoast.showToast(
                                    msg: "Conectarea a avut succes!",
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
                              }
                              else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const GoogleDetailsScreen(),
                                  ),
                                );
                              }

                            }
                            on Exception catch(e) {
                              Fluttertoast.showToast(
                                  msg: "A aparut o problema in timpul conectarii",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red.withOpacity(0.7),
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            }
                          },
                          child: Image.asset('lib/assets/icons/icon_google_48.png',
                            height: 30,
                            width: 30,
                          ),
                          shape: CircleBorder(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Nu aveti cont?  ',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 12,
                            color: textColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Inregistreaza-te',
                            style: TextStyle(
                              fontSize: 15,
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
