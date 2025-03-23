import 'package:flutter/material.dart';
import 'package:swiftgift_app/screens/user/user.dart';
import 'package:swiftgift_app/screens/users/all_users.dart';
import 'package:swiftgift_app/screens/wish/add_wish.dart';
import 'package:swiftgift_app/screens/wish/my_wishes.dart';
import '../util.dart';
import 'group/add_group.dart';
import 'group/groups.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleAddButton(BuildContext context) {
    if (_tabController.index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddGroupScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddOrEditWishScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: themeData,
      home: Scaffold(
        bottomNavigationBar: Container(
          padding: const EdgeInsets.only(bottom: 30),
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(icon: Icon(Icons.card_giftcard, size: 28)),
                  Tab(icon: Icon(Icons.diversity_1, size: 28)),
                  SizedBox.shrink(),
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
                    onPressed: () => _handleAddButton(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            MyWishesScreen(),
            AllGroupsScreen(),
            AddOrEditWishScreen(),
            AllUsersScreen(),
            UserProfileScreen(),
          ],
        ),
      ),
    );
  }
}
