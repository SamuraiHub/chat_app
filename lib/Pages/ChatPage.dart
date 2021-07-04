import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chat_app/CustomUI/CustomCard.dart';
import 'package:chat_app/CustomUI/WindowButtons.dart';
import 'package:chat_app/Model/ChatModel.dart';
import 'package:chat_app/Model/GroupModel.dart';
import 'package:chat_app/Model/MessageModel.dart';
import 'package:chat_app/Pages/FriendsList.dart';
import 'package:chat_app/Pages/GroupPage.dart';
import 'package:chat_app/Pages/IndividualPage.dart';
import 'package:chat_app/Pages/profilePage.dart';
import 'package:chat_app/Screens/AddFriend.dart';
import 'package:chat_app/Screens/CreateGroup.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import '../User.dart';
import '../main.dart';

class ChatPage extends StatefulWidget {
  ChatPage({Key? key, required this.chatmodels, required this.sourchat})
      : super(key: key) {
    isHighlighted = List.filled(chatmodels.length, false, growable: true);
    if (isHighlighted.length > 0) isHighlighted[chatmodels.length - 1] = true;
  }
  final List<ChatModel> chatmodels;
  final User sourchat;
  late final List<bool> isHighlighted;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int selectedIndex = -1; // used to select chat room
  int actions =
      0; // used to select from a set of actions (chats, add friend, creeate group, view profile, logout)

  ScrollController _scrollController =
      ScrollController(); // controls the scroll of the friends and groups a user can choose from

  late IO.Socket socket;
  late Timer
      _everyMinute; // used to reconnect every minute as connection might get lost.

  @override
  void initState() {
    super.initState();

    selectedIndex = widget.chatmodels.length - 1;

    print('selectedIndex: $selectedIndex');

    socket = IO.io("https://muaz-chat.herokuapp.com/", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });

    socket.connect();

    socket.emit("signin", widget.sourchat.chatID);

    onConnect();

