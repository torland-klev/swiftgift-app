import 'package:flutter/material.dart';

class AllUsersScreen extends StatefulWidget {
  const AllUsersScreen({super.key});

  @override
  State<AllUsersScreen> createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends State<AllUsersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:
              Text('Users', style: Theme.of(context).textTheme.headlineMedium),
        ),
        body: const Center(child: Text('Her vil man kunne se alle brukere')));
  }
}
