import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kaffi_cafe/services/product_relationship_service.dart';
import 'dart:math';

class RecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductRelationshipService _relationshipService =
      ProductRelationshipService();

  // KNN implementation for product recommendations
  Future<List<Map<String, dynamic>>> getFrequentlyBoughtTogether(
      String productId,
      {int k = 3}) async {
    try {
      // Get all orders to build user-item matrix
      final ordersSnapshot = await _firestore.collection('orders').where(
          'status',
          whereIn: ['Completed', 'Pending', 'Preparing']).get();

      if (ordersSnapshot.docs.isEmpty) {
        return [];
      }

      // Build user-item matrix
      Map<String, Map<String, int>> userItemMatrix = {};
      Set<String> allProducts = {};

      for (var orderDoc in ordersSnapshot.docs) {
        final orderData = orderDoc.data();
        final userId = orderData['userId'] as String;
        final items = orderData['items'] as List<dynamic>;

        // Initialize user row if not exists
        if (!userItemMatrix.containsKey(userId)) {
          userItemMatrix[userId] = {};
        }

        // Mark items as purchased (1) or not (0)
        for (var item in items) {
          final itemName = item['name'] as String;
          allProducts.add(itemName);
          userItemMatrix[userId]![itemName] = 1;
        }
      }

      // Fill missing values with 0
      for (var userId in userItemMatrix.keys) {
        for (var product in allProducts) {
          userItemMatrix[userId]!.putIfAbsent(product, () => 0);
        }
      }

      // Get the target product vector
      Map<String, int> targetVector = {};
      for (var userId in userItemMatrix.keys) {
        targetVector[userId] = userItemMatrix[userId]![productId] ?? 0;
      }

      // Calculate similarity between target product and all other products
      Map<String, double> productSimilarities = {};

      for (var product in allProducts) {
        if (product == productId) continue;

        Map<String, int> productVector = {};
        for (var userId in userItemMatrix.keys) {
          productVector[userId] = userItemMatrix[userId]![product] ?? 0;
        }

        // Calculate cosine similarity
        double similarity =
            _calculateCosineSimilarity(targetVector, productVector);
        productSimilarities[product] = similarity;
      }

      // Sort by similarity and get top k recommendations
      List<MapEntry<String, double>> sortedSimilarities =
          productSimilarities.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      List<Map<String, dynamic>> recommendations = [];

      // Get product details for top recommendations
      for (int i = 0; i < min(k, sortedSimilarities.length); i++) {
        final productName = sortedSimilarities[i].key;
        final similarity = sortedSimilarities[i].value;

        // Skip if similarity is too low
        if (similarity < 0.1) break;

        // Get product details from Firestore
        final productSnapshot = await _firestore
            .collection('products')
            .where('name', isEqualTo: productName)
            .limit(1)
            .get();

        if (productSnapshot.docs.isNotEmpty) {
          final productData = productSnapshot.docs.first.data();
          productData['similarity'] = similarity;
          recommendations.add(productData);
        }
      }

      return recommendations;
    } catch (e) {
      print('Error getting recommendations: $e');
      return [];
    }
  }

  // Calculate cosine similarity between two vectors
  double _calculateCosineSimilarity(
      Map<String, int> vectorA, Map<String, int> vectorB) {
    if (vectorA.isEmpty || vectorB.isEmpty) return 0.0;

    double dotProduct = 0.0;
    double magnitudeA = 0.0;
    double magnitudeB = 0.0;

    for (var userId in vectorA.keys) {
      if (vectorB.containsKey(userId)) {
        dotProduct += vectorA[userId]! * vectorB[userId]!;
      }
      magnitudeA += pow(vectorA[userId]!, 2);
    }

    for (var value in vectorB.values) {
      magnitudeB += pow(value, 2);
    }

    magnitudeA = sqrt(magnitudeA);
    magnitudeB = sqrt(magnitudeB);

    if (magnitudeA == 0 || magnitudeB == 0) return 0.0;

    return dotProduct / (magnitudeA * magnitudeB);
  }

  // Alternative approach: Get products frequently bought together based on co-occurrence
  Future<List<Map<String, dynamic>>> getCoOccurrenceRecommendations(
      String productId,
      {int k = 3}) async {
    try {
      // Get all orders to analyze co-occurrence
      final ordersSnapshot = await _firestore.collection('orders').where(
          'status',
          whereIn: ['Completed', 'Pending', 'Preparing']).get();

      if (ordersSnapshot.docs.isEmpty) {
        return [];
      }

      // Track co-occurrence counts
      Map<String, int> coOccurrenceCounts = {};
      int productCount = 0;

      for (var orderDoc in ordersSnapshot.docs) {
        final orderData = orderDoc.data();
        final items = orderData['items'] as List<dynamic>;
        List<String> orderProducts = [];

        for (var item in items) {
          orderProducts.add(item['name'] as String);
        }

        // Check if target product is in this order
        if (orderProducts.contains(productId)) {
          productCount++;

          // Count co-occurring products
          for (var product in orderProducts) {
            if (product != productId) {
              coOccurrenceCounts[product] =
                  (coOccurrenceCounts[product] ?? 0) + 1;
            }
          }
        }
      }

      // If product was never ordered, return empty list
      if (productCount == 0) {
        return [];
      }

      // Calculate co-occurrence ratios and sort
      List<MapEntry<String, double>> coOccurrenceRatios = [];
      for (var entry in coOccurrenceCounts.entries) {
        double ratio = entry.value / productCount;
        coOccurrenceRatios.add(MapEntry(entry.key, ratio));
      }

      coOccurrenceRatios.sort((a, b) => b.value.compareTo(a.value));

      // Get product details for top recommendations
      List<Map<String, dynamic>> recommendations = [];

      for (int i = 0; i < min(k, coOccurrenceRatios.length); i++) {
        final productName = coOccurrenceRatios[i].key;
        final ratio = coOccurrenceRatios[i].value;

        // Skip if ratio is too low (less than 10% co-occurrence)
        if (ratio < 0.1) break;

        // Get product details from Firestore
        final productSnapshot = await _firestore
            .collection('products')
            .where('name', isEqualTo: productName)
            .limit(1)
            .get();

        if (productSnapshot.docs.isNotEmpty) {
          final productData = productSnapshot.docs.first.data();
          productData['coOccurrenceRatio'] = ratio;
          recommendations.add(productData);
        }
      }

      return recommendations;
    } catch (e) {
      print('Error getting co-occurrence recommendations: $e');
      return [];
    }
  }

  // Get popular products in the same category
  Future<List<Map<String, dynamic>>> getPopularProductsInCategory(
      String category, String excludeProductId,
      {int k = 3}) async {
    try {
      final productsSnapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .where('name', isNotEqualTo: excludeProductId)
          .orderBy('orderCount', descending: true)
          .limit(k)
          .get();

      return productsSnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting popular products: $e');
      return [];
    }
  }
}
