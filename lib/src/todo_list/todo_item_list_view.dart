import 'package:flutter/material.dart';
import 'package:todo_list_chat_gpt/src/todo_list/todo.dart';

import '../data/database_helper.dart';
import '../sample_feature/sample_item.dart';
import '../sample_feature/sample_item_details_view.dart';
import '../settings/settings_view.dart';

class TodoItemListView extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
  static const routeName = '/';
}

/// Displays a list of SampleItems.
class _TodoListState extends State<TodoItemListView> {
  List<Todo> _todoList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getTasks();
  }

  void _getTasks() async {
    List<Todo> tasks = await DatabaseHelper.instance.getTasks();
    setState(() {
      _todoList = tasks;
    });
  }

  void _addTodoItem(String taskName) {
    setState(() {
      _todoList.add(Todo(
          name: taskName,
          isCompleted: false,
          id: DateTime.now().millisecondsSinceEpoch));
    });
  }

  void _removeTodoItem(int index) {
    setState(() {
      _todoList.removeAt(index);
    });
  }

  void _toggleTodoItem(int index) {
    setState(() {
      _todoList[index].isCompleted = !_todoList[index].isCompleted;
    });
  }

  Widget _buildTodoList() {
    return ListView.builder(
      itemCount: _todoList.length,
      itemBuilder: (context, index) {
        final task = _todoList[index];
        return ListTile(
          title: Text(task.name),
          trailing: Checkbox(
            value: task.isCompleted,
            onChanged: (value) {
              setState(() {
                task.isCompleted = value!;
                DatabaseHelper.instance.updateTask(task);
              });
            },
          ),
        );
      },
    );
  }

  void _showAddTaskDialog() {
    TextEditingController titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nova Tarefa'),
          content: TextField(
            autofocus: true,
            controller: titleController,
            decoration: InputDecoration(hintText: 'Título'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Adicionar'),
              onPressed: () async {
                Todo task = Todo(
                    name: titleController.text.trim(),
                    isCompleted: false,
                    id: DateTime.now().microsecondsSinceEpoch);
                await DatabaseHelper.instance.insertTask(task);
                _getTasks();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: Column(
        children: [
          TextField(
            onSubmitted: (String taskName) {
              _addTodoItem(taskName);
            },
            decoration: InputDecoration(
              hintText: 'Enter a task',
              contentPadding: EdgeInsets.all(16.0),
            ),
          ),
          Expanded(
            child: _buildTodoList(),
          ),
          FloatingActionButton(
            onPressed: _showAddTaskDialog,
            child: Icon(Icons.add),
          )
        ],
      ),
    );
  }
}
