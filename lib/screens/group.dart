import 'package:flutter/material.dart';
import 'package:gaveliste_app/main.dart';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  User(this.id, this.firstName, this.lastName, this.email);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['id'],
      json['firstName'],
      json['lastName'],
      json['email'],
    );
  }
}

enum GroupVisibility {
  private,
  public,
  completed,
}

class Group {
  final String id;
  final String name;
  final User createdBy;
  final GroupVisibility visibility;

  Group(this.id, this.name, this.createdBy, this.visibility);

  static Group fromJson(Map<String, dynamic> json) {
    User createdBy = User.fromJson(json['createdBy']);
    return Group(json['id'], json['name'], createdBy,
        GroupVisibility.values.byName(json['visibility'].toLowerCase()));
  }
}

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final Future<List<Group>> _groups = apiClient.groups();
  @override
  Widget build(BuildContext context) {
    return Center(
        child: FutureBuilder<List<Group>>(
            future: _groups,
            builder:
                (BuildContext context, AsyncSnapshot<List<Group>> snapshot) {
              List<Widget> children;
              if (snapshot.hasData) {
                children = <Widget>[
                  snapshot.data!.isNotEmpty
                      ? const Text("We found many groups!")
                      : const Text("No groups found")
                ];
              } else if (snapshot.hasError) {
                children = <Widget>[const Text("Could not retrieve groups")];
              } else {
                children = const <Widget>[
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(),
                  ),
                ];
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: children,
                ),
              );
            }));
  }
}
