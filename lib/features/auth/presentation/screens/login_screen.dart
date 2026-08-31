import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/di/injection_container.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/widgets/app_logo.dart';
import 'package:m_it_student_platform/features/auth/domain/repositories/auth_repository.dart';
import 'package:m_it_student_platform/features/auth/presentation/controllers/auth_controller.dart';
import 'package:m_it_student_platform/features/navigation/presentation/main_shell.dart';

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

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    setState(() => _inlineError = null);
    _authController.clearError();

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

    // Background color: Pure White in light mode, Dark Slate in dark mode
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final inputBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final labelColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final iconAccentColor = isDark ? AppColors.accentLime : const Color(0xFF00213D);
    final focusBorderColor = isDark ? AppColors.accentLime : const Color(0xFF00213D);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _authController,
          builder: (context, _) {
            final isLoading = _authController.isLoading;

            return Center(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ── Logo ──
                          const AppLogo(size: 78),
                          const SizedBox(height: 16),

                          // ── Title ──
                          Text(
                            'M-IT Academy',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // ── Subtitle ──
                          Text(
                            context.tr('loginSubtitle'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.5,
                              color: subtitleColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Login Card ──
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 24),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: borderColor,
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withValues(alpha: 0.3)
                                      : Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── Error Banner ──
                                if (_inlineError != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.danger.withValues(
                                          alpha: isDark ? 0.2 : 0.08),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.danger.withValues(
                                            alpha: isDark ? 0.4 : 0.25),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.error_outline_rounded,
                                          color: AppColors.danger,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            _inlineError!,
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                              color: isDark
                                                  ? const Color(0xFFFCA5A5)
                                                  : AppColors.danger,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // ── 1. Login Input Label ──
                                Text(
                                  context.tr('loginLabel'),
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: labelColor,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // ── Login TextFormField (Text, Username, Login) ──
                                TextFormField(
                                  controller: _loginController,
                                  cursorColor: isDark ? Colors.white : Colors.black,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                    color: titleColor,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: context.tr('loginHint'),
                                    hintStyle: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.normal,
                                      letterSpacing: 0,
                                      color: isDark
                                          ? const Color(0xFF64748B)
                                          : const Color(0xFF94A3B8),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.person_outline_rounded,
                                      size: 20,
                                      color: iconAccentColor,
                                    ),
                                    filled: true,
                                    fillColor: inputBg,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 15),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                          color: borderColor),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                          color: borderColor),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                          color: focusBorderColor, width: 1.8),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // ── 2. Password Input Label ──
                                Text(
                                  context.tr('passwordLabel'),
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: labelColor,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // ── Password TextFormField ──
                                TextFormField(
                                  controller: _passwordController,
                                  cursorColor: isDark ? Colors.white : Colors.black,
                                  obscureText: _obscurePassword,
                                  keyboardType: TextInputType.visiblePassword,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _handleLogin(),
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: _obscurePassword ? 2.0 : 0.4,
                                    color: titleColor,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    hintText: context.tr('passwordHint'),
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      letterSpacing: 0,
                                      color: isDark
                                          ? const Color(0xFF64748B)
                                          : const Color(0xFF94A3B8),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline_rounded,
                                      size: 20,
                                      color: iconAccentColor,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 20,
                                        color: isDark
                                            ? (_obscurePassword
                                                ? const Color(0xFF94A3B8)
                                                : AppColors.accentLime)
                                            : (_obscurePassword
                                                ? const Color(0xFF64748B)
                                                : const Color(0xFF00213D)),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword =
                                              !_obscurePassword;
                                        });
                                      },
                                    ),
                                    filled: true,
                                    fillColor: inputBg,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 15),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                          color: borderColor),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                          color: borderColor),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                          color: focusBorderColor, width: 1.8),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 22),

                                // ── 3. Login Button ──
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed:
                                        isLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDark ? AppColors.accentLime : AppColors.primary,
                                      foregroundColor: isDark ? Colors.black : AppColors.textOnPrimary,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: isLoading
                                        ? SizedBox(
                                            width: 22,
                                            height: 22,
                                            child:
                                                CircularProgressIndicator(
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
                                              color: isDark ? Colors.black : AppColors.textOnPrimary,
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
