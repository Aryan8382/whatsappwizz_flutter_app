import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation/presentation/app_router.dart';
import 'shared/services/toast_service.dart';
import 'shared/widgets/wave_loader.dart';

import 'core/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.instance.initHost();
  runApp(
    const ProviderScope(
      child: WhatsappWizApp(),
    ),
  );
}

class WhatsappWizApp extends ConsumerStatefulWidget {
  const WhatsappWizApp({super.key});

  @override
  ConsumerState<WhatsappWizApp> createState() => _WhatsappWizAppState();
}

class _WhatsappWizAppState extends ConsumerState<WhatsappWizApp> {
  bool _appReady = false;

  @override
  void initState() {
    super.initState();
    // Dismiss initial wave loader smoothly after initial render
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() => _appReady = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'WhatsApp Wiz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      scaffoldMessengerKey: ToastService.messengerKey,
      routerConfig: router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.textScalerOf(context).clamp(minScaleFactor: 0.85, maxScaleFactor: 1.25),
          ),
          child: Stack(
            children: [
              if (child != null) child,
              // App-level initial WaveLoader on first boot
              WaveLoader(ready: _appReady),
            ],
          ),
        );
      },
    );
  }
}
