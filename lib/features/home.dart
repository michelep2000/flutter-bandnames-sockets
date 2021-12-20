import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SocketService? _socketService;

  List<Band> bands = [];

  @override
  void initState() {
    _socketService = Provider.of<SocketService>(context, listen: false);
    _socketService?.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(payload) {
    bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    _socketService = Provider.of<SocketService>(context, listen: false);
    _socketService?.socket.off('active-bands');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _socketService = Provider.of<SocketService>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Bands',
          style: TextStyle(color: Colors.black38),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.only(right: 10.0),
            child: _socketService?.serverStatus == ServerStatus.online
                ? const Icon(
                    Icons.offline_bolt,
                    color: Colors.amber,
                  )
                : const Icon(
                    Icons.offline_bolt,
                    color: Colors.grey,
                  ),
          )
        ],
        backgroundColor: Colors.white70,
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, index) => _bandTile(bands[index]),
            ),
          )
        ],
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
      onDismissed: (_) =>
          _socketService!.socket.emit('delete-band', {'id': band.id}),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
            leading: _bandTileLeading(band.name!),
            title: _bandTileTitle(band.name!),
            trailing: _bandTileTrailing(band.votes!),
            // ignore: avoid_print
            onTap: () => _socketService?.socket.emit(
                  'vote-band',
                  {'id': band.id},
                )),
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
      _socketService!.socket.emit('add-band', {'name': name});
    }
    Navigator.pop(context);
  }

  _showGraph() {
    Map<String, double> dataMap = {};

    for (var band in bands) {
      dataMap.putIfAbsent(
        band.name!,
        () => band.votes!.toDouble(),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: PieChart(
        dataMap: dataMap,
        animationDuration: const Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 2.5,
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
        ringStrokeWidth: 32,
        legendOptions: const LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.w400,
          ),
        ),
        chartValuesOptions: const ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: true,
          showChartValuesOutside: false,
          decimalPlaces: 0,
        ),
        colorList: const [
          Colors.black38,
          Colors.blueGrey,
          Colors.amber,
          Colors.cyan
        ],
      ),
    );
  }
}