    // defines a timer that reconnects when socket is disconnected;
    /* _everyMinute = Timer.periodic(Duration(seconds: 1), (Timer t) {
      socket.onDisconnect((data) {
        print('Disconnected');
        socket.connect();

        socket.emit("signin", widget.sourchat.chatID);

        onConnect();
      });
    });*/
  }

  void onConnect() {
    // MessageModel messageModel = MessageModel(sourceId: widget.sourceChat.id.toString(),targetId: );

    socket.onConnect((data) {
      print("Connected");
      socket.on("receive_message", (jsonData) {
        print(jsonData);
        setIndividualMessage(jsonData['senderChatID'], jsonData['content']);
      });

      socket.on("receive_image", (jsonData) {
        print(jsonData);
        setIndividualImage(jsonData['senderChatID'], jsonData['content']);
      });

      socket.on("receive_group", (jsonData) {
        //print(jsonData);

        addNewGroup(
            jsonData['groupName'],
            jsonData['groupId'],
            jsonData['createdBy'],
            jsonData['groupMembers'],
            jsonData['groupMemberIds'],
            jsonData['userInside']);
      });

      socket.on("receive_group_message", (jsonData) {
        // print(jsonData);
        setGroupMessage(
            jsonData['senderChatID'], jsonData['groupID'], jsonData['content']);
      });

      socket.on("receive_group_image", (jsonData) {
        //print(jsonData);
        setGroupImage(
            jsonData['senderChatID'], jsonData['groupID'], jsonData['content']);
      });
    });
  }

  Future<void> setIndividualMessage(int senderID, String message) async {
    int destination = -1;

    for (int i = 0; i < widget.chatmodels.length; i++) {
      if (widget.chatmodels[i].isGroup == false &&
          widget.chatmodels[i].friend.chatID == senderID) {
        destination = i;
        break;
      }
    }

    if (destination == -1) {
      QueryBuilder queryBuilder = QueryBuilder<ParseUser>(ParseUser.forQuery())
        ..whereEqualTo('userID', senderID);

      var response1 = await queryBuilder.query();

      setState(() {
        widget.chatmodels.add(ChatModel(
            isGroup: false,
            friend: User(response1.results![0]['username'], senderID,
                response1.results![0]['EmailAddress'])));

        widget.isHighlighted.add(false);

        MessageModel messageModel = MessageModel(
            type: "destination",
            message: message,
            img: false,
            userName: response1.results![0]['username'],
            time: DateFormat('dd-MMMM-yyyy – hh:mm a').format(DateTime.now()));
        //print(messages);

        widget.chatmodels[widget.chatmodels.length - 1].messages
            .add(messageModel);

        if (selectedIndex != -1) widget.isHighlighted[selectedIndex] = false;

        widget.isHighlighted[widget.chatmodels.length - 1] = true;
        selectedIndex = widget.chatmodels.length - 1;
      });
    } else {
      setState(() {
        MessageModel messageModel = MessageModel(
            type: "destination",
            message: message,
            img: false,
            userName: widget.chatmodels[destination].friend.name,
            time: DateFormat('dd-MMMM-yyyy – hh:mm a').format(DateTime.now()));

        widget.chatmodels[destination].messages.add(messageModel);
        widget.chatmodels.add(widget.chatmodels.removeAt(destination));
        widget.isHighlighted[selectedIndex] = false;
        widget.isHighlighted[widget.chatmodels.length - 1] = true;
        selectedIndex = widget.chatmodels.length - 1;
      });
    }
  }

  Future<void> setIndividualImage(int senderID, String message) async {
    int destination = -1;

    for (int i = 0; i < widget.chatmodels.length; i++) {
      if (widget.chatmodels[i].isGroup == false &&
          widget.chatmodels[i].friend.chatID == senderID) {
        destination = i;
        break;
      }
    }

    if (destination == -1) {
      QueryBuilder queryBuilder = QueryBuilder<ParseUser>(ParseUser.forQuery())
        ..whereEqualTo('userID', senderID);

      var response1 = await queryBuilder.query();

      setState(() {
        widget.chatmodels.add(ChatModel(
            isGroup: false,
            friend: User(response1.results![0]['username'], senderID,
                response1.results![0]['EmailAddress'])));

        widget.isHighlighted.add(false);

        MessageModel messageModel = MessageModel(
            type: "destination",
            message: message,
            img: true,
            userName: response1.results![0]['username'],
            time: DateFormat('dd-MMMM-yyyy – hh:mm a').format(DateTime.now()));
        //print(messages);

        widget.chatmodels[widget.chatmodels.length - 1].messages
            .add(messageModel);

        if (selectedIndex != -1) widget.isHighlighted[selectedIndex] = false;

        widget.isHighlighted[widget.chatmodels.length - 1] = true;
        selectedIndex = widget.chatmodels.length - 1;
      });
    } else {
      setState(() {
        MessageModel messageModel = MessageModel(
            type: "destination",
            message: message,
            img: true,
            userName: widget.chatmodels[destination].friend.name,
            time: DateFormat('dd-MMMM-yyyy – hh:mm a').format(DateTime.now()));

        widget.chatmodels[destination].messages.add(messageModel);
        widget.chatmodels.add(widget.chatmodels.removeAt(destination));
        widget.isHighlighted[selectedIndex] = false;
        widget.isHighlighted[widget.chatmodels.length - 1] = true;
        selectedIndex = widget.chatmodels.length - 1;
      });
    }
  }

  void setGroupMessage(int senderID, int recieverID, String message) async {
    //print(messages);

    int destination = -1;

    for (int i = 0; i < widget.chatmodels.length; i++) {
      if (widget.chatmodels[i].isGroup == true &&
          widget.chatmodels[i].group.groupId == recieverID) {
        destination = i;
        break;
      }
    }

    MessageModel messageModel = MessageModel(
        type: "destination",
        message: message,
        userName: widget.chatmodels[destination].group.getUserName(senderID),
        img: false,
        time: DateFormat('dd-MMMM-yyyy – hh:mm a').format(DateTime.now()));

    setState(() {
      widget.chatmodels[destination].messages.add(messageModel);
      widget.chatmodels.add(widget.chatmodels.removeAt(destination));
      widget.isHighlighted[selectedIndex] = false;
      widget.isHighlighted[widget.chatmodels.length - 1] = true;
      selectedIndex = widget.chatmodels.length - 1;
    });
  }

  void setGroupImage(int senderID, int recieverID, String message) async {
    //print(messages);

    int destination = -1;

    for (int i = 0; i < widget.chatmodels.length; i++) {
      if (widget.chatmodels[i].isGroup == true &&
          widget.chatmodels[i].group.groupId == recieverID) {
        destination = i;
        break;
      }
    }

    MessageModel messageModel = MessageModel(
        type: "destination",
        message: message,
        userName: widget.chatmodels[destination].group.getUserName(senderID),
        img: true,
        time: DateFormat('dd-MMMM-yyyy – hh:mm a').format(DateTime.now()));

    setState(() {
      widget.chatmodels[destination].messages.add(messageModel);
      widget.chatmodels.add(widget.chatmodels.removeAt(destination));
      widget.isHighlighted[selectedIndex] = false;
      widget.isHighlighted[widget.chatmodels.length - 1] = true;
      selectedIndex = widget.chatmodels.length - 1;
    });
  }

  // adds a new group chat to existing chat models
  void addNewGroup(
      String groupName,
      int groupId,
      String createdBy,
      List<dynamic> groupMembers,
      List<dynamic> groupMemberIds,
      List<dynamic> userInside) {
    setState(() {
      widget.chatmodels.add(ChatModel(
          isGroup: true,
          group: GroupModel(
              groupName: groupName, groupId: groupId, createdBy: createdBy)));

      widget.isHighlighted.add(false);

      widget.chatmodels[widget.chatmodels.length - 1].group.groupMembers =
          groupMembers.cast<String>();

      widget.chatmodels[widget.chatmodels.length - 1].group.groupMemberIds =
          groupMemberIds.cast<int>();
      widget.chatmodels[widget.chatmodels.length - 1].group.userInside =
          userInside.cast<bool>();

      if (selectedIndex != -1) widget.isHighlighted[selectedIndex] = false;

      widget.isHighlighted[widget.chatmodels.length - 1] = true;
      selectedIndex = widget.chatmodels.length - 1;
    });
  }

  // shows error message
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

  // user logout
  Future<void> doLogout() async {
    final user = await ParseUser.currentUser();
    var response = await user.logout();
    if (response.success) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => MyApp()));
    } else {
      showError(response.error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 350,
          child: actions == 1
              ? AddFriend(
                  sourchat: widget.sourchat,
                  chatmodels: widget.chatmodels,
                  back: () {
                    setState(() {
                      actions = 0;
                      if (selectedIndex != -1) {
                        widget.isHighlighted[selectedIndex] = false;
                      }
                      if (widget.chatmodels.length >
                          widget.isHighlighted.length) {
                        int d = widget.chatmodels.length -
                            widget.isHighlighted.length;

                        widget.isHighlighted.addAll(List.filled(d, false));

                        selectedIndex = widget.chatmodels.length - 1;
                        widget.isHighlighted[selectedIndex] = true;
                      }
                    });
                  })
              : actions == 2
                  ? CreateGroup(
                      chatmodels: widget.chatmodels,
                      sourchat: widget.sourchat,
                      socket: socket,
                      back: () {
                        setState(() {
                          actions = 0;
                          if (selectedIndex != -1) {
                            widget.isHighlighted[selectedIndex] = false;
                          }
                          if (widget.chatmodels.length >
                              widget.isHighlighted.length) {
                            widget.isHighlighted.add(true);

                            selectedIndex = widget.chatmodels.length - 1;
                          }
                        });
                      })
                  : actions == 3
                      ? FriendsList(
                          chatmodels: widget.chatmodels,
                          back: () {
                            setState(() {
                              actions = 0;
                            });
                          })
                      : actions == 4
                          ? profilePage(
                              sourchat: widget.sourchat,
                              back: () {
                                setState(() {
                                  actions = 0;
                                });
                              })
                          : Scaffold(
                              appBar: AppBar(
                                title: Text(
                                  widget.sourchat.name,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                                actions: [
                                  PopupMenuButton<String>(
                                    padding: EdgeInsets.all(0),
                                    onSelected: (value) {
                                      if (value == 'AF') {
                                        setState(() {
                                          actions = 1;
                                        });
                                      } else if (value == 'NG') {
                                        setState(() {
                                          actions = 2;
                                        });
                                      } else if (value == 'VF') {
                                        setState(() {
                                          actions = 3;
                                        });
                                      } else if (value == 'VP') {
                                        setState(() {
                                          actions = 4;
                                        });
                                      } else {
                                        doLogout();
                                      }
                                    },
                                    itemBuilder: (BuildContext contesxt) {
                                      return [
                                        PopupMenuItem(
                                          child: Text('Add Friends'),
                                          value: "AF",
                                        ),
                                        PopupMenuItem(
                                          child: Text('New Group'),
                                          value: 'NG',
                                        ),
                                        PopupMenuItem(
                                          child: Text('View Friends'),
                                          value: 'VF',
                                        ),
                                        PopupMenuItem(
                                          child: Text('View Profile'),
                                          value: 'VP',
                                        ),
                                        PopupMenuItem(
                                          child: Text('Log out'),
                                          value: 'LO',
                                        ),
                                      ];
                                    },
                                  ),
                                ],
                              ),
                              body: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      itemCount: widget.chatmodels.length,
                                      itemBuilder: (context, index) =>
                                          CustomCard(
                                              chatModel:
                                                  widget.chatmodels[index],
                                              isHighlighted:
                                                  widget.isHighlighted[index],
                                              onTap: () {
                                                setState(() {
                                                  if (selectedIndex != -1) {
                                                    widget.isHighlighted[
                                                        selectedIndex] = false;
                                                  }
                                                  widget.isHighlighted[index] =
                                                      true;
                                                  selectedIndex = index;
                                                });
                                              }),
                                    ),
                                  ),
                                ],
                              ),
                            ),
        ),
        Expanded(
            child: selectedIndex == -1
                ? Container()
                : widget.chatmodels[selectedIndex].isGroup
                    ? new GroupPage(
                        chatModel: widget.chatmodels[selectedIndex],
                        sourchat: widget.sourchat,
                        socket: socket,
                        onGroupNameChanged: () {
                          setState(() {});
                        },
                      )
                    : new IndividualPage(
                        chatModel: widget.chatmodels[selectedIndex],
                        sourchat: widget.sourchat,
                        socket: socket))
      ],
    );
  }
}
