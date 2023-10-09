import 'package:google_docs/clients/socket_client.dart';
import 'package:socket_io_client/src/socket.dart';

class SocketRepository {
  final _socketClient = SocketClient.instance.socket!;

  Socket get socketClient => _socketClient;

  void joinRoom(String documentId) {
    _socketClient.emit('join', documentId);
  }

  // void typing(data, id){
  //   _socketClient.emit('typing', {
  //     'data':data,
  //     'id': id
  //   });
  // }

  void autoSave(String data, String id){
    _socketClient.emit('save', {
      'data':data,
      'id': id
    });
  }

  void fetchContent(id){
    _socketClient.emit('fetchContent',id);
  }




}