import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list_1/data/categories.dart';
import 'package:shopping_list_1/models/category.dart';
// import 'package:shopping_list_1/models/grocery_item.dart';
import'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});
 

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var enteredName = " ";
  var enteredQuantity = 1;
  var selectedcategory = categories[Categories.vegetables]!;

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final url = Uri.https(
        'flutter-prep1-32dff-default-rtdb.firebaseio.com', 'shopping-list.json');
      http.post(url,headers: {
       'Content-Type': 'application/json'
      },
      body: json.encode({
        'name': enteredName,
          'quantity': enteredQuantity,
         'category': selectedcategory.title,
      }),
      );
      // Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add a New Item',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),

      body: Padding(
        padding: EdgeInsetsGeometry.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: InputDecoration(label: Text('Text')),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must add a valid text between 1 to 50 characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  enteredName = value!;
                },
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(label: Text('Quantity')),
                      keyboardType: TextInputType.number,
                      initialValue: enteredQuantity.toString(),

                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must add a valid, positive number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      initialValue: selectedcategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                SizedBox(width: 6),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedcategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
             

              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                    },
                    child: Text('Reset'),
                  ),
                  ElevatedButton(onPressed: _saveItem, child: Text('Add Item')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
