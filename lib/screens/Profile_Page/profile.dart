import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../models/user.dart';
import '../../resources/repository.dart';
import '../../screens/Profile_Page/edit_profile.dart';

/*This screen displays all profile data, gives access to edit profile,
* and shows the info that other users can see of your profile*/
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var _repository = Repository();
  User _user;
  var _height;
  bool forceReload = false;

  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setProfileData(context);
      _isInit = false;
      super.didChangeDependencies();
    }
  }

  void setProfileData(BuildContext context) {
    setState(() {
      _isLoading = true;
      _height = MediaQuery.of(context).size.height;
      final _repository = Provider.of<Repository>(context, listen: false);
      _repository
          .getAndSetCurrentUser(forceRetrieve: true)
          .then((_) => setState(() {
                _user = _repository.user();
                _isLoading = false;
              }));
    });
  }

  Future<void> retrieveUserDetails() async {
    return await _repository.getAndSetCurrentUser().then((_) => setState(() {
          _user = _repository.user();
        }));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: new Container(),
            centerTitle: true,
            title: Text(
              'Profile',
              style: TextStyle(
                color: Colors.black,
                fontFamily: "Sunflower",
                fontWeight: FontWeight.w300,
                fontSize: 25.0,
              ),
            ),
            actions: <Widget>[
              // Text("Logout", style: TextStyle(color: Colors.red[900], fontSize: 18), ),
              IconButton(
                icon: Icon(Icons.highlight_off),
                color: Colors.red[900],
                onPressed: () {
                  _repository.signOut().then((v) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) {
                      return MyApp();
                    }));
                  });
                },
              )
            ],
          ),
          body: _isLoading
              ? Center(child: const CircularProgressIndicator())
              : ListView(
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 30, bottom: 20),
                          child: Container(
                              width: _height / 5.0,
                              height: _height / 5.0,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.red[900], width: 3),
                                borderRadius: BorderRadius.circular(130.0),
                                image: new DecorationImage(
                                    image: _user.photoUrl.isEmpty
                                        ? const AssetImage(
                                            'assets/images/no_image.png')
                                        : new NetworkImage(_user.photoUrl),
                                    fit: BoxFit.cover),
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: new Text(_user.displayName,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 30.0)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 35, vertical: 5),
                          child: _user.bio.isNotEmpty
                              ? new Text(_user.bio,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18.0))
                              : Container(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Divider(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  StreamBuilder(
                                    stream: _repository
                                        .fetchStats(
                                            uid: _user.uid, label: 'friends')
                                        .asStream(),
                                    builder: ((context,
                                        AsyncSnapshot<List<DocumentSnapshot>>
                                            snapshot) {
                                      if (snapshot.hasData) {
                                        return detailsWidget(
                                            snapshot.data.length.toString(),
                                            'Friends');
                                      } else {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                    }),
                                  ),
                                ],
                              ),
                              SizedBox(height: 40),
                              GestureDetector(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20.0),
                                  child: Container(
                                    width: 180.0,
                                    height: 45.0,
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                        border: Border.all(color: Colors.grey)),
                                    child: Center(
                                      child: Text('Edit Profile',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20)),
                                    ),
                                  ),
                                ),
                                onTap: () {
//                                  _isInit = true;
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: ((context) =>
                                              EditProfileScreen(
                                                  photoUrl: _user.photoUrl,
                                                  email: _user.email,
                                                  bio: _user.bio,
                                                  name: _user.displayName,
                                                  phone: _user.phone))));
                                },
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                )),
    );
  }

  Widget detailsWidget(String count, String label) {
    return Column(
      children: <Widget>[
        Text(count,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Colors.black)),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text(label,
              style: TextStyle(fontSize: 20.0, color: Colors.red[900])),
        )
      ],
    );
  }
}
