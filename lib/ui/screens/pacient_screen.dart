import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:licenta_patras/globals.dart';
import 'package:licenta_patras/model/appUser.dart';
import 'package:licenta_patras/ui/auth/login/login.dart';
import 'package:licenta_patras/ui/screens/changeDoctor_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants.dart';
import '../../model/Review.dart';
import '../../services/firebase_service.dart';
import '../../services/helper.dart';
import '../auth/signup/google_splash_screen.dart';
import '../components/confirmation_dialog.dart';
import 'chat_page.dart';

class PacientScreen extends StatefulWidget {
  late BuildContext context;

  @override
  _PacientScreenState createState() => _PacientScreenState();
}

late DocumentSnapshot snapshot;

class _PacientScreenState extends State<PacientScreen> {
  late FirebaseService service;
  late AppUser myDoctor = AppUser();
  num doctorRating = 0;
  List<Review> _allReviews = [];
  late Review myReview = Review();
  int _selectedIndex = 0;
  PageController pageController = PageController();

  PlatformFile? pickedFile;
  UploadTask? uploadTask;

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
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
              (Route<dynamic> route) => false);
        }
    }
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    pickedFile = result.files.first;
    final path = 'profilePictures/${pickedFile!.name}';
    final file = File(pickedFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(file);

    final snapshot = await uploadTask!.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    setState(() {
      loggedUser?.profilePic = downloadUrl;
    });
    try {
      service.updatePatient(loggedUser!, loggedUser?.medicatie,
          loggedUser?.afectiuni, loggedUser?.contraindicatii);
    } on Exception catch (e) {
      Fluttertoast.showToast(
          msg: "Actualizarea nu a avut succes.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red.withOpacity(0.3),
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  double getMedieRating() {
    if (_allReviews.isEmpty) {
      return 0;
    }
    double suma = 0;
    _allReviews.forEach((element) {
      suma += double.parse(element.stars.toString());
    });
    double medie = suma / _allReviews.length;
    return medie;
  }

  getProfile() async {
    service = Provider.of<FirebaseService>(context, listen: false);
    service.getDoctorById(loggedUser?.idDoctor).then((value) => setState(() {
          myDoctor = value;
          if (myDoctor.id == null) {
            Fluttertoast.showToast(
                msg:
                    "Medicul dumneavoastra nu a fost gasit, va rugam sa recompletati datele personale",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 2,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const GoogleDetailsScreen(),
                ),
                (Route<dynamic> route) => false);
          }
        }));
    service.getReviewsFromFirebase(loggedUser?.idDoctor).then((value) {
      _allReviews = service.getDoctorReviews();
      var myListFiltered =
          _allReviews.where((e) => e.idReviewer == loggedUser?.id);
      if (myListFiltered.length > 0) {
        myReview = myListFiltered.first;
      } else {
        // Element is not found
      }
      setState(() {
        doctorRating = getMedieRating();
      });
    });
  }

  @override
  void initState() {
    getProfile();
  }

  Widget doctorProfile() {
    double height = MediaQuery.of(context).size.height;
    double doctorCardMargin = height / 8;
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(top: doctorCardMargin),
        child: ListView.builder(
            itemCount: 1,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return doctorCard(
                fullName: myDoctor.fullName,
                specialty: 'Medic de familie',
                imagePath: myDoctor.profilePic,
                rating: doctorRating,
                varstaPacient: loggedUser?.varsta.toString(),
                afectiuniPacient: loggedUser?.afectiuni,
                medicatiePacient: loggedUser?.medicatie,
                contraPacient: loggedUser?.contraindicatii,
                biography: descriereDoctor,
              );
            }),
      ),
    );
  }

  Widget doctorCard({
    String? fullName,
    String? specialty,
    String? imagePath,
    num? rating,
    String? varstaPacient,
    String? afectiuniPacient,
    String? medicatiePacient,
    String? contraPacient,
    String? biography,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 1.0,
      color: primaryColorC,
      alignment: Alignment.center, // where to position the child
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(
              top: 15.0,
            ),
            decoration: new BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              color: Color(0xFFFFFFFF),
              boxShadow: [
                new BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20.0,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  //transform: Matrix4.translationValues(0.0, -16.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          MaterialButton(
                            color: Theme.of(context).primaryColor,
                            highlightColor: Theme.of(context).primaryColorLight,
                            textColor: Colors.white,
                            onPressed: () async {
                              String telephoneUrl = "tel:${myDoctor.telefon}";
                              if (await canLaunch(telephoneUrl)) {
                                await launch(telephoneUrl);
                              } else {
                                Fluttertoast.showToast(
                                    msg:
                                        "A aparut o eroare. Va rugam incercati mai tarziu",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              }
                            },
                            child: Icon(
                              Icons.phone,
                              size: 30,
                            ),
                            padding: EdgeInsets.all(16),
                            shape: CircleBorder(),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                              top: 10.0,
                            ),
                            child: Text(
                              'Apeleaza',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF6f6f6f),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(100),
                              ),
                              boxShadow: [
                                new BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 15.0,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                            transform:
                                Matrix4.translationValues(0.0, -15.0, 0.0),
                            child: CircleAvatar(
                              radius: 70,
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: imagePath ??
                                      'https://firebasestorage.googleapis.com/v0/b/licenta-7da46.appspot.com/o/istockphoto-1300845620-612x612.jpg?alt=media&token=02de0154-1ca6-41a7-88d6-c0f80e8451fe',
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Image.asset('assets/images/user.jpg'),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          MaterialButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    peerId: loggedUser!.idDoctor!,
                                    peerAvatar: myDoctor.profilePic!,
                                    peerNickname: myDoctor.fullName!,
                                    peerTelephone: myDoctor.telefon!,
                                    userAvatar: loggedUser!.profilePic!,
                                  ),
                                ),
                              );
                            },
                            color: Theme.of(context).primaryColor,
                            highlightColor: Theme.of(context).primaryColorLight,
                            textColor: Colors.white,
                            child: Icon(
                              Icons.mail_outline,
                              size: 30,
                            ),
                            padding: EdgeInsets.all(16),
                            shape: CircleBorder(),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                              top: 10.0,
                            ),
                            child: Text(
                              'Mesaj',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF6f6f6f),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 15.0,
                    bottom: 5.0,
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          '${fullName?.capitalize()}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Color(0xFF6f6f6f),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          specialty ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: primaryColorC,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () {
                        _leaveReviewDialog();
                      },
                      child: (rating == null)
                          ? Container()
                          : StarRating(
                              rating: rating,
                              rowAlignment: MainAxisAlignment.center,
                            ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: const EdgeInsets.only(top: 15),
                    child: InkWell(
                      onTap: () {
                        if (_allReviews.isEmpty) {
                          Fluttertoast.showToast(
                              msg: "Nu exista recenzii",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } else {
                          _openReviewsDialog();
                        }
                      },
                      child: Text(
                        '${_allReviews.length} recenzii',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF6f6f6f),
                        ),
                      ),
                    ),
                  ),
                ),
                biography != null
                    ? sectionTitle(context, "Biografie")
                    : Container(),
                biography != null
                    ? Container(
                        margin: const EdgeInsets.only(
                          left: 20.0,
                          right: 20.0,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            biography,
                            style: TextStyle(
                              color: Color(0xFF9f9f9f),
                            ),
                          ),
                        ),
                      )
                    : Container(),
                const SizedBox(
                  height: 20,
                ),
                sectionTitle(context, "Detalii contact"),
                Container(
                  margin: const EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'E-mail',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Color(0xFF6f6f6f),
                                ),
                              ),
                              Text(
                                myDoctor.email ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF9f9f9f),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Telefon',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFF6f6f6f),
                              ),
                            ),
                            Text(
                              myDoctor.telefon ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF9f9f9f),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget patientCard({
    String? fullName,
    String? imagePath,
    String? varstaPacient,
    String? afectiuniPacient,
    String? medicatiePacient,
    String? contraPacient,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 1.0,
      color: primaryColorC,
      alignment: Alignment.center, // where to position the child
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(
              top: 15.0,
            ),
            decoration: new BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              color: Color(0xFFFFFFFF),
              boxShadow: [
                new BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20.0,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  //transform: Matrix4.translationValues(0.0, -16.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(100),
                              ),
                              boxShadow: [
                                new BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 15.0,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                            transform:
                                Matrix4.translationValues(0.0, -15.0, 0.0),
                            child: InkWell(
                              onTap: () async {
                                var result = await confirmationDialog(
                                    "Schimbare poza profil",
                                    "Doriti sa schimbati poza de profil?",
                                    context);
                                if (result != null && result == true) {
                                  await selectFile();
                                }
                              },
                              child: CircleAvatar(
                                radius: 70,
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: imagePath ??
                                        'https://firebasestorage.googleapis.com/v0/b/licenta-7da46.appspot.com/o/istockphoto-1300845620-612x612.jpg?alt=media&token=02de0154-1ca6-41a7-88d6-c0f80e8451fe',
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        Image.asset('assets/images/user.jpg'),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 15.0,
                    bottom: 5.0,
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          '${fullName?.capitalize()}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Color(0xFF6f6f6f),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                sectionTitle(context, "Datele mele"),
                Container(
                  margin: const EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        (varstaPacient != null)
                            ? Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nume',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Color(0xFF6f6f6f),
                                      ),
                                    ),
                                    Text(
                                      loggedUser?.fullName ?? '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF9f9f9f),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Telefon',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFF6f6f6f),
                              ),
                            ),
                            Text(
                              loggedUser?.telefon ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF9f9f9f),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'E-mail',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFF6f6f6f),
                              ),
                            ),
                            Text(
                              loggedUser?.email ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF9f9f9f),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Numele doctorului dvs',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFF6f6f6f),
                              ),
                            ),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    myDoctor.fullName ?? '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF9f9f9f),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) =>  const ChangeDoctorScreen(),
                                      ));
                                    },
                                    child: Text(
                                      'Schimba medicul',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 16),
                                    ),
                                  ),
                                ]),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                sectionTitle(context, "Istoricul meu medical"),
                Container(
                  margin: const EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        (varstaPacient != null)
                            ? Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Varsta mea',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Color(0xFF6f6f6f),
                                      ),
                                    ),
                                    Text(
                                      varstaPacient,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF9f9f9f),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Afectiunile cunoscute',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFF6f6f6f),
                              ),
                            ),
                            Text(
                              (afectiuniPacient! == "necompletat")
                                  ? ""
                                  : afectiuniPacient,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF9f9f9f),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Medicatia curenta',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFF6f6f6f),
                              ),
                            ),
                            Text(
                              (medicatiePacient! == "necompletat")
                                  ? ""
                                  : medicatiePacient,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF9f9f9f),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Contraindicatii',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFF6f6f6f),
                              ),
                            ),
                            Text(
                              (contraPacient! == "necompletat")
                                  ? ""
                                  : contraPacient,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF9f9f9f),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: Scaffold(
        //appBar: StandardAppBar(),
        body: Container(
          width: MediaQuery.of(context).size.width * 1.0,
          color: primaryColorC,
          alignment: Alignment.center, // where to position the child
          child: PageView(
            controller: pageController,
            children: [doctorProfile(), myProfile()],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          backgroundColor: primaryColorC,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.local_hospital,
                  color: textColor,
                ),
                label: 'Doctorul meu'),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                color: textColor,
              ),
              label: 'Profilul meu',
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    pageController.jumpToPage(index);
  }

  Widget myProfile() {
    double height = MediaQuery.of(context).size.height;
    double doctorCardMargin = height / 8;
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(top: doctorCardMargin),
        child: ListView.builder(
            itemCount: 1,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return patientCard(
                fullName: loggedUser?.fullName,
                imagePath: loggedUser?.profilePic,
                varstaPacient: loggedUser?.varsta.toString(),
                afectiuniPacient: loggedUser?.afectiuni,
                medicatiePacient: loggedUser?.medicatie,
                contraPacient: loggedUser?.contraindicatii,
              );
            }),
      ),
    );
  }

  _openReviewsDialog() async {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
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
                  width: width - 25,
                  height: (height - height / 2.4),
                  child: ListView.separated(
                      separatorBuilder: (context, index) => const Divider(
                            color: textColorTransparent,
                            thickness: 1,
                          ),
                      shrinkWrap: true,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: _allReviews.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          key: Key(_allReviews[index].toString()),
                          onTap: () async {},
                          title: Text(_allReviews[index].reviewerName!,
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
                                      "Evaluare: ${_allReviews[index].stars.toString()}",
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w300,
                                          color: textColor)),
                                  StarRating(
                                    rating: _allReviews[index].stars,
                                    rowAlignment: MainAxisAlignment.center,
                                    color: textColor,
                                  ),
                                ],
                              ),
                              Text("Comentariu: ${_allReviews[index].content}",
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
            ],
          ),
        );
      },
    );
  }

  _leaveReviewDialog() async {
    TextEditingController controllerStars = TextEditingController();
    TextEditingController controllerReview = TextEditingController();
    bool edit = false;
    if (myReview.stars != null) {
      controllerReview.text = myReview.content!;
      controllerStars.text = myReview.stars.toString();
      edit = true;
    }
    AutovalidateMode autovalideMode = AutovalidateMode.disabled;
    final GlobalKey<FormState> reviewFormKey = GlobalKey();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
          child: AlertDialog(
            title: (edit)
                ? Text(
                    "Lasa o recenzie",
                    style: TextStyle(color: textColor),
                  )
                : Text(
                    "Editeaza recenzia",
                    style: TextStyle(color: textColor),
                  ),
            content: Container(
              child: Form(
                key: reviewFormKey,
                autovalidateMode: autovalideMode,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 50, right: 5, top: 10, bottom: 5),
                        child: Text(
                          'Introduceti un numar intre 1 si 5',
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
                      child: TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        textInputAction: TextInputAction.next,
                        controller: controllerStars,
                        validator: (String? value) {
                          int? nota = int.tryParse(value!);
                          if (nota == null || nota < 1 || nota > 5) {
                            return 'Introduceti un numar intreg de la 1 la 5';
                          }
                        },
                        onChanged: (String? val) {
                          controllerStars.text = val!;
                        },
                        style: const TextStyle(color: textColor),
                        decoration: const InputDecoration(
                          icon: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Icon(
                              Icons.star,
                              color: textColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: textColor),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 50, right: 5, top: 10, bottom: 5),
                        child: Text(
                          'Recenzie',
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
                            controller: controllerReview,
                            maxLines: null,
                            onChanged: (String? val) {},
                            style: const TextStyle(color: textColor),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(
                                  left: 20, right: 20, bottom: 15),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: textColor),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                onPressed: () {
                  reviewFormKey.currentState?.reset();
                  Navigator.pop(context);
                },
                child: const Text("Inapoi"),
              ),
              TextButton(
                  style: TextButton.styleFrom(
                    primary: textColor,
                  ),
                  onPressed: () async {
                    if (reviewFormKey.currentState!.validate()) {
                      reviewFormKey.currentState?.save();
                      Review myRevieww = Review.fromMap({
                        'stars': int.parse(controllerStars.text),
                        'idDoctor': '${loggedUser?.idDoctor}',
                        'content': controllerReview.text,
                        'reviewerName': loggedUser?.fullName,
                        'idReviewer': loggedUser?.id
                      });
                      try {
                        await FirebaseFirestore.instance
                            .doc('reviews/${loggedUser?.id}')
                            .set(myRevieww.toMap());

                        if (edit) {
                          myReview = myReview;
                          var index = _allReviews.indexWhere((element) =>
                              myReview.idReviewer == element.idReviewer);
                          _allReviews[index] = myReview;
                          controllerStars.text = myReview.stars.toString();
                          controllerReview.text = myReview.content!;
                          setState(() {
                            doctorRating = getMedieRating();
                          });
                          Fluttertoast.showToast(
                              msg: "Editarea a avut succes!",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } else {
                          setState(() {
                            _allReviews.add(myReview);
                            doctorRating = getMedieRating();
                          });
                          Fluttertoast.showToast(
                              msg: "Trimiterea avut succes!",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                        reviewFormKey.currentState?.reset();
                        Navigator.pop(context);
                      } on Exception catch (e) {
                        _allReviews.add(myReview);
                        setState(() {
                          doctorRating = getMedieRating();
                        });
                        Fluttertoast.showToast(
                            msg: "Trimiterea recenziei nu a avut succes",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red.withOpacity(0.7),
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }
                    } else {
                      setState(() {
                        autovalideMode = AutovalidateMode.always;
                      });
                    }
                    reviewFormKey.currentState!.reset();
                  },
                  child: const Text("Finalizare")),
            ],
          ),
        );
      },
    );
  }

}
