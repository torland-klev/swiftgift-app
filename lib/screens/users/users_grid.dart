import 'package:flutter/material.dart';
import 'package:swiftgift_app/screens/users/user_details.dart';

import '../../data/user.dart';
import '../wish/filters.dart';
import '../wish/wish_details.dart';

class UsersGrid extends StatelessWidget {
  final List<User> users;
  final WishFilters? filters;
  final List<WishAction> actions;

  const UsersGrid(
      {super.key, required this.users, this.filters, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: users.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 3 / 4,
      ),
      itemBuilder: (context, index) {
        final user = users[index];
        const imageUrl =
            'https://static.thenounproject.com/png/4154905-200.png';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserDetailsPage(
                    user: user, filters: filters, actions: actions),
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(imageUrl),
                    backgroundColor: getColor(user),
                  ),
                  const SizedBox(height: 10),
                  if (user.firstName != null || user.lastName != null)
                    Text(
                      '${user.firstName ?? ""} ${user.lastName ?? ""}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Color getColor(User user) {
  const List<Color> colors = [
    Color(0xFFFFC1CC),
    Color(0xFFB5EAD7),
    Color(0xFFFFF5BA),
    Color(0xFFAEC6CF),
    Color(0xFFE6A8D7),
  ];

  int emailHash = user.email.hashCode;
  int colorIndex = emailHash % colors.length;

  return colors[colorIndex];
}
