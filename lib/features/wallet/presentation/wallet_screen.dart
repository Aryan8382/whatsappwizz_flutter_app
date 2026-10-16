import 'package:flutter/material.dart';
import '../../../core/services/repositories/wallet_api_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/animated_entrance.dart';
import '../../../shared/widgets/modal_sheet.dart';
import '../../../shared/widgets/status_badge.dart';
import 'widgets/add_transaction_sheet.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _repo = WalletApiRepository();
  bool _isLoading = false;
  double _balance = 0.0;
  String _currency = 'INR';

  String _formatTxTitle(Map<String, dynamic> item) {
    final desc = item['description']?.toString().trim();
    if (desc != null && desc.isNotEmpty && !desc.startsWith('text-') && !desc.startsWith('msg-') && !desc.startsWith('pay_')) {
      return desc;
    }
    final ref = item['reference']?.toString() ?? item['reference_id']?.toString() ?? '';
    final type = item['type']?.toString().toLowerCase() ?? '';
    if (type == 'credit' || ref.startsWith('pay_') || ref.startsWith('rec_') || ref.startsWith('sys_credit')) {
      return 'Wallet Recharge';
    }
    if (ref.startsWith('text-') || ref.startsWith('msg-')) {
      return 'WhatsApp Outbound Message';
    }
    if (ref.startsWith('tpl-') || ref.startsWith('template-')) {
      return 'WhatsApp Template Message';
    }
    if (ref.startsWith('media-') || ref.startsWith('img-') || ref.startsWith('video-')) {
      return 'WhatsApp Media Attachment';
    }
    if (ref.startsWith('camp_')) {
      return 'Campaign Broadcast Deduction';
    }
    return type == 'debit' ? 'WhatsApp Message Delivery' : 'Wallet Credit';
  }

  Future<void> _loadWalletData() async {
    setState(() => _isLoading = true);
    try {
      final walletData = await _repo.getWallet();
      final balanceRaw = walletData['balance'];
      if (balanceRaw != null) {
        _balance = double.tryParse(balanceRaw.toString()) ?? _balance;
      }
      if (walletData['currency'] != null) {
        _currency = walletData['currency'].toString();
      }
      final txList = await _repo.getTransactions();
      if (txList.isNotEmpty) {
        _transactions.clear();
        for (final item in txList) {
          final amt = double.tryParse(item['amount']?.toString() ?? '0') ?? 0.0;
          _transactions.add({
            'id': item['id'],
            'wallet_id': item['walletId'],
            'title': _formatTxTitle(item),
            'description': item['description']?.toString() ?? '',
            'amount': amt,
            'type': item['type']?.toString() ?? (amt >= 0 ? 'credit' : 'debit'),
            'reference_id': item['reference']?.toString() ?? '',
            'created_at': DateTime.tryParse(item['createdAt']?.toString() ?? '') ?? DateTime.now(),
          });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  // DB Table: wallet_transactions
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 104,
      'wallet_id': 1,
      'title': 'Wallet Recharge (Razorpay)',
      'description': 'Online top-up via UPI / Netbanking',
      'amount': 2000.00,
      'type': 'credit',
      'reference_id': 'pay_Oz7K19xP2la98q',
      'created_at': DateTime.now().subtract(const Duration(hours: 3)),
    },
    {
      'id': 103,
      'wallet_id': 1,
      'title': 'Campaign Deduction: Diwali Mega Sale',
      'description': 'Marketing messages delivery charge (580 recipients)',
      'amount': -452.40,
      'type': 'debit',
      'reference_id': 'camp_diwali_2026_01',
      'created_at': DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    },
    {
      'id': 102,
      'wallet_id': 1,
      'title': 'Utility Template Charges',
      'description': 'Order confirmation & OTP utility notifications (140 msgs)',
      'amount': -49.00,
      'type': 'debit',
      'reference_id': 'batch_util_9921',
      'created_at': DateTime.now().subtract(const Duration(days: 3)),
    },
    {
      'id': 101,
      'wallet_id': 1,
      'title': 'Opening Balance Credit',
      'description': 'Initial account provisioning bonus',
      'amount': 3501.40,
      'type': 'credit',
      'reference_id': 'sys_credit_signup',
      'created_at': DateTime.now().subtract(const Duration(days: 7)),
    },
  ];

  // DB Table: invoices
  final List<Map<String, dynamic>> _invoices = [
    {
      'id': 12,
      'invoice_number': 'INV-2026-092',
      'amount': 2360.00,
      'base_amount': 2000.00,
      'gst_amount': 360.00,
      'status': 'paid',
      'razorpay_order_id': 'order_Oz7K18a09L2k1',
      'razorpay_payment_id': 'pay_Oz7K19xP2la98q',
      'paid_at': DateTime.now().subtract(const Duration(hours: 3)),
      'created_at': DateTime.now().subtract(const Duration(hours: 3, minutes: 10)),
    },
    {
      'id': 11,
      'invoice_number': 'INV-2026-081',
      'amount': 5900.00,
      'base_amount': 5000.00,
      'gst_amount': 900.00,
      'status': 'paid',
      'razorpay_order_id': 'order_Ny5T89b12P3q1',
      'razorpay_payment_id': 'pay_Ny5T90c23Q4r2',
      'paid_at': DateTime.now().subtract(const Duration(days: 14)),
      'created_at': DateTime.now().subtract(const Duration(days: 14)),
    },
    {
      'id': 10,
      'invoice_number': 'INV-2026-070',
      'amount': 2950.00,
      'base_amount': 2500.00,
      'gst_amount': 450.00,
      'status': 'paid',
      'razorpay_order_id': 'order_Mx4S78a01O2p0',
      'razorpay_payment_id': 'pay_Mx4S79b12P3q1',
      'paid_at': DateTime.now().subtract(const Duration(days: 35)),
      'created_at': DateTime.now().subtract(const Duration(days: 35)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadWalletData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showRechargeSheet() {
    final amountController = TextEditingController(text: '1000');
    ModalSheet.show(
      context: context,
      title: 'Top Up WABA Wallet',
      subtitle: 'Add messaging credits in $_currency (₹)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Recharge Amount (₹)',
              prefixText: '₹ ',
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: [500, 1000, 2500, 5000].map((amt) {
              return ActionChip(
                label: Text('₹$amt'),
                onPressed: () {
                  amountController.text = amt.toString();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(amountController.text) ?? 0.0;
              if (val > 0) {
                final refId = 'pay_${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
                final invNum = 'INV-2026-${(100 + _invoices.length).toString()}';
                final now = DateTime.now();

                setState(() {
                  _balance += val;
                  _transactions.insert(0, {
                    'id': _transactions.length + 101,
                    'wallet_id': 1,
                    'title': 'Wallet Recharge (Razorpay)',
                    'description': 'Instant wallet credit top-up',
                    'amount': val,
                    'type': 'credit',
                    'reference_id': refId,
                    'created_at': now,
                  });
                  _invoices.insert(0, {
                    'id': _invoices.length + 11,
                    'invoice_number': invNum,
                    'amount': val * 1.18,
                    'base_amount': val,
                    'gst_amount': val * 0.18,
                    'status': 'paid',
                    'razorpay_order_id': 'order_${refId.substring(4)}',
                    'razorpay_payment_id': refId,
                    'paid_at': now,
                    'created_at': now,
                  });
                });
                Navigator.of(context).pop();
                ToastService.success('Wallet credited with ₹${val.toStringAsFixed(2)}');
              }
            },
            child: const Text('Proceed to Payment (Razorpay)'),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(Map<String, dynamic> tx) {
    ModalSheet.show(
      context: context,
      title: 'Transaction Details',
      subtitle: 'Record ID #${tx['id']} in wallet_transactions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.g50,
              borderRadius: AppRadii.border2xl,
              border: Border.all(color: AppColors.g200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx['title'], style: AppTypography.titleMedium),
                const SizedBox(height: 4),
                Text(tx['description'], style: AppTypography.bodySmall),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Amount:', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      '${tx['amount'] > 0 ? '+' : ''} ₹${(tx['amount'] as double).abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: tx['type'] == 'credit' ? AppColors.statusGreenText : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _detailRow('Transaction ID', '#${tx['id']}'),
          _detailRow('Wallet ID', '#${tx['wallet_id']} (Organization #2)'),
          _detailRow('Transaction Type', (tx['type'] as String).toUpperCase()),
          _detailRow('Reference ID', tx['reference_id'], copyable: true),
          _detailRow('Timestamp', _formatDateTime(tx['created_at'])),
        ],
      ),
    );
  }

  void _showInvoiceDetails(Map<String, dynamic> inv) {
    ModalSheet.show(
      context: context,
      title: 'Tax Invoice ${inv['invoice_number']}',
      subtitle: 'GST Tax Invoice (DB Table: invoices)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadii.border2xl,
              border: Border.all(color: const Color(0x3322C55E)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(inv['invoice_number'], style: AppTypography.titleMedium.copyWith(color: AppColors.g950)),
                    StatusBadge(status: inv['status'], label: (inv['status'] as String).toUpperCase()),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Base Recharge Amount:', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                    Text('₹${(inv['base_amount'] as double).toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('IGST @ 18%:', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                    Text('₹${(inv['gst_amount'] as double).toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Paid Amount:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('₹${(inv['amount'] as double).toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.g800)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _detailRow('Razorpay Order ID', inv['razorpay_order_id'], copyable: true),
          _detailRow('Razorpay Payment ID', inv['razorpay_payment_id'], copyable: true),
          _detailRow('Paid At', _formatDateTime(inv['paid_at'])),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ToastService.success('Tax Invoice ${inv['invoice_number']} downloaded');
            },
            icon: const Icon(LucideIcons.download, size: 16),
            label: const Text('Download PDF Invoice'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              if (copyable) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => ToastService.info('Copied $value'),
                  child: const Icon(LucideIcons.copy, size: 14, color: AppColors.textMuted),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Wallet & Billing'),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 76),
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.g600,
          foregroundColor: Colors.white,
          icon: const Icon(LucideIcons.plus, size: 20),
          label: const Text('Add Transaction', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () {
            AddTransactionSheet.show(
              context,
              onSave: (data) {
                setState(() {
                  final amt = double.tryParse(data['amount'].toString()) ?? 0.0;
                  final isCredit = data['type'] == 'credit';
                  if (isCredit) {
                    _balance += amt;
                  } else {
                    _balance -= amt;
                  }
                  _transactions.insert(0, {
                    'id': _transactions.length + 101,
                    'wallet_id': 1,
                    'title': data['description'] ?? data['type'],
                    'description': data['reference'] ?? '',
                    'amount': isCredit ? amt : -amt,
                    'type': data['type'],
                    'reference_id': data['reference'] ?? 'manual',
                    'created_at': DateTime.now(),
                  });
                });
                ToastService.success('Transaction recorded');
              },
            );
          },
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Balance Card
                  FadeSlideIn(
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.g700, AppColors.g950],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: AppRadii.border3xl,
                        boxShadow: const [
                          BoxShadow(color: Color(0x3315803D), blurRadius: 16, offset: Offset(0, 6)),
                        ],
                      ),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Available Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Currency: $_currency',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '₹${_balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: ElevatedButton.icon(
                                onPressed: _showRechargeSheet,
                                icon: const Icon(AppIcons.add, size: 16, color: AppColors.g800),
                                label: const Text(
                                  'Top Up Balance',
                                  style: TextStyle(
                                    color: AppColors.g800,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: OutlinedButton.icon(
                                onPressed: () => ToastService.info('Rate card: ₹0.70/mkt, ₹0.35/utility'),
                                icon: const Icon(LucideIcons.info, size: 15, color: Colors.white),
                                label: const Text(
                                  'Meta Rates',
                                  style: TextStyle(color: Colors.white, fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white38),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ),
                  const SizedBox(height: 16),

                  // Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.g50,
                      borderRadius: AppRadii.borderXl,
                      border: Border.all(color: AppColors.g200),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.g600,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadii.borderXl,
                        boxShadow: const [
                          BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      labelColor: AppColors.g800,
                      unselectedLabelColor: AppColors.textMuted,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      tabs: [
                        Tab(text: 'Transactions (${_transactions.length})'),
                        Tab(text: 'Invoices (${_invoices.length})'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Transactions
            ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
              itemCount: _transactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final tx = _transactions[index];
                final isCredit = tx['type'] == 'credit';

                return FadeSlideIn.staggered(
                  index: index,
                  child: InkWell(
                    onTap: () => _showTransactionDetails(tx),
                    borderRadius: AppRadii.borderXl,
                    child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadii.borderXl,
                      border: Border.all(color: const Color(0x3322C55E)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isCredit ? AppColors.statusGreenBg : Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCredit ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
                            size: 16,
                            color: isCredit ? AppColors.statusGreenText : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tx['title'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(
                                'Ref: ${tx['reference_id']} • ${_formatDateTime(tx['created_at'])}',
                                style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${isCredit ? '+' : '-'} ₹${(tx['amount'] as double).abs().toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: isCredit ? AppColors.statusGreenText : const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                );
              },
            ),

            // Tab 2: Invoices
            ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
              itemCount: _invoices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final inv = _invoices[index];

                return FadeSlideIn.staggered(
                  index: index,
                  child: InkWell(
                    onTap: () => _showInvoiceDetails(inv),
                    borderRadius: AppRadii.borderXl,
                    child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadii.borderXl,
                      border: Border.all(color: const Color(0x3322C55E)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.statusGreenBg,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.fileText, size: 16, color: AppColors.waGreen),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(inv['invoice_number'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                              const SizedBox(height: 2),
                              Text(
                                'Paid: ${_formatDateTime(inv['paid_at'])}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${(inv['amount'] as double).toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.g950),
                            ),
                            const SizedBox(height: 2),
                            StatusBadge(status: inv['status'], label: (inv['status'] as String).toUpperCase()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
