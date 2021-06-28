import 'package:chat_app/Model/ChatModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../User.dart';

class GroupInfo extends StatefulWidget {
  GroupInfo(
      {Key? key,
      required this.chatModel,
      required this.sourchat,
      required this.back})
      : super(key: key);
  final ChatModel chatModel;
  final User sourchat;
  final VoidCallback back;

  @override
  _GroupInfoState createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Widget getGroupUsers() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.chatModel.group.groupMembers.length,
      itemBuilder: (context, index) {
        return Center(
            child: Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                child: Text(
                  widget.chatModel.group.groupMembers[index],
                  style: TextStyle(fontSize: 25),
                )));
      },
    );
  }

  // check weither new group exits. Used before changing group name.
  Future<bool> newGroupNameExists() async {
    var group = ParseObject('Groups');
    QueryBuilder querybuilder = QueryBuilder(group)
      ..whereEqualTo('groupName', _controller.text);

    var response = await querybuilder.query();

    if (response.success && response.results != null) {
      return true;
    }

    return false;
  }

  // check weither new group exits. Used before changing group name.
  Future<bool> saveNewGroup() async {
    var group = ParseObject('Groups');
    QueryBuilder querybuilder = QueryBuilder(group)
      ..whereEqualTo('groupName', widget.chatModel.group.groupName);

    var response = await querybuilder.query();

    if (response.success) {
      var newGroupName = ParseObject('Groups')
        ..objectId = response.results![0]['objectId']
        ..set('groupName', _controller.text);

      var response1 = await newGroupName.save();

      if (response1.success) return true;
    }

    return false;
  }

  // shows error message where applicable
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

  bool editGroupName = false; // for editing group name

  TextEditingController _controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.chatModel.group.groupName;
    print(widget.chatModel.group.createdBy);
    print(widget.sourchat.name);
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
          'Group Info',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
                left: 15.0, right: 15.0, top: 30, bottom: 0),
            child: Text(
              'Group Name',
              style: TextStyle(fontSize: 25),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 15.0, right: 15.0, top: 15, bottom: 0),
            child: widget.chatModel.group.createdBy ==
                    widget.sourchat.name.toLowerCase()
                ? editGroupName
                    ? TextField(
                        controller: _controller,
                        style: TextStyle(fontSize: 25),
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(Icons.check),
                            onPressed: () {
                              setState(() {
                                bool ngne = true;

                                if (!_controller.text.isEmpty &&
                                    _controller.text !=
                                        widget.chatModel.group.groupName) {
                                  newGroupNameExists().then((value) {
                                    ngne = value;

                                    if (!ngne) {
                                      saveNewGroup().then((value) {
                                        if (value) {
                                          widget.chatModel.group.groupName =
                                              _controller.text;
                                        }
                                      });
                                    } else {
                                      showError(
                                          'New Group Name Exits. Please change to aifferent group name');
                                    }

                                    editGroupName = false;
                                  });
                                } else {
                                  editGroupName = false;
                                }
                              });
                            },
                          ),
                        ))
                    : ListTile(
                        title: Text(
                          widget.chatModel.group.groupName,
                          style: TextStyle(fontSize: 25),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            setState(() {
                              editGroupName = true;
                            });
                          },
                        ),
                      )
                : Text(
                    widget.chatModel.group.groupName,
                    style: TextStyle(fontSize: 25),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 15.0, right: 15.0, top: 30, bottom: 0),
            child: Text(
              'Group Participants',
              style: TextStyle(fontSize: 25),
            ),
          ),
          getGroupUsers(),
        ],
      ),
    );
  }
}
