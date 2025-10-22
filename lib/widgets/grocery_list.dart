import 'package:flutter/material.dart';
import 'package:shopping_list_1/data/dummy_items.dart';
import 'package:shopping_list_1/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  void _addItem() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (ctx) => const NewItem()));
  }

  @override
  Widget build(BuildContext context) {
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
      body: ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Container(
              width: 24,
              height: 24,
              color: groceryItems[index].category.color,
            ),
            title: Text(groceryItems[index].name),
            trailing: Text(groceryItems[index].quantity.toString()),
          );
        },
      ),
    );
  }
}
