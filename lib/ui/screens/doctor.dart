import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../globals.dart';
import '../../model/Review.dart';
import '../../model/appUser.dart';
import '../../services/firebase_service.dart';
import '../../services/helper.dart';
import '../../services/home_provider.dart';
import '../auth/login/login.dart';
import '../components/confirmation_dialog.dart';
import '../components/keyboard_utils.dart';
import '../components/loading_view.dart';
import 'chat_page.dart';

class DoctorScreen extends StatefulWidget {
  late final String lastName;
  late BuildContext context;

  //ProfilePage(this.lastName);

  @override
  _DoctorScreenState createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  _DoctorScreenState();

  late FirebaseService service;
  List<AppUser> _allUsers = [];
  List<AppUser> _newMessagesFrom = [];
  List<AppUser> _filteredList = [];
  int _selectedIndex = 0;
  List<Review> _allReviews = [];
  PageController pageController = PageController();
  TextEditingController _controllerMedicamente = TextEditingController();
  TextEditingController _controllerAfectiuni = TextEditingController();
  TextEditingController _controllerVarsta = TextEditingController();
  TextEditingController _controllerContra = TextEditingController();

  PlatformFile? pickedFile;
  UploadTask? uploadTask;

  ///chat related
  final ScrollController scrollController = ScrollController();
  int _limit = 20;
  int _limitNew = 20;
  final int _limitIncrement = 20;
  String _textSearch = "";
  bool isLoading = false;
  late String currentUserId;
  late HomeProvider homeProvider;
  StreamController<bool> buttonClearController = StreamController<bool>();
  TextEditingController searchTextEditingController = TextEditingController();

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
        loggedUser = AppUser();
        Navigator.of(context)
            .pushAndRemoveUntil(MaterialPageRoute(
          builder: (context) =>  const LoginPage(),
        ), (Route<dynamic> route) => false);
    }
  }

  void scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }


  @override
  void dispose() {
    super.dispose();
    buttonClearController.close();
  }

  Widget buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(10),
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: primaryColorC,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 10,
          ),
          const Icon(
            Icons.person_search,
            color: textColor,
            size: 24,
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: TextFormField(
              textInputAction: TextInputAction.search,
              controller: searchTextEditingController,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  buttonClearController.add(true);
                  setState(() {
                    _textSearch = value;
                    _filteredList = _allUsers.where((e) => e.fullName!.toLowerCase().contains(_textSearch)).toList();
                  });
                } else {
                  buttonClearController.add(false);
                  setState(() {
                    _textSearch = "";
                    _filteredList = _allUsers.where((e) => e.fullName!.toLowerCase().contains(_textSearch)).toList();
                  });
                }
              },
              decoration: const InputDecoration.collapsed(
                hintText: 'Search here...',
                hintStyle: TextStyle(color: textColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    homeProvider = context.read<HomeProvider>();
    currentUserId = loggedUser!.id!;
    scrollController.addListener(scrollListener);
    getAll();
  }

  Widget buildItemNew(BuildContext context, index, list) {
      AppUser userChat = list[index];
      return TextButton(
          onPressed: () {
            if (KeyboardUtils.isKeyboardShowing()) {
              KeyboardUtils.closeKeyboard(context);
            }
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatPage(
                      peer: userChat,
                      peerId: userChat.id!,
                      peerAvatar: userChat.profilePic!,
                      peerNickname: userChat.fullName!,
                      peerTelephone: userChat.telefon!,
                      userAvatar: loggedUser!.profilePic!,
                    )));
          },
          child: ListTile(
            leading: (userChat.profilePic != null)
                ? ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                userChat.profilePic!,
                fit: BoxFit.cover,
                width: 50,
                height: 50,
                loadingBuilder: (BuildContext ctx, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                          color: Colors.grey,
                          value: loadingProgress.expectedTotalBytes !=
                              null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null),
                    );
                  }
                },
                errorBuilder: (context, object, stackTrace) {
                  return const Icon(Icons.account_circle, size: 50);
                },
              ),
            )
                : const Icon(
              Icons.account_circle,
              size: 50,
            ),
            title: Text(
              userChat.fullName!,
              style: const TextStyle(color: primaryColorC),
            ),
          ),
        );
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
      service.updateDoctor(loggedUser!);
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

  getRecentPeople() async {
    print("trying to get recent chatters");
    service.getPatientsWithNewMessages(currentUserId).then((value) => setState(() {_newMessagesFrom = service.getPatientsNewMessages();}));
  }

  getAll() async {
    service = Provider.of<FirebaseService>(context, listen: false);
    service.getPatientsFromFirebase().then((value) {
      setState(() {
        _allUsers = service.getMyPatients(loggedUser?.id);
        _filteredList = _allUsers;
      });
      print("Numar utilizatori: ${_allUsers.length}");
      getRecentPeople();
    });

    service.getReviewsFromFirebase(loggedUser?.id).then((value) {
      _allReviews = service.getDoctorReviews();
    });
  }

  Widget editUsers() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Column(
        children: [
          SizedBox(
            height: 40,
          ),
          SizedBox(
            height: 5,
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding:
                  EdgeInsets.only(left: width / 16, right: width / 16, top: 5),
              child: const Align(
                alignment: Alignment.topCenter,
                child: Text(
                  'Selectati un utilizator pentru editare date: ',
                  style: TextStyle(fontSize: 20, color: textColor),
                ),
              ),
            ),
          ),
          Container(
            height: (height - 170),
            margin: const EdgeInsets.only(bottom: 5),
            child: ListView.separated(
                separatorBuilder: (context, index) => const Divider(
                      color: textColorTransparent,
                      thickness: 1,
                    ),
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _allUsers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    key: Key(_allUsers[index].toString()),
                    onTap: () async {
                      editedUser = _allUsers[index].id;
                      _controllerContra.text =
                          _allUsers[index].contraindicatii!;
                      _controllerAfectiuni.text = _allUsers[index].afectiuni!;
                      _controllerMedicamente.text = _allUsers[index].medicatie!;
                      _controllerVarsta.text =
                          _allUsers[index].varsta!.toString();
                      print(_allUsers[index].id);
                      var result = await openEditDialog(index);
                      if (result != null && result == true) {
                        print("editare");
                        try {
                          await service.updatePatient(
                              _allUsers[index],
                              _controllerMedicamente.text,
                              _controllerAfectiuni.text,
                              _controllerContra.text);
                          setState(() {
                            _allUsers[index].afectiuni =
                                _controllerAfectiuni.text;
                            _allUsers[index].contraindicatii =
                                _controllerContra.text;
                            _allUsers[index].medicatie =
                                _controllerMedicamente.text;
                          });
                          Fluttertoast.showToast(
                              msg: "Istoricul a fost actualizat cu succes!",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } on Exception catch (_, e) {
                          Fluttertoast.showToast(
                              msg: "Actualizarea nu a avut succes.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red.withOpacity(0.3),
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      } else {
                        print("cancel");
                        Fluttertoast.showToast(
                            msg: "Editare anulata",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red.withOpacity(0.5),
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }
                    },
                    leading:
                        const Icon(Icons.person, color: textColor, size: 35),
                    title: Text(_allUsers[index].fullName!,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w300,
                            color: textColor)),
                    subtitle: Text("${_allUsers[index].telefon!}",
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            color: textColor)),
                  );
                }),
          ),
        ],
      );
  }

  Widget openChats() {
    return Scaffold(
        body: Stack(
            children: [
              Column(
                children: [
                  buildSearchBar(),
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _filteredList.length,
                      itemBuilder: (context, index) =>
                          buildItemNew(context, index, _filteredList),
                      separatorBuilder: (BuildContext context, int index) =>
                      const Divider(color: primaryColorC),
                    ),
                  ),
                ],
              ),
              Positioned(
                child: isLoading ? const LoadingView() : const SizedBox.shrink(),
              ),
            ],
          ),
        );
  }

  Widget openRecentChats() {
    return Scaffold(
        body: Stack(
        children: [
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: primaryColorC,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: TextButton(
                    onPressed: () {
                      pageController.jumpToPage(3);

                }, child: const Text('Scrie un mesaj nou', style: TextStyle(color: textColor),),),
              ),
              Expanded(
                child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _newMessagesFrom.length,
                          itemBuilder: (context, index) =>
                              buildItemNew(context, index, _newMessagesFrom),
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(color: primaryColorC),
                        ),
              ),
            ],
          ),
          Positioned(
            child: isLoading ? const LoadingView() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
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
                return profileCard(
                  fullName: loggedUser?.fullName,
                  imagePath: loggedUser?.profilePic,
                );
              }),
        ),
      );
  }

  Widget profileCard({
    String? fullName,
    String? imagePath,
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
                          'Dr. ${fullName?.capitalize()}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Color(0xFF6f6f6f),
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
                        Container(
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
                          children: const [
                            Text(
                              'Specialitate',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFF6f6f6f),
                              ),
                            ),
                            Text(
                              'Medic de familie',
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
                              'Numar pacienti inscrisi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFF6f6f6f),
                              ),
                            ),
                            Text(
                              _allUsers.length.toString(),
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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: onBackPress,
      child: Scaffold(
        body: Container(
          width: width,
          height: height,
          color: primaryColorC,
          child: PageView(
            controller: pageController,
            children: [
              openRecentChats(),
              editUsers(),
              myProfile(),
              openChats(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          //New
          backgroundColor: primaryColorC,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.question_answer,
                  color: textColor,
                ),
                label: 'Discutii in curs'),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.perm_identity,
                color: textColor,
              ),
              label: 'Editare pacienti',
            ),
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

  Future<dynamic> openEditDialog(index) async {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    BuildContext dialogContext;
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return Align(
          alignment: Alignment.topCenter,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
            child: Align(
              alignment: Alignment.topCenter,
              child: AlertDialog(
                title: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "${_allUsers[index].fullName!}",
                      style: TextStyle(color: textColor),
                    )),
                content: Container(
                  height: height / 2,
                  width: width,
                  child: Column(
                    children: [
                      ///camp varsta
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 50, right: 5, top: 5),
                          child: Text(
                            'Varsta pacient',
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
                        child: TextField(
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.next,
                          controller: _controllerVarsta,
                          enabled: false,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            icon: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Icon(
                                Icons.phone,
                                color: textColor,
                              ),
                            ),
                            contentPadding:
                                EdgeInsets.only(left: 0, right: 20, bottom: 15),
                            border: InputBorder.none,
                            hintText: "Telefon doctor",
                            hintStyle: TextStyle(color: textColor),
                          ),
                        ),
                      ),

                      ///camp afectiuni
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 50, right: 5, top: 10),
                          child: Text(
                            'Afectiuni cunoscute',
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
                        child: TextField(
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.next,
                          controller: _controllerAfectiuni,
                          onChanged: (String? val) {},
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            icon: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Icon(
                                Icons.coronavirus,
                                color: textColor,
                              ),
                            ),
                            contentPadding:
                                EdgeInsets.only(left: 0, right: 20, bottom: 15),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      ///camp medicamente

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 50, right: 5, top: 10),
                          child: Text(
                            'Medicatie curenta',
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
                        child: TextField(
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.next,
                          controller: _controllerMedicamente,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            icon: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Icon(
                                Icons.medication,
                                color: textColor,
                              ),
                            ),
                            contentPadding: EdgeInsets.only(
                                left: 5, right: 10, top: 10, bottom: 10),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      ///campcontra
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 50, right: 5, top: 10),
                          child: Text(
                            'Contraindicatii',
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
                        child: TextField(
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.next,
                          controller: _controllerContra,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            icon: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Icon(
                                Icons.mood_bad,
                                color: textColor,
                              ),
                            ),
                            contentPadding: EdgeInsets.only(
                                left: 5, right: 10, top: 10, bottom: 10),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                backgroundColor: primaryColorC,
                actionsAlignment: MainAxisAlignment.spaceBetween,
                insetPadding: EdgeInsets.only(
                  left: 5,
                  right: 5,
                ),
                buttonPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                contentPadding: EdgeInsets.only(bottom: 15),
                actions: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                        primary: textColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        )),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text("Renunta"),
                  ),
                  TextButton(
                      style: TextButton.styleFrom(
                        primary: textColor,
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext, rootNavigator: true)
                            .pop(true);
                      },
                      child: const Text("Finalizeaza")),
                ],
              ),
            ),
          ),
        );
      },
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

}
