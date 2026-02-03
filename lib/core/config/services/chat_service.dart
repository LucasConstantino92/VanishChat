import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatService {
  late WebSocketChannel _channel;
  final String _url = dotenv.get('BASE_URL');

  Stream get messages => _channel.stream;

  void connect(String roomCode) {
    _channel = WebSocketChannel.connect(Uri.parse(_url));

    sendAction('join', roomCode);
  }

  void sendAction(String type, String room, {String? content}) {
    final data = jsonEncode({'type': type, 'room': room, 'content': ?content});
    _channel.sink.add(data);
  }

  void dispose() {
    _channel.sink.close();
  }
}
