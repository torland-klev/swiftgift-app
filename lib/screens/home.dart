import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        home: DefaultTabController(
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
                    Center(
                        child: Padding(
                            padding: EdgeInsets.all(30),
                            child: Text(
                                "Alle ønskene? Kanskje du kan velge mellom dine, legg til ny, og se alle i grupper du er med i?"))),
                    Center(child: Text("Alle gruppene?")),
                    Center(child: Text("Noe profil-greier?")),
                  ],
                ))));
  }
}
