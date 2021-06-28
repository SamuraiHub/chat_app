//model for messages and images
class MessageModel {
  String type; // wheather it is source or destination.
  String userName; // username of themessage sender
  String message; // the message itself
  bool img; // if the message is an image url
  String time; // time of the post message
  MessageModel(
      {required this.userName,
      required this.message,
      required this.img,
      required this.type,
      required this.time});
}
