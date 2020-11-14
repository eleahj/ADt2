import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dyne/screens/Home_Page_Controller/home.dart';
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../resources/repository.dart';
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

/*This screen is only reached by new users when initializing their profile,
* they can set their name, photo, bio, phone, and email here. This then leads to
* the referral user screen */

class CreateProfileScreen extends StatefulWidget {
  final String photoUrl, email, bio, name, phone;

  CreateProfileScreen(
      {this.photoUrl, this.email, this.bio, this.name, this.phone});

  @override
  _CreateProfileScreenState createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  var _repository = Repository();
  User currentUser;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _displayNameValid = true;
  bool _bioValid = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
    _bioController.text = widget.bio;
    _emailController.text = widget.email;
    _phoneController.text = widget.phone;
  }

  List<User> usersList = List<User>();

  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      final _repository = Provider.of<Repository>(context, listen: false);
      _repository.getAndSetCurrentUser().then((_) {
        _repository
            .fetchAllUsersWithUser(_repository.user())
            .then((updatedList) => setState(() {
                  _nameController.text.trim().length < 3 ||
                          _nameController.text.isEmpty
                      ? _displayNameValid = false
                      : _displayNameValid = true;
                  _bioController.text.trim().length > 100
                      ? _bioValid = false
                      : _bioValid = true;
                  currentUser = _repository.user();
                  usersList = updatedList;
                  _isLoading = false;
                }));
      });

      _isInit = false;
      super.didChangeDependencies();
    }
  }

  File imageFile;

  Future<File> _pickImage(String action) async {
    PickedFile selectedImage;
    final picker = ImagePicker();
    action == 'Gallery'
        ? selectedImage = await picker.getImage(source: ImageSource.gallery)
        : await picker.getImage(source: ImageSource.camera);

    return File(selectedImage.path);
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Display Name",
              style: TextStyle(color: Colors.red[900], fontSize: 20),
            )),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: "Update Display Name",
            errorText: _displayNameValid ? null : "Display Name too short",
          ),
        )
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 15.0),
          child: Text(
            "Bio",
            style: TextStyle(color: Colors.red[900], fontSize: 20),
          ),
        ),
        TextField(
          controller: _bioController,
          decoration: InputDecoration(
            hintText: "Add Bio",
            errorText: _bioValid ? null : "Bio too long",
          ),
        )
      ],
    );
  }

  deleteIncompleteUser() {
      _repository
          .deleteUser(currentUser.uid);
  }

  updateProfileData() {
    setState(() {
      _nameController.text.trim().length < 3 || _nameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
      _bioController.text.trim().length > 100
          ? _bioValid = false
          : _bioValid = true;
    });

    if (_displayNameValid && _bioValid) {
      _repository
          .updateDetails(currentUser.uid, _nameController.text,
              _bioController.text, _emailController.text, _phoneController.text)
          .then((v) {
        _showPopUpDialog(context, "Are Your Changes Finalized?",
            "This will save all changes");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: new Color(0xfff8faf8),
        elevation: 1,
        centerTitle: true,
        title: Text(
          'Create Profile',
          style:
              TextStyle(fontFamily: "Sunflower", fontWeight: FontWeight.w400),
        ),
        leading: GestureDetector(
          child: Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
          ),
          onTap: deleteIncompleteUser,
        ),
        actions: <Widget>[
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Icon(Icons.done, color: Colors.red[900]),
            ),
            onTap: updateProfileData,
          )
        ],
      ),
      body: _isLoading
          ? Center(child: const CircularProgressIndicator())
          : ListView(children: <Widget>[
              Column(
                children: <Widget>[
                  GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Container(
                            width: 150.0,
                            height: 150.0,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.red[900], width: 2),
                              borderRadius: BorderRadius.circular(80.0),
                              image: DecorationImage(
                                  image: widget.photoUrl==null||widget.photoUrl.isEmpty
                                      ? AssetImage('assets/images/no_image.png')
                                      : NetworkImage(widget.photoUrl),
                                  fit: BoxFit.cover),
                            )),
                      ),
                      onTap: _showImageDialog),
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text('Change Photo',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 25.0,
                              fontWeight: FontWeight.w300)),
                    ),
                    onTap: _showImageDialog,
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    buildDisplayNameField(),
                    buildBioField(),
                  ],
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Text(
                  'Private Information',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 25.0,
                      fontWeight: FontWeight.w300),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Update Email address',
                    labelText: 'Email address',
                    labelStyle: TextStyle(color: Colors.red[900], fontSize: 20),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                child: TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    hintText: 'Add Phone Number',
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(color: Colors.red[900], fontSize: 20),
                  ),
                ),
              ),
            ]),
    );
  }

  _showImageDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: ((context) {
          return SimpleDialog(
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Choose from Gallery'),
                onPressed: () {
                  _pickImage('Gallery').then((selectedImage) {
                    setState(() {
                      imageFile = selectedImage;
                    });
                    compressImage();
                    _repository.uploadImageToStorage(imageFile).then((url) {
                      _repository.updatePhoto(url, currentUser.uid).then((v) {
                        Navigator.pop(context);
                        _showPopUpDialog(context, "Image updated from Gallery",
                            "Changes may take a minute to show \n Please Continue to the Main App",
                            isComplex: false);
                      });
                    });
                  });
                },
              ),
              SimpleDialogOption(
                child: Text('Take Photo'),
                onPressed: () {
                  _pickImage('Camera').then((selectedImage) {
                    setState(() {
                      imageFile = selectedImage;
                    });
                    compressImage();
                    _repository.uploadImageToStorage(imageFile).then((url) {
                      _repository.updatePhoto(url, currentUser.uid).then((v) {
                        Navigator.pop(context);
                        _showPopUpDialog(context, "Image updated from Gallery",
                            "Changes may take a minute to show \nPlease Continue to the Main App",
                            isComplex: false);
                      });
                    });
                  });
                },
              ),
              SimpleDialogOption(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        }));
  }

  void compressImage() async {
    print('starting compression');
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = Random().nextInt(10000);

    Im.Image image = Im.decodeImage(imageFile.readAsBytesSync());
    Im.copyResize(image, width: 25, height: 25);
    var newim2 = new File('$path/img_$rand.jpg')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 85));

    setState(() {
      imageFile = newim2;
    });
    print('done');
  }

  void _showPopUpDialog(BuildContext context, String title, String body,
      {isComplex = true}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: new Text(title),
          content: new Text(body),
          actions: <Widget>[
            new FlatButton(
              child: new Text(isComplex ? "Yes" : "Ok"),
              onPressed: () {
                isComplex ?
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return DyneHomeScreen();
                })): Navigator.of(context).pop();
              },
            ),
            isComplex
                ? new FlatButton(
                    child: new Text("No"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                : null,
          ],
        );
      },
    );
  }
}
