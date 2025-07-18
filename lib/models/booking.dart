import 'companion.dart';

enum BookingStatus {
  pending,
  confirmed,
  active,
  completed,
  cancelled,
  refunded
}

class Booking {
  final String id;
  final String date;
  final String time;
  final String location;
  final String service;
  final Companion companion;
  final double price;
  final BookingStatus status;
  final String notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Booking({
    required this.id,
    required this.date,
    required this.time,
    required this.location,
    required this.service,
    required this.companion,
    required this.price,
    required this.status,
    this.notes = '',
    required this.createdAt,
    this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      location: json['location'] ?? '',
      service: json['service'] ?? '',
      companion: Companion.fromJson(json['companion'] ?? {}),
      price: (json['price'] ?? 0.0).toDouble(),
      status: BookingStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'time': time,
      'location': location,
      'service': service,
      'companion': companion.toJson(),
      'price': price,
      'status': status.name,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String get statusText {
    switch (status) {
      case BookingStatus.pending:
        return 'En attente';
      case BookingStatus.confirmed:
        return 'Confirmée';
      case BookingStatus.active:
        return 'En cours';
      case BookingStatus.completed:
        return 'Terminée';
      case BookingStatus.cancelled:
        return 'Annulée';
      case BookingStatus.refunded:
        return 'Remboursée';
    }
  }
}
