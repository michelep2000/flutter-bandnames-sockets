import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as io;

enum ServerStatus { online, offline, connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.connecting;
  late io.Socket _socket;

  get serverStatus => _serverStatus;
  io.Socket get socket => _socket;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {

     _socket = io.io(
      'http://localhost:3000',
      io.OptionBuilder()
          .enableAutoConnect()
          .setTransports(['websocket']).build(),
    );

    _socket.onConnect((_) {
      _serverStatus = ServerStatus.online;
      print('connect');
      notifyListeners();
    });

    _socket.onDisconnect((_) {
      _serverStatus = ServerStatus.offline;
      print('disconnect');
      notifyListeners();
    });
  }
}
