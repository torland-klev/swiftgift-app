import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gaveliste_app/main.dart';
import 'package:gaveliste_app/util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../data/group.dart';
import '../../data/wish.dart';

class AddWishesScreen extends StatefulWidget {
  const AddWishesScreen({super.key});

  @override
  State<AddWishesScreen> createState() => _AddWishesScreenState();
}

class _AddWishesScreenState extends State<AddWishesScreen> {
  final _titleFormKey = GlobalKey<FormState>();
  final _imageFormKey = GlobalKey<FormState>();
  final _descriptionFormKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _titleFocusNode = FocusNode();
  File? _selectedImage;
  Occasion? _selectedOccasion;
  bool _isPrivate = false;
  Group? _selectedGroup;

  final Future<List<Group>> _groups = apiClient.groups();
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Request focus when the widget is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pageController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _submitForm() async {
    String? imageUrl = _selectedImage != null
        ? await apiClient.uploadImage(_selectedImage!)
        : null;

    apiClient
        .postWish(
            _selectedOccasion ?? Occasion.none,
            _isPrivate
                ? _selectedGroup == null
                    ? WishVisibility.private
                    : WishVisibility.group
                : WishVisibility.public,
            imageUrl,
            _descriptionController.text,
            _selectedGroup?.id,
            _titleController.text)
        .then((wish) {
      Navigator.pop(context, wish);
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
    if (_currentPageIndex >= 4) {
      if (_descriptionFormKey.currentState?.validate() != false) {
        FocusScope.of(context).unfocus();
        _submitForm();
      }
    } else {
      if (_titleFormKey.currentState?.validate() != false) {
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
        title:
            Text('Add Wish', style: Theme.of(context).textTheme.headlineMedium),
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
                _buildTitlePage(),
                _buildImagePage(),
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
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, size: 50),
                    onPressed: () {
                      _goToPage(_currentPageIndex - 1);
                    },
                  ),
                ),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: 5,
                  effect: const WormEffect(),
                ),
                IconButton(
                  icon: Icon(
                    _currentPageIndex >= 4 ? Icons.check : Icons.arrow_forward,
                    color: _currentPageIndex >= 4 ? Colors.green : null,
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

  Widget _buildTitlePage() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 16),
      child: Form(
        key: _titleFormKey,
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('What is it you wish for?',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 40),
            TextFormField(
              maxLength: 50,
              controller: _titleController,
              focusNode: _titleFocusNode,
              textAlign: TextAlign.center,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (value) {
                _nextPage();
              },
              onChanged: (value) {
                if (_titleFormKey.currentState?.validate() == false) {
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
                  return 'Please enter a title';
                }
                return null;
              },
            )
          ]),
        ),
      ),
    );
  }

  Widget _buildImagePage() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 32, bottom: 16),
      child: Form(
        key: _imageFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.file_upload,
                              size: 60, color: Colors.blueGrey),
                          Text("Select file", style: TextStyle(fontSize: 20)),
                        ],
                      ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Text("or"),
            ),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Open Camera & Take Photo"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionPage() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 16),
      child: Form(
        key: _descriptionFormKey,
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Add any more information?',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 40),
            TextFormField(
              maxLength: 250,
              keyboardType: TextInputType.text,
              minLines: 1,
              maxLines: 8,
              controller: _descriptionController,
              textAlign: TextAlign.center,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (value) {
                _nextPage();
              },
              decoration: const InputDecoration(
                errorStyle: TextStyle(height: 0),
                helperText: ' ',
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            )
          ]),
        ),
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
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _isPrivate ? Colors.blueAccent : Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: ListTile(
                          title: const Text("Only for me"),
                          tileColor:
                              _isPrivate ? Colors.blue.withOpacity(0.1) : null,
                          onTap: () {
                            setState(() {
                              if (!_isPrivate) {
                                _selectedGroup = null;
                                _isPrivate = true;
                              } else {
                                _isPrivate = false;
                              }
                            });
                          },
                        ),
                      ),
                      ...snapshot.data!.map((Group group) {
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
                                  _isPrivate = false;
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
