import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../resources/repository.dart';
import 'package:provider/provider.dart';

/*This screen shows other users' profile and has the option to create a meet-up
* with them as long as they are friends, you can also toggle your friendship here*/
class FriendProfileScreen extends StatefulWidget {
  final String name;

  FriendProfileScreen({this.name});

  @override
  _FriendProfileScreenState createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  String currentUserId, friendUserId, currentUserImg, currentUserName;
  var _repo;

  User _user, currentuser;

  bool isFriend = false;
  bool followButtonClicked = false;
  int friendsCount = 0;

  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      _repo = Provider.of<Repository>(context, listen: false);
      _repo.getAndSetCurrentUser().then((_) {
        setState(() {
          currentuser = _repo.user();
          currentUserId = currentuser.uid;
          currentUserName = currentuser.displayName;
          currentUserImg = currentuser.photoUrl;
        });
        _repo.checkIsFriend(widget.name, currentuser.uid).then((isMyFriend) {
          _repo.fetchUidBySearchedName(widget.name).then((uid) {
            _repo.fetchUserDetailsById(uid).then(
                  (user) => setState(() {
                    friendUserId = uid;
                    _user = user;
                    isFriend = isMyFriend;
                    _isLoading = false;
                  }),
                );
          });
        });
      });
      _isInit = false;
      super.didChangeDependencies();
    }
  }

  Future<void> followUser() async {
    print('friend user');
    await _repo
        .friendUser(
            currentUserId: currentUserId,
            friendUserId: friendUserId,
            currentUserImg: currentUserImg,
            currentUserName: currentUserName)
        .then((_) => setState(() {
              isFriend = true;
              followButtonClicked = true;
            }));
  }

  Future<void> unfollowUser() async {
    await _repo
        .unFriendUser(
            currentUserId: currentUserId,
            friendUserId: friendUserId,
            currentUserImg: currentUserImg,
            currentUserName: currentUserName)
        .then((_) => setState(() {
              isFriend = false;
              followButtonClicked = true;
            }));
  }

  Widget buildButton(
      {String text,
      Color backgroundColor,
      Color textColor,
      Color borderColor,
      Function function}) {
    var screenSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: function,
      child: Container(
        width: screenSize.width / 2 - 25,
        height: 40.0,
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(25.0),
            border: Border.all(color: borderColor)),
        child: Center(
          child: Text(text, style: TextStyle(color: textColor, fontSize: 20)),
        ),
      ),
    );
  }

  Widget buildProfileButton() {
    // already friend user - should show unfollow button
    if (isFriend) {
      return buildButton(
        text: "Unfriend",
        backgroundColor: Colors.white,
        textColor: Colors.black,
        borderColor: Colors.grey,
        function: unfollowUser,
      );
    } else {
      // does not follow user - should show follow button
      return buildButton(
        text: "Add Friend",
        backgroundColor: Colors.red[900],
        textColor: Colors.white,
        borderColor: Colors.red[900],
        function: followUser,
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
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
        ),
        body: _isLoading
            ? Center(child: const CircularProgressIndicator())
            : ListView(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 40, bottom: 10),
                        child: Container(
                            width: 150.0,
                            height: 150.0,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.red[900], width: 3),
                              borderRadius: BorderRadius.circular(130.0),
                              image: DecorationImage(
                                  image: _user.photoUrl.isEmpty
                                      ? AssetImage('assets/images/no_image.png')
                                      : NetworkImage(_user.photoUrl),
                                  fit: BoxFit.cover),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Text(_user.displayName,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w300,
                                fontSize: 30.0)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 35, vertical: 5),
                        child: _user.bio.isNotEmpty
                            ? Text(_user.bio,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20.0))
                            : Container(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                                StreamBuilder(
                                  stream: _repo
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
                           SizedBox(height: 30),
                           buildProfileButton(),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
      ),
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