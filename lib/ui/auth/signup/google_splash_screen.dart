import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../globals.dart';
import '../../../model/appUser.dart';
import '../../../services/firebase_service.dart';
import '../../components/custom_textfield.dart';
import '../../screens/pacient_screen.dart';





class GoogleDetailsScreen extends StatefulWidget {
  const GoogleDetailsScreen({Key? key}) : super(key: key);

  @override
  _GoogleDetailsScreenState createState() => _GoogleDetailsScreenState();
}

class _GoogleDetailsScreenState extends State<GoogleDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AutovalidateMode _validate = AutovalidateMode.disabled;
  late FirebaseService service;
  String? patientName, patientTelefon;
  var _selectedDoctor;
  TextEditingController _controllerAge = TextEditingController();

  List<AppUser> _allDoctors = [];
  List<DropdownMenuItem> _doctors = [];

  getAll() async {
    service = Provider.of<FirebaseService>(context, listen: false);
    service.getDoctorsFromFirebase().then((value) => setState(() {
      _allDoctors = service.getDoctors();
      _allDoctors.forEach((element) {
        setState((){
          _doctors.add(DropdownMenuItem<String>(child: Text(element.fullName!), value: element.id!));
        });
      });
      print(_allDoctors);
    }));
  }

  @override
  void initState() {
    getAll();
  }


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
                    'Bine ai venit!',
                    style: TextStyle(fontSize: 34, color: textColor),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Text(
                    'Completeaza urmatoarele campuri pentru a finaliza inregistrarea',
                    style: TextStyle(fontSize: 12, color: textColor),
                  ),
                  Form(
                    key: _formKey,
                    autovalidateMode: _validate,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 50, right: 5, top: 35),
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
                        Padding(
                          padding: EdgeInsets.only(left: 5, right: 5, top: 5),
                          child: Column(
                            children: [
                              CustomTextInput(
                                1,
                                'Introduceti numele complet',
                                false,
                                Icons.person,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 50, right: 5, top: 15),
                            child: Text(
                              'Varsta',
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
                            controller: _controllerAge,
                            validator: (String? value) {
                              int? age = int.tryParse(value!);
                              if(age == null || age <= 14 || age >= 110){
                                return 'Trebuie sa fie intre 14 si 110';
                              }
                            },
                            onChanged: (String? value) {
                              inputVarsta = _controllerAge.text;
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
                              focusedBorder:OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.white, width: 2.0),
                              ),
                              contentPadding:
                              EdgeInsets.only(left: 5, right: 10, bottom: 15),
                              border: InputBorder.none,
                              hintText: "Varsta dvs",
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
                            padding: EdgeInsets.only(left: 50, right: 5, top: 15),
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
                        Padding(
                          padding: EdgeInsets.only(left: 5, right: 5, top: 5),
                          child: CustomTextInput(
                            2,
                            'Numarul de telefon',
                            false,
                            Icons.phone,
                          ),
                        ),

                        SizedBox(
                          height: 10,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 50, right: 5, top: 15),
                            child: Text(
                              'Doctorul dumneavoastra',
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
                          child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              padding: EdgeInsets.only(left: 20),
                              alignedDropdown: true,
                              child: DropdownButtonFormField(
                                dropdownColor: textFieldBGColor,
                                value: _selectedDoctor,
                                items: _doctors,
                                validator: (value) => value == null ? 'Va rugam alegeti un medic' : null,
                                onChanged: (value) {
                                  setState((){ doctorId = value as String?;});
                                  print(doctorId);
                                },
                                style: TextStyle(color: textColor),
                                decoration: InputDecoration(
                                  icon: Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Icon(
                                      Icons.medical_services,
                                      color: textColor,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.only(
                                      left: 0, right: 20, bottom: 15),
                                  border: InputBorder.none,
                                  focusedBorder:OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.white, width: 2.0),
                                  ),
                                  hintText: "Alegeti doctor",
                                  hintStyle: TextStyle(color: textColor),
                                ),
                              ),
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
                              "Finalizeaza inscrierea",
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
                                final AppUser appUser = AppUser.fromMapPatient({
                                  'id': loggedUser?.id,
                                  'fullName': inputFullName,
                                  'telefon': inputPhoneNo,
                                  'email': loggedUser?.email,
                                  'idDoctor': doctorId,
                                  'role': 1,
                                  'varsta': int.parse(inputVarsta!),
                                  'medicatie': "necompletat",
                                  'afectiuni': "necompletat",
                                  'contraindicatii': "necompletat",
                                });
                                await FirebaseFirestore.instance
                                    .doc('users/${loggedUser?.id}')
                                    .set(appUser
                                    .toMapPatient());
                                loggedUser?.telefon = patientTelefon;
                                loggedUser?.fullName = patientName;
                                Navigator.of(context)
                                    .pushAndRemoveUntil(MaterialPageRoute(
                                  builder: (context) => PacientScreen(),
                                ), (Route<dynamic> route) => false);
                                // Navigator.of(context).push(
                                //   MaterialPageRoute(
                                //     builder: (context) => const PatientScreen(),
                                //   ),
                                // );
                                //creat succes
                                Fluttertoast.showToast(
                                    msg:
                                    "Contul dumneavoastra a fost inregistrat cu succes!!",
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
    );
  }
}
