import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tugas5_2/models/todo.dart';
import 'package:tugas5_2/utils/DBHelper.dart';
import 'edit_todo_screen.dart';

class TodoApp extends StatefulWidget {
  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final dbHelper = DBHelper.instance;
  late Future<List<Todo>> todosFuture;

  @override
  void initState() {
    super.initState();
    todosFuture = dbHelper.getTodos();
  }
  

  void _showAddTodoDialog() async {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    
    FocusNode descriptionFocusNode = FocusNode();
    
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Todo', style: GoogleFonts.poppins(),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title', labelStyle: GoogleFonts.poppins()),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description', labelStyle: GoogleFonts.poppins()),
                maxLines: null,
                focusNode: descriptionFocusNode,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: GoogleFonts.poppins(),),
            ),
            TextButton(
              onPressed: () async {
                await dbHelper.insertTodo(Todo(
                  title: titleController.text,
                  description: descriptionController.text,
                ));
                setState(() {
                  todosFuture = dbHelper.getTodos();
                });
                Navigator.pop(context);
              },
              child: Text('Add', style: GoogleFonts.poppins(),),
            ),
          ],
        );
      },
    );
  }

  void _editTodoScreen(BuildContext context, Todo todo) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTodoScreen(todo: todo)),
    );
    setState(() {
      todosFuture = dbHelper.getTodos();
    });
  }

  void _deleteTodo(Todo todo) async {
    await dbHelper.deleteTodo(todo.id!);
    setState(() {
      todosFuture = dbHelper.getTodos();
    });
  }

  void _toggleTodoStatus(Todo todo) async {
    Todo updatedTodo = Todo(
      id: todo.id,
      title: todo.title,
      description: todo.description,
      isDone: !todo.isDone, // Mengubah status todo menjadi kebalikan dari status sebelumnya
    );
    await dbHelper.updateTodo(updatedTodo);
    setState(() {
      todosFuture = dbHelper.getTodos();
    });
  }

  void _showTodoDetailsBottomSheet(Todo todo) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                todo.title,
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                todo.description,
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _editTodoScreen(context, todo);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: Text(
                      'Edit',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteTodoConfirmation(todo);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      'Delete',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }


  void _deleteTodoConfirmation(Todo todo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Todo', style: GoogleFonts.poppins(),),
          content: Text('Are you sure you want to delete this todo?', style: GoogleFonts.poppins(),),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: GoogleFonts.poppins(),),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteTodo(todo);
              },
              child: Text('Delete', style: GoogleFonts.poppins(),),
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
        titleTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<Todo>>(
        future: todosFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final todo = snapshot.data![index];
                return ListTile(
                  title: Text(todo.title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  subtitle: Text(todo.description, style: GoogleFonts.poppins()),
                
                  onTap: () {
                    _showTodoDetailsBottomSheet(todo);
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          todo.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: todo.isDone ? Colors.green : Colors.grey,
                        ),
                        onPressed: () {
                          _toggleTodoStatus(todo);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}", style: GoogleFonts.poppins()),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        shape: CircleBorder(),
        tooltip: 'Add Todo',
        child: Icon(Icons.add, color: Colors.white,),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
