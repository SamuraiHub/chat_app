import 'dart:async';
import 'dart:io';

import 'package:chat_app/CustomUI/OwnMessgaeCrad.dart';
import 'package:chat_app/CustomUI/ReplyCard.dart';
import 'package:chat_app/Model/ChatModel.dart';
import 'package:chat_app/Model/MessageModel.dart';
import 'package:chat_app/Pages/contractPage.dart';
import 'package:flutter_emoji_suite/flutter_emoji_suite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:chat_app/CustomUI/input_widget.dart';

import '../User.dart';

class IndividualPage extends StatefulWidget {
  IndividualPage(
      {Key? key,
      required this.chatModel,
      required this.sourchat,
      required this.socket})
      : super(key: key);
  final ChatModel chatModel;
  final User sourchat;
  final IO.Socket socket;

  @override
  _IndividualPageState createState() => _IndividualPageState();
}

class _IndividualPageState extends State<IndividualPage> {
  FocusNode focusNode = FocusNode();

  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool isEmojiVisible = false;
  bool viewContract = false;

  @override
  void initState() {
    super.initState();
  }

  Widget Messages() {
    return ListView.builder(
      shrinkWrap: true,
      controller: _scrollController,
      physics: BouncingScrollPhysics(),
      itemCount: widget.chatModel.messages.length + 1,
      itemBuilder: (context, index) {
        if (index == widget.chatModel.messages.length) {
          return Container(
            height: 70,
          );
        }
        if (widget.chatModel.messages[index].type == "Source") {
          return OwnMessageCard(
            message: widget.chatModel.messages[index].message,
            img: widget.chatModel.messages[index].img,
            time: widget.chatModel.messages[index].time,
          );
        } else {
          return ReplyCard(
            message: widget.chatModel.messages[index].message,
            img: widget.chatModel.messages[index].img,
            time: widget.chatModel.messages[index].time,
          );
        }
      },
    );
  }

  Future<void> sendMessage(String message) async {
    setMessage(widget.sourchat.name, message);

    widget.socket.emit("send_message", <String, dynamic>{
      'receiverChatID': widget.chatModel.friend.chatID,
      'senderChatID': widget.sourchat.chatID,
      'content': message,
    });

    var putMessage = ParseObject('Messages')
      ..set('SourceId', widget.sourchat.chatID)
      ..set('DestinationId', widget.chatModel.friend.chatID)
      ..set('Message', message);

    await putMessage.save();
  }

  void sendImage(String message) {
    widget.socket.emit("send_image", <String, dynamic>{
      'receiverChatID': widget.chatModel.friend.chatID,
      'senderChatID': widget.sourchat.chatID,
      'content': message,
    });
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
      widget.chatModel.messages.add(messageModel);
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
      widget.chatModel.messages.add(messageModel);
    });
  }

// room title. friend  name for individual and group name for groups
  Widget roomTitle() {
    return Text(
      widget.chatModel.friend.name,
      style: TextStyle(
        fontSize: 18.5,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return viewContract
        ? contractPage(
            chatModel: widget.chatModel,
            back: () {
              setState(() {
                viewContract = false;
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
                              "assets/person.svg",
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
                          if (value == 'VC')
                            setState(() {
                              viewContract = true;
                            });
                        },
                        itemBuilder: (BuildContext contesxt) {
                          return [
                            PopupMenuItem(
                              child: Text("View Contact"),
                              value: "VC",
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                            _moveScroll();
                          },
                          onSentImage: (String value) {
                            uploadImage(value).then((putImage) {
                              setImage(widget.sourchat.name,
                                  putImage['Image']['url']);
                              sendImage(putImage['Image']['url']);
                              _moveScroll();
                            });
                          }),
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
                ),
              ),
            ],
          );
  }

  Future<ParseObject> uploadImage(String value) async {
    ParseFileBase parseFile = ParseFile(File(value));
    var putImage = ParseObject('Messages')
      ..set('SourceId', widget.sourchat.chatID)
      ..set('DestinationId', widget.chatModel.friend.chatID)
      ..set('Message', '')
      ..set("Image", parseFile);
    var response = await putImage.save();
    parseFile.upload(
        progressCallback: (int count, int total) => print("$count of $total"));

    return putImage;
  }

  Future toggleEmoji() async {
    setState(() {
      isEmojiVisible = !isEmojiVisible;
      if (isEmojiVisible) {
        _moveScroll();
      }
    });
  }

  void _moveScroll() {
    Timer(Duration(milliseconds: 300), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }
}
