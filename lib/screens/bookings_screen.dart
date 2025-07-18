import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/booking_provider.dart';
import '../models/booking.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().initializeBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Réservations'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.orange,
          labelColor: AppColors.orange,
          unselectedLabelColor: AppColors.mediumGray,
          tabs: const [
            Tab(text: 'À venir'),
            Tab(text: 'Terminées'),
            Tab(text: 'Annulées'),
          ],
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          if (bookingProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.orange,
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingsList(bookingProvider.upcomingBookings, 'upcoming'),
              _buildBookingsList(bookingProvider.completedBookings, 'completed'),
              _buildBookingsList(bookingProvider.cancelledBookings, 'cancelled'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingsList(List<Booking> bookings, String type) {
    if (bookings.isEmpty) {
      return _buildEmptyState(type);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildBookingCard(booking, type),
        );
      },
    );
  }

  Widget _buildEmptyState(String type) {
    String title;
    String subtitle;
    IconData icon;

    switch (type) {
      case 'upcoming':
        title = 'Aucune réservation à venir';
        subtitle = 'Explorez nos services et réservez votre prochaine expérience';
        icon = Icons.calendar_today;
        break;
      case 'completed':
        title = 'Aucune réservation terminée';
        subtitle = 'Vos réservations terminées apparaîtront ici';
        icon = Icons.check_circle_outline;
        break;
      case 'cancelled':
        title = 'Aucune réservation annulée';
        subtitle = 'Vos réservations annulées apparaîtront ici';
        icon = Icons.cancel_outlined;
        break;
      default:
        title = 'Aucune réservation';
        subtitle = '';
        icon = Icons.calendar_today;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.mediumGray.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, String type) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGray.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Image du prestataire
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    booking.companion.image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: AppColors.lightGray,
                        child: const Icon(
                          Icons.person,
                          color: AppColors.mediumGray,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                
                // Informations de réservation
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              booking.companion.name,
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildStatusChip(booking.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.service,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.mediumGray,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: AppColors.mediumGray,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${booking.date} à ${booking.time}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.mediumGray,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              booking.location,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${booking.price.toInt()} FCFA',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Actions
          if (type == 'upcoming')
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightGray.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Call companion
                      },
                      icon: const Icon(Icons.phone, size: 16),
                      label: const Text('Appeler'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.green,
                        side: const BorderSide(color: AppColors.green),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Send message
                      },
                      icon: const Icon(Icons.message, size: 16),
                      label: const Text('Message'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    Color color;
    String text;

    switch (status) {
      case BookingStatus.pending:
        color = AppColors.warning;
        text = 'En attente';
        break;
      case BookingStatus.confirmed:
        color = AppColors.info;
        text = 'Confirmée';
        break;
      case BookingStatus.active:
        color = AppColors.success;
        text = 'En cours';
        break;
      case BookingStatus.completed:
        color = AppColors.success;
        text = 'Terminée';
        break;
      case BookingStatus.cancelled:
        color = AppColors.error;
        text = 'Annulée';
        break;
      case BookingStatus.refunded:
        color = AppColors.mediumGray;
        text = 'Remboursée';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
