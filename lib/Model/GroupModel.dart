// model for groups
class GroupModel {
  int groupId = 0; // group id
  String groupName = ''; // group name
  String createdBy = '';
  List<int> groupMemberIds =
      List.filled(0, 0, growable: true); // group member ids
  List<String> groupMembers =
      List.filled(0, '', growable: true); // group member names
  List<bool> userInside = List.filled(0, true,
      growable: true); // whither user is inside the group or left.

  GroupModel(
      {required int groupId,
      required String groupName,
      required String createdBy}) {
    this.groupId = groupId;
    this.createdBy = createdBy;
    this.groupName = groupName;
  }

  String getUserName(int memberId) {
    for (int i = 0; i < groupMemberIds.length; i++) {
      if (groupMemberIds[i] == memberId) return groupMembers[i];
    }

    return '';
  }
}
