import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GroupReplyCard extends StatelessWidget {
  const GroupReplyCard(
      {Key? key,
      required this.user,
      required this.message,
      required this.img,
      required this.time})
      : super(key: key);
  final String user;
  final String message;
  final bool img;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          // color: Color(0xffdcf8c6),
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 50,
                  top: 5,
                  bottom: 20,
                ),
                child: Text(
                  user,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue.shade500,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 50,
                  top: 27,
                  bottom: 20,
                ),
                child: img
                    ? Column(children: [
                        Image.network(message),
                        InkWell(
                            child: new Text('Open Image in Browser'),
                            onTap: () async {
                              if (await canLaunch(message)) {
                                await launch(
                                  message,
                                  forceSafariVC: false,
                                );
                              }
                            })
                      ])
                    : Text(
                        message,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
              ),
              SizedBox(
                height: 15,
              ),
              Positioned(
                bottom: 3,
                right: 10,
                child: Text(
                  time.substring(time.length - 7, time.length),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
