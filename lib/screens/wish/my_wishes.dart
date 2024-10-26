import 'package:flutter/material.dart';
import 'package:swiftgift_app/data/group.dart';
import 'package:swiftgift_app/main.dart';
import 'package:swiftgift_app/screens/wish/wishes_list.dart';
import 'package:swiftgift_app/util.dart';

import '../../data/wish.dart';
import 'filters.dart';

class MyWishesScreen extends StatefulWidget {
  const MyWishesScreen({super.key});

  @override
  State<MyWishesScreen> createState() => _MyWishesScreenState();
}

class _MyWishesScreenState extends State<MyWishesScreen> {
  late final Future<List<Group>> _groups;

  @override
  void initState() {
    _groups = apiClient.groups();
    super.initState();
  }

  Widget _buildFilterBar(BuildContext context, WishFilters? filters,
      Function(WishFilters newFilters) onChange) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterItem<Occasion>(
            context,
            'Occasion',
            Occasion.values,
            filters?.occasion,
            (occasion) {
              onChange(WishFilters(
                  occasion: occasion,
                  visibility: filters?.visibility,
                  group: filters?.group));
            },
            () {
              onChange(WishFilters(
                  occasion: null,
                  visibility: filters?.visibility,
                  group: filters?.group));
            },
            (occasion) {
              return occasion.name.toCapitalized();
            },
          ),
          _buildFilterItem<WishVisibility>(
              context, 'Visibility', WishVisibility.values, filters?.visibility,
              (visibility) {
            onChange(WishFilters(
                occasion: filters?.occasion,
                visibility: visibility,
                group: filters?.group));
          }, () {
            onChange(WishFilters(
                occasion: filters?.occasion,
                visibility: null,
                group: filters?.group));
          }, (visibility) {
            return visibility.name.toCapitalized();
          }),
          FutureBuilder<List<Group>>(
            future: _groups,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              } else {
                return _buildFilterItem<Group>(
                    context, 'Group', snapshot.data!, filters?.group, (group) {
                  onChange(WishFilters(
                      occasion: filters?.occasion,
                      visibility: filters?.visibility,
                      group: group));
                }, () {
                  onChange(WishFilters(
                      occasion: filters?.occasion,
                      visibility: filters?.visibility,
                      group: null));
                }, (group) {
                  return group.name;
                });
              }
            },
          )
        ],
      ),
    );
  }

  Widget _buildFilterItem<T>(
      BuildContext context,
      String filterLabel,
      List<T> options,
      T? selected,
      Function(T) onSelected,
      Function() deselect,
      String Function(T) getLabel) {
    return GestureDetector(
      onTap: () async {
        if (selected != null) {
          deselect();
        } else {
          final selectedOption = await Navigator.push<T>(
            context,
            MaterialPageRoute(
              builder: (context) => FilterOptionsScreen<T>(
                  filterLabel: filterLabel,
                  options: options,
                  getLabel: getLabel),
            ),
          );
          if (selectedOption != null) {
            onSelected(selectedOption);
          }
        }
      },
      child: Container(
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected != null ? Colors.blueAccent : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(4),
          color: selected != null
              ? Colors.blue.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Center(
          child: Text(selected == null ? filterLabel : getLabel(selected),
              style: const TextStyle(
                fontSize: 16,
              )),
        ),
      ),
    );
  }

  WishFilters? _filters;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Wishes',
            style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: Column(
        children: [
          Expanded(
              flex: 1,
              child: _buildFilterBar(context, _filters, (newFilters) {
                setState(() {
                  _filters = newFilters;
                });
              })),
          Expanded(
            flex: 8,
            child: Center(
              child: FutureBuilder<List<Wish>>(
                future: _filters?.group?.id == null
                    ? apiClient.wishesByLoggedOnUser()
                    : apiClient.wishesForGroup(_filters!.group!.id),
                builder:
                    (BuildContext context, AsyncSnapshot<List<Wish>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Could not retrieve wishes');
                  } else if (!snapshot.hasData) {
                    return const Text('No wishes found');
                  } else {
                    return FilteredWishList(
                      wishes: snapshot.requireData,
                      filters: _filters,
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FilterOptionsScreen<T> extends StatelessWidget {
  final String filterLabel;
  final List<T> options;
  final String Function(T) getLabel;

  const FilterOptionsScreen(
      {required this.filterLabel,
      required this.options,
      super.key,
      required this.getLabel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select $filterLabel'),
      ),
      body: ListView.builder(
        itemCount: options.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(getLabel(options[index])),
            onTap: () {
              Navigator.pop(context, options[index]);
            },
          );
        },
      ),
    );
  }
}
