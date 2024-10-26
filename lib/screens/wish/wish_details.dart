import 'package:flutter/material.dart';
import 'package:swiftgift_app/util.dart';

import '../../data/wish.dart';
import '../../main.dart';

class WishAction {
  final String label;
  final Function(Wish) function;

  WishAction({required this.label, required this.function});
}

class WishDetailsPage extends StatelessWidget {
  final Wish wish;
  final List<WishAction> actions;

  const WishDetailsPage(
      {super.key, required this.wish, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(wish.title),
      ),
      body: FutureBuilder(
        future: apiClient.loggedInUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading user data.'));
          } else if (snapshot.hasData) {
            final loggedInUser = snapshot.data;
            final isCreator = loggedInUser?.id == wish.createdBy.id;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wish.title.toCapitalized(),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  if (wish.description != null && wish.description!.isNotEmpty)
                    Text(
                      wish.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 24),
                  if (isCreator) ...[
                    ElevatedButton(
                      onPressed: () {
                        // TODO
                      },
                      child: Text('Edit'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // TODO
                      },
                      child: Text('Delete'),
                    ),
                  ] else ...[
                    ElevatedButton(
                      onPressed: () {
                        // TODO
                      },
                      child: Text('Assign'),
                    )
                  ],
                  ...actions.map((action) => ElevatedButton(
                        onPressed: () => action.function(wish),
                        child: Text(action.label),
                      ))
                ],
              ),
            );
          } else {
            return Center(child: Text('User not found.'));
          }
        },
      ),
    );
  }
}
