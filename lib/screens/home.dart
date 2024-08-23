import 'package:flutter/material.dart';
import 'package:gaveliste_app/screens/user/user.dart';
import 'package:gaveliste_app/screens/wish/wish.dart';

import '../util.dart';
import 'group/groups.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: themeData,
        home: DefaultTabController(
            length: 3,
            child: Scaffold(
                bottomNavigationBar: Container(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: const TabBar(
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(icon: Icon(Icons.card_giftcard, size: 32)),
                      Tab(icon: Icon(Icons.diversity_1, size: 32)),
                      Tab(icon: Icon(Icons.account_circle, size: 32)),
                    ],
                  ),
                ),
                body: const TabBarView(
                  children: [
                    Center(child: WishesScreen()),
                    Center(child: AllGroupsScreen()),
                    Center(child: UserProfileScreen()),
                  ],
                ))));
  }
}
