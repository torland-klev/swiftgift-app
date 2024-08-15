import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:gaveliste_app/main.dart';
import 'package:gaveliste_app/screens/wish/add_wish.dart';
import 'package:gaveliste_app/util.dart';

import '../../data/wish.dart';

class _WishCard extends StatelessWidget {
  final Wish wish;

  const _WishCard({required this.wish});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: Text(
                  wish.title.toCapitalized(),
                  style: Theme.of(context).textTheme.headlineSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (wish.description != null &&
                  wish.description!.trim().isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: Text(
                    wish.description!.toCapitalized().trim(),
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          FutureBuilder<File?>(
            future: apiClient.getImage(wish.img),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const SizedBox(width: 120);
              } else if (snapshot.hasData && snapshot.data != null) {
                return Container(
                  width: 120,
                  constraints:
                      const BoxConstraints(maxHeight: 110, minHeight: 80),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Image.file(
                    snapshot.data!,
                    fit: BoxFit.fitWidth,
                  ),
                );
              } else {
                return const SizedBox(width: 120, height: 80);
              }
            },
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
  final List<Wish> _newlyCreatedWishes = List.empty(growable: true);

  void _addWish() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddWishesScreen(),
      ),
    ).then((wish) => setState(() {
          if (kDebugMode) {
            print(wish.toJson());
          }
          if (wish != null) _newlyCreatedWishes.add(wish);
        }));
  }

  void _seeMyWishes() {
    Navigator.pushNamed(context, '/myWishes');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Wishes', style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: Center(
          child: FutureBuilder<List<Wish>>(
              future: _wishes,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Wish>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Could not retrieve wishes');
                } else if (!snapshot.hasData) {
                  return const Text('No wishes found');
                } else {
                  var combined = List.empty(growable: true);
                  combined.addAll(snapshot.requireData);
                  combined.addAll(_newlyCreatedWishes);
                  if (combined.isEmpty) {
                    return const Text('No wishes found');
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      children: combined
                          .where((wish) => wish.status == Status.open)
                          .map(
                            (entry) => _WishCard(
                              wish: entry,
                            ),
                          )
                          .toList(),
                    ),
                  );
                }
              })),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: Theme.of(context).primaryColor,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: 'Add wish',
            onTap: _addWish,
          ),
          SpeedDialChild(
            child: const Icon(Icons.list),
            label: 'See my wishes',
            onTap: _seeMyWishes,
          ),
        ],
      ),
    );
  }
}
