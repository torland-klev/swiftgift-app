import 'package:flutter/material.dart';
import 'package:swiftgift_app/screens/user/user.dart';
import 'package:swiftgift_app/screens/users/groups.dart';
import 'package:swiftgift_app/screens/wish/add_wish.dart';
import 'package:swiftgift_app/screens/wish/my_wishes.dart';

import '../util.dart';
import 'group/groups.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: themeData,
      home: DefaultTabController(
        length: 5,
        child: Scaffold(
          bottomNavigationBar: Container(
            padding: const EdgeInsets.only(bottom: 30),
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                const TabBar(
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: [
                    Tab(icon: Icon(Icons.card_giftcard, size: 28)),
                    Tab(icon: Icon(Icons.diversity_1, size: 28)),
                    SizedBox.shrink(), // Placeholder for Add button
                    Tab(icon: Icon(Icons.group, size: 28)),
                    Tab(icon: Icon(Icons.account_circle, size: 28)),
                  ],
                ),
                Positioned(
                  top: -15,
                  child: Material(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    color: Colors.white,
                    child: IconButton(
                      iconSize: 40,
                      padding: const EdgeInsets.all(12.0),
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddWishesScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              MyWishesScreen(),
              AllGroupsScreen(),
              AddWishesScreen(),
              AllUsersScreen(),
              UserProfileScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
