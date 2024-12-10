import 'dart:io';

import 'package:flutter/material.dart';
import 'package:swiftgift_app/util.dart';

import '../../data/wish.dart';
import '../../main.dart';
import 'add_wish.dart';

class WishAction {
  final String label;
  final Function(Wish) function;

  WishAction({required this.label, required this.function});
}

class WishDetailsPage extends StatelessWidget {
  final Wish wish;
  final File? wishImage;
  final List<WishAction> actions;

  const WishDetailsPage({
    super.key,
    required this.wish,
    this.wishImage,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          wish.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: FutureBuilder(
        future: apiClient.loggedInUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading user data.'));
          } else if (snapshot.hasData) {
            final loggedInUser = snapshot.data;
            final isCreator = loggedInUser?.id == wish.createdBy.id;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (wishImage != null)
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.file(
                          wishImage!,
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    wish.title.toCapitalized(),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (wish.description?.isNotEmpty ?? false)
                    Text(
                      wish.description!,
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.justify,
                    ),
                  const SizedBox(height: 32),
                  _buildActionButtons(context, isCreator),
                  const SizedBox(height: 24),
                  ...actions.map(
                    (action) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 24.0),
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onPressed: () => action.function(wish),
                        child: Text(
                          action.label,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('User not found.'));
          }
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isCreator) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isCreator) ...[
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text('Edit', style: TextStyle(fontSize: 16)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddWishesScreen(
                    wishToEdit: wish,
                    wishImage: wishImage,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            icon: const Icon(Icons.delete, color: Colors.white),
            label: const Text('Delete', style: TextStyle(fontSize: 16)),
            onPressed: () {
              // TODO: Implement delete logic
            },
          ),
        ] else ...[
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text('Assign', style: TextStyle(fontSize: 16)),
            onPressed: () {
              // TODO: Implement assign logic
            },
          ),
        ],
      ],
    );
  }
}
