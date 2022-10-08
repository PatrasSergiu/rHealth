import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:licenta_patras/globals.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../model/appUser.dart';
import '../../../services/firebase_service.dart';
import '../../components/custom_button.dart';
import '../../components/custom_textfield.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  List<AppUser> _allDoctors = [];
  late FirebaseService service;
  var _selectedDoctor;
  List<DropdownMenuItem> _doctors = [];
  TextEditingController _controllerAge = TextEditingController();

  getAll() async {
    service = Provider.of<FirebaseService>(context, listen: false);
    service.getDoctorsFromFirebase().then((value) => setState(() {
      _allDoctors = service.getDoctors();
      _allDoctors.forEach((element) {
        setState((){
          _doctors.add(DropdownMenuItem<dynamic>(child: Text(element.fullName!), value: element.id!));
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
    return Container(
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
                  bottom: 10.0,
                ),
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(
                      height: 80,
                    ),
                    Text(
                      'Inregistrare',
                      style: TextStyle(fontSize: 30, color: textColor),
                    ),
                    SizedBox(
                      height: 10,
                    ),
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
                        padding: EdgeInsets.only(left: 50, right: 5, top: 15),
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
                            'Introduceti email',
                            false,
                            Icons.mail,
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
                    SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 50, right: 5, top: 15),
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
                      child: Column(
                        children: [
                          CustomTextInput(
                            4,
                            'Introduceti parola',
                            true,
                            Icons.vpn_key,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 18),
                      child: CustomButton(2, 'Inregistrare'),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Ai deja un cont?  ',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 13,
                              color: textColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(
                                context,
                              );
                            },
                            child: Text(
                              'Autentificare',
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
      ),
    );
  }
}
