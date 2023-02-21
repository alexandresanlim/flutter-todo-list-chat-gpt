import 'package:flutter/material.dart';
import 'package:todo_list_chat_gpt/src/extensions/string_extension.dart';
import 'package:todo_list_chat_gpt/src/features/category_items/category_item.dart';
import 'package:todo_list_chat_gpt/src/features/todo_list/todo.dart';
import '../../api/chatgpt_client.dart';
import '../../data/database_helper.dart';

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
  List<Todo> _todoList = [];
  CategoryItem? _currentCategoryItem;
  bool isLoading = false;

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

                final String text = titleController.text.trim().capitalize();

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

  Future<bool?> _showDeleteConfirmationDialog(CategoryItem item) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir item'),
        content: Text('Tem certeza que deseja excluir ${item.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sim'),
          ),
        ],
      ),
    );
  }

  void _removeItem(CategoryItem item) async {
    final bool confirmation =
        await _showDeleteConfirmationDialog(item) ?? false;

    if (!confirmation) return;

    await DatabaseHelper.instance.deleteCategoryItem(item.id);

    await DatabaseHelper.instance.deleteTasksByCategoryItemId(item.id);

    setState(() {
      _items.remove(item);
    });
  }

  void _getTasks() async {
    List<CategoryItem> tasks = await DatabaseHelper.instance
        .getCategoryItemsByCategoryId(_currentCategory);
    setState(() {
      _items = tasks;
    });
  }

  void _getTasksByCurrentCategoryItem(int index, bool isExpanded) async {
    if (isExpanded) {
      setState(() {
        _items[index].isExpanded = false;
      });
      return;
    }

    if (_currentCategoryItem != null) {
      List<Todo> tasks = await DatabaseHelper.instance
          .getTasksByCategoryItemId(_currentCategoryItem?.id ?? 0);

      if (tasks.isEmpty) {
        setState(() {
          _items[index].isLoading = true;
        });
        final ChatMessage response = await getChatResponse(
            '$_startPrompt ${_currentCategoryItem!.title}');

        if (response.firstSteps.isNotEmpty) {
          for (String line in response.firstSteps) {
            final Todo task = Todo(
                name: line,
                isCompleted: false,
                categoryItemId: _currentCategoryItem?.id ?? 0,
                id: DateTime.now().microsecondsSinceEpoch);

            await DatabaseHelper.instance.insertTask(task);
          }
        }

        if (response.steps.isNotEmpty) {
          for (String line in response.steps) {
            final Todo task = Todo(
                name: line,
                isCompleted: false,
                categoryItemId: _currentCategoryItem?.id ?? 0,
                id: DateTime.now().microsecondsSinceEpoch);

            await DatabaseHelper.instance.insertTask(task);
          }
        }

        setState(() {
          _items[index].isLoading = false;
        });

        _getTasksByCurrentCategoryItem(index, isExpanded);

        return;
      }

      setState(() {
        _todoList = tasks;
        _items[index].isExpanded = true;
      });
    }
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        _currentCategoryItem = _items[index];

        _getTasksByCurrentCategoryItem(index, isExpanded);
      },
      children: _items.map<ExpansionPanel>((CategoryItem item) {
        return ExpansionPanel(
          canTapOnHeader: false,
          headerBuilder: (BuildContext context, bool isExpanded) {
            if (item.isLoading) {
              return ListTile(
                title: Text(
                  item.title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Buscando lista via ChatGPT 🤖',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                leading: const CircularProgressIndicator(),
              );
            }

            return ListTile(
              onLongPress: () => _removeItem(item),
              title: Text(
                item.title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            );
          },
          body: Column(
            children: _todoList.map<Widget>((subItem) {
              return Card(
                child: ListTile(
                  title: Text(
                    subItem.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: subItem.isCompleted ? Colors.grey : Colors.black,
                      decoration: subItem.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  trailing: Icon(
                    subItem.isCompleted
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: subItem.isCompleted ? Colors.grey : Colors.black,
                  ),
                  onTap: () {
                    setState(() {
                      subItem.isCompleted = !subItem.isCompleted;
                      DatabaseHelper.instance.updateTask(subItem);
                    });
                  },
                ),
              );
            }).toList(),
          ),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titlePage),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: _buildPanel(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        icon: const Icon(Icons.add),
        label: const Text(
          'Adicionar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
