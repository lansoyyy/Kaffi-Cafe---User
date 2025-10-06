import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kaffi_cafe/screens/order_confirmation_screen.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';
import 'package:kaffi_cafe/widgets/touchable_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:paymongo_sdk/paymongo_sdk.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kaffi_cafe/utils/keys.dart';
import 'package:kaffi_cafe/services/branch_service.dart';

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
  final box = GetStorage();
  final BranchService _branchService = BranchService();

  final GetStorage _storage = GetStorage();
  String _selectedPaymentMethod = 'GCash';
  String _voucherCode = '';
  String? _voucherId; // Store the voucher ID for marking as used
  double _discount = 0.0;
  int _pointsToEarn = 0;
  String _voucherMessage = '';
  bool _voucherValid = false;
  bool _isBranchOnline = false;
  bool _isLoadingBranchStatus = true;
  final TextEditingController _specialRemarksController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkBranchOnlineStatus();
  }

  Future<void> _checkBranchOnlineStatus() async {
    if (widget.selectedBranch != null) {
      setState(() {
        _isLoadingBranchStatus = true;
      });

      final isOnline =
          await _branchService.isBranchOnline(widget.selectedBranch!);

      setState(() {
        _isBranchOnline = isOnline;
        _isLoadingBranchStatus = false;
      });
    } else {
      setState(() {
        _isLoadingBranchStatus = false;
      });
    }
  }

  @override
  void didUpdateWidget(OrderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedBranch != widget.selectedBranch) {
      _checkBranchOnlineStatus();
    }
  }

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
                        Row(
                          children: [
                            Expanded(
                              child: TextWidget(
                                text: widget.selectedBranch ??
                                    'No branch selected',
                                fontSize: 14,
                                fontFamily: 'Bold',
                                color: textBlack,
                                maxLines: 2,
                              ),
                            ),
                            if (!_isLoadingBranchStatus)
                              Icon(
                                _isBranchOnline
                                    ? Icons.circle
                                    : Icons.circle_outlined,
                                color:
                                    _isBranchOnline ? Colors.green : Colors.red,
                                size: 16,
                              )
                            else
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: bayanihanBlue,
                                ),
                              ),
                          ],
                        ),
                        if (!_isLoadingBranchStatus && !_isBranchOnline)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: TextWidget(
                              text:
                                  'You can’t order at the moment store is close',
                              fontSize: 12,
                              fontFamily: 'Regular',
                              color: Colors.red,
                            ),
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
              child: TextField(
                controller: _specialRemarksController,
                decoration: InputDecoration(
                  hintText: widget.selectedType == 'Dine in'
                      ? 'Dine-in order - Table will be assigned upon arrival'
                      : 'Tell us about your special requests...',
                  hintStyle: TextStyle(
                    color: charcoalGray,
                    fontSize: 14,
                    fontFamily: 'Regular',
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  color: textBlack,
                  fontSize: 14,
                  fontFamily: 'Regular',
                ),
                maxLines: 3,
              ),
            ),

            const SizedBox(height: 20),

            // Payment Method
            _buildSectionHeader('Payment Method'),
            _buildPaymentMethodSelector(),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextWidget(
                      text:
                          'Please note: Payment is required before we can process your order.',
                      fontSize: 12,
                      fontFamily: 'Regular',
                      color: textBlack,
                    ),
                  ),
                ],
              ),
            ),

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
                    widget.selectedType == null ||
                    !_isBranchOnline ||
                    _isLoadingBranchStatus
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
            child: item['image'] != null && item['image'].toString().isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item['image'],
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to icon if image fails to load
                        return Icon(
                          Icons.local_cafe,
                          color: bayanihanBlue.withOpacity(0.5),
                          size: 30,
                        );
                      },
                    ),
                  )
                : Icon(
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
    final paymentMethods = ['GCash'];

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer, color: bayanihanBlue, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _voucherCode = value;
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
                  onTap: _voucherValid ? _removeVoucher : _validateVoucher,
                  child: TextWidget(
                    text: _voucherValid ? 'Remove' : 'Apply',
                    fontSize: 14,
                    fontFamily: 'Bold',
                    color: bayanihanBlue,
                  ),
                ),
            ],
          ),
          if (_voucherMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextWidget(
                text: _voucherMessage,
                fontSize: 12,
                fontFamily: 'Regular',
                color: _voucherValid ? Colors.green : Colors.red,
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

  Future<void> _validateVoucher() async {
    if (_voucherCode.isEmpty) {
      setState(() {
        _voucherMessage = 'Please enter a voucher code';
        _voucherValid = false;
      });
      return;
    }

    final _firestore = FirebaseFirestore.instance;
    final userEmail = box.read('user')?['email'];

    try {
      // Query Firestore for the voucher code in voucher_redemptions collection
      final voucherQuery = await _firestore
          .collection('voucher_redemptions')
          .where('voucherCode', isEqualTo: _voucherCode.toUpperCase())
          .where('userId', isEqualTo: userEmail)
          .get();

      if (voucherQuery.docs.isEmpty) {
        setState(() {
          _voucherMessage =
              'Invalid voucher code or you don\'t own this voucher';
          _voucherValid = false;
          _discount = 0.0;
        });
        return;
      }

      final voucherData = voucherQuery.docs.first.data();
      final voucherStatus = voucherData['status'] ?? 'active';
      final isUsed = voucherData['isUsed'] ?? false;
      final discountAmount = voucherData['voucherValue'] ?? 0;
      final voucherId = voucherQuery.docs.first.id;

      // Check if voucher is already used
      if (isUsed || voucherStatus == 'used') {
        setState(() {
          _voucherMessage = 'This voucher has already been used';
          _voucherValid = false;
          _discount = 0.0;
        });
        return;
      }

      // Check if voucher is active
      if (voucherStatus != 'active') {
        setState(() {
          _voucherMessage = 'This voucher is not active';
          _voucherValid = false;
          _discount = 0.0;
        });
        return;
      }

      // Apply the discount
      setState(() {
        _discount = discountAmount.toDouble();
        _voucherMessage =
            'Voucher applied! You saved P${_discount.toStringAsFixed(2)}';
        _voucherValid = true;
        _voucherId = voucherId; // Store the voucher ID for later use
      });
    } catch (e) {
      setState(() {
        _voucherMessage = 'Error validating voucher: ${e.toString()}';
        _voucherValid = false;
        _discount = 0.0;
      });
    }
  }

  void _removeVoucher() {
    setState(() {
      _voucherCode = '';
      _voucherId = null;
      _discount = 0.0;
      _voucherMessage = '';
      _voucherValid = false;
    });
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

      // Handle delivery orders with PayMongo payment
      if (_selectedPaymentMethod != 'Cash on Delivery') {
        try {
          final publicSDK = PaymongoClient<PaymongoPublic>(paymongoPublicKey);
          final data = SourceAttributes(
            type: 'gcash', // 'gcash' or 'card'
            amount:
                (widget.subtotal * 100).toDouble(), // PayMongo uses centavos
            currency: 'PHP',
            redirect: const Redirect(
              success: "https://example.com/success",
              failed: "https://example.com/failed",
            ),
            billing: PayMongoBilling(
                email: box.read('user')?['email'],
                phone: '09630539422',
                name:
                    '${box.read('user')?['given_name']} ${box.read('user')?['family_name']}',
                address: PayMongoAddress(
                    city: 'Quezon City',
                    country: 'PH',
                    line1: '123 Main St',
                    postalCode: '1100')),
          );

          final result = await publicSDK.instance.source.create(data);
          final redirectUrl = result.attributes?.redirect?.checkoutUrl;

          if (redirectUrl != null &&
              await canLaunchUrl(Uri.parse(redirectUrl))) {
            // Launch payment page and handle result
            await launchUrl(Uri.parse(redirectUrl)).whenComplete(() async {
              // After payment, create order in Firestore
              await _createOrderInFirestore('gcash');

              // For delivery orders, integrate with Lalamove
              // await _createLalamoveOrder();

              // Clear cart and show success
              widget.clearCart();

              // Navigate to confirmation screen
              _navigateToConfirmationScreen();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order placed successfully!')),
              );
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not launch payment page')),
            );
          }
        } catch (e) {
          String errorMsg = 'Payment error: ';
          if (e is PaymongoError) {
            print('PayMongo error: $e');
            errorMsg +=
                'Payment service is currently unavailable. Please try again later or use Cash on Delivery.';
          } else {
            print('PayMongo error: $e');
            errorMsg += e.toString();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg)),
          );
        }
      } else {
        // For pickup orders, proceed directly
        await _createOrderInFirestore('Cash');

        // Clear cart and show success
        widget.clearCart();

        // Navigate to confirmation screen
        _navigateToConfirmationScreen();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    }
  }

  // Helper method to show payment method dialog
  Future<String?> _showPaymentMethodDialog() async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TextWidget(
            text: 'Select Payment Method',
            fontSize: 18,
            fontFamily: 'Bold',
            color: textBlack,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: TextWidget(
                  text: 'GCash',
                  fontSize: 16,
                  fontFamily: 'Regular',
                  color: textBlack,
                ),
                onTap: () => Navigator.pop(context, 'gcash'),
              ),
              ListTile(
                title: TextWidget(
                  text: 'Credit/Debit Card (Currently Unavailable)',
                  fontSize: 16,
                  fontFamily: 'Regular',
                  color: Colors.grey,
                ),
                onTap: () {
                  Navigator.pop(context, 'card');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper method to create order in Firestore
  Future<void> _createOrderInFirestore(String paymentMethod) async {
    final _firestore = FirebaseFirestore.instance;

    // Generate order reference
    final orderId = DateTime.now().millisecondsSinceEpoch;
    final orderReference = 'CA-${orderId.toString().substring(7)}';

    // Calculate totals
    final subtotal = widget.subtotal;
    final deliveryFee = widget.selectedType == 'Delivery' ? 50.0 : 0.0;
    final total = subtotal + deliveryFee - _discount;

    // Prepare order data
    final orderData = {
      'orderRef': orderReference,
      'orderId': orderReference,
      'customer':
          '${box.read('user')?['given_name']} ${box.read('user')?['family_name']}',
      'buyer':
          '${box.read('user')?['given_name']} ${box.read('user')?['family_name']}',
      'status': widget.selectedType == 'Dine in' ? 'Preparing' : 'Pending',
      'orderType': widget.selectedType!,
      'branch': widget.selectedBranch!,
      'total': total,
      'userId': box.read('user')?['email'],
      'paymentMethod': paymentMethod,
      'timestamp': FieldValue.serverTimestamp(),
      'specialRemarks': _specialRemarksController.text.isNotEmpty
          ? _specialRemarksController.text
          : (widget.selectedType == 'Dine in'
              ? 'Dine-in order - Table will be assigned upon arrival'
              : ''),
      // Add voucher information if a voucher was used
      if (_voucherId != null && _voucherValid) ...{
        'voucherCode': _voucherCode,
        'voucherDiscount': _discount,
      },
      // Add reservation details if it's a dine-in order
      if (widget.selectedType == 'Dine in') ...{
        'reservationDate': _storage.read('reservationDate'),
        'reservationTime': _storage.read('reservationTime'),
        'reservationTableId': _storage.read('reservationTableId'),
        'reservationTableName': _storage.read('reservationTableName'),
        'reservationGuests': _storage.read('reservationGuests'),
      },
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

    // Mark voucher as used if one was applied
    if (_voucherId != null && _voucherValid) {
      await _firestore
          .collection('voucher_redemptions')
          .doc(_voucherId)
          .update({
        'isUsed': true,
        'status': 'used',
        'usedAt': FieldValue.serverTimestamp(),
        'usedInOrder': orderReference,
      });
    }

    // Update user points
    final userDoc =
        _firestore.collection('users').doc(box.read('user')?['email']);
    final pointsToEarn = (total ~/ 10).toInt();
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userDoc);
      final userData = snapshot.data() as Map<String, dynamic>? ?? {};
      final currentPoints = userData['points'] as int? ?? 0;

      transaction.set(
        userDoc,
        {
          'points': currentPoints + pointsToEarn,
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  // Helper method to navigate to confirmation screen
  void _navigateToConfirmationScreen() {
    // Generate dynamic pickup time (current time + 15-30 minutes)
    final now = DateTime.now();
    final pickupStart = now.add(const Duration(minutes: 15));
    final pickupEnd = now.add(const Duration(minutes: 30));
    final pickupTime =
        '${_formatDate(pickupStart)} - ${_formatTime(pickupEnd)}';

    // Calculate totals
    final subtotal = widget.subtotal;
    final deliveryFee = widget.selectedType == 'Delivery' ? 50.0 : 0.0;
    final total = subtotal + deliveryFee - _discount;

    // Navigate to confirmation screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationScreen(
          orderReference:
              'CA-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          customerName:
              '${box.read('user')?['given_name']} ${box.read('user')?['family_name']}',
          branch: widget.selectedBranch!,
          orderMethod: widget.selectedType!,
          pickupTime: pickupTime,
          orderItems: widget.cartItems,
          totalAmount: total,
        ),
      ),
    );
  }

  // Helper method to format date as "Month Day"
  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  // Helper method to format time as "H:MM AM/PM"
  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
    final formattedMinute = minute.toString().padLeft(2, '0');
    return '$formattedHour:$formattedMinute $period';
  }
}
