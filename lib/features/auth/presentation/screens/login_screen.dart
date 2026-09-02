import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/di/injection_container.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/widgets/app_logo.dart';
import 'package:m_it_student_platform/features/auth/domain/repositories/auth_repository.dart';
import 'package:m_it_student_platform/features/auth/presentation/controllers/auth_controller.dart';
import 'package:m_it_student_platform/features/navigation/presentation/main_shell.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.authController});
  final AuthController? authController;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AuthController _authController;
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  String? _inlineError;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;


  @override
  void initState() {
    super.initState();
    _authController = widget.authController ??
        (sl.isRegistered<AuthRepository>()
            ? AuthController(authRepository: sl<AuthRepository>())
            : AuthController());
    _authController.addListener(_onAuthStateChanged);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  void _onAuthStateChanged() {
    if (!mounted) return;
    if (_authController.errorMessage != null) {
      setState(() => _inlineError = _authController.errorMessage);
    }
  }

  @override
  void dispose() {
    _authController.removeListener(_onAuthStateChanged);
    _loginController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _openLegalUrl(String url) async {
    AppHaptics.selection();
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (_) {
      try {
        final uri = Uri.parse(url);
        await launchUrl(uri);
      } catch (_) {}
    }
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    setState(() => _inlineError = null);
    _authController.clearError();

    if (!_agreedToTerms) {
      setState(() => _inlineError = context.tr('termsAgreementError'));
      AppHaptics.error();
      return;
    }

    final loginRaw = _loginController.text.trim();
    final password = _passwordController.text.trim();

    if (loginRaw.isEmpty) {
      setState(() => _inlineError = context.tr('loginHint'));
      return;
    }

    if (password.isEmpty) {
      setState(() => _inlineError = context.tr('passwordValidation'));
      return;
    }

    AppHaptics.medium();
    final success = await _authController.login(phone: loginRaw, password: password);
    if (!mounted) return;

    if (success) {
      final user = _authController.currentUser;
      if (user != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const MainShell()),
          (route) => false,
        );
      } else {
        setState(() {
          _inlineError = _authController.errorMessage ?? context.tr('invalidCredentialsError');
        });
      }
    } else {
      AppHaptics.error();
      setState(() {
        _inlineError =
            _authController.errorMessage ?? context.tr('invalidCredentialsError');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final inputBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final focusBorderColor = isDark ? AppColors.accentLime : AppColors.brandNavy;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            final isLoading = _authController.isLoading;

            return FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ── App Brand Logo ──
                          const Center(
                            child: AppLogo(
                              size: 72,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // ── Header Title & Subtitle ──
                          Text(
                            context.tr('welcomeBack'),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.tr('loginSubtitle'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: subtitleColor,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Main Login Card ──
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: borderColor, width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Inline Error Banner
                                if (_inlineError != null) ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.danger.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.danger.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline_rounded,
                                            color: AppColors.danger, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _inlineError!,
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.danger,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // ── 1. Login Field ──
                                Text(
                                  context.tr('loginLabel'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _loginController,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  style: TextStyle(fontSize: 14.5, color: textColor),
                                  decoration: InputDecoration(
                                    hintText: context.tr('loginHint'),
                                    hintStyle: TextStyle(
                                      fontSize: 13.5,
                                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.person_outline_rounded,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                      size: 20,
                                    ),
                                    filled: true,
                                    fillColor: inputBg,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(color: borderColor),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(color: borderColor),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(color: focusBorderColor, width: 1.8),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // ── 2. Password Field ──
                                Text(
                                  context.tr('passwordLabel'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _handleLogin(),
                                  style: TextStyle(fontSize: 14.5, color: textColor),
                                  decoration: InputDecoration(
                                    hintText: context.tr('passwordHint'),
                                    hintStyle: TextStyle(
                                      fontSize: 13.5,
                                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline_rounded,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                      size: 20,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() => _obscurePassword = !_obscurePassword);
                                      },
                                    ),
                                    filled: true,
                                    fillColor: inputBg,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(color: borderColor),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(color: borderColor),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(color: focusBorderColor, width: 1.8),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // ── 3. Terms & Privacy Checkbox with Direct Blue Links ──
                                InkWell(
                                  onTap: () {
                                    AppHaptics.selection();
                                    setState(() => _agreedToTerms = !_agreedToTerms);
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: Checkbox(
                                            value: _agreedToTerms,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            activeColor: const Color(0xFF2563EB),
                                            checkColor: Colors.white,
                                            side: BorderSide(
                                              color: isDark
                                                  ? const Color(0xFF64748B)
                                                  : const Color(0xFF94A3B8),
                                              width: 1.5,
                                            ),
                                            onChanged: (val) {
                                              AppHaptics.selection();
                                              setState(() => _agreedToTerms = val ?? false);
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: subtitleColor,
                                                height: 1.45,
                                              ),
                                              children: [
                                                TextSpan(text: context.tr('termsAgreePrefix')),
                                                TextSpan(
                                                  text: context.tr('privacyPolicy'),
                                                  style: const TextStyle(
                                                    color: Color(0xFF2563EB),
                                                    fontWeight: FontWeight.w700,
                                                    decoration: TextDecoration.underline,
                                                  ),
                                                  recognizer: TapGestureRecognizer()
                                                    ..onTap = () => _openLegalUrl(
                                                          AppConfig.getPrivacyPolicyUrl(
                                                              context.language.name),
                                                        ),
                                                ),
                                                TextSpan(text: context.tr('termsAgreeAnd')),
                                                TextSpan(
                                                  text: context.tr('termsOfService'),
                                                  style: const TextStyle(
                                                    color: Color(0xFF2563EB),
                                                    fontWeight: FontWeight.w700,
                                                    decoration: TextDecoration.underline,
                                                  ),
                                                  recognizer: TapGestureRecognizer()
                                                    ..onTap = () => _openLegalUrl(
                                                          AppConfig.getTermsOfServiceUrl(
                                                              context.language.name),
                                                        ),
                                                ),
                                                TextSpan(text: context.tr('termsAgreeSuffix')),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // ── 4. Login Button (Disabled until Checkbox is checked) ──
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: (isLoading || !_agreedToTerms)
                                        ? null
                                        : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDark ? AppColors.accentLime : AppColors.primary,
                                      foregroundColor: isDark ? Colors.black : AppColors.textOnPrimary,
                                      disabledBackgroundColor: isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFE2E8F0),
                                      disabledForegroundColor: isDark
                                          ? const Color(0xFF64748B)
                                          : const Color(0xFF94A3B8),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: isLoading
                                        ? SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: isDark ? Colors.black : AppColors.textOnPrimary,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Text(
                                            context.tr('loginButton'),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.3,
                                              color: !_agreedToTerms
                                                  ? (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8))
                                                  : (isDark ? Colors.black : AppColors.textOnPrimary),
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
