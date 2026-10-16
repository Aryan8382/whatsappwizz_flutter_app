import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/animated_entrance.dart';
import '../../../shared/widgets/server_switcher_sheet.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _serverLabel(String host) {
    if (host == AppConstants.publicBackendUrl) return 'Ngrok Cloud';
    if (host == AppConstants.localLanUrl) return 'Local Wi-Fi';
    return host.replaceFirst('https://', '').replaceFirst('http://', '');
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    await ref.read(authControllerProvider.notifier).login(
          _emailController.text,
          _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image with gradient fallback
            Image.asset(
              'assets/images/loginbg.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.g100, AppColors.g50, Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Backdrop blur layer
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                color: Colors.black.withOpacity(0.08),
              ),
            ),

            // Foreground Content with adaptive constraints for all screen sizes
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 360 || constraints.maxHeight < 680;
                  final isVeryCompact = constraints.maxWidth < 330;
                  final horizontalPadding = isVeryCompact ? 12.0 : (isCompact ? 16.0 : 20.0);
                  final cardPadding = isVeryCompact ? 16.0 : (isCompact ? 20.0 : 26.0);
                  final logoHeight = isCompact ? 38.0 : 46.0;
                  final fieldSpacing = isCompact ? 12.0 : 16.0;
                  final sectionSpacing = isCompact ? 16.0 : 22.0;

                  return SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: (constraints.maxHeight - 24).clamp(0, double.infinity),
                      ),
                      child: Center(
                        child: FadeSlideIn(
                          duration: AppAnimations.comfortable,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 420),
                            padding: EdgeInsets.all(cardPadding),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.93),
                              borderRadius: isCompact ? AppRadii.border3xl : AppRadii.border4xl,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                              boxShadow: AppShadows.glassXl,
                            ),
                            child: Form(
                              key: _formKey,
                              child: AutofillGroup(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Logo
                                    Center(
                                      child: Image.asset(
                                        'assets/images/logo.png',
                                        height: logoHeight,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => const Text(
                                          'WhatsApp Wiz',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.g700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Sign in to your workspace',
                                      textAlign: TextAlign.center,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: isCompact ? 12 : 13,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Center(
                                      child: InkWell(
                                        onTap: () => ServerSwitcherSheet.show(
                                          context,
                                          onServerChanged: () => setState(() {}),
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                                          decoration: BoxDecoration(
                                            color: AppColors.g50,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: AppColors.g200),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 7,
                                                height: 7,
                                                decoration: const BoxDecoration(
                                                  color: AppColors.statusGreenText,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Server: ${_serverLabel(ApiService.instance.currentHost)}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.g800,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.textSecondary),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: sectionSpacing),

                                    // Error Banner
                                    if (authState.error != null) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: AppColors.statusRedBg,
                                          borderRadius: AppRadii.borderLg,
                                          border: Border.all(color: AppColors.statusRedText.withOpacity(0.3)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(AppIcons.alertCircle,
                                                    color: AppColors.statusRedText, size: 18),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    authState.error!,
                                                    style: const TextStyle(
                                                      color: AppColors.statusRedText,
                                                      fontSize: 12.5,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            InkWell(
                                              onTap: () => ServerSwitcherSheet.show(
                                                context,
                                                onServerChanged: () => setState(() {}),
                                              ),
                                              child: const Text(
                                                'âš™ï¸ Tap to switch to Local Wi-Fi or update Server URL',
                                                style: TextStyle(
                                                  color: AppColors.g800,
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w700,
                                                  decoration: TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: fieldSpacing),
                                    ],

                                    // Email Field
                                    Text('Work Email', style: AppTypography.labelMedium),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      autofillHints: const [AutofillHints.email, AutofillHints.username],
                                      textInputAction: TextInputAction.next,
                                      decoration: InputDecoration(
                                        hintText: 'name@company.com',
                                        prefixIcon: const Icon(LucideIcons.mail, size: 18),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: isCompact ? 11 : 14,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Email is required';
                                        }
                                        if (!value.contains('@')) {
                                          return 'Enter a valid email address';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: fieldSpacing),

                                    // Password Field
                                    Text('Password', style: AppTypography.labelMedium),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      autofillHints: const [AutofillHints.password],
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) => _handleSubmit(),
                                      decoration: InputDecoration(
                                        hintText: '••••••••',
                                        prefixIcon: const Icon(LucideIcons.lock, size: 18),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: isCompact ? 11 : 14,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? LucideIcons.eyeOff
                                                : LucideIcons.eye,
                                            size: 18,
                                          ),
                                          onPressed: () {
                                            setState(() => _obscurePassword = !_obscurePassword);
                                          },
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Password is required';
                                        }
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: sectionSpacing),

                                    // Login Button
                                    ElevatedButton(
                                      onPressed: authState.isLoading ? null : _handleSubmit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.g600,
                                        padding: EdgeInsets.symmetric(vertical: isCompact ? 12 : 14),
                                        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderXl),
                                      ),
                                      child: authState.isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              'Sign In',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                      ),
                                    ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


