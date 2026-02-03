import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final chatSocketProvider = Provider.family<WebSocketChannel, String>((
  ref,
  roomCode,
) {
  final url = dotenv.get('BASE_URL');
  final channel = WebSocketChannel.connect(Uri.parse(url));

  final joinMsg = jsonEncode({'type': 'join', 'room': roomCode});
  channel.sink.add(joinMsg);

  ref.onDispose(() => channel.sink.close());

  return channel;
});

final chatMessagesProvider = StreamProvider.family<dynamic, String>((
  ref,
  roomCode,
) {
  final channel = ref.watch(chatSocketProvider(roomCode));
  return channel.stream;
});
