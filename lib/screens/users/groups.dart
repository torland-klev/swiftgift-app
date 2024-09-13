import 'package:flutter/material.dart';

import '../../data/user.dart';
import '../../main.dart';

class AllUsersScreen extends StatefulWidget {
  const AllUsersScreen({super.key});

  @override
  State<AllUsersScreen> createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends State<AllUsersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users', style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: FutureBuilder<List<User>>(
        future: apiClient.getUsers(), // Fetch users from API
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator()); // Loading spinner
          } else if (snapshot.hasError) {
            return const Center(
                child: Text('Error fetching users')); // Error message
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found')); // No data found
          } else {
            final users = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(8.0), // Add padding around the grid
              child: GridView.builder(
                itemCount: users.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2-wide grid
                  mainAxisSpacing: 10.0, // Spacing between rows
                  crossAxisSpacing: 10.0, // Spacing between columns
                  childAspectRatio:
                      3 / 4, // Adjust the aspect ratio of each item
                ),
                itemBuilder: (context, index) {
                  final user = users[index];
                  // Use a default image if user.img is null or empty
                  const imageUrl =
                      'https://static.thenounproject.com/png/4154905-200.png';
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                    elevation: 5, // Card shadow effect
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                              radius: 40,
                              backgroundImage: const NetworkImage(imageUrl),
                              backgroundColor: getColor(user)),
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
                  );
                },
              ),
            );
          }
        },
      ),
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
