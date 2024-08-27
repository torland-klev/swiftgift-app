import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:swiftgift_app/data/group.dart';
import 'package:swiftgift_app/main.dart';
import 'package:swiftgift_app/screens/wish/add_wish.dart';
import 'package:swiftgift_app/util.dart';

import '../../data/wish.dart';
import 'wish_card.dart';

class _Filters {
  Occasion? occasion;
  WishVisibility? visibility;
  Group? group;

  _Filters(this.occasion, this.visibility, this.group);
}

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

  void _addWish() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddWishesScreen(),
      ),
    ).then((wish) => setState(() {
          if (wish != null) {
            if (kDebugMode) {
              print(wish.toJson());
            }
          }
        }));
  }

  Widget _buildFilterBar(BuildContext context, _Filters? filters,
      Function(_Filters newFilters) onChange) {
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
              onChange(_Filters(occasion, filters?.visibility, filters?.group));
            },
            () {
              onChange(_Filters(null, filters?.visibility, filters?.group));
            },
            (occasion) {
              return occasion.name.toCapitalized();
            },
          ),
          _buildFilterItem<WishVisibility>(
              context, 'Visibility', WishVisibility.values, filters?.visibility,
              (visibility) {
            onChange(_Filters(filters?.occasion, visibility, filters?.group));
          }, () {
            onChange(_Filters(filters?.occasion, null, filters?.group));
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
                  onChange(
                      _Filters(filters?.occasion, filters?.visibility, group));
                }, () {
                  onChange(
                      _Filters(filters?.occasion, filters?.visibility, null));
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

  _Filters? _filters;

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
            flex: 5,
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
                    List<Wish> combined = List.empty(growable: true);
                    combined.addAll(snapshot.requireData);
                    if (combined.isEmpty) {
                      return const Text('No wishes found');
                    }
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView(
                        children: combined
                            .where((wish) => wish.status == Status.open)
                            .where((wish) =>
                                _filters?.occasion == null ||
                                _filters!.occasion! == wish.occasion)
                            .where((wish) =>
                                _filters?.visibility == null ||
                                _filters!.visibility! == wish.visibility)
                            .map(
                              (entry) => WishCard(
                                wish: entry,
                              ),
                            )
                            .toList(),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addWish(),
        tooltip: 'Add wish',
        child: const Icon(Icons.add),
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
