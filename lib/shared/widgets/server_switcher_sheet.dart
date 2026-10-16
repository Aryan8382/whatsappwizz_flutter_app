import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_typography.dart';
import '../services/toast_service.dart';

class ServerSwitcherSheet extends StatefulWidget {
  final VoidCallback? onServerChanged;

  const ServerSwitcherSheet({super.key, this.onServerChanged});

  static Future<void> show(BuildContext context, {VoidCallback? onServerChanged}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ServerSwitcherSheet(onServerChanged: onServerChanged),
    );
  }

  @override
  State<ServerSwitcherSheet> createState() => _ServerSwitcherSheetState();
}

class _ServerSwitcherSheetState extends State<ServerSwitcherSheet> {
  late String _selectedHost;
  final TextEditingController _customController = TextEditingController();
  bool _isTesting = false;
  String? _testResult;
  bool? _testSuccess;

  @override
  void initState() {
    super.initState();
    _selectedHost = ApiService.instance.currentHost;
    if (_selectedHost != AppConstants.publicBackendUrl &&
        _selectedHost != AppConstants.localLanUrl) {
      _customController.text = _selectedHost;
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  Future<void> _testConnection(String host) async {
    setState(() {
      _isTesting = true;
      _testResult = 'Pinging $host...';
      _testSuccess = null;
    });

    final ok = await ApiService.instance.pingHost(host);
    if (!mounted) return;

    setState(() {
      _isTesting = false;
      _testSuccess = ok;
      _testResult = ok
          ? 'Connected successfully (200 OK)'
          : 'Failed: Server unreachable or tunnel offline';
    });
  }

  Future<void> _applyHost(String host) async {
    final clean = host.trim().replaceAll(RegExp(r'/+$'), '');
    if (clean.isEmpty) return;

    await ApiService.instance.setHost(clean);
    ToastService.success('Switched to ${_displayName(clean)}');
    widget.onServerChanged?.call();
    if (mounted) Navigator.of(context).pop();
  }

  String _displayName(String host) {
    if (host == AppConstants.publicBackendUrl) return 'Render Cloud';
    if (host == AppConstants.localLanUrl) return 'Local Wi-Fi';
    return host;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(Icons.dns_rounded, color: AppColors.g700, size: 22),
              const SizedBox(width: 10),
              Text('Backend Server Connection', style: AppTypography.displayMedium.copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Select how your mobile app reaches the WhatsApp Wiz backend server.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),

          // Option 1: Render Cloud Backend (Live)
          _buildOption(
            title: 'Render Cloud Backend (Live)',
            subtitle: AppConstants.publicBackendUrl,
            host: AppConstants.publicBackendUrl,
            icon: Icons.cloud_done_rounded,
            badge: 'Online 24/7',
          ),
          const SizedBox(height: 10),

          // Option 2: Local Wi-Fi URL
          _buildOption(
            title: 'Local Wi-Fi (Direct IP)',
            subtitle: AppConstants.localLanUrl,
            host: AppConstants.localLanUrl,
            icon: Icons.wifi_rounded,
            badge: 'Fastest on same Wi-Fi',
          ),
          const SizedBox(height: 14),

          // Custom URL Input
          Text('Custom Server URL', style: AppTypography.labelMedium),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customController,
                  decoration: InputDecoration(
                    hintText: 'https://your-tunnel.ngrok-free.dev',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: AppRadii.borderLg),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  final text = _customController.text.trim();
                  if (text.isNotEmpty) {
                    setState(() => _selectedHost = text);
                    _testConnection(text);
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.g600,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: AppRadii.borderLg),
                ),
                child: const Text('Test'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Test Status indicator
          if (_testResult != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _testSuccess == true
                    ? AppColors.statusGreenBg
                    : (_testSuccess == false ? AppColors.statusRedBg : Colors.grey.shade100),
                borderRadius: AppRadii.borderMd,
              ),
              child: Row(
                children: [
                  if (_isTesting)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      _testSuccess == true ? Icons.check_circle : Icons.error,
                      size: 16,
                      color: _testSuccess == true ? AppColors.statusGreenText : AppColors.statusRedText,
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _testResult!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _testSuccess == true ? AppColors.statusGreenText : AppColors.statusRedText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Apply Button
          FilledButton.icon(
            onPressed: () => _applyHost(_selectedHost),
            icon: const Icon(Icons.check, size: 18),
            label: Text('Use ${_displayName(_selectedHost)}', style: const TextStyle(fontWeight: FontWeight.w700)),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.g600,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: AppRadii.borderLg),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String title,
    required String subtitle,
    required String host,
    required IconData icon,
    required String badge,
  }) {
    final isSelected = _selectedHost == host;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedHost = host;
          _customController.text = '';
        });
        _testConnection(host);
      },
      borderRadius: AppRadii.borderLg,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.g50 : Colors.white,
          borderRadius: AppRadii.borderLg,
          border: Border.all(
            color: isSelected ? AppColors.g600 : Colors.grey.shade300,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.g600 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: isSelected ? Colors.white : AppColors.g800),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(badge, style: TextStyle(fontSize: 10, color: Colors.grey.shade700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, fontFamily: 'monospace'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.g600 : Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
