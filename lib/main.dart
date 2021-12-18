import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> notes = [];

  deleteNotes(String value) {
    setState(() {
      notes.remove(value);
      SharedPreferences.getInstance().then(
        (value) {
          value.setStringList("notes", notes);
        },
      );
    });
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      if (prefs.containsKey("notes")) {
        setState(() {
          notes = prefs.getStringList("notes")!;
        });
      } else {
        prefs.setStringList("notes", notes);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Notes"),
        centerTitle: true,
      ),
      body: ListView(
        children: [for (String i in notes) Note(value: i, onHold: deleteNotes)],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // set up the button
          String note = "";
          bool add = false;
          Widget okButton = TextButton(
            child: const Text("Add"),
            onPressed: () {
              add = true;
              Navigator.of(context).pop();
            },
          );

          // set up the AlertDialog
          AlertDialog alert = AlertDialog(
            title: const Text("Add"),
            content: TextField(
              autofocus: true,
              expands: false,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(2),
              ),
              maxLines: 2,
              onChanged: (String text) {
                note = text;
              },
            ),
            actions: [
              okButton,
            ],
          );

          // show the dialog
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
          ).then((somthing) {
            if (note != "" && add) {
              setState(() {
                notes.add(note);
                SharedPreferences.getInstance().then((value) {
                  value.setStringList("notes", notes);
                });
              });
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Note extends StatefulWidget {
  const Note({Key? key, required this.value, required this.onHold})
      : super(key: key);

  final String value;
  final Function(String value) onHold;

  @override
  _NoteState createState() => _NoteState();
}

class _NoteState extends State<Note> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          // boxShadow: [
          //   BoxShadow(color: Colors.grey, blurRadius: 5),
          // ],
        ),
        child: Text(
          widget.value,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      onLongPress: () => widget.onHold(widget.value),
    );
  }
}
