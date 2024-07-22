import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gaveliste_app/main.dart';
import 'package:gaveliste_app/util.dart';

import '../../data/group.dart';
import '../../data/wish.dart';

class AddWishesScreen extends StatefulWidget {
  const AddWishesScreen({super.key});

  @override
  State<AddWishesScreen> createState() => _AddWishesScreenState();
}

class _AddWishesScreenState extends State<AddWishesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  Occasion? _selectedOccasion;
  bool _isPrivate = false;
  Group? _selectedGroup;

  final Future<List<Group>> _groups = apiClient.groups();

  @override
  void dispose() {
    _descriptionController.dispose();
    _imageUrlController.dispose();
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
              _selectedGroup?.id)
          .then((wish) {
        if (kDebugMode) {
          print(wish.toJson());
        }
        Navigator.pop(context, wish);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Wish'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<Occasion>(
                value: _selectedOccasion,
                decoration: const InputDecoration(labelText: 'Occasion'),
                items: Occasion.values.map((Occasion occasion) {
                  return DropdownMenuItem<Occasion>(
                    value: occasion,
                    child: Text(occasion.name.toCapitalized()),
                  );
                }).toList(),
                onChanged: (Occasion? newValue) {
                  setState(() {
                    _selectedOccasion = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Group>>(
                future: _groups,
                builder: (BuildContext context,
                    AsyncSnapshot<List<Group>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Could not retrieve groups');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No groups found');
                  } else {
                    return DropdownButtonFormField<Group>(
                      decoration:
                          const InputDecoration(labelText: 'Select Group'),
                      value: _selectedGroup,
                      items: snapshot.data!.map((Group group) {
                        return DropdownMenuItem<Group>(
                          value: group,
                          child: Text(group.name),
                        );
                      }).toList(),
                      onChanged: (Group? newValue) {
                        setState(() {
                          _selectedGroup = newValue;
                        });
                      },
                    );
                  }
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
              SizedBox(
                height: 150.0, // Adjust height as needed
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Wish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
