import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:licenta_patras/services/firebase_service.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../globals.dart';
import '../../model/appUser.dart';
import '../../services/helper.dart';
import '../components/custom_textfield.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({Key? key, required this.ticket}) : super(key: key);
  final AppUser ticket;

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {

  ///combinat
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _telefon = TextEditingController();

  ///doctor
  final TextEditingController _descriere = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  bool _validated = false;
  late AppUser currentTicket;
  bool _edited = false;
  late FirebaseService service;

  void setUp() async {
    service = Provider.of<FirebaseService>(context, listen: false);

    currentTicket = widget.ticket;

    if (currentTicket.role == 2) {
      currentTicket = await service.getDoctorById(currentTicket.id);
      _descriere.text = descriereDoctor!;
    }
    else {
      currentTicket = await service.getUserById(currentTicket.id);
    }
    _fullName.text = currentTicket.fullName!;
    _telefon.text = currentTicket.telefon!;

    setState(() {});
  }

  @override
  void initState() {
    setUp();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    double height = MediaQuery
        .of(context)
        .size
        .height;
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
                    'Editare utilizator',
                    style: TextStyle(fontSize: 24, color: textColor),
                  ),
                  Form(
                    key: _formKey,
                    autovalidateMode: _autoValidate,
                    child: Column(
                      children: [
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
                            controller: _fullName,
                            validator: validateName,
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
                        SizedBox(
                          height: 10,
                        ),
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
                            controller: _telefon,
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

                        SizedBox(
                          height: 10,
                        ),
                        (currentTicket.role == 2) ? Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 50, right: 5, top: 15),
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
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 2,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                  color: textFieldBGColor,
                                  borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: height / 5 - 10,
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  reverse: true,
                                  child: TextFormField(
                                    textAlignVertical: TextAlignVertical.center,
                                    textInputAction: TextInputAction.next,
                                    controller: _descriere,
                                    maxLines: null,
                                    onChanged: (String? val) {},
                                    style: const TextStyle(color: textColor),
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.only(
                                          left: 20, right: 20, bottom: 15),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: textColor),
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ) : Container(),

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
                              "Finalizeaza editarea",
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
                                    _autoValidate = AutovalidateMode.always;
                                  });
                                  return;
                                }
                                if (currentTicket.role == 1) {
                                  final AppUser appUser = AppUser
                                      .fromMapPatient({
                                    'id': currentTicket.id,
                                    'fullName': _fullName.text,
                                    'telefon': _telefon.text,
                                    'email': currentTicket.email,
                                    'idDoctor': currentTicket.idDoctor,
                                    'role': 1,
                                    'varsta': currentTicket.varsta,
                                    'medicatie': currentTicket.medicatie,
                                    'afectiuni': currentTicket.afectiuni,
                                    'contraindicatii': currentTicket
                                        .contraindicatii,
                                    'profilePic': currentTicket.profilePic
                                  });
                                  await FirebaseFirestore.instance
                                      .doc('users/${currentTicket.id}')
                                      .set(appUser
                                      .toMapPatient());
                                  Navigator.pop(context, appUser);
                                }
                                else {
                                  final AppUser appUser = AppUser.fromMapDoctor(
                                      {
                                        'id': currentTicket.id,
                                        'fullName': _fullName.text,
                                        'telefon': _telefon.text,
                                        'email': currentTicket.email,
                                        'role': 2,
                                        'profilePic': currentTicket.profilePic
                                      });
                                  await FirebaseFirestore.instance
                                      .doc('users/${currentTicket.id}')
                                      .set(appUser
                                      .toMapDoctor(_descriere.text));
                                  Navigator.pop(context, appUser);
                                }

                                Fluttertoast.showToast(
                                    msg:
                                    "Utilizatorul a fost editat cu succes!!",
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
                                    "A aparut o problema in timpul salvarii modificarilor",
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
    );
  }
}