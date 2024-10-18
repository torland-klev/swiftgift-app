import 'package:flutter/material.dart';
import 'package:swiftgift_app/data/user.dart';
import 'package:swiftgift_app/main.dart';

class UpdateUserNameScreen extends StatefulWidget {
  const UpdateUserNameScreen({super.key, required this.user});
  final User user;
  @override
  State<UpdateUserNameScreen> createState() => _UpdateUserNameScreenState();
}

class _UpdateUserNameScreenState extends State<UpdateUserNameScreen> {
  final _pageController = PageController();
  final _nameFocusNode = FocusNode();
  final _nameController = TextEditingController();
  List<List<String>> _nameSplits = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameFocusNode.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _selectSplitPage() {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _addLastNamePage() {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleNameEntered(String value) {
    if (value.isNotEmpty) {
      List<String> names = value.split(' ');

      List<List<String>> combinations = [];

      if (names.length == 1) {
        combinations.add(names);
      }

      for (int i = 1; i < names.length; i++) {
        combinations
            .add([names.sublist(0, i).join(' '), names.sublist(i).join(' ')]);
      }

      setState(() {
        _nameSplits = combinations;
      });

      if (combinations.length > 1) {
        _selectSplitPage();
      } else if (combinations.length == 1 && combinations[0].length == 1) {
        _nameController.clear();
        _addLastNamePage();
      } else {
        _submitName(combinations[0][0], combinations[0][1]);
      }
    }
  }

  void _submitName(String firstName, String lastName) {
    apiClient.updateUser(firstName: firstName, lastName: lastName).then((user) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LandingPage(),
          ),
        );
      }
    });
  }

  void _handleLastNameEntered(String lastName) {
    _submitName(_nameSplits[0][0], lastName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                _buildEnterNamePage(),
                _buildAddLastNamePage(),
                _buildSelectNameVariationPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnterNamePage() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 16),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('What do you prefer to be called?',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center),
          const SizedBox(height: 40),
          TextField(
            focusNode: _nameFocusNode,
            controller: _nameController,
            textAlign: TextAlign.center,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              errorStyle: TextStyle(height: 0),
              helperText: ' ',
            ),
            style: const TextStyle(fontSize: 22),
            onSubmitted: _handleNameEntered,
          )
        ]),
      ),
    );
  }

  Widget _buildSelectNameVariationPage() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 150),
            Text(
              'Which of these are correct?',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView.builder(
                itemCount: _nameSplits.length,
                itemBuilder: (context, index) {
                  final nameCombo = _nameSplits[index];
                  final firstName = nameCombo[0];
                  final lastName = nameCombo[1];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: InkWell(
                      onTap: () {
                        _submitName(firstName, lastName);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Firstname: $firstName',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Lastname: $lastName',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddLastNamePage() {
    if (_nameSplits.isEmpty || _nameSplits[0].isEmpty) {
      return const SizedBox.shrink();
    }
    var name = _nameSplits[0][0];
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 16),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Do you have any last name, $name?',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center),
          const SizedBox(height: 40),
          TextField(
            focusNode: _nameFocusNode,
            controller: _nameController,
            textAlign: TextAlign.center,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              errorStyle: TextStyle(height: 0),
              helperText: ' ',
            ),
            style: const TextStyle(fontSize: 22),
            onSubmitted: _handleLastNameEntered,
          )
        ]),
      ),
    );
  }
}
