import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gaveliste_app/main.dart';
import 'package:gaveliste_app/util.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../data/group.dart';
import '../../data/wish.dart';

class AddWishesScreen extends StatefulWidget {
  const AddWishesScreen({super.key});

  @override
  State<AddWishesScreen> createState() => _AddWishesScreenState();
}

class _AddWishesScreenState extends State<AddWishesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  Occasion? _selectedOccasion;
  bool _isPrivate = false;
  Group? _selectedGroup;

  final Future<List<Group>> _groups = apiClient.groups();
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      apiClient
          .postWish(
              _selectedOccasion ?? Occasion.none,
              _isPrivate
                  ? _selectedGroup == null
                      ? WishVisibility.private
                      : WishVisibility.group
                  : WishVisibility.public,
              _imageUrlController.text,
              _descriptionController.text,
              _selectedGroup?.id,
              _titleController.text)
          .then((wish) {
        if (kDebugMode) {
          print(wish.toJson());
        }
        Navigator.pop(context, wish);
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Wish'),
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
                _buildTitleImagePage(),
                _buildGroupPage(),
                _buildOccasionPage(),
                _buildDescriptionPage(),
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
                  child: ElevatedButton(
                    onPressed: () {
                      _goToPage(_currentPageIndex - 1);
                    },
                    child: const Text('Previous'),
                  ),
                ),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: 4,
                  effect: const WormEffect(),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_currentPageIndex >= 3) {
                      _submitForm();
                    } else {
                      _goToPage(_currentPageIndex + 1);
                    }
                  },
                  child: Text(
                      _currentPageIndex == 2 && _selectedOccasion == null ||
                              _currentPageIndex == 1 && _selectedGroup == null
                          ? "Skip"
                          : _currentPageIndex == 3
                              ? 'Add Wish'
                              : 'Next'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTitleImagePage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Wish Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value != null &&
                    value.isNotEmpty &&
                    !Uri.parse(value).isAbsolute) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Make private'),
              value: _isPrivate,
              onChanged: (bool value) {
                setState(() {
                  _isPrivate = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextFormField(
        controller: _descriptionController,
        decoration: const InputDecoration(
          labelText: 'Description',
          border: OutlineInputBorder(),
        ),
        maxLength: 200,
        textAlignVertical: TextAlignVertical.top,
        maxLines: null,
        expands: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a description';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildOccasionPage() {
    return FutureBuilder<List<Occasion>>(
      future: Future.value(Occasion.values),
      builder: (BuildContext context, AsyncSnapshot<List<Occasion>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Could not retrieve occasions'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No occasions found'));
        } else {
          // Filter out the `Occasion.none` value
          final occasions = snapshot.data!
              .where((occasion) => occasion != Occasion.none)
              .toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select an Occasion',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: occasions.map((Occasion occasion) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedOccasion == occasion
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: ListTile(
                          title: Text(occasion.name.toCapitalized()),
                          tileColor: _selectedOccasion == occasion
                              ? Colors.blue.withOpacity(0.1)
                              : null,
                          onTap: () {
                            setState(() {
                              if (_selectedOccasion == occasion) {
                                _selectedOccasion = null;
                              } else {
                                _selectedOccasion = occasion;
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildGroupPage() {
    return FutureBuilder<List<Group>>(
      future: _groups,
      builder: (BuildContext context, AsyncSnapshot<List<Group>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Could not retrieve groups'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No groups found'));
        } else {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select a Group',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: snapshot.data!.map((Group group) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedGroup == group
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: ListTile(
                          title: Text(group.name),
                          tileColor: _selectedGroup == group
                              ? Colors.blue.withOpacity(0.1)
                              : null,
                          onTap: () {
                            setState(() {
                              if (_selectedGroup == group) {
                                _selectedGroup = null;
                              } else {
                                _selectedGroup = group;
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),
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
