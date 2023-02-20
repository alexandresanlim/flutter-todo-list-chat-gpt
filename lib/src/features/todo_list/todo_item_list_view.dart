import 'package:flutter/material.dart';
import 'package:todo_list_chat_gpt/src/features/category_items/category_item.dart';
import 'package:todo_list_chat_gpt/src/features/todo_list/todo.dart';
import '../../api/chatgpt_client.dart';
import '../../data/database_helper.dart';

class TodoItemListView extends StatefulWidget {
  const TodoItemListView({super.key});

  @override
  _TodoListState createState() => _TodoListState();
  static const routeName = '/todo_item_list';
}

/// Displays a list of SampleItems.
class _TodoListState extends State<TodoItemListView> {
  List<Todo> _todoList = [];
  CategoryItem? _currentCategoryItem;
  String _startPrompt = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final arguments = (ModalRoute.of(context)!.settings.arguments ??
          <String, dynamic>{}) as Map;

      final int categoryItemId = int.parse(arguments['itemId'] as String);
      _startPrompt = arguments['startPrompt'] as String;

      _currentCategoryItem =
          await DatabaseHelper.instance.getCategoryItemById(categoryItemId);

      _getTasks();
    });
  }

  void _getTasks() async {
    if (_currentCategoryItem != null) {
      List<Todo> tasks = await DatabaseHelper.instance
          .getTasksByCategoryItemId(_currentCategoryItem?.id ?? 0);

      if (tasks.isEmpty) {
        setState(() {
          isLoading = true;
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
          isLoading = false;
        });

        _getTasks();
      }

      setState(() {
        _todoList = tasks;
      });
    }
  }

  Widget _buildTodoList() {
    return ListView.builder(
      itemCount: _todoList.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              _todoList[index].name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color:
                    _todoList[index].isCompleted ? Colors.grey : Colors.black,
                decoration: _todoList[index].isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            trailing: Icon(
              _todoList[index].isCompleted
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              color: _todoList[index].isCompleted ? Colors.grey : Colors.black,
            ),
            onTap: () {
              setState(() {
                _todoList[index].isCompleted = !_todoList[index].isCompleted;
                DatabaseHelper.instance.updateTask(_todoList[index]);
                _getTasks();
              });
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
        title: Text(_currentCategoryItem?.title ?? ''),
      ),
      body: Stack(children: [
        Column(
          children: [
            Expanded(
              child: _buildTodoList(),
            ),
          ],
        ),
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
      ]),
    );
  }
}
