import 'package:flutter/material.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final String orderId;

  const OrderDetailsScreen({
    super.key,
    required this.orderData,
    required this.orderId,
  });

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return palmGreen; // Green
      case 'pending':
        return accentOrange; // Orange
      case 'preparing':
        return palmGreen; // Green
      case 'ready':
        return Colors.purple;
      case 'cancelled':
        return festiveRed; // Red
      default:
        return textBlack; // Black
    }
  }

  String _getPaymentStatus(Map<String, dynamic> orderData) {
    if (orderData['paymentStatus'] != null) {
      return orderData['paymentStatus'];
    }
    return orderData['paymentMethod'] == 'Cash' ? 'Pending' : 'Paid';
  }

  @override
  Widget build(BuildContext context) {
    // Handle different possible data structures for cart items
    List<Map<String, dynamic>> cartItems = [];

    // Try different ways to extract cart items
    if (orderData['cartItems'] != null) {
      cartItems = List<Map<String, dynamic>>.from(orderData['cartItems']);
    } else if (orderData['items'] != null) {
      cartItems = List<Map<String, dynamic>>.from(orderData['items']);
    } else if (orderData['products'] != null) {
      cartItems = List<Map<String, dynamic>>.from(orderData['products']);
    }

    // Debug print to check the data structure
    print('Order data: ${orderData.keys.toList()}');
    if (cartItems.isNotEmpty) {
      print('First item data: ${cartItems.first.keys.toList()}');
      if (cartItems.first['customizations'] != null) {
        print(
            'First item customizations: ${cartItems.first['customizations']}');
      }
    }

    final timestamp = orderData['timestamp'] as Timestamp?;
    final status = orderData['status'] ?? 'Pending';
    final total = orderData['total'] ?? 0.0;
    final branch = orderData['branch'] ?? 'Unknown Branch';
    final type = orderData['type'] ?? 'Unknown';
    final paymentMethod = orderData['paymentMethod'] ?? 'Cash';
    final pickupInstructions = orderData['pickupInstructions'] ?? '';
    final paymentStatus = _getPaymentStatus(orderData);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextWidget(
          text: 'Order Details',
          fontSize: 20,
          color: textBlack,
          fontFamily: 'Bold',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getStatusColor(status),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWidget(
                        text: 'Order Status',
                        fontSize: 16,
                        color: textBlack,
                        fontFamily: 'Bold',
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextWidget(
                          text: status,
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: 'Bold',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextWidget(
                    text: 'Order Reference',
                    fontSize: 14,
                    color: charcoalGray,
                    fontFamily: 'Regular',
                  ),
                  const SizedBox(height: 4),
                  TextWidget(
                    text: '#${orderId.substring(0, 8).toUpperCase()}',
                    fontSize: 18,
                    color: textBlack,
                    fontFamily: 'Bold',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Store Information
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bayanihanBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.store, color: bayanihanBlue, size: 20),
                      const SizedBox(width: 8),
                      TextWidget(
                        text: 'Store Information',
                        fontSize: 16,
                        color: textBlack,
                        fontFamily: 'Bold',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextWidget(
                    text: 'Branch',
                    fontSize: 14,
                    color: charcoalGray,
                    fontFamily: 'Regular',
                  ),
                  const SizedBox(height: 4),
                  TextWidget(
                    text: branch,
                    fontSize: 16,
                    color: textBlack,
                    fontFamily: 'Bold',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Order Method & Payment
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ashGray.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              type == 'Pick-up'
                                  ? Icons.takeout_dining
                                  : Icons.restaurant,
                              color: bayanihanBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            TextWidget(
                              text: 'Order Method',
                              fontSize: 14,
                              color: textBlack,
                              fontFamily: 'Bold',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextWidget(
                          text: type,
                          fontSize: 16,
                          color: bayanihanBlue,
                          fontFamily: 'Bold',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ashGray.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              paymentMethod == 'Cash'
                                  ? Icons.money
                                  : Icons.credit_card,
                              color: bayanihanBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            TextWidget(
                              text: 'Payment',
                              fontSize: 14,
                              color: textBlack,
                              fontFamily: 'Bold',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextWidget(
                          text: paymentMethod,
                          fontSize: 16,
                          color: bayanihanBlue,
                          fontFamily: 'Bold',
                        ),
                        const SizedBox(height: 4),
                        TextWidget(
                          text: paymentStatus,
                          fontSize: 12,
                          color: paymentStatus == 'Paid'
                              ? palmGreen
                              : accentOrange,
                          fontFamily: 'Bold',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Date and Time
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ashGray.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, color: bayanihanBlue, size: 20),
                      const SizedBox(width: 8),
                      TextWidget(
                        text: 'Date and Time',
                        fontSize: 14,
                        color: textBlack,
                        fontFamily: 'Bold',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextWidget(
                    text:
                        timestamp != null ? _formatDate(timestamp) : 'Unknown',
                    fontSize: 16,
                    color: textBlack,
                    fontFamily: 'Regular',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Pickup Instructions (if available)
            if (type == 'Pick-up' && pickupInstructions.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ashGray.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.note_alt, color: bayanihanBlue, size: 20),
                        const SizedBox(width: 8),
                        TextWidget(
                          text: 'Pickup Instructions',
                          fontSize: 14,
                          color: textBlack,
                          fontFamily: 'Bold',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextWidget(
                      text: pickupInstructions,
                      fontSize: 16,
                      color: textBlack,
                      fontFamily: 'Regular',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Order Items
            TextWidget(
              text: 'Order Items',
              fontSize: 18,
              color: textBlack,
              fontFamily: 'Bold',
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ashGray.withOpacity(0.3)),
              ),
              child: cartItems.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: TextWidget(
                          text: 'No items found in this order',
                          fontSize: 16,
                          color: charcoalGray,
                          fontFamily: 'Regular',
                        ),
                      ),
                    )
                  : Column(
                      children: cartItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;

                        // Handle different possible field names
                        final itemName = item['name'] ??
                            item['productName'] ??
                            item['title'] ??
                            'Unknown Item';
                        final itemQuantity = item['quantity'] ?? 1;
                        final itemPrice = (item['price'] ?? 0.0).toDouble();
                        final itemImage = item['image'] ??
                            item['imageUrl'] ??
                            item['productImage'];

                        // Handle customizations/add-ons
                        final customizations =
                            item['customizations'] as Map<String, dynamic>? ??
                                {};
                        final addOns = item['addOns'] as List<dynamic>? ?? [];
                        final hasAddOns = addOns.isNotEmpty;

                        return Padding(
                          padding: EdgeInsets.only(
                              bottom: index < cartItems.length - 1 ? 16.0 : 0),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product image (if available)
                                  if (itemImage != null) ...[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        itemImage,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: ashGray.withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.fastfood,
                                              color: charcoalGray,
                                              size: 30,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  // Item details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextWidget(
                                          text: '$itemName x$itemQuantity',
                                          fontSize: 16,
                                          color: textBlack,
                                          fontFamily: 'Bold',
                                        ),
                                        const SizedBox(height: 4),
                                        // Display customizations if available
                                        if (customizations.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: ashGray.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TextWidget(
                                                  text: 'Customizations:',
                                                  fontSize: 12,
                                                  color: textBlack,
                                                  fontFamily: 'Bold',
                                                ),
                                                const SizedBox(height: 4),
                                                // Display each customization with proper formatting
                                                if (customizations[
                                                        'espresso'] !=
                                                    null) ...[
                                                  _buildCustomizationItem(
                                                      'Espresso',
                                                      customizations[
                                                          'espresso']),
                                                ],
                                                if (customizations['addShot'] !=
                                                        null &&
                                                    customizations['addShot'] ==
                                                        true) ...[
                                                  _buildCustomizationItem(
                                                      'Extra Shot', '+₱25.00'),
                                                ],
                                                if (customizations['size'] !=
                                                    null) ...[
                                                  _buildCustomizationItem(
                                                      'Size',
                                                      customizations['size'],
                                                      customizations['size'] ==
                                                              'Large'
                                                          ? '+₱15.00'
                                                          : null),
                                                ],
                                                if (customizations[
                                                        'sweetness'] !=
                                                    null) ...[
                                                  _buildCustomizationItem(
                                                      'Sweetness',
                                                      customizations[
                                                          'sweetness']),
                                                ],
                                                if (customizations['ice'] !=
                                                    null) ...[
                                                  _buildCustomizationItem(
                                                      'Ice Level',
                                                      customizations['ice']),
                                                ],
                                                // Display any other customizations that might exist
                                                ...customizations.entries
                                                    .where((entry) => ![
                                                          'espresso',
                                                          'addShot',
                                                          'size',
                                                          'sweetness',
                                                          'ice'
                                                        ].contains(entry.key))
                                                    .map((entry) =>
                                                        _buildCustomizationItem(
                                                            _formatCustomizationKey(
                                                                entry.key),
                                                            entry.value
                                                                .toString())),
                                              ],
                                            ),
                                          ),
                                        ],
                                        // Display add-ons if available
                                        if (hasAddOns) ...[
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: ashGray.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TextWidget(
                                                  text: 'Add-ons:',
                                                  fontSize: 12,
                                                  color: textBlack,
                                                  fontFamily: 'Bold',
                                                ),
                                                const SizedBox(height: 4),
                                                ...addOns.map((addOn) {
                                                  final addOnName = addOn is Map
                                                      ? addOn['name'] ??
                                                          'Add-on'
                                                      : addOn.toString();
                                                  final addOnPrice = addOn
                                                          is Map
                                                      ? (addOn['price'] ?? 0.0)
                                                          .toDouble()
                                                      : 0.0;
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 2),
                                                    child: TextWidget(
                                                      text:
                                                          '+ $addOnName ${addOnPrice > 0 ? '(₱${addOnPrice.toStringAsFixed(2)})' : ''}',
                                                      fontSize: 12,
                                                      color: charcoalGray,
                                                      fontFamily: 'Regular',
                                                    ),
                                                  );
                                                }),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  // Price
                                  TextWidget(
                                    text:
                                        '₱${(itemPrice * itemQuantity).toStringAsFixed(2)}',
                                    fontSize: 16,
                                    color: bayanihanBlue,
                                    fontFamily: 'Bold',
                                  ),
                                ],
                              ),
                              // Divider between items
                              if (index < cartItems.length - 1) ...[
                                const SizedBox(height: 16),
                                const Divider(height: 1, color: ashGray),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),

            const SizedBox(height: 20),

            // Order Total
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bayanihanBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: bayanihanBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                    text: 'Total Amount',
                    fontSize: 18,
                    color: textBlack,
                    fontFamily: 'Bold',
                  ),
                  TextWidget(
                    text: '₱${total.toStringAsFixed(2)}',
                    fontSize: 20,
                    color: bayanihanBlue,
                    fontFamily: 'Bold',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Action Button
            Center(
              child: ButtonWidget(
                label: 'Back to Activity',
                onPressed: () => Navigator.of(context).pop(),
                color: bayanihanBlue,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomizationItem(String label, String value,
      [String? priceInfo]) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          TextWidget(
            text: '$label: ',
            fontSize: 12,
            color: charcoalGray,
            fontFamily: 'Regular',
          ),
          TextWidget(
            text: value,
            fontSize: 12,
            color: textBlack,
            fontFamily: 'Bold',
          ),
          if (priceInfo != null) ...[
            const SizedBox(width: 4),
            TextWidget(
              text: priceInfo,
              fontSize: 12,
              color: bayanihanBlue,
              fontFamily: 'Bold',
            ),
          ],
        ],
      ),
    );
  }

  String _formatCustomizationKey(String key) {
    // Convert camelCase or snake_case to Title Case
    return key
        .replaceAll(RegExp(r'[_-]'), ' ')
        .split(' ')
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}
