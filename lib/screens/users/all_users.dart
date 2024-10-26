import 'package:flutter/material.dart';
import 'package:swiftgift_app/screens/users/users_grid.dart';

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
        future: apiClient.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching users'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found'));
          } else {
            final users = snapshot.data!;
            return Padding(
                padding: const EdgeInsets.all(8.0),
                child: UsersGrid(users: users));
          }
        },
      ),
    );
  }
}
