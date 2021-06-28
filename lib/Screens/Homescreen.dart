import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chat_app/CustomUI/WindowButtons.dart';
import 'package:chat_app/Model/ChatModel.dart';
import 'package:chat_app/Model/GroupModel.dart';
import 'package:chat_app/Model/MessageModel.dart';
import 'package:chat_app/Pages/ChatPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../User.dart';
import '../main.dart';

class Homescreen extends StatelessWidget {
  Homescreen({Key? key, required this.sourchat}) : super(key: key);

  final User sourchat;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Login',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Scaffold(
            body: WindowBorder(
                color: Color(0xFF805306),
                width: 1,
                child: Column(children: <Widget>[
                  Container(
                    height: 35,
                    color: Colors.blue,
                    child: WindowTitleBarBox(
                        child: Row(children: [
                      Expanded(
                          child: MoveWindow(
                              child: Row(
                        children: <Widget>[
                          Image.asset(
                            'assets/icons8-chat-96.jpg',
                            scale: 0.5,
                          ),
                          Text(
                            'Chat App',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          )
                        ],
                      ))),
                      WindowButtons()
                    ])),
                  ),
                  Expanded(
                    child: homescreen(sourchat: sourchat),
                  )
                ]))));
  }
}

class homescreen extends StatefulWidget {
  homescreen({Key? key, required this.sourchat}) : super(key: key);
  final List<ChatModel> chatmodels =
      List.filled(0, ChatModel(isGroup: false), growable: true);

  final User sourchat;

  @override
  _HomescreenState createState() => _HomescreenState();
}

