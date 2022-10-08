import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../globals.dart';
import '../model/Review.dart';
import '../model/appUser.dart';

class FirebaseService {
  FirebaseFirestore? _instance;

  List<AppUser> _users = [];
  List<AppUser> _doctors = [];
  List<AppUser> _patients = [];
  List<AppUser> _patientsWithNewMessages = [];
  List<Review> _reviews = [];
  List<Review> _allReviews = [];

  List<AppUser> getPatients() {
    return _patients;
  }

  List<AppUser> getPatientsNewMessages() {
    return _patientsWithNewMessages;
  }

  List<AppUser> getMyPatients(String? doctorId) {
    return _patients.where((e) => e.idDoctor == doctorId).toList();
  }

  List<AppUser> getUsers() {
    return _users;
  }

  List<AppUser> getDoctors() {
    return _doctors;
  }

  List<Review> getDoctorReviews() {
    return _reviews;
  }

  List<Review> getAllReviews() {
    return _allReviews;
  }

  Future<AppUser> getUserById(String? id) async {
    print(id);
    var document =
    await FirebaseFirestore.instance.collection('users').doc(id).get();

    if (document.exists) {
      Map<String, dynamic>? data = document.data();
      final AppUser appUser = AppUser.fromMapPatient({
        'id': data?['id'],
        'fullName': data?['fullName'],
        'telefon': data?['telefon'],
        'email': data?['email'],
        'idDoctor': data?['idDoctor'],
        'role': data?['role'],
        'profilePic': data?['profilePic'],
        'varsta': data?['varsta'],
        'afectiuni': data?['afectiuni'],
        'contraindicatii': data?['contraindicatii'],
        'medicatie': data?['medicatie'],

      });
      return appUser;
    } else {
      throw Exception("Ceva a mers prost. Va rugam sa incercati mai tarziu");
    }
  }

  Future<AppUser> getDoctorById(String? id) async {
    print(id);
    var document =
        await FirebaseFirestore.instance.collection('users').doc(id).get();

    if (document.exists) {
      Map<String, dynamic>? data = document.data();
      descriereDoctor = data?['descriere'];
      final AppUser appUser = AppUser.fromMapDoctor({
        'id': data?['id'],
        'fullName': data?['fullName'],
        'telefon': data?['telefon'],
        'email': data?['email'],
        'role': data?['role'],
        'profilePic': data?['profilePic']
      });
      return appUser;
    } else {
      final AppUser appUser = AppUser.fromMapDoctor({
        'id': null,
        'fullName': null,
        'telefon': null,
        'email': null,
        'role': null,
        'profilePic': null
      });
      return appUser;
    }
  }

  Future<void> getPatientsWithNewMessages(String doctorId) async {
    var myPatients = getMyPatients(doctorId);
    String groupChatId = "";
    _patientsWithNewMessages = [];
    _instance = FirebaseFirestore.instance;
    for(AppUser patient in myPatients) {
      if (doctorId.compareTo(patient.id!) > 0) {
        groupChatId = '$doctorId - ${patient.id!}';
      } else {
        groupChatId = '${patient.id!} - $doctorId';
      }
      QuerySnapshot querySnapshot = await _instance!
          .collection("messages")
          .doc(groupChatId)
          .collection(groupChatId)
          .orderBy("timestamp", descending: true)
          .limit(1).get();
      querySnapshot.docs.forEach((element) {
        Map<String, dynamic>? data = element.data() as Map<String, dynamic>?;
        print(data);
        if(data?['idTo'] == doctorId) {
          var myListFiltered = myPatients.where((e) => e.id == data?['idFrom']);
          if (myListFiltered.length > 0) {
            _patientsWithNewMessages.add(myListFiltered.first);
          } else {
            // Element is not found
          }
        }
      });
    }
    print(_patientsWithNewMessages.length);

  }

  Future<void> getPatientsFromFirebase() async {
    _instance = FirebaseFirestore.instance;
    _patients = [];
    CollectionReference collectionReference = _instance!.collection('users');
    QuerySnapshot querySnapshot =
        await collectionReference.where("role", isEqualTo: 1).get();
    int nr = 0;
    querySnapshot.docs.forEach((element) {
      if (kDebugMode) {
        print(nr++);
      }
      Map<String, dynamic>? data = element.data() as Map<String, dynamic>?;
      if (data != null) {
        final AppUser appUser = AppUser.fromMapPatient({
          'id': data['id'],
          'fullName': data['fullName'],
          'telefon': data['telefon'],
          'email': data['email'],
          'idDoctor': data['idDoctor'],
          'role': data['role'],
          'contraindicatii': data['contraindicatii'],
          'afectiuni': data['afectiuni'],
          'varsta': data['varsta'],
          'medicatie': data['medicatie'],
          'profilePic': data['profilePic']
        });
        _patients.add(appUser);
      }
    });
  }

