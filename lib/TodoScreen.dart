import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'LoginPage.dart';

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class Task {
  String id; // Document ID from Firestore
  String title;
  bool completed;

  Task({this.id = '', required this.title, this.completed = false});
}

class _TodoScreenState extends State<TodoScreen> {
  List<Task> todos = [];
  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: TaskSearchDelegate(todos),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Account'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Change Account'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final task = todos[index];
          return ListTile(
            title: Text(task.title),
            leading: Checkbox(
              value: task.completed,
              onChanged: (value) async {
                setState(() {
                  task.completed = value ?? false;
                });
                await FirebaseFirestore.instance.collection('tasks').doc(task.id).update({
                  'completed': task.completed,
                });
              },
            ),
            onTap: () {
              editTask(context, task, _textEditingController);
            },
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('tasks').doc(task.id).delete();
                setState(() {
                  todos.removeAt(index);
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('New Task'),
                content: TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration(hintText: 'Enter task...'),
                ),
                actions: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _textEditingController.clear();
                    },
                  ),
                  TextButton(
                    child: Text('Add'),
                    onPressed: () async {
                      final newTask = Task(title: _textEditingController.text);
                      await FirebaseFirestore.instance.collection('tasks').add({
                        'title': newTask.title,
                        'completed': newTask.completed,
                      }).then((value) {
                        newTask.id = value.id;
                        setState(() {
                          todos.add(newTask);
                          _textEditingController.clear();
                        });
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class TaskSearchDelegate extends SearchDelegate<Task> {
  final List<Task> tasks;

  TaskSearchDelegate(this.tasks);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, Task(title:''));
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final taskSuggestions = query.isEmpty
        ? tasks
        : tasks.where((task) {
      return task.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
        itemCount: taskSuggestions.length,
        itemBuilder:(context, index){
          return ListTile(
              title : Text(taskSuggestions[index].title),
              onTap : (){
                close(context,taskSuggestions[index]);
              }
          );
        }
    );
  }
}

void editTask(BuildContext context, Task task, TextEditingController _textEditingController) {
  _textEditingController.text = task.title;
  _textEditingController.selection = TextSelection.fromPosition(
    TextPosition(offset: _textEditingController.text.length),
  );

  FocusScope.of(context).requestFocus(FocusNode());
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _textEditingController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Edit task...',
                  border: InputBorder.none,
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(width: 8.0),
                  TextButton(
                    child: Text('Save'),
                    onPressed: () async {
                      task.title = _textEditingController.text;
                      await FirebaseFirestore.instance
                          .collection('tasks')
                          .doc(task.id)
                          .update({
                        'title': task.title,
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}