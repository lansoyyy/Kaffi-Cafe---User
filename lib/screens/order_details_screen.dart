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
    final cartItems =
        List<Map<String, dynamic>>.from(orderData['cartItems'] ?? []);
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
              child: Column(
                children: cartItems.map((item) {
                  final customizations =
                      item['customizations'] as Map<String, dynamic>? ?? {};
                  final hasCustomizations = customizations.isNotEmpty;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget(
                                    text:
                                        '${item['name']} x${item['quantity']}',
                                    fontSize: 16,
                                    color: textBlack,
                                    fontFamily: 'Bold',
                                  ),
                                  if (hasCustomizations) ...[
                                    const SizedBox(height: 4),
                                    ...customizations.entries
                                        .map((entry) => Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8, top: 2),
                                              child: Row(
                                                children: [
                                                  TextWidget(
                                                    text: '${entry.key}: ',
                                                    fontSize: 12,
                                                    color: charcoalGray,
                                                    fontFamily: 'Regular',
                                                  ),
                                                  Expanded(
                                                    child: TextWidget(
                                                      text: entry.value
                                                          .toString(),
                                                      fontSize: 12,
                                                      color: textBlack,
                                                      fontFamily: 'Regular',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ))
                                        .toList(),
                                  ],
                                ],
                              ),
                            ),
                            TextWidget(
                              text:
                                  '₱${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                              fontSize: 16,
                              color: sunshineYellow,
                              fontFamily: 'Bold',
                            ),
                          ],
                        ),
                        if (cartItems.indexOf(item) < cartItems.length - 1)
                          const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Divider(height: 1, color: ashGray),
                          ),
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
}
