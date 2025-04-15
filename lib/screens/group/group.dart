import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:swiftgift_app/screens/wish/filters.dart';
import 'package:swiftgift_app/screens/wish/wish_details.dart';
import 'package:swiftgift_app/util.dart';

import '../../data/group.dart';
import '../../data/wish.dart';
import '../../main.dart';
import '../users/users_grid.dart';

class GroupDetailsScreen extends StatefulWidget {
  final Group group;

  const GroupDetailsScreen({required this.group, super.key});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  bool _isJoining = false;

  void _invite() async {
    String url = await apiClient.getGroupInviteLink(widget.group.id);
    if (kDebugMode) {
      print("Invite URL: $url");
    }
    Share.share(
        'Vil du bli med i gavelista ${widget.group.name}? Følg linken her:\n\n$url',
        subject: "SwiftGift Invitasjon");
  }

  void _joinGroup() async {
    setState(() {
      _isJoining = true;
    });

    try {
      var newGroup = await apiClient.addUserToGroup(widget.group.id);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) =>
                  GroupDetailsScreen(group: newGroup)),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to join group: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }

  void _removeWishFromGroup(Wish wish) {
    // TODO
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GroupRole?>(
      future: apiClient.getLoggedInUsersRoleForGroup(widget.group.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || _isJoining) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          final role = snapshot.data;
          final isMember = role != null;
          final isAuthorized = isMember && role != GroupRole.member;

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Details",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.group.name,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Text(
                              'Created by ${widget.group.createdBy.firstName} ${widget.group.createdBy.lastName}',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(.5)),
                            ),
                            const Spacer(),
                            Chip(
                              shape: const StadiumBorder(side: BorderSide()),
                              label: Text(
                                widget.group.visibility
                                    .toString()
                                    .split('.')
                                    .last
                                    .toCapitalized(),
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: widget.group.visibility ==
                                        GroupVisibility.public
                                        ? const Color.fromRGBO(
                                        65, 136, 254, 100)
                                        : Colors.white),
                              ),
                              backgroundColor: widget.group.visibility ==
                                  GroupVisibility.public
                                  ? const Color.fromRGBO(172, 204, 255, 100)
                                  : const Color.fromRGBO(65, 136, 254, 100),
                            ),
                          ],
                        )
                      ]),
                  const SizedBox(height: 40),
                  Expanded(
                    child: UsersGrid(
                      users: widget.group.members,
                      filters: WishFilters(group: widget.group),
                      actions: isAuthorized
                          ? [
                        WishAction(
                            label: "Remove",
                            function: _removeWishFromGroup)
                      ]
                          : [],
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: isMember
                ? FloatingActionButton(
              onPressed: _invite,
              tooltip: 'Invite to group',
              child: const Icon(Icons.person_add),
            )
                : FloatingActionButton(
              onPressed: _joinGroup,
              tooltip: 'Join group',
              child: const Icon(Icons.group_add),
            ),
          );
        }
      },
    );
  }
}
