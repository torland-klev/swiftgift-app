import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:swiftgift_app/data/user.dart';
import 'package:swiftgift_app/main.dart';

import '../../data/group.dart';

class AddGroupScreen extends StatefulWidget {
  const AddGroupScreen({super.key});

  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final _groupNameFormKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  final _groupNameFocusNode = FocusNode();
  bool _isPrivate = false;
  final List<User> _selectedUsers = List.empty(growable: true);

  final Future<List<User>> _users = apiClient.getOtherUsers();
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _groupNameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _pageController.dispose();
    _groupNameFocusNode.dispose();
    super.dispose();
  }

  void _submitForm() async {
    apiClient
        .postGroup(
            _groupNameController.text,
            _isPrivate ? GroupVisibility.private : GroupVisibility.public,
            _selectedUsers)
        .then((group) {
      if (mounted) Navigator.pop(context, group);
    });
  }

  void _goToPage(int pageIndex) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPageIndex = pageIndex;
      });
    }
  }

  void _nextPage() {
    if (_currentPageIndex >= 1) {
      FocusScope.of(context).unfocus();
      _submitForm();
    } else {
      if (_groupNameFormKey.currentState?.validate() != false) {
        FocusScope.of(context).unfocus();
        _goToPage(_currentPageIndex + 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Create Group",
            style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPageIndex = page;
                });
              },
              children: [
                _groupNamePage(),
                _addMembersPage(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Opacity(
                  opacity: _currentPageIndex > 0 ? 1.0 : 0,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, size: 50),
                    onPressed: () {
                      _goToPage(_currentPageIndex - 1);
                    },
                  ),
                ),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: 2,
                  effect: const WormEffect(),
                ),
                IconButton(
                  icon: Icon(
                    _currentPageIndex >= 1 ? Icons.check : Icons.arrow_forward,
                    color: _currentPageIndex >= 1 ? Colors.green : null,
                    size: 50,
                  ),
                  onPressed: _nextPage,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _groupNamePage() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 16),
      child: Form(
        key: _groupNameFormKey,
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('What should the group be called?',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 40),
            TextFormField(
              maxLength: 50,
              controller: _groupNameController,
              focusNode: _groupNameFocusNode,
              textAlign: TextAlign.center,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (value) {
                _nextPage();
              },
              onChanged: (value) {
                if (_groupNameFormKey.currentState?.validate() == false) {
                  setState(() {});
                }
              },
              decoration: const InputDecoration(
                errorStyle: TextStyle(height: 0),
                helperText: ' ',
              ),
              style: const TextStyle(fontSize: 30),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            )
          ]),
        ),
      ),
    );
  }

  Widget _addMembersPage() {
    return FutureBuilder<List<User>>(
      future: _users,
      builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Could not retrieve users'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No users found'));
        } else {
          var users = snapshot.data!
              .where((user) => user.displayName().isNotEmpty)
              .toList();
          users.sort((a, b) => a.displayName().compareTo(b.displayName()));

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add members',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      ...users.map((User user) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedUsers.contains(user)
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: ListTile(
                            title: Text(user.displayName()),
                            tileColor: _selectedUsers.contains(user)
                                ? Colors.blue.withValues(alpha: 0.1)
                                : null,
                            onTap: () {
                              setState(() {
                                if (_selectedUsers.contains(user)) {
                                  _selectedUsers.remove(user);
                                } else {
                                  _selectedUsers.add(user);
                                }
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
