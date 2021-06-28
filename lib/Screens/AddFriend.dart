import 'package:chat_app/Model/ChatModel.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../User.dart';

class AddFriend extends StatefulWidget {
  AddFriend(
      {Key? key,
      required this.chatmodels,
      required this.sourchat,
      required this.back})
      : super(key: key);

  final List<ChatModel> chatmodels;
  final User sourchat;
  final VoidCallback back;

  @override
  _AddFriendState createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  final List<User> Users = List.filled(0, User('', 0, ''), growable: true);
  final selectedUsers = List.filled(0, User('', 0, ''), growable: true);
  late final List<bool> selected;
  String usersText = '';

  Future<void> getUsers() async {
    var friend = ParseObject('Friends');

    QueryBuilder<ParseObject> FriendQuery = QueryBuilder<ParseObject>(friend)
      ..whereEqualTo('User', widget.sourchat.chatID);

    QueryBuilder queryBuilder = QueryBuilder<ParseUser>(ParseUser.forQuery())
      ..whereDoesNotMatchKeyInQuery('userID', 'Friend', FriendQuery);

    var response1 = await queryBuilder.query();

    if (response1.success) {
      setState(() {
        for (int i = 0; i < response1.results!.length; i++) {
          if (response1.results![i]['userID'] != widget.sourchat.chatID)
            Users.add(User(
                response1.results![i]['username'],
                response1.results![i]['userID'],
                response1.results![i]['EmailAddress']));
        }
        selected = List.filled(Users.length, false);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    getUsers();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => widget.back(),
        ),
        title: Text(
          'Add Friends',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 25, bottom: 0),
              child: Text(
                'Select Friends:',
                style: TextStyle(fontSize: 30),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15.0, bottom: 0),
              child: SizedBox(
                height: 200.0,
                width: 250,
                child: ListView.builder(
                  itemCount: Users.length,
                  itemBuilder: (context, index) => ListTile(
                      title: Text(
                        (Users[index].name),
                        style: selected[index]
                            ? TextStyle(
                                fontSize: 18,
                                color: Colors.blue.shade500,
                                fontWeight: FontWeight.bold,
                              )
                            : TextStyle(fontSize: 18),
                      ),
                      trailing: selected[index]
                          ? Icon(Icons.check,
                              color: Colors.blue.shade500, size: 26)
                          : null,
                      onTap: () {
                        setState(() {
                          selected[index] = !selected[index];
                          if (selected[index]) {
                            selectedUsers.add(Users[index]);
                          } else
                            selectedUsers.remove(Users[index]);

                          usersText =
                              selectedUsers.map((User) => User.name).join(', ');
                        });
                      }),
                ),
              ),
            ),
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              child: Text(
                'Selected Users',
                style: TextStyle(fontSize: 25),
              ),
            ),
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              child: Text(
                usersText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 25),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                onPressed: () {
                  AddFriends().then((success) {
                    if (success) {
                      showSuccess("Friends Successfully Added");
                    }
                  });
                  /*Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => Groups(
                              chatmodels: widget.chatmodels,
                              sourchat: widget.sourchat)))*/
                  ;
                },
                child: Text(
                  'Add Friends',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
          ]),
    );
  }

  void showSuccess(String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success!"),
          content: Text(message),
          actions: <Widget>[
            new TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                widget.back();
              },
            )
          ],
        );
      },
    );
  }

  void showError(String errorMessage) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error!"),
          content: Text(errorMessage),
          actions: <Widget>[
            new TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // creates the group specified. shows an error message if something is wrong. else shows that it was successful
  Future<bool> AddFriends() async {
    var response;

    for (int i = 0; i < selectedUsers.length; i++) {
      var addFriend = ParseObject('Friends')
        ..set('User', widget.sourchat.chatID)
        ..set('Friend', selectedUsers[i].chatID);
      response = await addFriend.save();

      print(widget.sourchat.chatID);
      print(selectedUsers[i].chatID);

      if (response.success) {
        addFriend = ParseObject('Friends')
          ..set('User', selectedUsers[i].chatID)
          ..set('Friend', widget.sourchat.chatID);
        response = await addFriend.save();

        print(selectedUsers[i].chatID);
        print(widget.sourchat.chatID);

        widget.chatmodels.add(ChatModel(
            isGroup: false,
            friend: User(selectedUsers[i].name, selectedUsers[i].chatID,
                selectedUsers[i].email)));
      }

      if (!response.success) break;
    }
    if (!response.success) {
      showError(response.error!.message);
      return false;
    }
    return true;
  }
}
