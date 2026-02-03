import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unique_chat_app/features/chat/presentation/chat_page.dart';
import 'package:uuid/uuid.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Text(
                'VANISH\nCHAT',
                style: theme.textTheme.displayMedium?.copyWith(
                  color: colorScheme.primary,
                  letterSpacing: 4,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Comunicação efêmera de ponta a ponta.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(),

              _HomeCard(
                title: 'CRIAR SALA',
                subtitle: 'Gere um código único para convidar alguém',
                icon: Icons.add_moderator_outlined,
                color: colorScheme.primary,
                onTap: () => _showCreateRoomDialog(context),
              ),

              const SizedBox(height: 16),

              _HomeCard(
                title: 'ENTRAR NA SALA',
                subtitle: 'Digite o código recebido de um amigo',
                icon: Icons.login_rounded,
                color: colorScheme.secondary,
                onTap: () => _showJoinRoomDialog(context),
              ),

              const Spacer(),

              Text(
                'O servidor no Google Cloud atua apenas como relay.\nNenhum dado é persistido.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showJoinRoomDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Entrar na Sala'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Código da Sala',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              final code = controller.text.trim().toUpperCase();
              if (code.isNotEmpty) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(roomCode: code),
                  ),
                );
              }
            },
            child: const Text('ENTRAR'),
          ),
        ],
      ),
    );
  }

  void _showCreateRoomDialog(BuildContext context) {
    final String roomCode = const Uuid().v4().substring(0, 6).toUpperCase();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Código da sua Sala',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SelectableText(
                roomCode,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Compartilhe este código com quem você quer conversar.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(roomCode: roomCode),
                  ),
                );
              },
              child: const Text('ENTRAR NA SALA AGORA'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HomeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.15), Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: color.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}
