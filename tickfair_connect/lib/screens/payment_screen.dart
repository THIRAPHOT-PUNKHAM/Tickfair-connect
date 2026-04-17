import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/db_service.dart';
import '../theme/app_theme.dart';

class PaymentScreen extends StatefulWidget {
  static const routeName = '/payment';

  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedPaymentMethod;
  bool _processing = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'credit_card',
      'name': 'Credit/Debit Card',
      'icon': Icons.credit_card,
      'description': 'Visa, Mastercard, American Express',
    },
    {
      'id': 'mobile_banking',
      'name': 'Mobile Banking',
      'icon': Icons.phone_android,
      'description': 'KBank, BBL, SCB, Krungthai',
    },
    {
      'id': 'wallet',
      'name': 'E-Wallet',
      'icon': Icons.account_balance_wallet,
      'description': 'PromptPay, LINE Pay, Alipay',
    },
  ];

  Future<void> _processPayment(
    String eventId,
    String queueId,
    String seatLabel,
    int price,
  ) async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    setState(() => _processing = true);
    try {
      final db = context.read<DbService>();

      // Create ticket with payment
      final ticketId = await db.reserveTicketWithSeat(
        eventId,
        queueId,
        seatLabel,
        price,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/reservation',
          arguments: {'eventId': eventId, 'ticketId': ticketId},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final eventId = args?['eventId'] as String?;
    final eventName = args?['eventName'] as String?;
    final seatLabel = args?['seatLabel'] as String?;
    final price = args?['price'] as int? ?? 0;
    final queueId = args?['queueId'] as String?;

    if (eventId == null || queueId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payment')),
        body: const Center(child: Text('Invalid payment data')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ticket Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryRow('Event', eventName ?? 'N/A', Colors.white),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Seat', seatLabel ?? 'N/A', Colors.white),
                    const SizedBox(height: 12),
                    Container(
                      height: 1,
                      color: Colors.white24,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '฿$price',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Payment Methods
              const Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              ..._paymentMethods.map((method) {
                final isSelected = _selectedPaymentMethod == method['id'];
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedPaymentMethod = method['id']);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected
                          ? AppTheme.primaryColor.withAlpha((0.05 * 255).round())
                          : Colors.white,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor.withAlpha((0.1 * 255).round())
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            method['icon'],
                            color: AppTheme.primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method['name'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                method['description'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: AppTheme.primaryColor,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),
              // Processing Fee Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.blue[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Processing fee may apply depending on payment method',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Pay Button
              ElevatedButton(
                onPressed: _processing
                    ? null
                    : () => _processPayment(
                          eventId,
                          queueId,
                          seatLabel ?? '',
                          price,
                        ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.successColor,
                ),
                child: Text(
                  _processing ? 'Processing...' : 'Confirm Payment - ฿$price',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Cancel Button
              TextButton(
                onPressed: _processing ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: textColor.withAlpha((0.8 * 255).round())),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