  Future<void> getAllReviewsFromFirebase() async {
    // Create a reference to the cities collection
    _instance = FirebaseFirestore.instance;
    _allReviews = [];
    CollectionReference collectionReference = _instance!.collection('reviews');
    QuerySnapshot querySnapshot =
    await collectionReference.get();
    int nr = 0;
    querySnapshot.docs.forEach((element) {
      if (kDebugMode) {
        print(nr++);
      }
      Map<String, dynamic>? data = element.data() as Map<String, dynamic>?;
      if (data != null) {
        //print(data);
        final Review doctorReview = Review.fromMap({
          'idReviewer': data['idReviewer'],
          'idDoctor': data['doctorReviewed'],
          'content': data['content'],
          'stars': data['stars'],
          'reviewerName': data['reviewerName']
        });
        _allReviews.add(doctorReview);
        //print(doctorReview.idReviewer);
      }
    });
  }

  Future<void> getReviewsFromFirebase(String? doctorId) async {
    // Create a reference to the cities collection
    _instance = FirebaseFirestore.instance;
    _reviews = [];
    CollectionReference collectionReference = _instance!.collection('reviews');
    QuerySnapshot querySnapshot =
    await collectionReference.where("doctorReviewed", isEqualTo: doctorId).get();
    int nr = 0;
    querySnapshot.docs.forEach((element) {
      if (kDebugMode) {
        print(nr++);
      }
      Map<String, dynamic>? data = element.data() as Map<String, dynamic>?;
      if (data != null) {
        print(data);
        final Review doctorReview = Review.fromMap({
          'idReviewer': data['idReviewer'],
          'idDoctor': data['doctorReviewed'],
          'content': data['content'],
          'stars': data['stars'],
          'reviewerName': data['reviewerName']
        });
        _reviews.add(doctorReview);
        print(doctorReview.idReviewer);
      }
    });
  }

  Future<void> getDoctorsFromFirebase() async {
    // Create a reference to the cities collection
    _instance = FirebaseFirestore.instance;
    _doctors = [];
    CollectionReference collectionReference = _instance!.collection('users');
    QuerySnapshot querySnapshot =
        await collectionReference.where("role", isEqualTo: 2).get();
    int nr = 0;
    querySnapshot.docs.forEach((element) {
      if (kDebugMode) {
        print(nr++);
      }
      Map<String, dynamic>? data = element.data() as Map<String, dynamic>?;
      if (data != null) {
        final AppUser appUser = AppUser.fromMap({
          'id': data['id'],
          'fullName': data['fullName'],
          'telefon': data['telefon'],
          'email': data['email'],
          'idDoctor': null,
          'role': data['role'],
          'profilePic': data['profilePic']
        });
        _doctors.add(appUser);
        print(appUser.fullName);
      }
    });
  }

  Future<void> deleteUser(String? id) async {
    _instance!.collection("users").doc(id).delete().then(
          (doc) => print("Document deleted"),
          onError: (e) => throw Exception("Utilizatorul nu a putut fi sters."),
        );
  }

  Future<void> updatePatient(AppUser user, String? medicatie, String? afectiune,
      String? contra) async {
    AppUser updatedUser = AppUser();
    updatedUser.id = user.id;
    updatedUser.idDoctor = user.idDoctor;
    updatedUser.fullName = user.fullName;
    updatedUser.telefon = user.telefon;
    updatedUser.email = user.email;
    updatedUser.role = user.role;
    updatedUser.varsta = user.varsta;
    updatedUser.profilePic = user.profilePic;

    updatedUser.medicatie = medicatie;
    updatedUser.afectiuni = afectiune;
    updatedUser.contraindicatii = contra;
    
    await FirebaseFirestore.instance
        .doc('users/${updatedUser.id}')
        .set(updatedUser.toMapPatient());
  }

  Future<void> updateDoctor(AppUser user) async {
    AppUser updatedUser = AppUser();
    updatedUser.id = user.id;
    updatedUser.fullName = user.fullName;
    updatedUser.telefon = user.telefon;
    updatedUser.email = user.email;
    updatedUser.role = user.role;
    updatedUser.profilePic = user.profilePic;
    
    await FirebaseFirestore.instance
        .doc('users/${updatedUser.id}')
        .set(updatedUser.toMapDoctor(descriereDoctor));
  }

  Future<void> getUsersFromFirebase() async {
    print("here");
    _instance = FirebaseFirestore.instance;
    _users = [];

    CollectionReference collectionReference = _instance!.collection('users');
    QuerySnapshot querySnapshot = await collectionReference.get();
    //final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    int nr = 0;
    querySnapshot.docs.forEach((element) {
      Map<String, dynamic>? data = element.data() as Map<String, dynamic>?;
      print(data);
      if (data != null) {
        final AppUser appUser = AppUser.fromMap({
          'id': data['id'],
          'fullName': data['fullName'],
          'telefon': data['telefon'],
          'email': data['email'],
          'idDoctor': null,
          'role': data['role'],
          'profilePic': data['profilePic']
        });
        if (appUser.role != 3) {
          _users.add(appUser);
        }
      }
    });
  }

}
