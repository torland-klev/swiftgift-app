import 'user.dart';

enum GroupVisibility {
  private,
  public,
  completed,
}

enum GroupRole { owner, member, moderator, admin }

class Group {
  final String id;
  final String name;
  final User createdBy;
  final GroupVisibility visibility;
  final List<User> members;

  Group(this.id, this.name, this.createdBy, this.visibility, this.members);

  static Group fromJson(Map<String, dynamic> groupJson,
      [List<User> members = const []]) {
    User createdBy = User.fromJson(groupJson['createdBy']);
    return Group(
        groupJson['id'],
        groupJson['name'],
        createdBy,
        GroupVisibility.values.byName(groupJson['visibility'].toLowerCase()),
        members);
  }
}
