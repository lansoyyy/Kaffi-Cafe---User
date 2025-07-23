import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaffi_cafe/screens/checkout_screen.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/divider_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';
import 'package:kaffi_cafe/widgets/textfield_widget.dart';
import 'package:kaffi_cafe/widgets/touchable_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paymongo_sdk/paymongo_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

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

  String get _buyerName {
    final user = _auth.currentUser;
    if (user != null) {
      return user.displayName ?? user.email ?? 'Unknown User';
    }
    return 'Unknown User';
  }

  String get _userName => _auth.currentUser?.displayName ?? 'User';
  String get _userEmail => _auth.currentUser?.email ?? 'No email';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.036;
    final padding = screenWidth * 0.035;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: 'Your Cart',
            fontSize: 24,
            color: textBlack,
            isBold: true,
            fontFamily: 'Bold',
            letterSpacing: 1.3,
          ),
          const SizedBox(height: 12),
          DividerWidget(),
          Expanded(
            child: widget.cartItems.isEmpty
                ? Center(child: Text('Your cart is empty.'))
                : ListView.builder(
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.cartItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(item['name']),
                          subtitle:
                              Text('₱${item['price']} x ${item['quantity']}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              widget.removeFromCart(item);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          DividerWidget(),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Total: ₱${widget.subtotal.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: fontSize + 2,
                fontWeight: FontWeight.bold,
                color: bayanihanBlue,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: widget.cartItems.isEmpty ? null : widget.clearCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ashGray,
                  foregroundColor: textBlack,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Clear Cart'),
              ),
              ElevatedButton(
                onPressed: widget.cartItems.isEmpty ||
                        widget.selectedBranch == null ||
                        widget.selectedType == null
                    ? null
                    : () async {
                        try {
                          final publicSDK = PaymongoClient<PaymongoPublic>(
                              'pk_test_JhXGeThyqM7XEMjiKeda72YK');
                          final data = SourceAttributes(
                            type: 'gcash',
                            amount: widget.subtotal,
                            currency: 'PHP',
                            redirect: const Redirect(
                              success: "https://example.com/success",
                              failed: "https://example.com/failed",
                            ),
                            billing: PayMongoBilling(
                                name: _userName,
                                phone: '09630539422',
                                email: _userEmail,
                                address: PayMongoAddress(
                                    city: 'Quezon City',
                                    country: 'PH',
                                    line1: '123 Main St',
                                    postalCode: '1100')),
                          );

                          final result =
                              await publicSDK.instance.source.create(data);
                          final redirectUrl =
                              result.attributes?.redirect?.checkoutUrl;
                          if (redirectUrl != null &&
                              await canLaunch(redirectUrl)) {
                            await launch(redirectUrl).whenComplete(
                              () async {
                                final _firestore = FirebaseFirestore.instance;
                                final orderId =
                                    DateTime.now().millisecondsSinceEpoch;
                                try {
                                  await _firestore.collection('orders').add({
                                    'orderId': orderId.toString(),
                                    'buyer': _buyerName,
                                    'userId': _auth.currentUser?.uid,
                                    'items': widget.cartItems
                                        .map((item) => {
                                              'name': item['name'],
                                              'quantity': item['quantity'],
                                              'price': item['price'],
                                            })
                                        .toList(),
                                    'total': widget.subtotal,
                                    'status': 'Pending',
                                    'timestamp': FieldValue.serverTimestamp(),
                                    'type': widget.selectedType,
                                    'branch': widget.selectedBranch,
                                  });

                                  // Add points to user: 1 point per 10 pesos spent
                                  final user = _auth.currentUser;
                                  if (user != null) {
                                    final pointsToAdd = widget.subtotal ~/ 10;
                                    final userDoc = _firestore
                                        .collection('users')
                                        .doc(user.uid);
                                    await _firestore
                                        .runTransaction((transaction) async {
                                      final snapshot =
                                          await transaction.get(userDoc);
                                      final currentPoints =
                                          (snapshot.data()?['points'] ?? 0)
                                              as int;
                                      transaction.update(userDoc, {
                                        'points': currentPoints + pointsToAdd,
                                      });
                                    });
                                  }

                                  widget.clearCart();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Order placed successfully!')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Failed to place order: $e')),
                                  );
                                }
                              },
                            );
                            // Immediately show success screen after launching payment page
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Could not launch payment page')),
                            );
                          }
                        } catch (e) {
                          String errorMsg = 'Payment error: ';
                          if (e is PaymongoError) {
                            print('PayMongo error: $e');
                            errorMsg += e.toString();
                          } else {
                            print('PayMongo error: $e');
                            errorMsg += e.toString();
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(errorMsg)),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: bayanihanBlue,
                  foregroundColor: plainWhite,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Place Order'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
