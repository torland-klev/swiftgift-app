import 'package:flutter/material.dart';
import 'package:gaveliste_app/data/user.dart';

import '../../main.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<User?>(
        future: apiClient.loggedInUser(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong. Please try again later.',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            User user = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReadOnlyField(
                      label: 'First Name', value: user.firstName),
                  const SizedBox(height: 16),
                  _buildReadOnlyField(label: 'Last Name', value: user.lastName),
                  const SizedBox(height: 16),
                  _buildReadOnlyField(label: 'Email', value: user.email),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        logout(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text('Log Out'),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Text(
                'User not found.',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, String? value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: Text(
            value ?? "",
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
