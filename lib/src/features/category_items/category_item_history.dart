import 'package:flutter/material.dart';
import 'package:todo_list_chat_gpt/src/features/category_items/category_item.dart';
import '../../data/database_helper.dart';
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
  String _titlePage = '';
  String _startPrompt = '';
  String _placeHolder = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = (ModalRoute.of(context)!.settings.arguments ??
          <String, dynamic>{}) as Map;

      _currentCategory = int.parse(arguments['categoryId'] as String);
      _titlePage = arguments['titlePage'] as String;
      _startPrompt = arguments['startPrompt'] as String;
      _placeHolder = arguments['placeHolder'] as String;

      _getTasks();
    });
  }

  void _showAddTaskDialog() {
    TextEditingController titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar'),
          content: TextField(
            autofocus: true,
            controller: titleController,
            decoration: InputDecoration(hintText: 'Ex: $_placeHolder'),
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

    await DatabaseHelper.instance.deleteTasksByCategoryItemId(item.id);

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
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              _items[index].title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removeItem(index),
            ),
            onTap: () {
              final CategoryItem item = _items.elementAt(index);

              final String itemId = item.id.toString();
              Navigator.restorablePushNamed(
                context,
                TodoItemListView.routeName,
                arguments: {'itemId': itemId, 'startPrompt': _startPrompt},
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titlePage),
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
