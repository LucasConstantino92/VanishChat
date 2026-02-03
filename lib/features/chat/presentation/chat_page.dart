import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unique_chat_app/core/utils/crypto_utils.dart';
import 'package:unique_chat_app/providers/chat_provider.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String roomCode;
  const ChatPage({super.key, required this.roomCode});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _myNickname;
  final List<Map<String, dynamic>> _messages = [];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _myNickname == null) return;

    final encryptedContent = await CryptoUtil.encrypt(text, widget.roomCode);

    final socket = ref.read(chatSocketProvider(widget.roomCode));
    final messageData = {
      'type': 'message',
      'room': widget.roomCode,
      'content': encryptedContent,
      'sender': _myNickname,
    };

    setState(() {
      _messages.add({
        'type': 'message',
        'content': text,
        'sender': _myNickname,
        'isMe': true,
      });
    });
    _scrollToBottom();

    socket.sink.add(jsonEncode(messageData));
    _messageController.clear();
  }

  void _confirmKill(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Autodestruir Sala?'),
        content: const Text(
          'Isso expulsará todos os usuários e apagará a sala do servidor imediatamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final socket = ref.read(chatSocketProvider(widget.roomCode));
              socket.sink.add(
                jsonEncode({'type': 'kill', 'room': widget.roomCode}),
              );
              Navigator.pop(context);
            },
            child: const Text(
              'DESTRUIR',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNicknamePrompt() {
    final controller = TextEditingController();
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Como quer ser chamado nesta sala?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Ex: Lucas, Admin, Anon...',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    setState(() => _myNickname = val.trim());
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    setState(() => _myNickname = controller.text.trim());
                  }
                },
                child: const Text('ENTRAR NO CHAT'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_myNickname == null) {
      return _buildNicknamePrompt();
    }

    final messagesAsync = ref.watch(chatMessagesProvider(widget.roomCode));

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.bolt, color: Colors.amber),
            tooltip: 'Autodestruição',
            onPressed: () => _confirmKill(context),
          ),
        ],
        title: Text('SALA: ${widget.roomCode}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (data) {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  if (data.toString() == 'SALA_DESTRUIDA') {
                    if (mounted) {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sala finalizada com sucesso.'),
                          ),
                        );
                      }
                    }
                    return;
                  }

                  try {
                    final decoded = jsonDecode(data);
                    if (decoded['type'] == 'message') {
                      final decryptedText = await CryptoUtil.decrypt(
                        decoded['content'],
                        widget.roomCode,
                      );

                      decoded['content'] = decryptedText;
                      decoded['isMe'] = false;

                      if (!_messages.any(
                        (m) => m.toString() == decoded.toString(),
                      )) {
                        setState(() => _messages.add(decoded));
                        _scrollToBottom();
                      }
                    }
                  } catch (e) {
                    final systemMsg = {
                      'type': 'system',
                      'content': data.toString(),
                    };
                    if (!_messages.any(
                      (m) => m.toString() == systemMsg.toString(),
                    )) {
                      setState(() => _messages.add(systemMsg));
                      _scrollToBottom();
                    }
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isSystem = msg['type'] == 'system';

                    if (isSystem) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            msg['content'] ?? '',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      );
                    }

                    return _ChatBubble(
                      message: msg['content'] ?? '',
                      isMe: msg['isMe'] ?? false,
                      senderName: msg['sender'] ?? 'Anônimo',
                      theme: theme,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text(
                  'Erro na conexão: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 8,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Mensagem secreta...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(
                    Icons.send_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String senderName;
  final ThemeData theme;

  const _ChatBubble({
    required this.message,
    this.isMe = false,
    required this.senderName,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Text(
                senderName,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMe
                  ? theme.colorScheme.primary
                  : theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomRight: isMe
                    ? const Radius.circular(0)
                    : const Radius.circular(16),
                bottomLeft: isMe
                    ? const Radius.circular(16)
                    : const Radius.circular(0),
              ),
            ),
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isMe
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
