import 'package:flutter/material.dart';
import 'package:kaffi_cafe/screens/order_confirmation_screen.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';
import 'package:kaffi_cafe/widgets/touchable_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';

class OrderScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final void Function(Map<String, dynamic> item) removeFromCart;
  final VoidCallback clearCart;
  final double subtotal;
  final String? selectedBranch;
  final void Function(String?) setBranch;
  final String? selectedType;
  final void Function(String?) setType;
  final List<String> branches;
  const OrderScreen({
    Key? key,
    required this.cartItems,
    required this.removeFromCart,
    required this.clearCart,
    required this.subtotal,
    required this.selectedBranch,
    required this.setBranch,
    required this.selectedType,
    required this.setType,
    required this.branches,
  }) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GetStorage _storage = GetStorage();
  String _selectedPaymentMethod = 'Cash on Delivery';
  String _voucherCode = '';
  double _discount = 0.0;
  int _pointsToEarn = 0;

  String get _userName => _auth.currentUser?.displayName ?? 'User';

  @override
  Widget build(BuildContext context) {
    _pointsToEarn = (widget.subtotal ~/ 10).toInt();

    if (widget.cartItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: ashGray),
            const SizedBox(height: 16),
            TextWidget(
              text: 'Your cart is empty',
              fontSize: 18,
              color: charcoalGray,
              fontFamily: 'Regular',
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pickup/Delivery header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F7FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: bayanihanBlue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: '${widget.selectedType?.toUpperCase()} AT',
                          fontSize: 12,
                          fontFamily: 'Bold',
                          color: charcoalGray,
                        ),
                        TextWidget(
                          text: widget.selectedBranch ?? 'No branch selected',
                          fontSize: 14,
                          fontFamily: 'Bold',
                          color: textBlack,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: charcoalGray),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Pickup time (if available from reservation)
            if (_storage.read('reservationTime') != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: ashGray.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: bayanihanBlue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: 'Pickup On Queue',
                            fontSize: 14,
                            fontFamily: 'Bold',
                            color: textBlack,
                          ),
                          TextWidget(
                            text: 'ASAP',
                            fontSize: 12,
                            fontFamily: 'Regular',
                            color: charcoalGray,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: charcoalGray),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Your Order section
            TextWidget(
              text: 'Your Order',
              fontSize: 18,
              fontFamily: 'Bold',
              color: textBlack,
            ),

            const SizedBox(height: 12),

            // Order items
            ...widget.cartItems.map((item) => _buildOrderItem(item)).toList(),

            const SizedBox(height: 20),

            // Special Remarks
            TextWidget(
              text: 'Special Remarks',
              fontSize: 16,
              fontFamily: 'Bold',
              color: textBlack,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: ashGray.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextWidget(
                text: 'Tell us about your special requests...',
                fontSize: 14,
                fontFamily: 'Regular',
                color: charcoalGray,
              ),
            ),

            const SizedBox(height: 20),

            // Payment Method
            _buildSectionHeader('Payment Method'),
            _buildPaymentMethodSelector(),

            const SizedBox(height: 20),

            // Voucher section
            _buildSectionHeader('Voucher'),
            _buildVoucherSection(),

            const SizedBox(height: 20),

            // Payment Details
            _buildSectionHeader('Payment Details'),
            _buildPaymentDetails(),

            const SizedBox(height: 20),

            // Points to earn
            _buildPointsSection(),

            const SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ButtonWidget(
            label: 'Order now',
            onPressed: widget.cartItems.isEmpty ||
                    widget.selectedBranch == null ||
                    widget.selectedType == null
                ? null
                : _placeOrder,
            color: bayanihanBlue,
            textColor: Colors.white,
            fontSize: 16,
            height: 50,
            radius: 25,
            width: double.infinity,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: ashGray.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Product image placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: ashGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.local_cafe,
              color: bayanihanBlue.withOpacity(0.5),
              size: 30,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: item['name'],
                  fontSize: 16,
                  fontFamily: 'Bold',
                  color: textBlack,
                ),
                const SizedBox(height: 4),
                TextWidget(
                  text: 'P ${item['price'].toStringAsFixed(2)}',
                  fontSize: 14,
                  fontFamily: 'Bold',
                  color: bayanihanBlue,
                ),
                if (item['customizations'] != null)
                  TextWidget(
                    text:
                        'Size: ${item['customizations']['size']} • Sweetness: ${item['customizations']['sweetness']} • Ice: ${item['customizations']['ice']}',
                    fontSize: 12,
                    fontFamily: 'Regular',
                    color: charcoalGray,
                    maxLines: 2,
                  ),
                const SizedBox(height: 4),
                TextWidget(
                  text: 'Qty: ${item['quantity']}',
                  fontSize: 12,
                  fontFamily: 'Regular',
                  color: charcoalGray,
                ),
              ],
            ),
          ),

          Column(
            children: [
              TouchableWidget(
                onTap: () {
                  // Show edit dialog for now since OrderScreen doesn't have addToCart
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: TextWidget(
                        text: 'Edit Item',
                        fontSize: 16,
                        fontFamily: 'Bold',
                        color: textBlack,
                      ),
                      content: TextWidget(
                        text: 'Item editing will be available soon.',
                        fontSize: 14,
                        fontFamily: 'Regular',
                        color: charcoalGray,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: TextWidget(
                            text: 'OK',
                            fontSize: 14,
                            fontFamily: 'Bold',
                            color: bayanihanBlue,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bayanihanBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: TextWidget(
                    text: 'Edit',
                    fontSize: 12,
                    fontFamily: 'Bold',
                    color: bayanihanBlue,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TouchableWidget(
                onTap: () => widget.removeFromCart(item),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextWidget(
        text: title,
        fontSize: 16,
        fontFamily: 'Bold',
        color: textBlack,
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    final paymentMethods = ['Cash on Delivery', 'GCash', 'Credit/Debit Card'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: ashGray.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.payment, color: bayanihanBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
                items: paymentMethods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: TextWidget(
                      text: method,
                      fontSize: 14,
                      fontFamily: 'Regular',
                      color: textBlack,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: ashGray.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.local_offer, color: bayanihanBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _voucherCode = value;
                  // Simple discount logic - 10% off if code is "SAVE10"
                  _discount = value.toUpperCase() == 'SAVE10'
                      ? widget.subtotal * 0.1
                      : 0.0;
                });
              },
              decoration: InputDecoration(
                hintText: 'Enter voucher code',
                hintStyle: TextStyle(color: charcoalGray, fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
          if (_voucherCode.isNotEmpty)
            TouchableWidget(
              onTap: () {
                setState(() {
                  _voucherCode = '';
                  _discount = 0.0;
                });
              },
              child: TextWidget(
                text: 'Apply',
                fontSize: 14,
                fontFamily: 'Bold',
                color: bayanihanBlue,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    final subtotal = widget.subtotal;
    final deliveryFee = widget.selectedType == 'Delivery' ? 50.0 : 0.0;
    final total = subtotal + deliveryFee - _discount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: ashGray.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildPaymentRow('Subtotal', 'P ${subtotal.toStringAsFixed(2)}'),
          if (deliveryFee > 0)
            _buildPaymentRow(
                'Delivery Fee', 'P ${deliveryFee.toStringAsFixed(2)}'),
          if (_discount > 0)
            _buildPaymentRow('Discount', '- P ${_discount.toStringAsFixed(2)}',
                isDiscount: true),
          const Divider(),
          _buildPaymentRow('Total', 'P ${total.toStringAsFixed(2)}',
              isBold: true),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String amount,
      {bool isBold = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget(
            text: label,
            fontSize: 14,
            fontFamily: isBold ? 'Bold' : 'Regular',
            color: textBlack,
          ),
          TextWidget(
            text: amount,
            fontSize: 14,
            fontFamily: isBold ? 'Bold' : 'Regular',
            color: isDiscount ? Colors.green : textBlack,
          ),
        ],
      ),
    );
  }

  Widget _buildPointsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.star, color: Colors.amber, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextWidget(
              text: 'You will earn $_pointsToEarn points from this order',
              fontSize: 14,
              fontFamily: 'Regular',
              color: textBlack,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder() async {
    final _firestore = FirebaseFirestore.instance;

    try {
      // Validate required fields with stricter checks
      if (widget.cartItems.isEmpty ||
          widget.selectedBranch == null ||
          widget.selectedType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete your order details')),
        );
        return;
      }

      // Ensure user is authenticated
      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to place an order')),
        );
        return;
      }

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Placing your order...')),
      );

      // Generate order reference
      final orderId = DateTime.now().millisecondsSinceEpoch;
      final orderReference = 'CA-${orderId.toString().substring(7)}';

      // Calculate totals
      final subtotal = widget.subtotal;
      final deliveryFee = widget.selectedType == 'Delivery' ? 50.0 : 0.0;
      final total = subtotal + deliveryFee - _discount;

      // Prepare order data with validation
      final orderData = {
        'orderRef': orderReference,
        'customer': _userName.isNotEmpty ? _userName : 'Guest',
        'status': 'Pending',
        'orderType': widget.selectedType!,
        'branch': widget.selectedBranch!,
        'total': total,
        'timestamp': FieldValue.serverTimestamp(),
        // Add cart items as a sub-collection or array if needed
        'items': widget.cartItems
            .map((item) => {
                  'name': item['name'],
                  'price': item['price'],
                  'quantity': item['quantity'],
                  'customizations': item['customizations'] ?? {},
                })
            .toList(),
      };

      // Add order to Firestore
      await _firestore.collection('orders').add(orderData);

      // Update user points
      final userDoc = _firestore.collection('users').doc(user.uid);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        final userData = snapshot.data() as Map<String, dynamic>? ?? {};
        final currentPoints = userData['points'] as int? ?? 0;

        transaction.set(
            userDoc,
            {
              'points': currentPoints + _pointsToEarn,
              'lastUpdated': FieldValue.serverTimestamp(),
            },
            SetOptions(
                merge: true)); // Use merge to avoid overwriting existing data
      });

      // Navigate to confirmation screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationScreen(
            orderReference: orderReference,
            customerName: _userName,
            branch: widget.selectedBranch!,
            orderMethod: widget.selectedType!,
            pickupTime: 'August 4, 3:24 PM - 3:39 PM',
            orderItems: widget.cartItems,
            totalAmount: total,
          ),
        ),
      );

      widget.clearCart();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Order placed successfully! Reference: $orderReference'),
          backgroundColor: palmGreen,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    }
  }
}
