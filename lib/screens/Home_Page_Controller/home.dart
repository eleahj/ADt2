import 'package:dyne/screens/Search_Users/search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../resources/repository.dart';
import '../../screens/Notifications_Page/notifications.dart';
import '../../screens/Profile_Page/profile.dart';
import 'dart:async';
import 'package:dyne/models/user.dart' as appuser;

/*This class defines the main page controller for the app, listing the
* explore, notifs, radar, manage meet-ups, and profile screen buttons. We
* will soon migrate the latter two pages together for added simplicity*/

class DyneHomeScreen extends StatefulWidget {
  @override
  _DyneHomeScreenState createState() => _DyneHomeScreenState();
}

PageController pageController;

class _DyneHomeScreenState extends State<DyneHomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var _isInit = true;
  var _isLoading = false;
  int _page = 0;
  var _repository = Repository();
  appuser.User _user;

  void navigationTapped(int page) {
    //Animating Page
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      pageController = new PageController();
      retrieveUserDetails().then((_) =>
          setState(() {
            print(_user);
            _isLoading = false;
          }));
      _isInit = false;
      super.didChangeDependencies();
    }
  }

  Future<void> retrieveUserDetails() async {
    return await _repository.getAndSetCurrentUser().then((_) =>
        setState(() {
          _user = _repository.user();
        }));
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: _isLoading ? Center(child: const CircularProgressIndicator()) :
      new PageView(children: [
          new Container(color: Colors.white, child: ActivityFeed()),
          new Container(color: Colors.white, child: SearchScreen()),
          new Container(color: Colors.white, child: ProfileScreen())],
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: new CupertinoTabBar(
        activeColor: Colors.black,
        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(
              icon: new Icon(Icons.notifications_active,
                  color: (_page == 0) ? Colors.red[900] : Colors.black),
              // ignore: deprecated_member_use
              title: new Container(height: 0.0),
              backgroundColor: Colors.white),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.search,
                  color: (_page == 1) ? Colors.red[900] : Colors.black),
              // ignore: deprecated_member_use
              title: new Container(height: 0.0),
              backgroundColor: Colors.white),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.person,
                  color: (_page == 2) ? Colors.red[900] : Colors.black),
              // ignore: deprecated_member_use
              title: new Container(height: 0.0),
              backgroundColor: Colors.white),
        ],
        onTap: navigationTapped,
        currentIndex: _page,
      ),
    );
  }
}
