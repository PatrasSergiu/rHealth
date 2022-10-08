import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:licenta_patras/globals.dart';
import 'package:licenta_patras/ui/screens/editUserPage.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../model/appUser.dart';
import '../../services/firebase_service.dart';
import '../../services/helper.dart';
import '../auth/login/login.dart';
import '../components/confirmation_dialog.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AutovalidateMode _validate = AutovalidateMode.disabled;
  late FirebaseService service;
  bool _obSecure = true;
  bool _deleteMode = false;
  String? doctorEmail,
      doctorName,
      doctorPassword,
      doctorTelefon,
      doctorDescriere;
  List<AppUser> _allUsers = [];

  Future<bool> onBackPress() {
    openLogoutDialog();
    return Future.value(false);
  }

  Future<void> openLogoutDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return SimpleDialog(
            backgroundColor: textFieldBGColor,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Deconectare',
                  style: TextStyle(color: textColor),
                ),
                Icon(
                  Icons.exit_to_app,
                  size: 30,
                  color: Colors.white,
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Vrei sa te deconectezi?',
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor, fontSize: 16),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 0);
                    },
                    child: const Text(
                      'Nu',
                      style: TextStyle(color: textColor),
                    ),
                  ),
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 1);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryColorC,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                      child: const Text(
                        'Da',
                        style: TextStyle(color: textColor),
                      ),
                    ),
                  )
                ],
              )
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        {
          loggedUser = AppUser();
          Navigator.of(context)
              .pushAndRemoveUntil(MaterialPageRoute(
            builder: (context) =>  const LoginPage(),
          ), (Route<dynamic> route) => false);
        }
    }
  }

  getAll() async {
    service = Provider.of<FirebaseService>(context, listen: false);
    service.getUsersFromFirebase().then((value) => setState(() {
          _allUsers = service.getUsers();
          print(_allUsers[0].contraindicatii);
          print(_allUsers[1].contraindicatii);
        }));
  }

  @override
  void initState() {
    super.initState();
    getAll();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: onBackPress,
      child: Scaffold(
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
                //physics: AlwaysScrollableScrollPhysics(),
                child: (_deleteMode)
                    ?  Column(
                          children: [
                            SizedBox(
                              height: 80,
                            ),
                            Text(
                              'Buna ziua ${loggedUser?.fullName}',
                              style: TextStyle(fontSize: 30, color: textColor),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: width / 16, right: width / 16),
                                    child: Text(
                                      'Mod stergere utilizator: ',
                                      style:
                                          TextStyle(fontSize: 20, color: textColor),
                                    ),
                                  ),
                                ),
                                Checkbox(
                                  value: _deleteMode,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _deleteMode = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: width / 16, right: width / 16, top: 5),
                                child: Text(
                                  'Alegeti un utilizator pentru stergere sau editare: ',
                                  style: TextStyle(fontSize: 20, color: textColor),
                                ),
                              ),
                            ),
                            ListView.separated(
                                separatorBuilder: (context, index) => const Divider(
                                      color: textColorTransparent,
                                      thickness: 1,
                                    ),
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _allUsers.length,
                                itemBuilder: (context, index) {
                                  return Dismissible(
                                      confirmDismiss:
                                          (DismissDirection direction) async {
                                        var result = await confirmationDialog(
                                            "Confirmare stergere",
                                            "Sunteti siguri ca doriti sa stergeti acest utilizator?",
                                            context);
                                        if (result != null && result == true) {
                                          try {
                                            await service
                                                .deleteUser(_allUsers[index].id);
                                            setState(() {
                                              _allUsers.removeWhere((element) =>
                                                  element.id ==
                                                  _allUsers[index].id);
                                            });
                                          } on Exception catch (_, e) {
                                            Fluttertoast.showToast(
                                                msg: e.toString(),
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor:
                                                    Colors.red.withOpacity(0.3),
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                          }
                                        }
                                      },
                                      key: Key(_allUsers[index].toString()),
                                      secondaryBackground: Container(
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.only(right: 20.0),
                                        color: listSlideColor,
                                        child: Row(
                                          children: const [
                                            Icon(Icons.delete, color: textColor),
                                            Text(
                                              "Stergere",
                                              style: TextStyle(color: textColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                      background: Container(
                                        padding: const EdgeInsets.only(left: 20),
                                        alignment: Alignment.centerRight,
                                        child: Row(
                                          children: const [
                                            Icon(Icons.delete, color: textColor),
                                            Text(
                                              "Stergere",
                                              style: TextStyle(color: textColor),
                                            ),
                                          ],
                                        ),
                                        color: listSlideColor,
                                      ),
                                      child: ListTile(
                                        onTap: () async {
                                          final result = await Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) =>  EditScreen(ticket: _allUsers[index]),
                                          ));
                                          if(result != null) {
                                            setState(() {
                                              var index = _allUsers.indexWhere((element) => result.id == element.id);
                                              _allUsers[index] = result;
                                            });
                                          }
                                        },
                                        //leading: const Icon((_allUsers[index].role == 2) ? Icons.medical_services : Icons.person, color: textColor, size: 35),
                                        title: Text(_allUsers[index].fullName!,
                                            style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w300,
                                                color: textColor)),
                                        subtitle: Text(
                                            "${_allUsers[index].email}\n${_allUsers[index].telefon!}\n${(_allUsers[index].role == 2) ? "Medic" : "Pacient"}",
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w300,
                                                color: textColor)),
                                      ));
                                }),
                          ],
                        )
                    : Column(
                        children: [
                          SizedBox(
                            height: 80,
                          ),
                          Text(
                            'Buna ziua ${loggedUser?.fullName}',
                            style: TextStyle(fontSize: 30, color: textColor),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: width / 16, right: width / 16),
                                  child: Text(
                                    'Mod stergere utilizator: ',
                                    style:
                                        TextStyle(fontSize: 20, color: textColor),
                                  ),
                                ),
                              ),
                              Checkbox(
                                value: _deleteMode,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _deleteMode = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: width / 16, right: width / 16, top: 5),
                              child: Text(
                                'Va rugam sa completati campurile pentru a adauga un medic',
                                style: TextStyle(fontSize: 20, color: textColor),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Form(
                            key: _formKey,
                            autovalidateMode: _validate,
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 50, right: 5, top: 40),
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
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 40),
                                  height: 45,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          spreadRadius: 2,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        )
                                      ],
                                      color: textFieldBGColor,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10))),
                                  child: TextFormField(
                                    textAlignVertical: TextAlignVertical.center,
                                    textInputAction: TextInputAction.next,
                                    validator: validateEmail,
                                    onChanged: (String? val) {},
                                    onSaved: (String? val) {
                                      doctorEmail = val;
                                    },
                                    style: TextStyle(color: textColor),
                                    decoration: InputDecoration(
                                      icon: Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Icon(
                                          Icons.email,
                                          color: textColor,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.only(
                                          left: 0, right: 20, bottom: 15),
                                      border: InputBorder.none,
                                      hintText: "Email doctor",
                                      hintStyle: TextStyle(color: textColor),
                                    ),
                                  ),
                                ),

                                ///camp parola
                                ///telefon
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 50, right: 5, top: 40),
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
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 40),
                                  height: 45,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          spreadRadius: 2,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        )
                                      ],
                                      color: textFieldBGColor,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10))),
                                  child: TextFormField(
                                    textAlignVertical: TextAlignVertical.center,
                                    textInputAction: TextInputAction.next,
                                    validator: validatePassword,
                                    obscureText: _obSecure,
                                    onSaved: (String? val) {
                                      doctorPassword = val;
                                    },
                                    style: TextStyle(color: textColor),
                                    decoration: InputDecoration(
                                      suffixIcon: _obSecure
                                          ? IconButton(
                                              icon: Icon(
                                                Icons.visibility_off_rounded,
                                                size: 16,
                                                color: textColor,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _obSecure = false;
                                                });
                                              })
                                          : IconButton(
                                              icon: Icon(
                                                Icons.visibility,
                                                size: 16,
                                                color: textColor,
                                              ),
                                              onPressed: () {
                                                if (true) {
                                                  setState(() {
                                                    _obSecure = true;
                                                  });
                                                }
                                              }),
                                      icon: Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Icon(
                                          Icons.vpn_lock,
                                          color: textColor,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.only(
                                          left: 0, right: 20, bottom: 15),
                                      border: InputBorder.none,
                                      hintText: "Parola doctor",
                                      hintStyle: TextStyle(color: textColor),
                                    ),
                                  ),
                                ),

                                ///camp nume

                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 50, right: 5, top: 40),
                                    child: Text(
                                      'Nume complet',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 40),
                                  height: 45,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          spreadRadius: 2,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        )
                                      ],
                                      color: textFieldBGColor,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10))),
                                  child: TextFormField(
                                    textAlignVertical: TextAlignVertical.center,
                                    textInputAction: TextInputAction.next,
                                    validator: validateName,
                                    onSaved: (String? val) {
                                      doctorName = val;
                                    },
                                    style: TextStyle(color: textColor),
                                    decoration: InputDecoration(
                                      icon: Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Icon(
                                          Icons.person,
                                          color: textColor,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.only(
                                          left: 5,
                                          right: 10,
                                          top: 10,
                                          bottom: 10),
                                      border: InputBorder.none,
                                      hintText: "Nume doctor",
                                      hintStyle: TextStyle(color: textColor),
                                    ),
                                  ),
                                ),

                                ///telefon
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 50, right: 5, top: 40),
                                    child: Text(
                                      'Telefon',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 40),
                                  height: 45,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          spreadRadius: 2,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        )
                                      ],
                                      color: textFieldBGColor,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10))),
                                  child: TextFormField(
                                    textAlignVertical: TextAlignVertical.center,
                                    textInputAction: TextInputAction.next,
                                    validator: validatePhoneNumber,
                                    onSaved: (String? val) {
                                      doctorTelefon = val;
                                    },
                                    style: TextStyle(color: textColor),
                                    decoration: InputDecoration(
                                      icon: Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Icon(
                                          Icons.phone,
                                          color: textColor,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.only(
                                          left: 0, right: 20, bottom: 15),
                                      border: InputBorder.none,
                                      hintText: "Telefon doctor",
                                      hintStyle: TextStyle(color: textColor),
                                    ),
                                  ),
                                ),

                                ///biografie
                                ///
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 50, right: 5, top: 40),
                                    child: Text(
                                      'Biografie',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 40),
                                  height: 200,
                                  constraints: BoxConstraints(
                                    maxHeight: double.infinity,
                                  ),
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          spreadRadius: 2,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        )
                                      ],
                                      color: textFieldBGColor,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10))),
                                  child: TextFormField(
                                    textAlignVertical: TextAlignVertical.center,
                                    textInputAction: TextInputAction.next,
                                    maxLines: null,
                                    minLines: 5,
                                    onSaved: (String? val) {
                                      doctorDescriere = val;
                                    },
                                    style: TextStyle(color: textColor),
                                    decoration: InputDecoration(
                                      prefixIcon: Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Icon(
                                          Icons.newspaper,
                                          color: textColor,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.only(
                                          left: 0, right: 20, bottom: 5, top: 5),
                                      border: InputBorder.none,
                                      hintText: "Biografie doctor",
                                      hintStyle: TextStyle(color: textColor),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      top: 25, bottom: 15, left: 45, right: 45),
                                  width: double.infinity,
                                  child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ),
                                    color: Colors.white,
                                    child: Text(
                                      "Adauga medic",
                                      style: TextStyle(
                                          fontSize: 16, color: accentColorC),
                                    ),
                                    onPressed: () async {
                                      try {
                                        _formKey.currentState!.validate();
                                        if (_formKey.currentState!.validate()) {
                                          print("validat");
                                          _formKey.currentState?.save();
                                        } else {
                                          Fluttertoast.showToast(
                                              msg:
                                                  "A aparut o problema in timpul inregistrarii",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor:
                                                  Colors.red.withOpacity(0.7),
                                              textColor: Colors.white,
                                              fontSize: 16.0);
                                          setState(() {
                                            _validate = AutovalidateMode.always;
                                          });
                                          return;
                                        }

                                        final UserCredential? result =
                                            await FirebaseAuth.instance
                                                .createUserWithEmailAndPassword(
                                                    email: doctorEmail!,
                                                    password: doctorPassword!);

                                        final AppUser appUser = AppUser.fromMap({
                                          'id': result?.user?.uid,
                                          'fullName': doctorName,
                                          'telefon': doctorTelefon,
                                          'email': result?.user?.email,
                                          'profilePic': 'https://firebasestorage.googleapis.com/v0/b/licenta-7da46.appspot.com/o/istockphoto-1300845620-612x612.jpg?alt=media&token=02de0154-1ca6-41a7-88d6-c0f80e8451fe',
                                          'role': 2
                                        });
                                        await FirebaseFirestore.instance
                                            .doc('users/${result?.user!.uid}')
                                            .set(appUser
                                                .toMapDoctor(doctorDescriere));
                                        //creat succes
                                        setState(() {
                                          _allUsers.add(appUser);
                                        });
                                        Fluttertoast.showToast(
                                            msg:
                                                "Medicul a fost adaugat cu succes!!",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.green,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                        setState(() {
                                          _formKey.currentState?.reset();
                                        });
                                      } on Exception catch (ex) {
                                        Fluttertoast.showToast(
                                            msg:
                                                "A aparut o problema in timpul inregistrarii",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor:
                                                Colors.red.withOpacity(0.3),
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                      }
                                    },
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
      ),
    );
  }
}
