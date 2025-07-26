import 'package:flutter/material.dart';
import 'notes_service.dart';
import 'dart:async';

class NotesProvider with ChangeNotifier {
  final NotesService _notesService = NotesService();

  List<Note> _notes = [];
  List<Note> get notes => _notes;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  StreamSubscription<List<Note>>? _notesSubscription;

  NotesProvider() {
    _startNotesSubscription();
  }

  void _startNotesSubscription() {
    _isLoading = true;
    notifyListeners();
    _notesSubscription = _notesService.fetchNotes().listen(
      (notes) {
        _notes = notes;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        notifyListeners();
        // Handle error appropriately, maybe show a snackbar
        debugPrint('Error fetching notes: $error');
      },
    );
  }

  Future<void> addNote(String text) async {
    await _notesService.addNote(text);
  }

  Future<void> updateNote(String id, String text) async {
    await _notesService.updateNote(id, text);
  }

  Future<void> deleteNote(String id) async {
    await _notesService.deleteNote(id);
  }

  @override
  void dispose() {
    _notesSubscription?.cancel();
    super.dispose();
  }
}
