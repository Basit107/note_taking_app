import 'package:flutter/material.dart';
import 'package:note_taking_app/models/note.dart';
import 'package:note_taking_app/view_models/custom_auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:note_taking_app/view_models/note_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;
  const AddEditNoteScreen({super.key, this.note});

  @override
  _AddEditNoteScreenState createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String _title = '';
  late String _content = '';

  @override
  void initState() {
    if (widget.note != null) {
      _title = widget.note!.title;
      _content = widget.note!.content;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.note == null ? 'Add Note' : 'Edit Note')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(9.0),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 11.2,
              children: [
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: _title,
                  decoration: InputDecoration(
                      hintText: 'Title', contentPadding: EdgeInsets.all(7.0)),
                  validator: (value) =>
                      value!.isEmpty ? 'Title is required' : null,
                  onSaved: (value) => _title = value!,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: _content,
                  decoration: InputDecoration(
                      hintText: 'Content', contentPadding: EdgeInsets.all(7.0)),
                  maxLines: 5,
                  onSaved: (value) => _content = value!,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                    onPressed: () async {
                      if (widget.note == null) {
                        await _uploadNote();
                      } else {
                        await _saveNote();
                      }
                      Navigator.pop(context, true);
                    },
                    child: Text('Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _uploadNote() async {
    print('upload note');
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print('Note saved. Title: $_title, Content: $_content');

      try {
        final authProvider =
            Provider.of<CustomAuthProvider>(context, listen: false);
        final notesProvider =
            Provider.of<NotesProvider>(context, listen: false);

        final note = Note(
          noteId: widget.note?.noteId ?? '',
          title: _title,
          content: _content,
          createdAt: widget.note?.createdAt ?? Timestamp.now(),
          userId: authProvider.user!.uid,
        );

        await notesProvider.addNote(note);
        print('Note Added');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _saveNote() async {
    print('save note');
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print('Note saved. Title: $_title, Content: $_content');

      try {
        final authProvider =
            Provider.of<CustomAuthProvider>(context, listen: false);
        final notesProvider =
            Provider.of<NotesProvider>(context, listen: false);

        final note = Note(
          noteId: widget.note?.noteId ?? '',
          title: _title,
          content: _content,
          createdAt: widget.note?.createdAt ?? Timestamp.now(),
          userId: authProvider.user!.uid,
        );

        await notesProvider.updateNote(note);
        print('Note Updated');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}
