import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:gaveliste_app/data/group.dart';
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

class _Filters {
  Occasion? occasion;
  WishVisibility? visibility;
  Group? group;

  _Filters(this.occasion, this.visibility, this.group);
}

class WishesScreen extends StatefulWidget {
  const WishesScreen({super.key});

  @override
  State<WishesScreen> createState() => _WishesScreenState();
}

class _WishesScreenState extends State<WishesScreen> {
  final List<Wish> _newlyCreatedWishes = List.empty(growable: true);

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
            _newlyCreatedWishes.add(wish);
          }
        }));
  }

  void _seeMyWishes() {
    Navigator.pushNamed(context, '/myWishes');
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
            (occasion) {
              return occasion.name.toCapitalized();
            },
          ),
          _buildFilterItem<WishVisibility>(
              context, 'Visibility', WishVisibility.values, filters?.visibility,
              (visibility) {
            onChange(_Filters(filters?.occasion, visibility, filters?.group));
          }, (visibility) {
            return visibility.name.toCapitalized();
          }),
          FutureBuilder<List<Group>>(
            future: apiClient.groups(), // Replace with your API call
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
      String Function(T) getLabel) {
    return GestureDetector(
      onTap: () async {
        final selectedOption = await Navigator.push<T>(
          context,
          MaterialPageRoute(
            builder: (context) => FilterOptionsScreen<T>(
                filterLabel: filterLabel, options: options, getLabel: getLabel),
          ),
        );
        if (selectedOption != null) {
          onSelected(selectedOption);
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
        title:
            Text('Wishes', style: Theme.of(context).textTheme.headlineMedium),
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
                    ? apiClient.wishes()
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
                },
              ),
            ),
          ),
        ],
      ),
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
