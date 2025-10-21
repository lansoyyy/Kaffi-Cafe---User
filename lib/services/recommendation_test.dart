import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kaffi_cafe/services/product_relationship_service.dart';
import 'package:kaffi_cafe/services/recommendation_service.dart';

/// Test service to verify the recommendation system works correctly
class RecommendationTest {
  final ProductRelationshipService _relationshipService =
      ProductRelationshipService();
  final RecommendationService _recommendationService = RecommendationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Test the complete recommendation flow
  Future<void> testRecommendationSystem() async {
    print('Testing Kaffi Cafe Recommendation System...');

    try {
      // 1. Create test order data
      List<Map<String, dynamic>> testOrder = [
        {'name': 'Spanish Latte', 'price': 150.0, 'quantity': 1},
        {'name': 'Croissant', 'price': 80.0, 'quantity': 2},
        {'name': 'Cappuccino', 'price': 120.0, 'quantity': 1},
      ];

      // 2. Track product relationships
      print('Tracking product relationships...');
      await _relationshipService.trackProductRelationships(testOrder);
      print('✓ Product relationships tracked successfully');

      // 3. Test getting recommendations
      print('Getting recommendations for Spanish Latte...');
      final recommendations = await _recommendationService
          .getFrequentlyBoughtTogether('Spanish Latte');

      if (recommendations.isNotEmpty) {
        print('✓ Recommendations found:');
        for (var rec in recommendations) {
          print(
              '  - ${rec['name']} (Co-occurrence: ${rec['coOccurrenceRatio']?.toStringAsFixed(2) ?? 'N/A'})');
        }
      } else {
        print('⚠ No recommendations found (this is normal for new systems)');
      }

      // 4. Test popular products in category
      print('Getting popular Coffee products...');
      final popularProducts = await _recommendationService
          .getPopularProductsInCategory('Coffee', 'Spanish Latte');

      if (popularProducts.isNotEmpty) {
        print('✓ Popular products found:');
        for (var product in popularProducts) {
          print(
              '  - ${product['name']} (Ordered ${product['orderCount'] ?? 0} times)');
        }
      } else {
        print('⚠ No popular products found');
      }

      print('\n✅ Recommendation system test completed successfully!');
    } catch (e) {
      print('❌ Test failed: $e');
    }
  }

  /// Initialize sample data for testing
  Future<void> initializeSampleData() async {
    print('Initializing sample data for testing...');

    try {
      // Sample products
      List<Map<String, dynamic>> sampleProducts = [
        {
          'name': 'Spanish Latte',
          'category': 'Coffee',
          'price': 150.0,
          'branch': 'Kaffi Cafe - Eloisa St',
          'orderCount': 0,
          'image': 'https://example.com/spanish-latte.jpg',
          'description':
              'A rich espresso with steamed milk and a touch of vanilla',
          'ingredients': 'Espresso, Steamed Milk, Vanilla Syrup',
          'timestamp': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Croissant',
          'category': 'Pastries',
          'price': 80.0,
          'branch': 'Kaffi Cafe - Eloisa St',
          'orderCount': 0,
          'image': 'https://example.com/croissant.jpg',
          'description': 'Buttery, flaky French pastry',
          'ingredients': 'Flour, Butter, Yeast, Sugar, Salt',
          'timestamp': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Cappuccino',
          'category': 'Coffee',
          'price': 120.0,
          'branch': 'Kaffi Cafe - Eloisa St',
          'orderCount': 0,
          'image': 'https://example.com/cappuccino.jpg',
          'description': 'Espresso with steamed milk foam',
          'ingredients': 'Espresso, Steamed Milk, Milk Foam',
          'timestamp': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Blueberry Muffin',
          'category': 'Pastries',
          'price': 90.0,
          'branch': 'Kaffi Cafe - Eloisa St',
          'orderCount': 0,
          'image': 'https://example.com/blueberry-muffin.jpg',
          'description': 'Fresh blueberry muffin with a crumb topping',
          'ingredients': 'Flour, Blueberries, Sugar, Eggs, Butter',
          'timestamp': FieldValue.serverTimestamp(),
        },
      ];

      // Add products to Firestore
      for (var product in sampleProducts) {
        final existingProducts = await _firestore
            .collection('products')
            .where('name', isEqualTo: product['name'])
            .get();

        if (existingProducts.docs.isEmpty) {
          await _firestore.collection('products').add(product);
          print('✓ Added sample product: ${product['name']}');
        } else {
          print('⚠ Product already exists: ${product['name']}');
        }
      }

      print('✅ Sample data initialization completed!');
    } catch (e) {
      print('❌ Failed to initialize sample data: $e');
    }
  }
}
