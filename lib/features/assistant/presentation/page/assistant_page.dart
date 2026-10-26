import 'dart:async';
import 'dart:typed_data';

import 'package:domain_extention/app/theme/sukuna_theme.dart';
import 'package:domain_extention/features/assistant/domain/entity/chat_message.dart';
import 'package:domain_extention/features/assistant/domain/repository/i_assistant_repository.dart';
import 'package:domain_extention/features/assistant/presentation/page/i_assistant_page.dart';
import 'package:domain_extention/features/voice/domain/repository/i_cloned_voice_repository.dart';
import 'package:domain_extention/features/voice/presentation/widget/voice_player.dart';
import 'package:flutter/material.dart';

class AssistantPage extends StatefulWidget implements IAssistantPage {
  const AssistantPage({
    super.key,
    required this.assistantRepository,
    required this.voiceRepository,
  });

  final IAssistantRepository assistantRepository;
  final IClonedVoiceRepository voiceRepository;

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _ChatLine {
  const _ChatLine({
    required this.role,
    required this.text,
    this.audio,
    this.busy = false,
  });

  final String role;
  final String text;
  final Uint8List? audio;
  final bool busy;
}

class _AssistantPageState extends State<AssistantPage> {
  final _input = TextEditingController();
  final _lines = <_ChatLine>[];
  var _sending = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _sending = true;
      _lines.add(_ChatLine(role: 'user', text: text));
      _lines.add(const _ChatLine(role: 'assistant', text: '', busy: true));
      _input.clear();
    });

    try {
      final history = _lines
          .where((line) => !line.busy && line.text.isNotEmpty)
          .map((line) => ChatMessage(role: line.role, text: line.text))
          .toList();
      if (history.isNotEmpty && history.last.role == 'user') {
        history.removeLast();
      }

      final answer = await widget.assistantRepository.reply(
        userText: text,
        history: history,
      );
      final voice = await widget.voiceRepository.getByCharacterId('sukuna');
      final audio = await widget.voiceRepository.speak(
        text: answer.text,
        voice: voice,
      );

      if (!mounted) return;
      setState(() {
        _lines.removeLast();
        _lines.add(
          _ChatLine(role: 'assistant', text: answer.text, audio: audio),
        );
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _lines.removeLast();
        _lines.add(_ChatLine(role: 'assistant', text: error.toString()));
      });
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сукуна'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _lines.isEmpty
                ? const Center(
                    child: Text(
                      'Напиши фразу — ответит голосом',
                      style: TextStyle(color: SukunaTheme.bone),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: _lines.length,
                    itemBuilder: (context, index) {
                      return _Bubble(line: _lines[index]);
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      enabled: !_sending,
                      style: const TextStyle(color: SukunaTheme.bone),
                      decoration: InputDecoration(
                        hintText: 'Скажи ему что-нибудь',
                        hintStyle: TextStyle(
                          color: SukunaTheme.bone.withValues(alpha: 0.4),
                        ),
                        filled: true,
                        fillColor: SukunaTheme.ash,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => unawaited(_send()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: SukunaTheme.blood,
                      foregroundColor: SukunaTheme.bone,
                    ),
                    onPressed: _sending ? null : () => unawaited(_send()),
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_upward_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.line});

  final _ChatLine line;

  @override
  Widget build(BuildContext context) {
    final mine = line.role == 'user';

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: mine
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    color: SukunaTheme.ash,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Text(line.text),
                  ),
                )
              : line.busy
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Слушает...'),
                )
              : line.audio == null
              ? Text(line.text)
              : VoicePlayer(bytes: line.audio!),
        ),
      ),
    );
  }
}
