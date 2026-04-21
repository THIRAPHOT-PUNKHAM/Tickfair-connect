import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/db_service.dart';
import '../theme/app_theme.dart';
import 'event_detail_screen.dart';

class EventListScreen extends StatefulWidget {
  static const routeName = '/events';
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final db = context.read<DbService>();
    final auth = context.read<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<Map<String, dynamic>?>(
          stream: auth.currentUserData,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              final userName = snapshot.data!['displayName'] ?? snapshot.data!['email'] ?? 'User';
              return Text('Hi, $userName');
            }
            return const Text('Available Events');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: AppTheme.primaryColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Search by event name or venue...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

              ],
            ),
          ),
          // Events List
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: db.getEventsStream(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                }
                final docs = snapshot.data?.docs ?? <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                final filtered = docs.where((event) {
                  final data = event.data();
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final venue = (data['venue'] ?? '').toString().toLowerCase();
                  final description = (data['description'] ?? '').toString().toLowerCase();
                  
                  return name.contains(_searchQuery) || 
                         venue.contains(_searchQuery) ||
                         description.contains(_searchQuery);
                }).toList();

                // Sort the events by date/time
                filtered.sort((a, b) {
                  final dateA = (a.data()['dateTime'] as Timestamp?)?.toDate() ?? DateTime(2999);
                  final dateB = (b.data()['dateTime'] as Timestamp?)?.toDate() ?? DateTime(2999);
                  return dateA.compareTo(dateB);
                });

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.event_note, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No events available',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(14),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.82,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final event = filtered[i];
                    final data = event.data();
                    final eventId = event.id;
                    final name = data['name'] ?? 'Untitled Event';
                    final venue = data['venue'] ?? 'Location TBA';
                    final capacity = data['capacity'] ?? 0;
                    final available = data['ticketsAvailable'] ?? 0;
                    final dateTime = data['dateTime']?.toDate();
                    final date = dateTime != null
                        ? '${dateTime.day}/${dateTime.month}/${dateTime.year}'
                        : 'TBA';

                    // Determine background image based on event name
                    String? backgroundImage;
                    final lowerName = name.toLowerCase();
                    if (lowerName.contains('khemjira')) {
                      backgroundImage = 'assets/images/khemjira.jpg';
                    } else if (lowerName.contains('bts') || lowerName.contains('homecoming')) {
                      backgroundImage = 'assets/images/BTS.jpg';
                    } else if (lowerName.contains('pixxie')) {
                      backgroundImage = 'assets/images/pixxie.jpg';
                    } else if (lowerName.contains('bowkylion')) {
                      backgroundImage = 'assets/images/bowkylion.webp';
                    }

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.2 * 255).round()),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        color: Colors.grey[800],
                        image: backgroundImage != null
                            ? DecorationImage(
                                image: AssetImage(backgroundImage),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withAlpha((0.4 * 255).round()),
                                  BlendMode.darken,
                                ),
                              )
                            : null,
                      ),
                      child: InkWell(
                        onTap: () {
                          // include event id in the path to support deep links
                          Navigator.pushNamed(
                            ctx,
                            '${EventDetailScreen.routeName}/$eventId',
                            arguments: eventId,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: available > 0
                                          ? AppTheme.successColor.withAlpha((0.2 * 255).round())
                                          : AppTheme.errorColor.withAlpha((0.2 * 255).round()),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      available > 0 ? '$available' : 'Full',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: available > 0
                                            ? AppTheme.successColor
                                            : AppTheme.errorColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 13, color: Colors.white70),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      venue,
                                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 13, color: Colors.white70),
                                  const SizedBox(width: 3),
                                  Text(
                                    date,
                                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              LinearProgressIndicator(
                                value: capacity > 0 ? (capacity - available) / capacity : 0,
                                backgroundColor: Colors.white30,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppTheme.successColor,
                                ),
                                minHeight: 4,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$capacity tkt',
                                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                                  ),
                                  Text(
                                    '${((capacity - available) / capacity * 100).toStringAsFixed(0)}%',
                                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // floatingActionButton: kDebugMode
      //     ? FloatingActionButton(
      //         tooltip: 'Create sample event',
      //         child: const Icon(Icons.event),
      //         onPressed: () async {
      //           String message;
      //           try {
      //             final id = await db.createSampleEvent();
      //             message = 'Created sample event $id';
      //           } catch (e) {
      //             message = 'Error: ${e.toString()}';
      //           }
      //           if (mounted) {
      //             // ignore: use_build_context_synchronously
      //             ScaffoldMessenger.of(context).showSnackBar(
      //               SnackBar(content: Text(message)),
      //             );
      //           }
      //         },
      //       )
      //     : null,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

}
