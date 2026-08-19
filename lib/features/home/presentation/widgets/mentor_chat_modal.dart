import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
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

class _MentorChatModalState extends State<MentorChatModal>
    with SingleTickerProviderStateMixin {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isTyping = false;
  bool _isAiMode = true;
  int _selectedPromptCategory = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late final List<AiMentorMessage> _messages;

  final Map<int, List<String>> _promptCategories = {
    0: [
      'BLoC va Provider farqi nima?',
      'Clean Architecture qanday tuziladi?',
      'RenderFlex overflow xatosi',
      'Dart Null Safety qoidalari',
      'Bugungi dars jadvalim qanday?',
      'Python da ikkilik qidiruv',
    ],
    1: [
      'BLoC va Provider farqi nima?',
      'StatelessWidget va StatefulWidget farqi',
      'Future va Stream farqi nima?',
      'Dart Sound Null Safety nima?',
      'Clean Architecture qatlamlari',
    ],
    2: [
      'RenderFlex overflow xatosini tuzatish',
      'Null check operator used on null',
      'LateInitializationError xatosi',
      'SocketException qanday ushlanadi?',
    ],
    3: [
      'Bugungi dars jadvalim qanday?',
      'Oylik to\'lov va qoldiq summa qancha?',
      '204-kompyuter xonasi qayerda?',
      'Uy vazifasini qanday topshiraman?',
    ],
    4: [
      'Python da Binary Search kodi',
      'REST API va SQL farqi',
      'HTML va CSS asoslari',
      'Git commit va push buyruqlari',
    ],
  };

  @override
  void initState() {
    super.initState();
    final studentName = MockProfileRepository.currentStudent.firstName;
    _messages = [
      AiMentorMessage(
        id: 'msg_welcome',
        senderName: 'Abbos Qodirov (AI Mentor)',
        text: 'Assalomu alaykum $studentName! 👋 Men sizning 24/7 ishlaydigan **AI Mentor**ingizman.\n\n'
            'Flutter, Dart, Python, kod xatoliklari yoki o\'quv markaz darslari bo\'yicha istalgan savolingizni berishingiz mumkin!',
        time: 'Hozir',
        isUser: false,
        isAi: true,
        category: AiQueryCategory.general,
        followUpPrompts: const [
          'BLoC va Provider farqi nima?',
          'RenderFlex overflow xatosini tuzatish',
          'Bugungi dars jadvali va xonam',
        ],
      ),
    ];

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return;

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

    // AI reasoning delay simulation (realistic streaming/thinking pace)
    final delayMs = _isAiMode ? 850 : 1800;
    Timer(Duration(milliseconds: delayMs), () {
      if (!mounted) return;

      final rNow = DateTime.now();
      final rTime =
          '${rNow.hour.toString().padLeft(2, '0')}:${rNow.minute.toString().padLeft(2, '0')}';

      final AiMentorResponse aiReply;
      if (_isAiMode) {
        aiReply = AiMentorService.generateAnswer(clean);
      } else {
        aiReply = AiMentorResponse(
          text: 'Assalomu alaykum ${student.firstName}! Savolingiz ustoz Abbos Qodirovga yetkazildi. Mentor tez orada siz bilan shaxsan bog\'lanadi.',
          category: AiQueryCategory.academy,
        );
      }

      final mentorMsg = AiMentorMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderName: _isAiMode ? 'Abbos Qodirov (AI Mentor)' : 'Abbos Qodirov (Jonli Mentor)',
        text: aiReply.text,
        time: rTime,
        isUser: false,
        isAi: _isAiMode,
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
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _copyToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr('codeCopied')),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearChat() {
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
                  const AiMentorMessage(
                    id: 'msg_welcome',
                    senderName: 'Abbos Qodirov (AI Mentor)',
                    text: 'Chat tozalandi. Qanday yangi savolingiz bor? 🚀',
                    time: 'Hozir',
                    isUser: false,
                    isAi: true,
                    followUpPrompts: [
                      'BLoC va Provider farqi nima?',
                      'RenderFlex overflow xatosini tuzatish',
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

    final categoryTabs = [
      context.tr('filterAllPrompts'),
      context.tr('filterFlutterPrompts'),
      context.tr('filterDebuggingPrompts'),
      context.tr('filterAcademyPrompts'),
      context.tr('filterWebPrompts'),
    ];

    final currentPrompts = _promptCategories[_selectedPromptCategory] ?? _promptCategories[0]!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            10,
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 10),

          // Header: AI Mentor Profile & Status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Stack(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF10B981)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '👨‍💻',
                            style: TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.success,
                            border: Border.all(color: theme.colorScheme.surface, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Mode
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              context.tr('aiMentorTitle'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withValues(alpha: isDark ? 0.35 : 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              context.tr('aiMentorBadge'),
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isAiMode
                            ? context.tr('aiMentorSubtitle')
                            : context.tr('aiModeLiveMentor'),
                        style: TextStyle(
                          fontSize: 11,
                          color: _isAiMode ? AppColors.success : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Mode Toggle Button
                IconButton(
                  tooltip: _isAiMode ? context.tr('tooltipAiMode') : context.tr('tooltipLiveMentor'),
                  icon: Icon(
                    _isAiMode ? Icons.auto_awesome_rounded : Icons.person_rounded,
                    color: _isAiMode ? const Color(0xFF6366F1) : AppColors.primary,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _isAiMode = !_isAiMode);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isAiMode
                              ? context.tr('aiModeActive')
                              : context.tr('aiModeLiveMentor'),
                        ),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),

                // Clear Chat Action
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
          const Divider(height: 14),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6366F1)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    context.tr('aiTyping'),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Quick Prompt Categories Bar
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: SizedBox(
              height: 28,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: categoryTabs.length,
                separatorBuilder: (_, i) => const SizedBox(width: 6),
                itemBuilder: (context, i) {
                  final active = _selectedPromptCategory == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPromptCategory = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: active
                            ? (isDark ? const Color(0xFF6366F1).withValues(alpha: 0.35) : const Color(0xFF6366F1))
                            : (isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: active ? const Color(0xFF6366F1) : theme.colorScheme.outline,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          categoryTabs[i],
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                            color: active ? Colors.white : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Quick Prompt Suggestions Chips Carousel
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              itemCount: currentPrompts.length,
              separatorBuilder: (_, i) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final prompt = currentPrompts[i];
                return GestureDetector(
                  onTap: () => _sendMessage(prompt),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outline),
                    ),
                    child: Center(
                      child: Text(
                        prompt,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),

          // Bottom Input Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.colorScheme.outline),
                    ),
                    child: TextField(
                      controller: _msgController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                      decoration: InputDecoration(
                        hintText: context.tr('askAiHint'),
                        hintStyle: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                        suffixIcon: _msgController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _msgController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF10B981)],
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    onPressed: () => _sendMessage(_msgController.text),
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
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF059669).withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                msg.text,
                style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                msg.time,
                style: const TextStyle(fontSize: 9.5, color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    // AI Message Tile
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.88),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          ),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sender Badge & Time
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: isDark ? 0.3 : 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, size: 10, color: Color(0xFF6366F1)),
                      const SizedBox(width: 4),
                      Text(
                        context.tr('aiGeneratedTag'),
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  msg.time,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Formatted Message Text
            Text(
              msg.text,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: theme.colorScheme.onSurface,
              ),
            ),

            // Optional Code Snippet Block with Copy Button
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
                    // Code header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E293B),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              msg.codeLanguage?.toUpperCase() ?? 'CODE',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _copyToClipboard(msg.codeSnippet!),
                            child: Row(
                              children: [
                                const Icon(Icons.copy_rounded, size: 12, color: Color(0xFF94A3B8)),
                                const SizedBox(width: 4),
                                Text(
                                  context.tr('copyCode'),
                                  style: const TextStyle(
                                    fontSize: 10,
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

                    // Code content
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

            // Interactive Dynamic Follow-up Prompts
            if (msg.followUpPrompts.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: msg.followUpPrompts.map((prompt) {
                  return GestureDetector(
                    onTap: () => _sendMessage(prompt),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.74,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: isDark ? 0.2 : 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_forward_rounded, size: 10, color: Color(0xFF6366F1)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              prompt,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6366F1),
                              ),
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
