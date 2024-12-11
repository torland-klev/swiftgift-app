import 'dart:io';

import 'package:flutter/material.dart';
import 'package:swiftgift_app/screens/wish/wish_details.dart';
import 'package:swiftgift_app/util.dart';

import '../../data/wish.dart';
import '../../main.dart';

class WishCard extends StatefulWidget {
  final Wish wish;
  final List<WishAction> actions;

  const WishCard({super.key, required this.wish, this.actions = const []});

  @override
  State<WishCard> createState() => _WishCardState();
}

class _WishCardState extends State<WishCard> {
  late Wish _wish;

  @override
  void initState() {
    super.initState();
    _wish = widget.wish;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WishDetailsPage(
                wish: widget.wish,
                actions: widget.actions,
                onWishChanged: (result) {
                  setState(() {
                    _wish = result;
                  });
                },
              ),
            ),
          );
        },
        child: Card(
          color: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _wish.title.toCapitalized(),
                    style: Theme.of(context).textTheme.headlineSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_wish.description != null &&
                      _wish.description!.trim().isNotEmpty)
                    Text(
                      _wish.description!.toCapitalized().trim(),
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )
                ],
              )),
              FutureBuilder<File?>(
                future: apiClient.getImage(_wish.img),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const SizedBox.shrink();
                  } else if (snapshot.hasData && snapshot.data != null) {
                    _wish.wishImage = snapshot.data;
                    return Container(
                      width: 120,
                      constraints:
                          const BoxConstraints(maxHeight: 110, minHeight: 80),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.file(snapshot.data!,
                          fit: BoxFit.cover, alignment: Alignment.centerRight),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
        ));
  }
}
