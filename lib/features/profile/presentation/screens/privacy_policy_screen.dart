import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/widgets/ui/mit_toast.dart';
import 'package:url_launcher/url_launcher.dart';

/// Rasmiy qonuniy hujjatlar ekrani (URL orqali tashqi brauzerda ochiladi)
class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key, this.initialTab = 0});
  final int initialTab; // 0: Privacy Policy, 1: Terms of Service

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _openCurrentWeb();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getUrlForIndex(int index) {
    final lang = context.language.name;
    return index == 0
        ? AppConfig.getPrivacyPolicyUrl(lang)
        : AppConfig.getTermsOfServiceUrl(lang);
  }

  Future<void> _openCurrentWeb() async {
    final url = _getUrlForIndex(_tabController.index);
    await _openWeb(url);
  }

  Future<void> _openWeb(String url) async {
    AppHaptics.selection();
    try {
      final uri = Uri.parse(url);
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (_) {
      try {
        final uri = Uri.parse(url);
        await launchUrl(uri);
      } catch (_) {
        if (mounted) {
          Clipboard.setData(ClipboardData(text: url));
          MitToast.info(context, '$url ${context.tr('copied')}');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0A0F1D) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF111927) : Colors.white;
    final appBarBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF1E2D42) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isDark ? Colors.white : AppColors.brandNavy,
          ),
          onPressed: () {
            AppHaptics.light();
            Navigator.of(context).maybePop();
          },
        ),
        title: Text(
          'Qonuniy hujjatlar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: isDark ? Colors.white : AppColors.brandNavy,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Nusxa olish',
            icon: Icon(
              Icons.share_rounded,
              size: 20,
              color: isDark ? AppColors.accentLime : AppColors.secondary,
            ),
            onPressed: () {
              final activeUrl = _getUrlForIndex(_tabController.index);
              Clipboard.setData(ClipboardData(text: activeUrl));
              MitToast.success(context, context.tr('linkCopied'));
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => _openCurrentWeb(),
          indicatorColor: isDark ? AppColors.accentLime : AppColors.primary,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: isDark ? AppColors.accentLime : AppColors.primary,
          unselectedLabelColor:
              isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          labelStyle:
              const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
          unselectedLabelStyle:
              const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(
              icon: Icon(Icons.shield_outlined, size: 18),
              text: 'Maxfiylik siyosati',
            ),
            Tab(
              icon: Icon(Icons.description_outlined, size: 18),
              text: 'Foydalanish shartlari',
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.accentLime : AppColors.primary)
                        .withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.open_in_browser_rounded,
                    size: 32,
                    color: isDark ? AppColors.accentLime : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _tabController.index == 0
                      ? 'Maxfiylik Siyosati'
                      : 'Foydalanish Shartlari',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.brandNavy,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rasmiy hujjatlar to\'liq veb-sahifada joylashtirilgan. Havola orqali brauzerda ochishingiz mumkin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _openCurrentWeb,
                    icon: const Icon(Icons.launch_rounded, size: 18),
                    label: const Text(
                      'Brauzerda ochish',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDark ? AppColors.accentLime : AppColors.primary,
                      foregroundColor:
                          isDark ? Colors.black : AppColors.textOnPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
