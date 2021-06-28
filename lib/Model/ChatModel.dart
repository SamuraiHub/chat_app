import 'package:intl/intl.dart';
import 'dart:convert';

import '../User.dart';
import 'GroupModel.dart';
import 'MessageModel.dart';

// model for chat between users and groups
class ChatModel {
  // messages of the room chat
  List<MessageModel> messages = List.filled(0,
      MessageModel(time: '', message: '', type: '', userName: '', img: false),
      growable: true);

  // where it is individual or a group
  bool isGroup = false;

  // if individual should contain the friend the user messagws
  User friend = User('', 0, '');

  //if group should contain the group where a couple of users message each other.
  GroupModel group = GroupModel(createdBy: '', groupId: 0, groupName: '');

  ChatModel({required bool isGroup, User? friend, GroupModel? group}) {
    this.isGroup = isGroup;
    this.friend = friend != null ? friend : this.friend;
    this.group = group != null ? group : this.group;
  }
}
