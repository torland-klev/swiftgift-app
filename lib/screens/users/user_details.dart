import 'package:flutter/material.dart';
import 'package:swiftgift_app/screens/wish/filters.dart';

import '../../data/user.dart';
import '../../data/wish.dart';
import '../../main.dart';
import '../wish/wishes_list.dart';

class UserDetailsPage extends StatelessWidget {
  final User user;
  final WishFilters? filters;

  const UserDetailsPage({super.key, required this.user, this.filters});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${user.firstName} ${user.lastName}'),
      ),
      body: Center(
        child: FutureBuilder<List<Wish>>(
          future: apiClient.wishesByUser(
              userId: user.id, groupId: filters?.group?.id),
          builder: (BuildContext context, AsyncSnapshot<List<Wish>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Could not retrieve wishes');
            } else if (!snapshot.hasData) {
              return const Text('No wishes found');
            } else {
              return FilteredWishList(
                wishes: snapshot.requireData,
                filters: filters,
              );
            }
          },
        ),
      ),
    );
  }
}
