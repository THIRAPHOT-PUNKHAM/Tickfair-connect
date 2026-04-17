import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/db_service.dart';
import '../theme/app_theme.dart';

class QueueStatusScreen extends StatefulWidget {
  static const routeName = '/queue-status';

  const QueueStatusScreen({super.key});

  @override
  State<QueueStatusScreen> createState() => _QueueStatusScreenState();
}

class _QueueStatusScreenState extends State<QueueStatusScreen> {
  bool _cancelling = false;

  Future<void> _cancelQueue(String queueId) async {
    setState(() => _cancelling = true);
    try {
      final db = context.read<DbService>();
      await db.cancelQueueEntry(queueId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Queue cancelled')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  Future<void> _reserveTicket(String eventId, String queueId) async {
    try {
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/seat-selection',
          arguments: {'eventId': eventId, 'queueId': queueId},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final eventId = args?['eventId'] as String?;
    final queueId = args?['queueId'] as String?;

    if (eventId == null || queueId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Queue Status')),
        body: const Center(child: Text('Invalid queue data')),
      );
    }

    final db = context.read<DbService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Queue Status')),
      body: FutureBuilder(
        future: db.getQueuePosition(queueId),
        builder: (ctx, posSnapshot) {
          if (posSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (posSnapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to load queue status'),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      posSnapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        child: const Text('Retry'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          if (!posSnapshot.hasData || posSnapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Queue entry not found'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final posData = posSnapshot.data!;
          final position = posData['position'] as int? ?? 0;
          final isReady = position == 1;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // Position Circle
                  Center(
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isReady
                            ? AppTheme.successColor.withAlpha((0.1 * 255).round())
                            : AppTheme.primaryColor.withAlpha((0.1 * 255).round()),
                        border: Border.all(
                          color: isReady ? AppTheme.successColor : AppTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$position',
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: isReady ? AppTheme.successColor : AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isReady ? 'Your queue' : 'Your queue',
                            style: TextStyle(
                              fontSize: 13,
                              color: isReady ? AppTheme.successColor : AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Queue Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isReady
                          ? AppTheme.successColor.withAlpha((0.08 * 255).round())
                          : AppTheme.primaryColor.withAlpha((0.08 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isReady ? AppTheme.successColor : AppTheme.primaryColor,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildQueueInfo(
                          icon: Icons.queue,
                          label: 'Your Position',
                          value: position == 1 ? 'Next!' : 'Position #$position',
                          isHighlight: isReady,
                        ),
                        const SizedBox(height: 12),
                        _buildQueueInfo(
                          icon: Icons.info_outline,
                          label: 'Status',
                          value: position == 1 ? 'Ready to reserve' : 'Please wait your turn',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Reserve Button (enabled when position == 1)
                  if (isReady)
                    ElevatedButton.icon(
                      onPressed: () => _reserveTicket(eventId, queueId),
                      icon: const Icon(Icons.confirmation_number),
                      label: const Text('Reserve Your Ticket'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: const Text('Waiting for your turn...'),
                    ),
                  const SizedBox(height: 12),
                  // Cancel Button
                  TextButton(
                    onPressed: _cancelling ? null : () => _cancelQueue(queueId),
                    child: Text(
                      _cancelling ? 'Cancelling...' : 'Cancel Queue',
                      style: const TextStyle(color: AppTheme.errorColor),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQueueInfo({
    required IconData icon,
    required String label,
    required String value,
    bool isHighlight = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: isHighlight ? AppTheme.successColor : AppTheme.primaryColor,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isHighlight ? AppTheme.successColor : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
