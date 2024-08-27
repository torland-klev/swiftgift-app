import 'dart:io';

import 'package:flutter/material.dart';
import 'package:swiftgift_app/util.dart';

import '../../data/wish.dart';
import '../../main.dart';

class WishCard extends StatelessWidget {
  final Wish wish;

  const WishCard({super.key, required this.wish});

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
