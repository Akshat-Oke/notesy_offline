import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notesy_offline/models/note_model.dart';
import 'package:hive/hive.dart';

class OldNoteService with ChangeNotifier {
  final _userId = FirebaseAuth.instance.currentUser?.uid;

  late var _collection; //FirebaseFirestore.instance.collection(_userId!);
  OldNoteService() {
    _collection = FirebaseFirestore.instance.collection(_userId!);
    LoggedInUser._userId = _userId;
  }
  void addNote(BuildContext context,
      {String? title, String? content, String? color}) async {
    if (title == null && content == null) {
      return;
    }
    await _collection
        .add({'title': title, 'content': content, 'color': color ?? "NULL"});
    Navigator.pop(context);
  }
}

extension NoteDocument on DocumentSnapshot {
  Note? toNote() => exists
      ? Note(
          id: id,
          title: data()?['title'],
          content: data()?['content'],
          color: data()?['color'],
          createdAt:
              DateTime.fromMillisecondsSinceEpoch(data()?['createdAt'] ?? 0),
          modifiedAt:
              DateTime.fromMillisecondsSinceEpoch(data()?['modifiedAt'] ?? 0),
        )
      : null;
}

extension NoteStore on Note {
  Future<dynamic> saveToFireStore({required String boxName}) async {
    final box = Hive.box<Note>(boxName);
    if (this.id == null)
      return box.add(this);
    else
      return box.put(this.key, this);
    // final collection = FirebaseFirestore.instance.collection('notes-$uid');
    // return id == null ? collection.add(toJson()) : collection.doc(id).update(toJson());
  }

  Future<dynamic> deleteFromFireStore(String boxName) async {
    final box = Hive.box<Note>(boxName);
    return box.delete(this.key);
    // final collection = FirebaseFirestore.instance.collection('notes-$uid');
    // return id == null ? Future.value(null) : collection.doc(id).delete();
  }

  Future<dynamic> addReminder(String boxName) async {
    final box = Hive.box<Note>(boxName);
    if (this.id != null) {
      print("notification saved");
      return box.put(this.key, this);
    } else
      return Future.value(false);
  }

  Future<dynamic> deleteReminder(String boxName) async {
    final box = Hive.box<Note>(boxName);
    this.deleteLocalReminder();
    if (this.id != null)
      return box.put(this.id, this);
    else
      return Future.value(false);
  }
  //   if (uid != null) {
  //     this.deleteLocalReminder();
  //     final collection = FirebaseFirestore.instance.collection('notes-$uid');
  //     return id == null ? Future.value(null) : collection.doc(id).update({'remindAt': 0});
  //   } else
  //     return Future.value(false);
  // }
}

class LoggedInUser {
  static var _userId = FirebaseAuth.instance.currentUser?.uid;

  static final collection = FirebaseFirestore.instance.collection(_userId!);
}
