import 'package:flutter/material.dart';
import 'package:note_taking_app/models/note.dart';
import 'package:note_taking_app/view_models/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:note_taking_app/view_models/note_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AddEditNoteScreen extends StatefulWidget {
  final Note? note;
  AddEditNoteScreen({this.note});

  @override
  _AddEditNoteScreenState createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _content;

  @override
  void initState() {
    if (widget.note != null) {
      _title = widget.note!.title;
      _content = widget.note!.content;
    }
    super.initState();
  }

  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final notesProvider = Provider.of<NotesProvider>(context, listen: false);

      final note = Note(
        noteId: widget.note?.noteId ?? '', // Empty for new notes
        title: _title,
        content: _content,
        createdAt: widget.note?.createdAt ?? Timestamp.now(),
        userId: authProvider.user!.uid,
      );

      if (widget.note == null) {
        await notesProvider.addNote(note);
      } else {
        await notesProvider.updateNote(note);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.note == null ? 'Add Note' : 'Edit Note')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Title is required' : null,
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                initialValue: _content,
                decoration: InputDecoration(labelText: 'Content'),
                maxLines: 5,
                onSaved: (value) => _content = value!,
              ),
              ElevatedButton(onPressed: _saveNote, child: Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}