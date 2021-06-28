import 'package:chat_app/Model/ChatModel.dart';
import 'package:flutter/material.dart';

class FriendsList extends StatelessWidget {
  FriendsList({Key? key, required this.chatmodels, required this.back})
      : super(key: key);

  final List<ChatModel> chatmodels;
  final VoidCallback back;

  Widget Friends() {
    List<String> fs = List.filled(0, '', growable: true);

    for (int i = 0; i < chatmodels.length; i++) {
      if (!chatmodels[i].isGroup) {
        fs.add(chatmodels[i].friend.name);
      }
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: fs.length,
      itemBuilder: (context, index) {
        return Center(
            child: Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                child: Text(
                  fs[index],
                  style: TextStyle(fontSize: 25),
                )));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => back(),
        ),
        title: Text(
          'Friends List',
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
              'Friends',
              style: TextStyle(fontSize: 25),
            ),
          ),
          Friends(),
        ],
      ),
    );
  }
}
