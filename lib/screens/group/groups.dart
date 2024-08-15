import 'package:flutter/material.dart';
import 'package:gaveliste_app/main.dart';

import '../../data/group.dart';
import 'group.dart';

class _GroupCard extends StatefulWidget {
  final Group group;

  const _GroupCard({
    required this.group,
  });

  @override
  _GroupCardState createState() => _GroupCardState();
}

class _GroupCardState extends State<_GroupCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Card(
        color: _isHovered
            ? const Color.fromRGBO(146, 186, 255, 100)
            : theme.cardColor,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupDetailsScreen(group: widget.group),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                widget.group.name,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Members: ${widget.group.members.length}',
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AllGroupsScreen extends StatefulWidget {
  const AllGroupsScreen({super.key});

  @override
  State<AllGroupsScreen> createState() => _AllGroupsScreenState();
}

class _AllGroupsScreenState extends State<AllGroupsScreen> {
  final Future<List<Group>> _groups = apiClient.groups();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:
              Text('Groups', style: Theme.of(context).textTheme.headlineMedium),
        ),
        body: Center(
            child: FutureBuilder<List<Group>>(
                future: _groups,
                builder: (BuildContext context,
                    AsyncSnapshot<List<Group>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Could not retrieve groups');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No groups found');
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView(
                        children: snapshot.data!
                            .asMap()
                            .entries
                            .map(
                              (entry) => _GroupCard(
                                group: entry.value,
                              ),
                            )
                            .toList(),
                      ),
                    );
                  }
                })));
  }
}
