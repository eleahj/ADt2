import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import './models/const.dart';
import './resources/repository.dart';
import './screens/Home_Page_Controller/home.dart';
import './screens/Onboarding_Pages/onboarding.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatefulWidget {
  MyApp();
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  /*Repository is the wrapper of the Firebase Provider Class, which provides most
  * general database logic, including those related to user creation/edit,
  * meet-ups, managing friends, chats, and for almost all asynchronous code
  * portions in the app*/
  var _repository = Repository();

  @override
  Widget build(BuildContext context) {
    /*The MultiProvider is used to provide lateral access to all of its
    * components for all point's in the widget's subtree. This subtree is the
    * whole app in this case as the main widget is the root of the widget tree.
    * These providers are the way to access data as an alternative to a
    * pass-by-reference */
    return MultiProvider(
      providers: [
        /*Change Notifier allows for any objects which are instantiated in them
        * to be referenced and accessed atomically by all widgets which
        * instantiate them. */
        ChangeNotifierProvider<Repository>(
          /*This is mostly used to refer to the current user of the app,
          * giving access to friends, meet-ups, and general auth*/
          create: (_) => Repository(),
        ),
      ],
      child: Consumer<Repository>(
        builder: (context, auth, child) => MaterialApp(
          title: Constants.appName,
          debugShowCheckedModeBanner: false,
          theme: Constants.lightTheme,
          home: FutureBuilder(
            future: _repository.getCurrentUser(),
            builder: (context, AsyncSnapshot<User> snapshot) {
              if (snapshot.hasData) {
                return DyneHomeScreen(); // if the user is signed in go to the
                // main screen of the app
              } else {
                return OnboardingScreen(); //on boarding of the user when they are
                //not logged in
              }
            },
          ),
        ),
      ),
    );
  }
}
