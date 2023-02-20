import 'package:flutter/material.dart';
import 'package:todo_list_chat_gpt/src/features/todo_list/todo.dart';
import '../../api/chatgpt_client.dart';
import '../../data/database_helper.dart';

class TodoItemListView extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
  static const routeName = '/todo_item_list';
}

/// Displays a list of SampleItems.
class _TodoListState extends State<TodoItemListView> {
  List<Todo> _todoList = [];
  bool isLoading = false;

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
            decoration: const InputDecoration(hintText: 'Título'),
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

                setState(() {
                  isLoading = true;
                });

                final response = await getChatResponse(text);

                Todo task = Todo(
                    name: titleController.text.trim(),
                    isCompleted: false,
                    id: DateTime.now().microsecondsSinceEpoch);

                await DatabaseHelper.instance.insertTask(task);

                _getTasks();

                setState(() {
                  isLoading = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTodoList() {
    return ListView.builder(
      itemCount: _todoList.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              _todoList[index].name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
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
        title: Text('ChatGPT ToDo List'),
      ),
      body: Stack(children: [
        Column(
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
    );
  }
}
