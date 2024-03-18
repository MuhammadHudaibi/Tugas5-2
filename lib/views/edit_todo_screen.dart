import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tugas5_2/models/todo.dart';
import 'package:tugas5_2/utils/DBHelper.dart';

class EditTodoScreen extends StatefulWidget {
  final Todo todo;

  EditTodoScreen({required this.todo});

  @override
  _EditTodoScreenState createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends State<EditTodoScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  FocusNode descriptionFocusNode = FocusNode();
    

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController =
        TextEditingController(text: widget.todo.description);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ), 
        title: Text('Edit Todo'),
        titleTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title', labelStyle: GoogleFonts.poppins()),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description', labelStyle: GoogleFonts.poppins()),
              maxLines: null,
              focusNode: descriptionFocusNode,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                _updateTodo();
              },
              child: Text('Save Changes', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _updateTodo() async {
    Todo updatedTodo = Todo(
      id: widget.todo.id,
      title: _titleController.text,
      description: _descriptionController.text,
      isDone: widget.todo.isDone,
    );
    await DBHelper.instance.updateTodo(updatedTodo);
    Navigator.pop(context);
  }
}
