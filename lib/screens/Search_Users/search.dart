import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../resources/repository.dart';
import '../../screens/Profile_Page/friend_profile.dart';
import 'package:provider/provider.dart';

/*This widget is used to search for users on the app*/

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  var _repository = Repository();
  var _isInit = true;
  var _isLoading = false;

  List<User> usersList = List<User>();
  List<User> friends = List<User>();

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      _repository = Provider.of<Repository>(context, listen: true);

      _repository.getAndSetCurrentUser().then((_) {
        print("USER : ${_repository.user().displayName}");
        _repository
            .fetchAllUsersWithUser(_repository.user())
            .then((updatedList) => setState(() {
          usersList = updatedList;
          _isLoading = false;
        }));
      });

      _repository.getAndSetCurrentUser().then((_) {
        _repository.fetchFriendsUidsWithUser(_repository.user()).then(
                (friendUids) => _repository
                .fetchAllUsersInFriends(friendUids)
                .then((listOfFriends) => setState(() {
              friends = listOfFriends;
              _isLoading = false;
            })));
      });

      _isInit = false;
      super.didChangeDependencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.red[900]),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            'Search Friends',
            style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 25,
                fontWeight: FontWeight.w300),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.red[900],
              ),
              onPressed: () {
                showSearch(
                    context: context,
                    delegate: UserSearch(hintText: "Search All Users",usersList: usersList));
              },
            )
          ],
        ),
        body: _isLoading
            ? Center(child: const CircularProgressIndicator())
            : ListView.builder(
          itemCount: friends.length,
          itemBuilder: ((context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () => showProfile(
                  context,
                  displayName: friends[index].displayName,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                    NetworkImage(friends[index].photoUrl),
                  ),
                  title: Text(friends[index].displayName),
                ),
              ),
            );
          }),
        ));
  }
}

class UserSearch extends SearchDelegate<String> {
  List<User> usersList;

  UserSearch({String hintText, this.usersList})
      : super(
    searchFieldLabel: hintText,
    searchFieldStyle: TextStyle(
        fontFamily: "Poppins",
        fontSize: 25,
        fontWeight: FontWeight.w300),
    keyboardType: TextInputType.text,
    textInputAction: TextInputAction.search,
  );

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(
          Icons.clear,
          color: Colors.red[900],
        ),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<User> emptyList = List<User>();

    final List<User> suggestionsList = query.isEmpty
        ? emptyList
        : usersList.where((p) => p.displayName.toLowerCase().startsWith(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: suggestionsList.length,
      itemBuilder: ((context, index) => ListTile(
        onTap: () => showProfile(
          context,
          displayName: suggestionsList[index].displayName,
        ),
        leading: CircleAvatar(
          backgroundImage: (suggestionsList[index].photoUrl == null ||
              suggestionsList[index].photoUrl.isEmpty)
              ? AssetImage('assets/no_image.png')
              : NetworkImage(suggestionsList[index].photoUrl),
        ),
        title: Text(suggestionsList[index].displayName),
      )),
    );
  }
}

showProfile(BuildContext context, {@required String displayName}) {
  if (displayName == null) {
    print('no display name, null');
  }
  print('display name: $displayName');
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => FriendProfileScreen(name: displayName)));
}
