import 'package:flutter/foundation.dart';
import '../models/companion.dart';

class CompanionProvider with ChangeNotifier {
  List<Companion> _companions = [];
  List<Companion> _featuredCompanions = [];
  List<Companion> _filteredCompanions = [];
  String _selectedCategory = 'Tous';
  String _searchQuery = '';
  bool _isLoading = false;

  List<Companion> get companions => _companions;
  List<Companion> get featuredCompanions => _featuredCompanions;
  List<Companion> get filteredCompanions => _filteredCompanions;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  final List<String> categories = [
    'Tous',
    'Guides',
    'Événements',
    'VIP',
    'Business',
    'Escort'
  ];

  void initializeCompanions() {
    _isLoading = true;
    notifyListeners();

    // Simulation de données avec des noms ivoiriens
    _companions = [
      Companion(
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
        description: 'Guide expérimentée spécialisée dans les visites culturelles d\'Abidjan',
        phone: '+225 07 00 00 01',
      ),
      Companion(
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
        description: 'Spécialiste en organisation d\'événements sociaux et corporatifs',
        phone: '+225 07 00 00 02',
      ),
      Companion(
        id: '3',
        name: 'Adjoa Assi',
        specialty: 'Service VIP & Protocole',
        location: 'Marcory, Abidjan',
        image: 'https://images.pexels.com/photos/1547971/pexels-photo-1547971.jpeg',
        rating: 4.9,
        price: 45000,
        reviews: 156,
        verified: true,
        available: false,
        languages: ['Français', 'Attié', 'Anglais'],
        experience: '8 ans',
        category: 'VIP',
        description: 'Experte en services VIP et protocole d\'entreprise',
        phone: '+225 07 00 00 03',
      ),
      Companion(
        id: '4',
        name: 'Koffi Yao',
        specialty: 'Consultant Business',
        location: 'Deux Plateaux, Abidjan',
        image: 'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg',
        rating: 4.7,
        price: 50000,
        reviews: 73,
        verified: true,
        available: true,
        languages: ['Français', 'Baoulé', 'Anglais'],
        experience: '10 ans',
        category: 'Business',
        description: 'Consultant senior en développement business',
        phone: '+225 07 00 00 04',
      ),
      Companion(
        id: '5',
        name: 'Aïssa Coulibaly',
        specialty: 'Escort & Sécurité',
        location: 'Treichville, Abidjan',
        image: 'https://images.pexels.com/photos/1130626/pexels-photo-1130626.jpeg',
        rating: 4.6,
        price: 30000,
        reviews: 92,
        verified: true,
        available: true,
        languages: ['Français', 'Dioula', 'Malinké'],
        experience: '6 ans',
        category: 'Escort',
        description: 'Spécialiste en services d\'escort et sécurité personnelle',
        phone: '+225 07 00 00 05',
      ),
      Companion(
        id: '6',
        name: 'Mariam Bamba',
        specialty: 'Guide Culturel',
        location: 'Yopougon, Abidjan',
        image: 'https://images.pexels.com/photos/1040880/pexels-photo-1040880.jpeg',
        rating: 4.8,
        price: 28000,
        reviews: 67,
        verified: true,
        available: true,
        languages: ['Français', 'Dioula', 'Bambara'],
        experience: '4 ans',
        category: 'Guides',
        description: 'Passionnée de culture ivoirienne et d\'histoire locale',
        phone: '+225 07 00 00 06',
      ),
    ];

    _featuredCompanions = _companions.where((c) => c.rating >= 4.8).toList();
    _filteredCompanions = List.from(_companions);
    
    _isLoading = false;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _filterCompanions();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterCompanions();
    notifyListeners();
  }

  void _filterCompanions() {
    _filteredCompanions = _companions.where((companion) {
      final matchesCategory = _selectedCategory == 'Tous' || 
                             companion.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
                           companion.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           companion.specialty.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           companion.location.toLowerCase().contains(_searchQuery.toLowerCase());
      
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Companion? getCompanionById(String id) {
    try {
      return _companions.firstWhere((companion) => companion.id == id);
    } catch (e) {
      return null;
    }
  }

  void toggleAvailability(String companionId) {
    final index = _companions.indexWhere((c) => c.id == companionId);
    if (index != -1) {
      // Note: Since Companion fields are final, we would need to create a new instance
      // For now, we'll just notify listeners
      notifyListeners();
    }
  }
}