class _HomescreenState extends State<homescreen>
    with SingleTickerProviderStateMixin {
  Widget chatPage = Container();

  @override
  void initState() {
    super.initState();

    getFriendsAndMessages().then((value) {
      if (value) {
        getGroupsAndMessages().then((value) {
          if (value) {
            setState(() {
              chatPage = ChatPage(
                chatmodels: widget.chatmodels,
                sourchat: widget.sourchat,
              );
            });
          }
        });
      }
      ;
    });
  }

  // gets friends and messages from friends of the user.
  Future<bool> getFriendsAndMessages() async {
    var queryBuilder = QueryBuilder(ParseObject('Friends'))
      ..whereEqualTo('User', widget.sourchat.chatID);

    var response = await queryBuilder.query();

    if (response.success) {
      if (response.results != null) {
        for (int i = 0; i < response.results!.length; i++) {
          queryBuilder = QueryBuilder<ParseUser>(ParseUser.forQuery())
            ..whereEqualTo('userID', response.results![i]['Friend']);

          var response1 = await queryBuilder.query();

          //setState(() {
          widget.chatmodels.add(ChatModel(
              isGroup: false,
              friend: User(
                  response1.results![0]['username'],
                  response.results![i]['Friend'],
                  response1.results![0]['EmailAddress'])));
          //});

          var queryBuilder1 = QueryBuilder(ParseObject('Messages'))
            ..whereEqualTo('SourceId', widget.sourchat.chatID)
            ..whereEqualTo('DestinationId', response.results![i]['Friend']);

          var queryBuilder2 = QueryBuilder(ParseObject('Messages'))
            ..whereEqualTo('DestinationId', widget.sourchat.chatID)
            ..whereEqualTo('SourceId', response.results![i]['Friend']);

          queryBuilder = QueryBuilder.or(
            ParseObject('Messages'),
            [queryBuilder1, queryBuilder2],
          )..orderByAscending('createdAt');

          var response2 = await queryBuilder.query();

          if (response2.success && response2.results != null) {
            //setState(() {
            for (int j = 0; j < response2.results!.length; j++) {
              String m = response2.results![j]['Message'];

              if (response2.results![j]['SourceId'] == widget.sourchat.chatID) {
                widget.chatmodels[i].messages.add(MessageModel(
                    message:
                        m == '' ? response2.results![j]['Image']['url'] : m,
                    type: 'Source',
                    userName: widget.sourchat.name,
                    img: m == '',
                    time: DateFormat('dd-MMMM-yyyy – hh:mm a')
                        .format(response2.results![j]['createdAt'])));
              } else {
                widget.chatmodels[i].messages.add(MessageModel(
                    message:
                        m == '' ? response2.results![j]['Image']['url'] : m,
                    type: 'Destination',
                    userName: response1.results![0]['username'],
                    img: m == '',
                    time: DateFormat('dd-MMMM-yyyy – hh:mm a')
                        .format(response2.results![j]['createdAt'])));
              }
            }
            // });
          }
        }
      }
      return true;
    } else {
      print(response.error!.message);
      return false;
    }
  }

  // gets groups and messages from groups of the user.
  Future<bool> getGroupsAndMessages() async {
    var queryBuilder = QueryBuilder(ParseObject('userGroups'))
      ..whereEqualTo('userID', widget.sourchat.chatID);

    var response = await queryBuilder.query();

    if (response.success) {
      if (response.results != null) {
        for (int i = 0; i < response.results!.length; i++) {
          if (response.results![i]['userInside'] == true) {
            queryBuilder = QueryBuilder(ParseObject('Groups'))
              ..whereEqualTo('groupId', response.results![i]['groupId']);

            var response1 = await queryBuilder.query();

            queryBuilder = QueryBuilder<ParseUser>(ParseUser.forQuery())
              ..whereEqualTo('userID', response1.results![0]['createdBy']);

            var response3 = await queryBuilder.query();

            //setState(() {
            widget.chatmodels.add(ChatModel(
                isGroup: true,
                group: GroupModel(
                    groupId: response1.results![0]['groupId'],
                    groupName: response1.results![0]['groupName'],
                    createdBy: response3.results![0]['username'])));

            // });

            queryBuilder = QueryBuilder(ParseObject('userGroups'))
              ..whereEqualTo('groupId', response.results![i]['groupId']);

            var response0 = await queryBuilder.query();

            if (response0.success) {
              for (int j = 0; j < response0.results!.length; j++) {
                widget.chatmodels[widget.chatmodels.length - 1].group
                    .groupMemberIds
                    .add(response0.results![j]['userID']);

                widget.chatmodels[widget.chatmodels.length - 1].group.userInside
                    .add(response0.results![j]['userInside']);

                queryBuilder = QueryBuilder<ParseUser>(ParseUser.forQuery())
                  ..whereEqualTo('userID', response0.results![j]['userID']);

                response3 = await queryBuilder.query();

                widget
                    .chatmodels[widget.chatmodels.length - 1].group.groupMembers
                    .add(response3.results![0]['username']);
              }
            }

            queryBuilder = QueryBuilder(ParseObject('GroupMessages'))
              ..whereEqualTo('GroupId', response.results![i]['groupId'])
              ..orderByAscending('createdAt');

            var response2 = await queryBuilder.query();

            if (response2.success && response2.results != null) {
              //setState(() {
              for (int j = 0; j < response2.results!.length; j++) {
                String m = response2.results![j]['Message'];

                if (response2.results![j]['SourceId'] ==
                    widget.sourchat.chatID) {
                  widget.chatmodels[widget.chatmodels.length - 1].messages.add(
                      MessageModel(
                          message: m == ''
                              ? response2.results![j]['Image']['url']
                              : m,
                          type: 'Source',
                          userName: widget.sourchat.name,
                          img: m == '',
                          time: DateFormat('dd-MMMM-yyyy – hh:mm a')
                              .format(response2.results![j]['createdAt'])));
                } else {
                  widget.chatmodels[widget.chatmodels.length - 1].messages.add(
                      MessageModel(
                          message: m == ''
                              ? response2.results![j]['Image']['url']
                              : m,
                          type: 'Destination',
                          userName: widget
                              .chatmodels[widget.chatmodels.length - 1].group
                              .getUserName(response2.results![j]['SourceId']),
                          img: m == '',
                          time: DateFormat('dd-MMMM-yyyy – hh:mm a')
                              .format(response2.results![j]['createdAt'])));
                }
              }
              //});
            }
          }
        }
      }
      return true;
    } else {
      print(response.error!.message);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return chatPage;
  }
}
