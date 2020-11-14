import 'package:flutter/material.dart';

/*This widget is used to display a set of introductory tidbits about the app
* before the user signs in thus letting the user know about the app before needing
* to sign in.*/
class EntryVisual extends StatelessWidget {
  final String h1Text;
  final String h2Text;
  final String imgLink;
  final double scalar;
  final bool gradient;

  EntryVisual(
      {@required this.imgLink,
      @required this.h1Text,
      @required this.h2Text,
      this.scalar = 1.0,
      this.gradient = false});

  // ignore: missing_return
  BoxDecoration _createGradient(BuildContext context) {
    if (!gradient) {
      return BoxDecoration(color: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 55, 0, 0),
      decoration: _createGradient(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Image(
              image: AssetImage(
                this.imgLink,
              ),
              height: 300.0 * scalar,
              width: 300.0 * scalar,
            ),
          ),
          SizedBox(height: 12.0 / (scalar / 2)),
          Text(
            this.h1Text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            this.h2Text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
