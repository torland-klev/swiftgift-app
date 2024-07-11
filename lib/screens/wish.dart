import 'package:flutter/material.dart';
import 'package:gaveliste_app/main.dart';
import 'package:gaveliste_app/util.dart';

import '../data/wish.dart';

class _WishCard extends StatelessWidget {
  final Wish wish;

  const _WishCard({required this.wish});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (wish.imageUrl != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.network(
                wish.imageUrl!,
                width: 150,
                height: 150,
              ),
            ),
          if (wish.description != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                wish.description!.toCapitalized(),
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class WishesScreen extends StatefulWidget {
  const WishesScreen({super.key});

  @override
  State<WishesScreen> createState() => _WishesScreenState();
}

class _WishesScreenState extends State<WishesScreen> {
  final Future<List<Wish>> _wishes = apiClient.wishes();

  @override
  Widget build(BuildContext context) {
    return Center(
        child: FutureBuilder<List<Wish>>(
            future: _wishes,
            builder:
                (BuildContext context, AsyncSnapshot<List<Wish>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Text('Could not retrieve wishes');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No wishes found');
              } else {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: snapshot.data!
                        .asMap()
                        .entries
                        .where((wish) => wish.value.status == Status.open)
                        .map(
                          (entry) => _WishCard(
                            wish: entry.value,
                          ),
                        )
                        .toList(),
                  ),
                );
              }
            }));
  }
}
