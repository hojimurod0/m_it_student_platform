import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/widgets/ui/mit_toast.dart';
import 'package:m_it_student_platform/features/home/data/services/ai_mentor_service.dart';
import 'package:m_it_student_platform/features/home/domain/models/ai_mentor_model.dart';
import 'package:m_it_student_platform/features/profile/data/repositories/mock_profile_repository.dart';

class MentorChatModal extends StatefulWidget {
  const MentorChatModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MentorChatModal(),
    );
  }

  @override
  State<MentorChatModal> createState() => _MentorChatModalState();
}

class _MentorChatModalState extends State<MentorChatModal> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isTyping = false;
  late final List<AiMentorMessage> _messages;

  final List<String> _quickPrompts = const [
    '❓ Uy vazifasini qanday topshiraman?',
    '📅 Bugungi dars vaqti va xonam qayerda?',
    '💡 BLoC va Provider farqi nima?',
    '🐞 Kodimdagi xatoni topishga yordam ber',
    '💳 To\'lovim qancha qolgan?',
    '🚀 Flutterda vidjetlar bilan ishlash',
  ];

  @override
  void initState() {
    super.initState();
    final studentName = MockProfileRepository.currentStudent.firstName;
    _messages = [
      AiMentorMessage(
        id: 'msg_welcome',
        senderName: 'Abbos Qodirov (Mentor)',
        text: 'Assalomu alaykum $studentName! 👋\n\n'
            'Men sizning M-IT yordamchi mentoringizman. Darslar, uy vazifalari yoki dasturlash kodlari bo\'yicha istalgan savolingizni berishingiz mumkin!',
        time: 'Hozir',
        isUser: false,
        isAi: true,
        category: AiQueryCategory.general,
        followUpPrompts: const [
          '❓ Uy vazifasini qanday topshiraman?',
          '📅 Bugungi dars jadvalim qanday?',
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return;

    AppHaptics.light();
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final student = MockProfileRepository.currentStudent;
    final userMsg = AiMentorMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderName: student.fullName,
      text: clean,
      time: timeStr,
      isUser: true,
      isAi: false,
    );

    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
      _msgController.clear();
    });

    _scrollToBottom();

    // Mentor thinking and reply
    Timer(const Duration(milliseconds: 750), () {
      if (!mounted) return;

      final rNow = DateTime.now();
      final rTime =
          '${rNow.hour.toString().padLeft(2, '0')}:${rNow.minute.toString().padLeft(2, '0')}';

      final aiReply = AiMentorService.generateAnswer(clean);

      final mentorMsg = AiMentorMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderName: 'Abbos Qodirov (Mentor)',
        text: aiReply.text,
        time: rTime,
        isUser: false,
        isAi: true,
        category: aiReply.category,
        codeSnippet: aiReply.codeSnippet,
        codeLanguage: aiReply.codeLanguage,
        followUpPrompts: aiReply.followUpPrompts,
      );

      setState(() {
        _isTyping = false;
        _messages.add(mentorMsg);
      });

      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 140,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _copyToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code));
    AppHaptics.light();
    MitToast.success(context, context.tr('codeCopied'));
  }

  void _clearChat() {
    AppHaptics.selection();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('clearChat')),
        content: Text(context.tr('clearChatConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _messages.clear();
                _messages.add(
                  AiMentorMessage(
                    id: 'msg_welcome',
                    senderName: 'Abbos Qodirov (Mentor)',
                    text: context.tr('chatCleaned'),
                    time: 'Hozir',
                    isUser: false,
                    isAi: true,
                    followUpPrompts: const [
                      '❓ Uy vazifasini qanday topshiraman?',
                      '📅 Bugungi dars jadvalim qanday?',
                    ],
                  ),
                );
              });
            },
            child: Text(context.tr('clear'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 12, 10),
            child: Row(
              children: [
                // Mentor Avatar with Online Indicator
                Stack(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '👨‍🏫',
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF10B981),
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Name & Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Abbos Qodirov',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.25 : 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Mentor',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            context.tr('onlineSupport247'),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Clear Chat
                IconButton(
                  tooltip: context.tr('clearChat'),
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  onPressed: _clearChat,
                ),

                // Close Button
                IconButton(
                  tooltip: context.tr('close'),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              physics: const BouncingScrollPhysics(),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageTile(msg, isDark, theme);
              },
            ),
          ),

          // Typing Indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('mentorTyping'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

          // Quick Suggestion Chips (Tezkor Savollar)
          Container(
            height: 38,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickPrompts.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final prompt = _quickPrompts[index];
                return GestureDetector(
                  onTap: () => _sendMessage(prompt),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceSecondary : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        prompt,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Input Bar
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 6,
              bottom: MediaQuery.of(context).viewInsets.bottom +
                  MediaQuery.of(context).padding.bottom +
                  12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceSecondary : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: TextField(
                      controller: _msgController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                      decoration: InputDecoration(
                        hintText: 'Mentordan savol so\'rang...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _sendMessage(_msgController.text),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _msgController.text.trim().isNotEmpty
                          ? (isDark ? AppColors.accentLime : AppColors.brandNavy)
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      color: _msgController.text.trim().isNotEmpty
                          ? (isDark ? AppColors.brandNavy : Colors.white)
                          : (isDark ? const Color(0xFF64748B) : Colors.white70),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTile(AiMentorMessage msg, bool isDark, ThemeData theme) {
    if (msg.isUser) {
      // User message bubble (Right side)
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.80),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.accentLime : AppColors.brandNavy,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                msg.text,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.35,
                  fontWeight: isDark ? FontWeight.w700 : FontWeight.normal,
                  color: isDark ? AppColors.brandNavy : Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                msg.time,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark
                      ? AppColors.brandNavy.withValues(alpha: 0.75)
                      : Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Mentor message bubble (Left side)
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.86),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceSecondary : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : const Color(0xFF64748B).withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sender & Time
            Row(
              children: [
                const Icon(
                  Icons.support_agent_rounded,
                  size: 16,
                  color: Color(0xFF10B981),
                ),
                const SizedBox(width: 6),
                Text(
                  msg.senderName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF10B981),
                  ),
                ),
                const Spacer(),
                Text(
                  msg.time,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Message text
            Text(
              msg.text,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: theme.colorScheme.onSurface,
              ),
            ),

            // Code Snippet Block (if any)
            if (msg.codeSnippet != null && msg.codeSnippet!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E293B),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            msg.codeLanguage?.toUpperCase() ?? 'KOD NAMUNASI',
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _copyToClipboard(msg.codeSnippet!),
                            child: const Row(
                              children: [
                                Icon(Icons.copy_rounded, size: 12, color: Color(0xFF94A3B8)),
                                SizedBox(width: 4),
                                Text(
                                  'Nusxa olish',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: SelectableText(
                        msg.codeSnippet!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11.5,
                          height: 1.4,
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Follow-up prompts
            if (msg.followUpPrompts.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: msg.followUpPrompts.map((prompt) {
                  return GestureDetector(
                    onTap: () => _sendMessage(prompt),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.2 : 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_forward_rounded, size: 11, color: Color(0xFF10B981)),
                          const SizedBox(width: 4),
                          Text(
                            prompt,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
