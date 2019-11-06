import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_notekeepr_app/models/note.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; //Signature DatabaseHelper
  static Database _database;

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  // Get the database
  Future<Database> get database async {
    if (_database == null) {
      _database = await initializedDatabase();
    }
    return _database;
  }

  Future<Database> initializedDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';
    var notesDatabse = openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabse;
  }

  // create db
  void _createDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
        '$colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  // fetch operations: get all note objects from database
  Future<List<Map<String, dynamic>>>getNoteMapList() async {
    var db = await this.database;
    var result = await db.query(noteTable,  orderBy: '$colPriority ASC'); // table name and pass the
    return result;
  }

  // insert operations: into database from the database.
  Future<int> insertNote(Note note) async {
    var db = await this.database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  // Update operations : Update into database here
  Future<int> updateNote(Note note) async {
    var db = await this.database;
    var result = await db.update(noteTable, note.toMap(), where: '$colId = ?' , whereArgs: [note.id]);
    return result;
  }

  // Delete operations: delete this database from the database.
  Future<int> deleteNote(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
    return result;
  }

  // Count operations : count the database
  Future<int> getCount() async {
    var db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // get the list form the database
  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;

    List<Note> noteList = List<Note>();
    for ( int i = 0; i < count; i++ ) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }
}