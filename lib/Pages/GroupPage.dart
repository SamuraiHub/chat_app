import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chat_app/CustomUI/GroupReplyCard.dart';
import 'package:chat_app/CustomUI/OwnMessgaeCrad.dart';
import 'package:chat_app/CustomUI/ReplyCard.dart';
import 'package:chat_app/Model/ChatModel.dart';
import 'package:chat_app/Model/MessageModel.dart';
import 'package:flutter_emoji_suite/flutter_emoji_suite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:chat_app/CustomUI/input_widget.dart';

import '../User.dart';
import 'GroupInfo.dart';

class GroupPage extends StatefulWidget {
  GroupPage(
      {Key? key,
      required this.chatModel,
      required this.sourchat,
      required this.socket})
      : super(key: key);
  final ChatModel chatModel;
  final User sourchat;
  final IO.Socket socket;

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  FocusNode focusNode = FocusNode();

  List<MessageModel> messages = [];
  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool isEmojiVisible = false;
  bool viewGroupInfo = false;

  @override
  void initState() {
    super.initState();

    messages = widget.chatModel.messages;

    if (_scrollController.hasClients)
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  Widget Messages() {
    return ListView.builder(
      shrinkWrap: true,
      controller: _scrollController,
      itemCount: messages.length + 1,
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return Container(
            height: 70,
          );
        }
        if (messages[index].type == "Source") {
          return OwnMessageCard(
            message: messages[index].message,
            img: messages[index].img,
            time: messages[index].time,
          );
        } else {
          return GroupReplyCard(
            message: messages[index].message,
            user: messages[index].userName,
            img: messages[index].img,
            time: messages[index].time,
          );
        }
      },
    );
  }

  Future<void> sendMessage(String message) async {
    setMessage(widget.sourchat.name, message);

    List<int> gmi = widget.chatModel.group.groupMemberIds;

    for (int i = 0; i < gmi.length; i++) {
      if (gmi[i] != widget.sourchat.chatID)
        widget.socket.emit("send_group_message", <String, dynamic>{
          'receiverChatID': gmi[i],
          'senderChatID': widget.sourchat.chatID,
          'groupID': widget.chatModel.group.groupId,
          'content': message,
        });
    }
    var putMessage = ParseObject('GroupMessages')
      ..set('SourceId', widget.sourchat.chatID)
      ..set('GroupId', widget.chatModel.group.groupId)
      ..set('Message', message);

    await putMessage.save();
  }

  void sendImage(String message) {
    List<int> gmi = widget.chatModel.group.groupMemberIds;

    for (int i = 0; i < gmi.length; i++) {
      if (gmi[i] != widget.sourchat.chatID)
        widget.socket.emit("send_group_image", <String, dynamic>{
          'receiverChatID': gmi[i],
          'senderChatID': widget.sourchat.chatID,
          'groupID': widget.chatModel.group.groupId,
          'content': message,
        });
    }
  }

  void setMessage(String userName, String message) {
    MessageModel messageModel = MessageModel(
        type: 'Source',
        userName: userName,
        img: false,
        message: message,
        time: DateFormat('dd-MMMM-yyyy – hh:mm a').format(DateTime.now()));
    //print(messages);

    setState(() {
      messages.add(messageModel);
    });
  }

  void setImage(String userName, String imageUrl) {
    MessageModel messageModel = MessageModel(
        type: 'Source',
        userName: userName,
        img: true,
        message: imageUrl,
        time: DateFormat('dd-MMMM-yyyy – hh:mm a').format(DateTime.now()));
    //print(messages);

    setState(() {
      messages.add(messageModel);
    });
  }

// room title. friend  name for individual and group name for groups
  Widget roomTitle() {
    return Text(
      widget.chatModel.group.groupName,
      style: TextStyle(
        fontSize: 18.5,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return viewGroupInfo
        ? GroupInfo(
            chatModel: widget.chatModel,
            sourchat: widget.sourchat,
            back: () {
              setState(() {
                viewGroupInfo = false;
              });
            })
        : Stack(
            children: [
              Image.asset(
                "assets/whatsapp_Back.png",
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(60),
                  child: AppBar(
                    leadingWidth: 70,
                    titleSpacing: 0,
                    leading: InkWell(
                      onTap: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            child: SvgPicture.asset(
                              "assets/groups.svg",
                              color: Colors.white,
                              height: 36,
                              width: 36,
                            ),
                            radius: 20,
                            backgroundColor: Colors.blueGrey,
                          ),
                        ],
                      ),
                    ),
                    title: InkWell(
                      onTap: () {},
                      child: Container(
                        margin: EdgeInsets.all(6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [roomTitle()],
                          /*Text(
                        "last seen today at 12:05",
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      )*/
                        ),
                      ),
                    ),
                    actions: [
                      PopupMenuButton<String>(
                        padding: EdgeInsets.all(0),
                        onSelected: (value) {
                          if (value == 'GI') {
                            setState(() {
                              viewGroupInfo = true;
                            });
                          }
                          ;
                        },
                        itemBuilder: (BuildContext contesxt) {
                          return [
                            PopupMenuItem(
                              child: Text("Group Info"),
                              value: "GI",
                            ),
                          ];
                        },
                      ),
                    ],
                  ),
                ),
                body: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: WillPopScope(
                    child: Column(
                      children: [
                        !isEmojiVisible
                            ? Expanded(
                                //height: MediaQuery.of(context).size.height - 250,
                                child: Messages())
                            : Container(
                                height: MediaQuery.of(context).size.height / 3,
                                child: Messages()),
                        InputWidget(
                          onBlurred: toggleEmoji,
                          controller: _controller,
                          isEmojiVisible: isEmojiVisible,
                          onSentMessage: (message) {
                            sendMessage(message);
                            Timer(Duration(milliseconds: 300), () {
                              _scrollController.jumpTo(
                                  _scrollController.position.maxScrollExtent);
                            });
                          },
                          onSentImage: (String value) async {
                            uploadImage(value).then((putImage) {
                              setImage(widget.sourchat.name,
                                  putImage['Image']['url']);
                              sendImage(putImage['Image']['url']);
                              Timer(Duration(milliseconds: 300), () {
                                _scrollController.jumpTo(
                                    _scrollController.position.maxScrollExtent);
                              });
                            });
                          },
                        ),
                        isEmojiVisible
                            ? Expanded(
                                child: EmojiPicker(
                                  emojiPickObserver: (dynamic emoji) {
                                    setState(() {
                                      _controller.text =
                                          '${_controller.text}$emoji';
                                      toggleEmoji();
                                    });
                                  },
                                ),
                              )
                            : Container(),
                      ],
                    ),
                    onWillPop: () {
                      if (isEmojiVisible) {
                        setState(() {
                          toggleEmoji();
                        });
                      } else {
                        Navigator.pop(context);
                      }
                      return Future.value(false);
                    },
                  ),
                ),
              ),
            ],
          );
  }

  Future<ParseObject> uploadImage(String value) async {
    ParseFileBase parseFile = ParseFile(File(value));
    var putImage = ParseObject('GroupMessages')
      ..set('SourceId', widget.sourchat.chatID)
      ..set('GroupId', widget.chatModel.group.groupId)
      ..set('Message', '')
      ..set("Image", parseFile);
    await putImage.save();
    parseFile.upload(
        progressCallback: (int count, int total) => print("$count of $total"));

    return putImage;
  }

  Future toggleEmoji() async {
    setState(() {
      isEmojiVisible = !isEmojiVisible;
      if (isEmojiVisible) _moveScroll();
    });
  }

  void _moveScroll() {
    Timer(Duration(milliseconds: 300), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }
}
