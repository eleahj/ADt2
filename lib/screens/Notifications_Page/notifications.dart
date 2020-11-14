import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/user.dart';
import '../../resources/repository.dart';
import '../../screens/Profile_Page/friend_profile.dart';
import '../../widgets/progress.dart';

/*This screen is used to display the notifications of the app, from adding
* friends to meet-up information to eventual coupon and restaurant offers*/

final activityFeedRef = FirebaseFirestore.instance.collection('feed');

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  User _user;

  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      final _repository = Provider.of<Repository>(context, listen: false);
      _repository.getAndSetCurrentUser().then((_) => setState(() {
        _user = _repository.user();
        _isLoading = false;
        print(_user.email);
      }));
      _isInit = false;
      super.didChangeDependencies();
    }
  }

  Future<List<ActivityFeedItem>> getActivityFeed() async {
    return await activityFeedRef
        .doc(_user.uid)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get()
        .then((snapshot) {
      List<ActivityFeedItem> feedItems = [];
      snapshot.docs.forEach((value) {
        feedItems.add(ActivityFeedItem.fromDocument(value));
      });
      return feedItems;
    });
  }

  Future<int> getActivityFeedCount() async {
    return await activityFeedRef
        .doc(_user.uid)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get()
        .then((snapshot) {
      List<ActivityFeedItem> feedItems = [];
      snapshot.docs.forEach((doc) {
        feedItems.add(ActivityFeedItem.fromDocument(doc));
        // print('Activity Feed Item: ${doc.data}');
      });
      return feedItems.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.fromLTRB(0, 35.0, 0, 0),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: new Container(),
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            'Notifications',
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
            : Container(
            height: MediaQuery.of(context).size.height,
            child: FutureBuilder(
              future: getActivityFeed(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return circularProgress();
                }
                return ListView(
                  children: snapshot.data,
                );
              },
            )),
      ),
    );
  }
}

Widget mediaPreview;
String activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String displayName;
  final String hostId;
  final String userId;
  final String userProfileImg;
  final Timestamp timestamp;

  ActivityFeedItem({
    this.displayName,
    this.hostId,
    this.userId,
    this.userProfileImg,
    this.timestamp,
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      displayName: doc.data()['displayName'],
      hostId: doc.data()['hostId'],
      userId: doc.data()['userId'],
      userProfileImg: doc.data()['userProfileImg'],
      timestamp: doc.data()['timestamp'],
    );
  }


  configureMediaPreview(context) {

      mediaPreview = GestureDetector(
        onTap: () => showProfile(context, displayName: displayName),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                child: Icon(Icons.person),
              )),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: () => showProfile(context, displayName: displayName),
            child: RichText(
              overflow: TextOverflow.visible,
              text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: displayName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: " added you as a friend",
                    ),
                  ]),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: (userProfileImg == null ||
                userProfileImg.isEmpty)
                ? AssetImage('assets/no_image.png')
                :CachedNetworkImageProvider(userProfileImg),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}

showProfile(BuildContext context, {String displayName}) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => FriendProfileScreen(name: displayName)));
}
