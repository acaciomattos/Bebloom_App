import 'package:flutter/material.dart';

import '../../app.dart';
import '../../shared/widgets/avatar_placeholder.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuracoes')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: AvatarPlaceholder(size: 84)),
                  const SizedBox(height: 16),
                  Text(
                    'English Tutor Demo',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tela simples para concentrar ajustes futuros da demo, preferencias do aluno e evolucao do placeholder de avatar.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.storage_rounded),
              title: Text('Persistencia local'),
              subtitle: Text(
                'SharedPreferences salva progresso, resultados de exercicios, vocabulario e ultima aula aberta.',
              ),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.smart_toy_outlined),
              title: Text('Avatar'),
              subtitle: Text(
                'Implementado como placeholder visual pronto para futura troca por um avatar com voz.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Resetar progresso'),
                    content: const Text(
                      'Isso vai limpar aulas concluidas, respostas de exercicios, vocabulario salvo e ultima aula aberta neste aparelho.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Resetar'),
                      ),
                    ],
                  );
                },
              );

              if (confirmed != true) {
                return;
              }

              await controller.resetProgress();
              if (!context.mounted) {
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Progresso local resetado com sucesso.'),
                ),
              );
            },
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('Resetar progresso local'),
          ),
        ],
      ),
    );
  }
}
