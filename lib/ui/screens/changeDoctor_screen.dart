import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:licenta_patras/services/firebase_service.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../globals.dart';
import '../../model/Review.dart';
import '../../model/appUser.dart';
import '../../services/helper.dart';
import '../components/custom_textfield.dart';
import 'pacient_screen.dart';

class ChangeDoctorScreen extends StatefulWidget {
  const ChangeDoctorScreen({Key? key}) : super(key: key);

  @override
  _ChangeDoctorScreenState createState() => _ChangeDoctorScreenState();
}

class _ChangeDoctorScreenState extends State<ChangeDoctorScreen> {


  List<DropdownMenuItem> _doctors = [];
  List<AppUser> _allDoctors = [];
  late FirebaseService service;
  List<Review> _allReviews = [];
  List<Review> _filteredReviews = [];

  void setUp() async {
    service = Provider.of<FirebaseService>(context, listen: false);
    service.getDoctorsFromFirebase().then((value) => setState(() {
      _allDoctors = service.getDoctors();
    }));
    service.getAllReviewsFromFirebase().then((value) {
        _allReviews = service.getAllReviews();
    });
    setState(() {
      _filteredReviews = _allReviews;
    });
  }

  @override
  void initState() {
    setUp();
  }

  _openReviewsDialog(index) async {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String? idDcotor = _allDoctors[index].id;
    setState(() {
      _filteredReviews = _allReviews.where((e) => e.idDoctor == idDcotor).toList();
    });
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
          child: AlertDialog(
            title: const Center(
                child: Text(
                  "Recenzii",
                  style: TextStyle(color: textColor, fontSize: 36),
                )),
            content: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 40),
                  height: (height - height / 2.4),
                  child: ListView.separated(
                      separatorBuilder: (context, index) => const Divider(
                        color: textColorTransparent,
                        thickness: 1,
                      ),
                      shrinkWrap: true,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: _filteredReviews.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          key: Key(_filteredReviews[index].toString()),
                          onTap: () async {},
                          title: Text(_filteredReviews[index].reviewerName!,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300,
                                  color: textColor)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                      "Evaluare: ${_filteredReviews[index].stars.toString()}",
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w300,
                                          color: textColor)),
                                  StarRating(
                                    rating: _filteredReviews[index].stars,
                                    rowAlignment: MainAxisAlignment.center,
                                    color: textColor,
                                  ),
                                ],
                              ),
                              Text("Comentariu: ${_filteredReviews[index].content}",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                      color: textColor)),
                            ],
                          ),
                        );
                      }),
                ),
              ],
            ),
            backgroundColor: primaryColorC,
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                    primary: textColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    )),
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Inapoi"),
              ),
              TextButton(
                style: TextButton.styleFrom(
                    primary: textColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    )),
                onPressed: () async {
                  try {
                    loggedUser?.idDoctor = _allDoctors[index].id;
                    AppUser appUser = AppUser.fromMapPatient({
                      'id': loggedUser?.id,
                      'fullName': loggedUser?.fullName,
                      'telefon': loggedUser?.telefon,
                      'idDoctor': loggedUser?.idDoctor,
                      'role': loggedUser?.role,
                      'email': loggedUser?.email,
                      'varsta': loggedUser?.varsta,
                      'afectiuni': loggedUser?.afectiuni,
                      'medicatie': loggedUser?.medicatie,
                      'profilePic': loggedUser?.profilePic,
                      'contraindicatii': loggedUser?.contraindicatii
                    });
                    await FirebaseFirestore.instance
                        .doc('users/${loggedUser?.id}')
                        .set(appUser.toMapPatient());
                    Navigator.of(context)
                        .pushAndRemoveUntil(MaterialPageRoute(
                      builder: (context) => PacientScreen(),
                    ), (Route<dynamic> route) => false);
                  }
                  on Exception catch (_, e) {
                    Fluttertoast.showToast(
                        msg: "A aparut o eroare la schimbarea medicului.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor:
                        Colors.red.withOpacity(0.3),
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }

                },
                child: const Text("Alege doctor"),
              ),
            ],
          ),
        );
      },
    );
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
                    'Schimbare medic',
                    style: TextStyle(fontSize: 24, color: textColor),
                  ),
                  ListView.separated(
                      separatorBuilder: (context, index) => const Divider(
                        color: textColorTransparent,
                        thickness: 1,
                      ),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _allDoctors.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                              key: Key(_allDoctors[index].toString()),
                              onTap: () async {
                                _openReviewsDialog(index);
                              },
                              //leading: const Icon((_allUsers[index].role == 2) ? Icons.medical_services : Icons.person, color: textColor, size: 35),
                              title: Text(_allDoctors[index].fullName!,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w300,
                                      color: textColor)),
                              subtitle: Text(
                                  "${_allDoctors[index].email}\n${_allDoctors[index].telefon!}",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                      color: textColor)),
                            );
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}