import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_notekeepr_app/models/note.dart';
import 'package:flutter_notekeepr_app/utlis/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class noteDetails extends StatefulWidget {
  final String appBarTitle;
  final Note note;
  noteDetails(this.note, this.appBarTitle);

  @override
  _noteDetailsState createState() {
    return _noteDetailsState(this.note, this.appBarTitle);
  }
}
class _noteDetailsState extends State<noteDetails> {
  DatabaseHelper helper = DatabaseHelper();
  String appBarTitle;
  Note note;
  static var _priorites = ['High', 'Low'];
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  _noteDetailsState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.subhead;
    TextStyle mTextStyle =
    Theme.of(context).textTheme.subtitle.copyWith(fontSize: 18.0);
    TextStyle mButtonTextStyle = Theme.of(context)
        .textTheme
        .subtitle
        .copyWith(fontSize: 16.0, color: Colors.white);
    titleController.text = note.title;
    descriptionController.text = note.description;

    return Scaffold(
      appBar: AppBar(
        title: Text(this.appBarTitle),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        child: ListView(
          children: <Widget>[
            // first element
            ListTile(
              title: DropdownButton<String>(
                  items: _priorites.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    );
                  }).toList(),
                  style: textStyle,
                  value: getPriorityAsString(note.priority),
                  onChanged: (value) {
                    setState(() {
                      updatePriorityAsInt(value);
                    });
                  }),
            ),
            // second element
            Padding(
              padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
              child: TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please Enter Title.';
                  }
                },
                controller: titleController,
                style: textStyle,
                onChanged: (value) {
                  updateTitle();
                },
                decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter title',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),
            // third element
            Padding(
              padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
              child: TextFormField(
                maxLines: 8,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please Enter Description.';
                  }
                },
                controller: descriptionController,
                style: textStyle,
                onChanged: (value) {
                  debugPrint('Enter description');
                  updateDescription();
                },
                decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter Description',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),
            // fourth item
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      child: Text(
                        'Save',
                        textScaleFactor: 1.5,
                      ),
                      onPressed: () {
                        setState(() {
                          debugPrint('Button Pressed');
                          _save();
                        });
                      },
                    ),
                  ),
                  Container(
                    width: 5.0,
                  ),
                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      child: Text(
                        'Delete',
                        textScaleFactor: 1.5,
                      ),
                      onPressed: () {
                        setState(() {
                          debugPrint('Delete button clicked ');
                          _delete();
                        });
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }
  // convert int priority to string priority
  getPriorityAsString (int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorites[0]; // high
        break;
      case 2:
        priority = _priorites[1]; // low
        break;
    }
    return priority;
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // update the title of the object
  void updateTitle() {
    note.title = titleController.text;
  }

  // update the description
  void updateDescription() {
    note.description = descriptionController.text;
  }
  // to save into database
  void _save() async {
     moveToLastScreen();
     note.date = DateFormat.yMMMd().format(DateTime.now());
     int result;
      if (note.id != null) {
        result = await helper.updateNote(note);
      } else {
        result = await helper.insertNote(note);
      }
      if (result != 0) {
        _showAlertDialog('Status', 'Note Saved Successfully !!');
      } else {
        _showAlertDialog('Status', 'Something went wrong !!');
      }
  }

  // delete the database
  void _delete() async {
    moveToLastScreen();
    if (note.id != null) {
        _showAlertDialog('Status', 'No notes was deleted !!');
        return;
    }
   int result = await helper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully !!');
    } else {
      _showAlertDialog('Status', 'Something went wrong !!');
    }
  }

  // show dialog here
  void _showAlertDialog(String title, String message) {
      AlertDialog alertDialog = AlertDialog(
        title: Text(title),
        content: Text(message),
      );
      showDialog(
        context: context,
        builder: (_) => alertDialog
      );
  }
}
