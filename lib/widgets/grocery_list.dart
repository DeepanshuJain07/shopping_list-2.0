import 'package:flutter/material.dart';
import 'package:shopping_list_1/data/categories.dart';
import 'package:shopping_list_1/models/grocery_item.dart';
import 'package:shopping_list_1/widgets/new_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];

  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
      'flutter-prep1-32dff-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        _error = 'Failed to Fetch Data. Please Try again later';
      }
      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);

      final List<GroceryItem> loadedItems = [];

      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
              (catElement) => catElement.value.title == item.value['category'],
            )
            .value;
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Something Went Wrong. Please Try again later';
      });
    }
  }

  void _addItem() async {
    final groceryData = await Navigator.of(
      context,
    ).push<GroceryItem>(MaterialPageRoute(builder: (ctx) => const NewItem()));

    if (groceryData == null) {
      return;
    }

    setState(() {
      _groceryItems.add(groceryData);
    });
  }

  void removeItem(GroceryItem newItem) async {
    final groceryItemIndex = _groceryItems.indexOf(newItem);
    setState(() {
      _groceryItems.remove(newItem);
    });

    final url = Uri.https(
      'flutter-prep1-32dff-default-rtdb.firebaseio.com',
      'shopping-list/${newItem.id}.json',
    );
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(groceryItemIndex, newItem);
      });
    }
  
    ScaffoldMessenger.of(context).clearSnackBars();
   
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Grocery Item Deleted'),
        duration: Duration(seconds: 7),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _groceryItems.insert(groceryItemIndex, newItem);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'You got no Items here!',
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Try adding some Item here",
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );

    if (_isLoading) {
      content = Center(child: CircularProgressIndicator());
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) => Dismissible(
          background: Container(
            color: Theme.of(context).colorScheme.error,
            margin: EdgeInsets.symmetric(
              horizontal: Theme.of(context).cardTheme.margin?.horizontal ?? 8,
            ),
          ),
          key: ValueKey(_groceryItems[index]),
          onDismissed: (direction) => removeItem(_groceryItems[index]),
          child: ListTile(
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            title: Text(_groceryItems[index].name),
            trailing: Text(_groceryItems[index].quantity.toString()),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(child: Text(_error!));
    }
    //   );
    // Widget buildEmptyContent() {
    //   return Center(
    //     child: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         Text(
    //           'You got no Items here!',
    //           style: Theme.of(context).textTheme.headlineMedium!.copyWith(
    //             color: Theme.of(context).colorScheme.onSurface,
    //           ),
    //         ),
    //         SizedBox(height: 5),
    //         Text(
    //           "Try adding some Item here",
    //           style: Theme.of(context).textTheme.labelMedium!.copyWith(
    //             color: Theme.of(context).colorScheme.onSurface,
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
    // }

    // Widget buildGroceryList() {
    //   return ListView.builder(
    //     itemCount: _groceryItems.length,
    //     itemBuilder: (context, index) => Dismissible(
    //       background: Container(
    //         color: Theme.of(context).colorScheme.error,
    //         margin: EdgeInsets.symmetric(
    //           horizontal: Theme.of(context).cardTheme.margin?.horizontal ?? 8,
    //         ),
    //       ),
    //       key: ValueKey(_groceryItems[index]),
    //       onDismissed: (direction) => removeItem(_groceryItems[index]),
    //       child: ListTile(
    //         leading: Container(
    //           width: 24,
    //           height: 24,
    //           color: _groceryItems[index].category.color,
    //         ),
    //         title: Text(_groceryItems[index].name),
    //         trailing: Text(_groceryItems[index].quantity.toString()),
    //       ),
    //     ),
    //   );
    // }
    // Yaha par humne Extract method ka use kiya hai, jisme hum apne widgets ko alag se helper method me nikal lete hai.
    //hum yaha par aur bhi kayi tariko ka use kar sakte hai.

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Groceries',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [IconButton(onPressed: _addItem, icon: Icon(Icons.add))],
      ),

      //body: _groceryItems.isEmpty ? buildEmptyContent() : buildGroceryList(),
      body: content,
    );
  }
}
