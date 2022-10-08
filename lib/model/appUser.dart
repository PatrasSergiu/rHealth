import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AppUser {
  static const colId = 'id';
  static const colFullName = 'fullName';
  static const colTelefon = 'telefon';
  static const colEmail = 'email';
  static const colIdDoctor = 'idDoctor';
  static const colRole = 'role';
  static const colMedicatie = 'medicatie';
  static const colAfectiuni = 'afectiuni';
  static const colVarsta = 'varsta';
  static const colContra = 'contraindicatii';
  static const colProfile = 'profilePic';

  int? role, varsta;
  String? id,
      fullName,
      telefon,
      idDoctor,
      email,
      contraindicatii,
      medicatie,
      afectiuni,
      profilePic;

  AppUser(
      {this.id,
      this.fullName,
      this.email,
      this.telefon,
      this.idDoctor,
      this.role,
      this.afectiuni,
      this.contraindicatii,
      this.varsta,
      this.medicatie,
      this.profilePic});

  factory AppUser.fromMapPatientChat(DocumentSnapshot snapshot) {
    String fullName = "",
        telefon = "",
        idDoctor = "",
        email = "",
        afectiuni = "",
        medicatie = "",
        profilePic = "",
        contraindicatii = "";
    int varsta = 0, role = 1;

    try {
      fullName = snapshot.get('fullName');
      telefon = snapshot.get('telefon');
      idDoctor = snapshot.get('idDoctor');
      email = snapshot.get('email');
      afectiuni = snapshot.get('afectiuni');
      medicatie = snapshot.get('medicatie');
      profilePic = snapshot.get('profilePic');
      contraindicatii = snapshot.get('contraindicatii');
      varsta = snapshot.get('varsta');
      role = snapshot.get('role');
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return AppUser(
      id: snapshot.id,
      fullName: fullName,
      telefon: telefon,
      idDoctor: idDoctor,
      email: email,
      afectiuni: afectiuni,
      medicatie: medicatie,
      profilePic: profilePic,
      contraindicatii: contraindicatii,
      varsta: varsta,
      role: role,
    );
  }

  AppUser.fromMap(Map<dynamic, dynamic> map) {
    id = map[colId];
    fullName = map[colFullName];
    telefon = map[colTelefon];
    email = map[colEmail];
    idDoctor = map[colIdDoctor];
    role = map[colRole];
    profilePic = map[colProfile];
  }

  AppUser.fromMapPatient(Map<dynamic, dynamic> map) {
    id = map[colId];
    fullName = map[colFullName];
    telefon = map[colTelefon];
    email = map[colEmail];
    idDoctor = map[colIdDoctor];
    role = map[colRole];
    varsta = map[colVarsta];
    afectiuni = map[colAfectiuni];
    contraindicatii = map[colContra];
    medicatie = map[colMedicatie];
    profilePic = map[colProfile];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'fullName': fullName,
      'telefon': telefon,
      'idDoctor': idDoctor,
      'role': role,
      'email': email,
      'profilePic': profilePic
    };
    if (id != null) {
      map[colId] = id;
    }
    return map;
  }

  Map<String, dynamic> toMapPatient() {
    var map = <String, dynamic>{
      'id': id,
      'fullName': fullName,
      'telefon': telefon,
      'idDoctor': idDoctor,
      'role': role,
      'email': email,
      'varsta': varsta,
      'afectiuni': afectiuni,
      'medicatie': medicatie,
      'profilePic': profilePic,
      'contraindicatii': contraindicatii
    };
    if (id != null) {
      map[colId] = id;
    }
    return map;
  }

  AppUser.fromMapDoctor(Map<dynamic, dynamic> map) {
    id = map[colId];
    fullName = map[colFullName];
    telefon = map[colTelefon];
    email = map[colEmail];
    role = map[colRole];
    profilePic = map[colProfile];
  }

  Map<String, dynamic> toMapDoctor(String? descriere) {
    var map = <String, dynamic>{
      'id': id,
      'fullName': fullName,
      'telefon': telefon,
      'role': role,
      'email': email,
      'descriere': descriere,
      'profilePic': profilePic
    };
    if (id != null) {
      map[colId] = id;
    }
    return map;
  }
}
