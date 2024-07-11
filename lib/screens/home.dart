import 'package:flutter/material.dart';
import 'package:gaveliste_app/main.dart';
import 'package:gaveliste_app/screens/wish.dart';

import 'group/groups.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: themeData,
        home: const DefaultTabController(
            length: 3,
            child: Scaffold(
                bottomNavigationBar: TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.card_giftcard)),
                    Tab(icon: Icon(Icons.diversity_1)),
                    Tab(icon: Icon(Icons.account_circle)),
                  ],
                ),
                body: TabBarView(
                  children: [
                    Center(child: WishesScreen()),
                    Center(child: AllGroupsScreen()),
                    Center(child: Text("Noe profil-greier?")),
                  ],
                ))));
  }
}
