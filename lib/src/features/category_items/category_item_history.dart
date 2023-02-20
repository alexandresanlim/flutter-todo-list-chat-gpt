import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:todo_list_chat_gpt/src/features/category_items/category_item.dart';

import '../../arguments/screen_arguments.dart';
import '../../data/database_helper.dart';
import '../category_option/category_option.dart';
import '../todo_list/todo_item_list_view.dart';

class CategoryItemListPage extends StatefulWidget {
  const CategoryItemListPage({super.key});

  @override
  _CategoryItemListPageState createState() => _CategoryItemListPageState();
  static const routeName = '/category_item_history';
}

class _CategoryItemListPageState extends State<CategoryItemListPage> {
  List<CategoryItem> _items = [];
  int _currentCategory = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = (ModalRoute.of(context)!.settings.arguments ??
          <String, dynamic>{}) as Map;

      _currentCategory = int.parse(arguments['categoryId'] as String);

      _getTasks();
    });
  }

  void _showAddTaskDialog() {
    TextEditingController titleController = TextEditingController();
    String generatedMessage = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nova Tarefa'),
          content: TextField(
            autofocus: true,
            controller: titleController,
            decoration: const InputDecoration(hintText: 'Bolo de cenoura'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Adicionar'),
              onPressed: () async {
                Navigator.pop(context);

                final String text = titleController.text.trim();

                if (text.isEmpty) return;

                CategoryItem task = CategoryItem(
                    title: text,
                    id: DateTime.now().microsecondsSinceEpoch,
                    categoryId: _currentCategory);

                _addItem(task);
              },
            ),
          ],
        );
      },
    );
  }

  void _addItem(CategoryItem item) async {
    await DatabaseHelper.instance.insertCategoryItem(item);

    setState(() {
      _items.add(item);
    });
  }

  void _removeItem(int index) async {
    final CategoryItem item = _items.elementAt(index);

    await DatabaseHelper.instance.deleteCategoryItem(item.id);

    setState(() {
      _items.removeAt(index);
    });
  }

  void _getTasks() async {
    List<CategoryItem> tasks = await DatabaseHelper.instance
        .getCategoryItemsByCategoryId(_currentCategory);
    setState(() {
      _items = tasks;
    });
  }

  Widget _buildTodoList() {
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              _items[index].title,
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _removeItem(index),
            ),
            onTap: () {
              final CategoryItem item = _items.elementAt(index);

              final String itemId = item.id.toString();
              Navigator.restorablePushNamed(
                context,
                TodoItemListView.routeName,
                arguments: {'itemId': itemId},
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final arguments = (ModalRoute.of(context)?.settings.arguments ??
    //     <String, dynamic>{}) as Map;

    // _currentCategory = int.parse(arguments['categoryId'] as String);

    //_getTasks();

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Itens'),
      ),
      body: Column(children: [
        Expanded(
          child: _buildTodoList(),
        )
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
    );
  }
}
