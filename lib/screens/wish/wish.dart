import 'dart:io';

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
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Text(
                    wish.title.toCapitalized(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (wish.description != null &&
                    wish.description!.trim().isNotEmpty)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200),
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
          ),
          FutureBuilder<File?>(
            future: apiClient.getImage(wish.img),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const SizedBox(width: 120, height: 110);
              } else if (snapshot.hasData && snapshot.data != null) {
                return Container(
                  width: 120,
                  height: 110,
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
                return const SizedBox(width: 120, height: 60);
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
          _newlyCreatedWishes.add(wish);
        }));
  }

  void _seeMyWishes() {
    Navigator.pushNamed(context, '/myWishes');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishes'),
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
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No wishes found');
                } else {
                  var combined = List.empty(growable: true);
                  combined.addAll(snapshot.requireData);
                  combined.addAll(_newlyCreatedWishes);
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
