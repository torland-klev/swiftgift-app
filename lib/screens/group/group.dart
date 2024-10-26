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

class GroupDetailsScreen extends StatelessWidget {
  final Group group;

  const GroupDetailsScreen({required this.group, super.key});

  void _invite() async {
    String url = await apiClient.getGroupInviteLink(group.id);
    if (kDebugMode) {
      print("Invite URL: $url");
    }
    Share.share(
        'Vil du bli med i gavelista ${group.name}? Følg linken her:\n\n$url',
        subject: "SwiftGift Invitasjon");
  }

  void _removeWishFromGroup(Wish wish) {
    // TODO
  }

  @override
  Widget build(BuildContext context) {
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
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                group.name,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Text(
                    'Created by ${group.createdBy.firstName} ${group.createdBy.lastName}',
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
                      group.visibility
                          .toString()
                          .split('.')
                          .last
                          .toCapitalized(),
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: group.visibility == GroupVisibility.public
                              ? const Color.fromRGBO(65, 136, 254, 100)
                              : Colors.white),
                    ),
                    backgroundColor: group.visibility == GroupVisibility.public
                        ? const Color.fromRGBO(172, 204, 255, 100)
                        : const Color.fromRGBO(65, 136, 254, 100),
                  ),
                ],
              )
            ]),
            const SizedBox(height: 40),
            FutureBuilder<GroupRole>(
              future: apiClient.getLoggedInUsersRoleForGroup(group.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final role = snapshot.data;
                  final isAuthorized = role != GroupRole.member;

                  return Expanded(
                    child: UsersGrid(
                      users: group.members,
                      filters: WishFilters(group: group),
                      actions: isAuthorized
                          ? [
                              WishAction(
                                  label: "Remove",
                                  function: _removeWishFromGroup)
                            ]
                          : [],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _invite(),
        tooltip: 'Invite to group',
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
