import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

/*This abstract class defines the user type, and manages some JSON to User
* conversions and visa versa*/

class User {
  String uid;
  String email;
  String photoUrl;
  String displayName;
  String bio;
  GeoPoint lastLocation;
  Timestamp lastTime;
  String phone;
  String referralUid;

  User({
    @required this.uid,
    @required this.email,
    this.photoUrl,
    @required this.displayName,
    this.bio,
    this.lastLocation,
    this.lastTime,
    this.phone,
    this.referralUid = "",
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      uid: doc.get('uid'),
      email: doc.get('email'),
      photoUrl: doc.get('photoUrl'),
      displayName: doc.get('displayName'),
      bio: doc.get('bio'),
      lastLocation: doc.get('lastLocation'),
      lastTime: doc.get('lastTime'),
      phone: doc.get('phone'),
      referralUid: doc.get('referralUid'),
    );
  }

  Map<String, dynamic> toMap(User user) {
    return {
      'uid': user.uid,
      'email': user.email,
      'photoUrl': user.photoUrl,
      'displayName': user.displayName,
      'bio': user.bio,
      'lastLocation': user.lastLocation,
      'lastTime': user.lastTime,
      'phone': user.phone,
      'referralUid': user.referralUid
    };
  }

  User.fromMap(Map<String, dynamic> mapData) {
    uid = mapData['uid'];
    email = mapData['email'];
    photoUrl = mapData['photoUrl'];
    displayName = mapData['displayName'];
    bio = mapData['bio'];
    lastTime = mapData['lastTime'];
    lastLocation = mapData['lastLocation'];
    phone = mapData['phone'];
    referralUid = mapData['referralUid'];
  }
}
