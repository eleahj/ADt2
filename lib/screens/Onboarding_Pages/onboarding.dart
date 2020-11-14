import 'package:dyne/screens/Login_Signup/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'onboarding_visual.dart';

//This widget runs through the various onboarding screens including the sign-in
//page which allows for google and apple sign in and login
class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final int _numPages = 4;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  var height;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages + 1; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return _currentPage != 0
        ? AnimatedContainer(
            duration: Duration(milliseconds: 150),
            margin: EdgeInsets.symmetric(horizontal: 8.0),
            height: 8.0,
            width: isActive ? 24.0 : 16.0,
            decoration: BoxDecoration(
              color: (_currentPage == 0) ? Colors.white : Colors.black,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          )
        : Text('');
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 30, 0, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  alignment: Alignment.centerRight,
                  child: FlatButton(
                    onPressed: () {
                      _pageController.animateToPage(
                        4,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    },
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: (_currentPage == 0 || _currentPage == 4)
                            ? Colors.white
                            : Colors.black,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: height * 0.7,
                  child: PageView(
                    physics: ClampingScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: <Widget>[
                      EntryVisual(
                        scalar: (5 / 6),
                        imgLink: 'assets/images/dynelogo.png',
                        h1Text: "",
                        h2Text: "",
                      ),
                      EntryVisual(
                        scalar: (5 / 6),
                        imgLink: 'assets/images/onboading1.jpg',
                        h1Text: 'Meet People With Similar Interests!',
                        h2Text: 'Explore New Restaurants \n And Cuisines!',
                      ),
                      EntryVisual(
                        scalar: (5 / 6),
                        imgLink: 'assets/images/onboarding2.jpg',
                        h1Text: 'Earn Coupons with Every Meetup!',
                        h2Text:
                            'Get Amazing Discounts and Offers \n And Save Money!',
                      ),
                      EntryVisual(
                        scalar: (7 / 9),
                        imgLink: 'assets/images/onboarding3.png',
                        h1Text: 'Book Meetups with Nearby Friends!',
                        h2Text:
                            'Introducing The New Radar Feature \n with Live Location Updates!',
                      ),
                      EntryVisual(
                        scalar: (5 / 6),
                        imgLink: 'assets/images/onboarding4.jpg',
                        h1Text: 'Grow Your Social Circle',
                        h2Text:
                            'Get Instant Universal Updates about \n New Social Challenges and Discounts!',
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicator(),
                ),
                _currentPage != _numPages
                    ? Expanded(
                        child: Align(
                          alignment: FractionalOffset.bottomRight,
                          child: FlatButton(
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.ease,
                                );
                              },
                              child: _currentPage != _numPages
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          'Next',
                                          style: TextStyle(
                                            color: (_currentPage == 0)
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 22.0,
                                          ),
                                        ),
                                        SizedBox(width: 10.0),
                                        Icon(
                                          Icons.arrow_forward,
                                          color: (_currentPage == 0)
                                              ? Colors.red[900]
                                              : Colors.black,
                                          size:
                                              (_currentPage == 0) ? 50.0 : 30.0,
                                        ),
                                      ],
                                    )
                                  : Text('')),
                        ),
                      )
                    : Text(''),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: _currentPage == _numPages
          ? Container(
              height: height / 10.0,
              width: double.infinity,
              color: Colors.white,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: ((context) => LoginScreen())));
                },
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(),
                    child: Text(
                      'Get started',
                      style: TextStyle(
                        color: Colors.red[900],
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Text(''),
    );
  }
}
