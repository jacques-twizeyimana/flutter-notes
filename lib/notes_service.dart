
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Note {
  final String id;
  final String text;
  final String userId;
  final Timestamp timestamp;

  Note({
    required this.id,
    required this.text,
    required this.userId,
    required this.timestamp,
  });

  factory Note.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Note(
      id: doc.id,
      text: data['text'] ?? '',
      userId: data['userId'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'userId': userId,
      'timestamp': timestamp,
    };
  }
}

class NotesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<List<Note>> getNotes() {
    if (currentUser == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('notes')
        .where('userId', isEqualTo: currentUser!.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
    });
  }

  Future<void> addNote(String text) async {
    if (currentUser == null) return;
    await _firestore.collection('notes').add({
      'text': text,
      'userId': currentUser!.uid,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> updateNote(String id, String text) async {
    await _firestore.collection('notes').doc(id).update({
      'text': text,
    });
  }

  Future<void> deleteNote(String id) async {
    await _firestore.collection('notes').doc(id).delete();
  }
}
