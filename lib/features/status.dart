import 'package:band_names/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    print(socketService.serverStatus);

    String serverStatusText = socketService.serverStatus == ServerStatus.online
        ? 'Online'
        : socketService.serverStatus == ServerStatus.offline
            ? 'Offline'
            : 'Connecting';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(serverStatusText),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            print('PRESSED');
            socketService.socket.emit('new-msg', [
              {'name': 'flutter', 'msg': 'Hello flutter'}
            ]);
          }),
    );
  }
}
