import 'package:flutter/material.dart';
import 'package:swiftgift_app/screens/wish/filters.dart';

import '../../data/wish.dart';
import 'wish_card.dart';

class FilteredWishList extends StatelessWidget {
  final List<Wish> wishes;
  final WishFilters? filters;

  const FilteredWishList({
    super.key,
    required this.wishes,
    this.filters,
  });

  @override
  Widget build(BuildContext context) {
    List<Wish> combined = List.from(wishes);

    if (combined.isEmpty) {
      return const Text('No wishes found');
    }

    return ListView(
      children: combined
          .where((wish) => wish.status == Status.open)
          .where((wish) =>
              filters?.occasion == null || filters!.occasion! == wish.occasion)
          .where((wish) =>
              filters?.visibility == null ||
              filters!.visibility! == wish.visibility)
          .map(
            (entry) => Column(
              children: [
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(left: 4, right: 0),
                  child: WishCard(
                    wish: entry,
                  ),
                ),
                const Divider(),
              ],
            ),
          )
          .toList(),
    );
  }
}
