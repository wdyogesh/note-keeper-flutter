import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_notekeepr_app/models/note.dart';
import 'package:flutter_notekeepr_app/utlis/database_helper.dart';
import 'package:flutter_notekeepr_app/screens/note_details.dart';
import 'package:sqflite/sqflite.dart';

class noteList extends StatefulWidget {
  @override
  _noteListState createState() => _noteListState();
}

class _noteListState extends State<noteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;
  @override

  Widget build(BuildContext context) {
    if (noteList == null) {
       noteList = List<Note>();
       updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('FAB Clicked ');
          navigationDetails(Note('','', 2) , 'Add Note');
        },

        tooltip: 'Add Notes',

        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getPriorityColor(this.noteList[position].priority),
              child: getPriorityIcon(this.noteList[position].priority),
            ),
            title: Text(
              this.noteList[position].title,
              style: titleStyle,
            ),
            subtitle: Text(this.noteList[position].date),
            trailing: GestureDetector(
              child: Icon(
                Icons.delete,
                color: Colors.grey,
              ),
              onTap:() {
                _delete(context, noteList[position]);
              },
            ),
            onTap: () {
              debugPrint('Title Tapped');
              navigationDetails(this.noteList[position] ,'Edit Note');

            },
          ),
        );
      },
    );
  }

  // Return the priority order
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;
      default:
        return Colors.yellow;
    }
  }
  // Return the priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;
      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0){
      _showSnackbar(context, 'Note Deleted Successfully !!');
      updateListView();
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigationDetails(Note note,String title) async{
    bool result =  await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return noteDetails(note, title);
    }));
    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializedDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
          setState(() {
            this.noteList = noteList;
            this.count = noteList.length;
          });
      });
    });
  }
}
