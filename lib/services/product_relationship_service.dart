import 'package:cloud_firestore/cloud_firestore.dart';

class ProductRelationshipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Track product relationships when an order is placed
  Future<void> trackProductRelationships(
      List<Map<String, dynamic>> items) async {
    if (items.length < 2) return; // No relationships to track for single items

    try {
      // Get all unique product pairs in the order
      List<String> productNames =
          items.map((item) => item['name'] as String).toList();

      // Create all possible pairs (combinations)
      for (int i = 0; i < productNames.length; i++) {
        for (int j = i + 1; j < productNames.length; j++) {
          String product1 = productNames[i];
          String product2 = productNames[j];

          // Update relationship count for both directions
          await _updateProductRelationship(product1, product2);
          await _updateProductRelationship(product2, product1);
        }
      }

      // Also update individual product order counts
      for (String productName in productNames) {
        await _updateProductOrderCount(productName);
      }
    } catch (e) {
      print('Error tracking product relationships: $e');
    }
  }

  // Update relationship count between two products
  Future<void> _updateProductRelationship(
      String product1, String product2) async {
    final relationshipRef = _firestore
        .collection('product_relationships')
        .doc('${product1}_$product2');

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(relationshipRef);
      final data = snapshot.data() as Map<String, dynamic>? ?? {};

      final currentCount = data['count'] as int? ?? 0;

      transaction.set(
          relationshipRef,
          {
            'product1': product1,
            'product2': product2,
            'count': currentCount + 1,
            'lastUpdated': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
    });
  }

  // Update individual product order count
  Future<void> _updateProductOrderCount(String productName) async {
    final productRef = _firestore
        .collection('products')
        .where('name', isEqualTo: productName)
        .limit(1);

    final querySnapshot = await productRef.get();
    if (querySnapshot.docs.isNotEmpty) {
      final docRef = querySnapshot.docs.first.reference;

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        final data = snapshot.data() as Map<String, dynamic>? ?? {};

        final currentCount = data['orderCount'] as int? ?? 0;

        transaction.set(
            docRef,
            {
              'orderCount': currentCount + 1,
              'lastOrdered': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true));
      });
    }
  }

  // Get frequently bought together products for a given product
  Future<List<Map<String, dynamic>>> getFrequentlyBoughtTogether(
      String productName,
      {int limit = 5}) async {
    try {
      final relationshipsSnapshot = await _firestore
          .collection('product_relationships')
          .where('product1', isEqualTo: productName)
          .orderBy('count', descending: true)
          .limit(limit)
          .get();

      List<Map<String, dynamic>> recommendations = [];

      for (var doc in relationshipsSnapshot.docs) {
        final data = doc.data();
        final relatedProductName = data['product2'] as String;
        final count = data['count'] as int;

        // Get product details
        final productSnapshot = await _firestore
            .collection('products')
            .where('name', isEqualTo: relatedProductName)
            .limit(1)
            .get();

        if (productSnapshot.docs.isNotEmpty) {
          final productData = productSnapshot.docs.first.data();
          productData['coOccurrenceCount'] = count;
          recommendations.add(productData);
        }
      }

      return recommendations;
    } catch (e) {
      print('Error getting frequently bought together: $e');
      return [];
    }
  }

  // Get popular products in a category
  Future<List<Map<String, dynamic>>> getPopularProductsInCategory(
      String category,
      {int limit = 5}) async {
    try {
      final productsSnapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .orderBy('orderCount', descending: true)
          .limit(limit)
          .get();

      return productsSnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting popular products: $e');
      return [];
    }
  }
}
