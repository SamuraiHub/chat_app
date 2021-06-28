import 'package:chat_app/Model/ChatModel.dart';
import 'package:chat_app/Model/GroupModel.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../User.dart';
import 'Homescreen.dart';

class CreateGroup extends StatefulWidget {
  CreateGroup(
      {Key? key,
      required this.chatmodels,
      required this.sourchat,
      required this.socket,
      required this.back})
      : super(key: key);

  final List<ChatModel> chatmodels;
  final User sourchat;
  final IO.Socket socket;
  final VoidCallback back;

  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final controllerGroupname = TextEditingController();
  final List<User> Users = List.filled(0, User('', 0, ''), growable: true);
  final selectedUsers = List.filled(0, User('', 0, ''), growable: true);
  late final List<bool> selected;
  String usersText = '';

  Future<void> getUsers() async {
    QueryBuilder queryBuilder = QueryBuilder<ParseUser>(ParseUser.forQuery())
      ..whereNotEqualTo('userID', widget.sourchat.chatID);

    var response1 = await queryBuilder.query();

    if (response1.success) {
      setState(() {
        for (int i = 0; i < response1.results!.length; i++) {
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
          'New Group',
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
                    left: 15.0, right: 15.0, top: 30, bottom: 0),
                child: TextField(
                    controller: controllerGroupname,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Group Name',
                        hintText: 'Enter group name'))),
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 25, bottom: 0),
              child: Text(
                'Select Users (to add to group):',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15.0, bottom: 0),
              child: SizedBox(
                height: 200,
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
                  CreateGroup().then((value) {
                    if (value) {
                      showSuccess("Group Successfully Added");
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
                  'Create Group',
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
  Future<bool> CreateGroup() async {
    var group = ParseObject('Groups');

    QueryBuilder<ParseObject> GroupQuery = QueryBuilder<ParseObject>(group)
      ..orderByDescending('groupId');

    int maxUserId = 0;

    bool groupNameExists = false;

    var apiResponse = await GroupQuery.query();
    if (apiResponse.success && apiResponse.result != null) {
      //print(apiResponse.results![0]);
      maxUserId = apiResponse.results![0]['groupId'];
      //print(countUsers);
      for (int i = 0; i < apiResponse.results!.length; i++) {
        if (apiResponse.results![i]['groupName'] ==
            controllerGroupname.text.toLowerCase()) {
          groupNameExists = true;
        }
      }
    }

    if (controllerGroupname.text == '') {
      showError('Group Name cannot be empty');
      return false;
    } else if (groupNameExists) {
      showError('Group Name already exists. Please type a different  one');
      return false;
    } else {
      var groupid = group
        ..set('groupName', controllerGroupname.text.toLowerCase())
        ..set('createdBy', widget.sourchat.chatID)
        ..set('groupId', maxUserId + 1);
      var response = await groupid.save();

      if (response.success) {
        selectedUsers.insert(0, widget.sourchat);
        List<String> groupMembers = List.generate(
            selectedUsers.length, (index) => selectedUsers[index].name);
        List<int> groupMemberIds = List.generate(
            selectedUsers.length, (index) => selectedUsers[index].chatID);
        List<bool> userInside =
            List.filled(selectedUsers.length, true, growable: true);

        widget.chatmodels.add(ChatModel(
            isGroup: true,
            group: GroupModel(
                createdBy: widget.sourchat.name,
                groupId: maxUserId + 1,
                groupName: controllerGroupname.text.toLowerCase())));

        widget.chatmodels[widget.chatmodels.length - 1].group.groupMembers =
            groupMembers;
        widget.chatmodels[widget.chatmodels.length - 1].group.groupMemberIds =
            groupMemberIds;
        widget.chatmodels[widget.chatmodels.length - 1].group.userInside =
            userInside;

        for (int i = 0; i < selectedUsers.length; i++) {
          var user = ParseObject('userGroups')
            ..set('groupId', maxUserId + 1)
            ..set('userID', selectedUsers[i].chatID)
            ..set('userInside', true);
          response = await user.save();
          if (!response.success) {
            break;
          } else {
            if (i > 0)
              widget.socket.emit("send_group", <String, dynamic>{
                'receiverChatID': selectedUsers[i].chatID,
                'groupName': controllerGroupname.text.toLowerCase(),
                'groupId': maxUserId + 1,
                'createdBy': widget.sourchat.name,
                'groupMembers': groupMembers,
                'groupMemberIds': groupMemberIds,
                'userInside': userInside,
              });
          }
        }

        if (!response.success) {
          showError(response.error!.message);
          return false;
        }
      } else {
        showError(response.error!.message);
        return false;
      }
    }

    return true;
  }
}
