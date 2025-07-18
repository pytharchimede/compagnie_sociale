import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../models/companion.dart';

class BookingProvider with ChangeNotifier {
  List<Booking> _bookings = [];
  bool _isLoading = false;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;

  List<Booking> get upcomingBookings => _bookings
      .where((booking) => 
        booking.status == BookingStatus.confirmed || 
        booking.status == BookingStatus.pending)
      .toList();

  List<Booking> get completedBookings => _bookings
      .where((booking) => booking.status == BookingStatus.completed)
      .toList();

  List<Booking> get cancelledBookings => _bookings
      .where((booking) => 
        booking.status == BookingStatus.cancelled ||
        booking.status == BookingStatus.refunded)
      .toList();

  void initializeBookings() {
    _isLoading = true;
    notifyListeners();

    // Simulation de réservations
    _bookings = [
      Booking(
        id: 'book_1',
        date: '25 Juillet 2025',
        time: '14:00',
        location: 'Hôtel Ivoire, Abidjan',
        service: 'Guide Touristique',
        companion: Companion(
          id: '1',
          name: 'Aminata Koné',
          specialty: 'Guide Touristique Premium',
          location: 'Plateau, Abidjan',
          image: 'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg',
          rating: 4.9,
          price: 25000,
          reviews: 124,
          verified: true,
          available: true,
          languages: ['Français', 'Baoulé', 'Anglais'],
          experience: '5 ans',
          category: 'Guides',
          description: 'Guide expérimentée',
          phone: '+225 07 00 00 01',
        ),
        price: 25000,
        status: BookingStatus.confirmed,
        notes: 'Visite des sites historiques d\'Abidjan',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Booking(
        id: 'book_2',
        date: '20 Juillet 2025',
        time: '18:00',
        location: 'Sofitel Abidjan',
        service: 'Événement Social',
        companion: Companion(
          id: '2',
          name: 'Fatoumata Traoré',
          specialty: 'Organisatrice d\'Événements',
          location: 'Cocody, Abidjan',
          image: 'https://images.pexels.com/photos/1181519/pexels-photo-1181519.jpeg',
          rating: 4.8,
          price: 35000,
          reviews: 89,
          verified: true,
          available: true,
          languages: ['Français', 'Dioula', 'Anglais'],
          experience: '7 ans',
          category: 'Événements',
          description: 'Organisatrice experte',
          phone: '+225 07 00 00 02',
        ),
        price: 35000,
        status: BookingStatus.completed,
        notes: 'Organisation soirée d\'entreprise',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createBooking({
    required String companionId,
    required String date,
    required String time,
    required String location,
    required String service,
    required double price,
    String notes = '',
  }) async {
    _isLoading = true;
    notifyListeners();

    // Simulation de création de réservation
    await Future.delayed(const Duration(seconds: 1));

    // Note: In a real app, you would get the companion from a service
    // For now, we'll create a dummy companion
    final booking = Booking(
      id: 'book_${DateTime.now().millisecondsSinceEpoch}',
      date: date,
      time: time,
      location: location,
      service: service,
      companion: Companion(
        id: companionId,
        name: 'Companion Name',
        specialty: service,
        location: location,
        image: 'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg',
        rating: 4.5,
        price: price,
        reviews: 50,
        verified: true,
        available: true,
        languages: ['Français'],
        experience: '3 ans',
        category: 'General',
        description: 'Professional companion',
        phone: '+225 07 00 00 00',
      ),
      price: price,
      status: BookingStatus.pending,
      notes: notes,
      createdAt: DateTime.now(),
    );

    _bookings.add(booking);
    _isLoading = false;
    notifyListeners();
  }

  void updateBookingStatus(String bookingId, BookingStatus status) {
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index != -1) {
      // Note: Since Booking fields are final, in a real app you would
      // create a new booking instance or use a mutable model
      _bookings[index] = Booking(
        id: _bookings[index].id,
        date: _bookings[index].date,
        time: _bookings[index].time,
        location: _bookings[index].location,
        service: _bookings[index].service,
        companion: _bookings[index].companion,
        price: _bookings[index].price,
        status: status,
        notes: _bookings[index].notes,
        createdAt: _bookings[index].createdAt,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void cancelBooking(String bookingId) {
    updateBookingStatus(bookingId, BookingStatus.cancelled);
  }

  Booking? getBookingById(String id) {
    try {
      return _bookings.firstWhere((booking) => booking.id == id);
    } catch (e) {
      return null;
    }
  }
}
