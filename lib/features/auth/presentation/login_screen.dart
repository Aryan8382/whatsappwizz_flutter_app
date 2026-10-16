import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/animated_entrance.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: AppConstants.demoAdminEmail);
  final _passwordController = TextEditingController(text: AppConstants.demoAdminPassword);
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillDemo(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
    });
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
                                        child: Row(
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
                                    SizedBox(height: sectionSpacing),

                                    // Quick Credentials Helper
                                    Container(
                                      padding: EdgeInsets.all(isCompact ? 10 : 12),
                                      decoration: BoxDecoration(
                                        color: AppColors.g50,
                                        borderRadius: AppRadii.borderLg,
                                        border: Border.all(color: AppColors.g200),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(AppIcons.info,
                                                  size: 15, color: AppColors.g700),
                                              const SizedBox(width: 6),
                                              Text(
                                                '1-Tap Login Credentials',
                                                style: AppTypography.labelSmall.copyWith(
                                                  color: AppColors.g800,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            children: [
                                              _CredChip(
                                                label: 'Admin',
                                                isSelected: _emailController.text == AppConstants.demoAdminEmail,
                                                onTap: () => _fillDemo(
                                                  AppConstants.demoAdminEmail,
                                                  AppConstants.demoAdminPassword,
                                                ),
                                              ),
                                              _CredChip(
                                                label: 'Supervisor',
                                                isSelected: _emailController.text == AppConstants.demoSupervisorEmail,
                                                onTap: () => _fillDemo(
                                                  AppConstants.demoSupervisorEmail,
                                                  AppConstants.demoSupervisorPassword,
                                                ),
                                              ),
                                              _CredChip(
                                                label: 'Agent',
                                                isSelected: _emailController.text == AppConstants.demoAgentEmail,
                                                onTap: () => _fillDemo(
                                                  AppConstants.demoAgentEmail,
                                                  AppConstants.demoAgentPassword,
                                                ),
                                              ),
                                              _CredChip(
                                                label: 'Reseller',
                                                isSelected: _emailController.text == AppConstants.demoResellerEmail,
                                                onTap: () => _fillDemo(
                                                  AppConstants.demoResellerEmail,
                                                  AppConstants.demoResellerPassword,
                                                ),
                                              ),
                                              _CredChip(
                                                label: 'Super Admin',
                                                isSelected: _emailController.text == AppConstants.demoSuperAdminEmail,
                                                onTap: () => _fillDemo(
                                                  AppConstants.demoSuperAdminEmail,
                                                  AppConstants.demoSuperAdminPassword,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
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

class _CredChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CredChip({
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.g600 : Colors.white,
          borderRadius: AppRadii.borderFull,
          border: Border.all(
            color: isSelected ? AppColors.g600 : AppColors.g300,
            width: isSelected ? 1.4 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.g600.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.g800,
          ),
        ),
      ),
    );
  }
}
