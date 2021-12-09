import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '1', name: 'Imagine Dragons', votes: 10),
    Band(id: '2', name: 'Coldplay', votes: 5),
    Band(id: '3', name: 'One Republic', votes: 7),
    Band(id: '4', name: 'TwentyOne Pilots', votes: 8),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Bands',
          style: TextStyle(color: Colors.black38),
        ),
        backgroundColor: Colors.white70,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (context, index) => _bandTile(bands[index]),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        elevation: 10,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.grey.shade400,
        onPressed: _addNewBand,
      ),
    );
  }

  Widget _bandTile(Band band) {

    return Dismissible(
      key: Key(band.id!),
      direction: DismissDirection.startToEnd,
      background: Container(
        padding: const EdgeInsets.only(left: 10.0),
        color: Colors.redAccent,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Icon(
            Icons.delete_forever,
            color: Colors.white,
            size: 30.0,
          ),
        ),
      ),

      onDismissed: (direction) {
        print('direction: $direction');
      },

      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
            leading: _bandTileLeading(band.name!),
            title: _bandTileTitle(band.name!),
            trailing: _bandTileTrailing(band.votes!),
            // ignore: avoid_print
            onTap: () => print(band.name!)),
      ),
    );
  }

  Widget _bandTileLeading(String name) => CircleAvatar(
        backgroundColor: Colors.cyan,
        child: Text(
          name.substring(0, 2),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
      );

  Widget _bandTileTitle(String name) => Container(
        padding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 8.0,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w300),
        ),
      );

  Widget _bandTileTrailing(int votes) => CircleAvatar(
        backgroundColor: Colors.amber,
        child: Text(
          '$votes',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

  void _addNewBand() {
    final textController = TextEditingController();

    ThemeData theme = ThemeData(primarySwatch: Colors.cyan);

    if (Platform.isAndroid) {
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext dialogContext) {
          return Theme(
            data: theme,
            child: AlertDialog(
              title: const Text('Add band'),
              content: TextField(
                cursorColor: Colors.cyan,
                decoration: const InputDecoration(
                    hoverColor: Colors.cyan,
                    focusColor: Colors.cyan,
                    hintText: 'Band Name...',
                    fillColor: Colors.cyan),
                controller: textController,
              ),
              actions: <Widget>[
                MaterialButton(
                  child: const Text('Add'),
                  elevation: 10,
                  textColor: Colors.cyan,
                  onPressed: () => _onPressedNewBand(textController.text),
                ),
              ],
            ),
          );
        },
      );
    } else if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text('Add Band'),
          ),
          content: CupertinoTextField(controller: textController),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Add'),
              onPressed: () => _onPressedNewBand(textController.text),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
    }
  }

  void _onPressedNewBand(String name) {
    if (name.isNotEmpty) {
      print(name);
    }
    Navigator.pop(context);
  }
}
