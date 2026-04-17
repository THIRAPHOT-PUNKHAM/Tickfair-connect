import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/auth_service.dart';
import '../services/db_service.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final db = context.read<DbService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Header
                StreamBuilder<Map<String, dynamic>?>(
                  stream: auth.currentUserData,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      final userData = snapshot.data!;
                      final email = userData['email'] ?? 'N/A';
                      final displayName = userData['displayName'] ?? 'User';

                      return Column(
                        children: [
                          // Avatar
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryColor.withAlpha((0.2 * 255).round()),
                            ),
                            child: Center(
                              child: Text(
                                displayName[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Display Name
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A5F7A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Email
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF5A7B8C),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                // Divider
                Divider(
                  color: Colors.grey[300],
                  thickness: 1,
                  height: 20,
                ),
                // Profile Information
                const Text(
                  'Account Information',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A5F7A),
                  ),
                ),
                const SizedBox(height: 12),
                // Info Cards
                _buildInfoCard('Email Verified', 'Yes', Icons.check_circle),
                const SizedBox(height: 20),
                // Booked Tickets Section
                const Text(
                  'Your Booked Tickets',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A5F7A),
                  ),
                ),
                const SizedBox(height: 12),
                // Tickets List
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: db.getUserTicketsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: AppTheme.errorColor, fontSize: 12),
                        ),
                      );
                    }

                    final tickets = snapshot.data?.docs ?? [];

                    if (tickets.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Center(
                          child: Text(
                            'No booked tickets yet',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF5A7B8C),
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: tickets.map((doc) {
                        final ticket = doc.data();
                        final eventId = ticket['eventId'] ?? '';
                        final ticketId = ticket['ticketId'] ?? 'N/A';
                        final seatLabel = ticket['seatLabel'] ?? 'N/A';
                        final price = ticket['price'] ?? 0;
                        final reservedAt = ticket['reservedAt'] as Timestamp?;

                        return FutureBuilder<Map<String, dynamic>?>(
                          future: db.getEventDataForTicket(eventId),
                          builder: (context, eventSnapshot) {
                            final eventName = eventSnapshot.data?['name'] ?? 'Loading...';

                            return GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(
                                      eventName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A5F7A),
                                      ),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(Icons.event_seat, size: 18, color: AppTheme.primaryColor),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Seat: $seatLabel',
                                              style: const TextStyle(fontSize: 14, color: Color(0xFF1A5F7A)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Icon(Icons.attach_money, size: 18, color: AppTheme.primaryColor),
                                            const SizedBox(width: 12),
                                            Text(
                                              '$price Baht',
                                              style: const TextStyle(fontSize: 14, color: Color(0xFF1A5F7A)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Icon(Icons.confirmation_number, size: 18, color: AppTheme.primaryColor),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                'ID: $ticketId',
                                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          showDialog(
                                            context: context,
                                            builder: (scanCtx) {
                                              return Dialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(24),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Text(
                                                        'Scan to Verify Ticket',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 24),
                                                      QrImageView(
                                                        data: ticketId,
                                                        version: QrVersions.auto,
                                                        size: 200,
                                                        backgroundColor: Colors.white,
                                                      ),
                                                      const SizedBox(height: 16),
                                                      Text(
                                                        ticketId,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                          color: Colors.grey,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(height: 24),
                                                      ElevatedButton(
                                                        onPressed: () => Navigator.pop(scanCtx),
                                                        style: ElevatedButton.styleFrom(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 32,
                                                            vertical: 12,
                                                          ),
                                                        ),
                                                        child: const Text('Close'),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: const Text('Scan'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[50],
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.event_note, size: 16, color: AppTheme.primaryColor),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        eventName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A5F7A),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Logout Button
                ElevatedButton.icon(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    await auth.signOut();
                    if (!mounted) return;
                    navigator.pushReplacementNamed('/login');
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF5A7B8C),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A5F7A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
