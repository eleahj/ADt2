import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../resources/repository.dart';
import '../../screens/Login_Signup/create_account.dart';
import '../../screens/Home_Page_Controller/home.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:apple_sign_in/apple_sign_in_button.dart' as appleButton;

/*This page is the login screen, we have google and apple authentication*/
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var _repository = Repository();
  var height;
  var width;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
            Container(
              width: 400.0,
              height: 2.0 * height / 6.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/dynelogo.png',
                  ),
                ),
              ),
            ),
            SizedBox(height: 120.0),
            GestureDetector(
                onTap: () {
                  _repository.signIn().then((user) {
                    if (user != null) {
                      authenticateUser(user);
                    } else {
                      print("Error");
                    }
                  });
                },
                child: Container(
                  width: width - 30,
                  height: 45.0,
                  decoration: BoxDecoration(
                      color: Colors.red[900],
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(color: Colors.red[900], width: 3)),
                  child: Center(
                    child: Container(
                      width: width - 30,
                      height: 45,
                      decoration: BoxDecoration(
                          color: Colors.red[900],
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(color: Colors.red[900], width: 3)),
                      child: Image.asset(
                        'assets/images/google_sign_in.png',
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                )),
            SizedBox(height: 20.0),
            FutureBuilder(
              future: _repository.appleSignInAvailable(),
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return Center(
                    child: Container(
                      width: width - 30,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.red[900],
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: AppleSignInButton(
                        onPressed: () {
                          _repository.signInWithApple().then((user) {
                            if (user != null) {
                              authenticateUser(user);
                            } else {
                              print("Error");
                            }
                          });
                        },
                        style: appleButton.ButtonStyle.black,
                      ),
                    ),
                  );
                } else {
                  print("Android");
                  return Container();
                }
              },
            ),
          ])),
    ));
  }

  void authenticateUser(User user) {
    print("Inside Login Screen -> authenticateUser");
    _repository.authenticateUser(user).then((value) {
      if (value) {
        print("VALUE : $value");
        print("INSIDE NEW USER");
        _repository.retrieveUserDetails(user);
        _repository.addDataToDb(user).then((value) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => CreateProfileScreen(
                      photoUrl: "",
                      email: user.email,
                      bio: "",
                      name: "",
                      phone: ""))));
        });
      } else {
        print("INSIDE ALREADY A USER");
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return DyneHomeScreen();
        }));
      }
    });
  }


}
