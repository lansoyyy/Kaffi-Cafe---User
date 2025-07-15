import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:kaffi_cafe/screens/chatsupport_screen.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/divider_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get user data from Firebase Auth
  String get _userName => _auth.currentUser?.displayName ?? 'User';
  String get _userEmail => _auth.currentUser?.email ?? 'No email';

  // Sample order history
  final List<Map<String, dynamic>> _orderHistory = [
    {
      'item': 'Espresso',
      'date': '2025-07-01',
      'price': 69.0,
      'status': 'Completed',
      'image':
          'https://static.vecteezy.com/system/resources/thumbnails/012/025/024/small_2x/coffee-banner-ads-retro-brown-style-with-latte-and-coffee-beans-3d-realistic-simple-vector.jpg',
    },
    {
      'item': 'Cappuccino',
      'date': '2025-06-30',
      'price': 89.0,
      'status': 'Completed',
      'image':
          'https://static.vecteezy.com/system/resources/thumbnails/012/025/024/small_2x/coffee-banner-ads-retro-brown-style-with-latte-and-coffee-beans-3d-realistic-simple-vector.jpg',
    },
    {
      'item': 'Croissant',
      'date': '2025-06-29',
      'price': 49.0,
      'status': 'Completed',
      'image':
          'https://static.vecteezy.com/system/resources/thumbnails/012/025/024/small_2x/coffee-banner-ads-retro-brown-style-with-latte-and-coffee-beans-3d-realistic-simple-vector.jpg',
    },
  ];

  // Sample FAQs
  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I earn points?',
      'answer': 'Earn 1 point for every ₱10 spent on orders.'
    },
    {
      'question': 'How can I redeem vouchers?',
      'answer': 'Visit the Rewards tab to redeem vouchers using your points.'
    },
    {
      'question': 'What is the return policy?',
      'answer': 'Returns are accepted within 24 hours with a valid receipt.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.44;
    final cardHeight = screenWidth * 0.58;
    final fontSize = screenWidth * 0.036;
    final padding = screenWidth * 0.035;

    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(_auth.currentUser?.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        final userName = userData?['name'] ?? _userName;
        final userEmail = userData?['email'] ?? _userEmail;
        final userPoints = userData?['points'] ?? 0;
        final totalOrders = userData?['totalOrders'] ?? 0;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Information
                TextWidget(
                  text: 'Profile',
                  fontSize: 22,
                  color: textBlack,
                  isBold: true,
                  fontFamily: 'Bold',
                  letterSpacing: 1.3,
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: bayanihanBlue.withOpacity(0.2),
                      width: 1.0,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: plainWhite,
                      boxShadow: [
                        BoxShadow(
                          color: bayanihanBlue.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar Placeholder
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: bayanihanBlue.withOpacity(0.1),
                            border: Border.all(
                              color: bayanihanBlue,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: TextWidget(
                              text: userName.isNotEmpty ? userName[0] : 'U',
                              fontSize: 28,
                              color: bayanihanBlue,
                              isBold: true,
                              fontFamily: 'Bold',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Profile Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    color: bayanihanBlue,
                                    size: fontSize + 4,
                                  ),
                                  const SizedBox(width: 8),
                                  TextWidget(
                                    text: userName,
                                    fontSize: fontSize + 3,
                                    color: textBlack,
                                    isBold: true,
                                    fontFamily: 'Bold',
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    color: bayanihanBlue,
                                    size: fontSize + 4,
                                  ),
                                  const SizedBox(width: 8),
                                  TextWidget(
                                    text: userEmail,
                                    fontSize: fontSize + 1,
                                    color: charcoalGray,
                                    fontFamily: 'Regular',
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: 18),
            DividerWidget(),
            // Points Tracker
            TextWidget(
              text: 'Points Tracker',
              fontSize: 20,
              color: textBlack,
              isBold: true,
              fontFamily: 'Bold',
              letterSpacing: 1.2,
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: plainWhite,
                  boxShadow: [
                    BoxShadow(
                      color: bayanihanBlue.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      text: 'Your Points',
                      fontSize: fontSize + 2,
                      color: textBlack,
                      isBold: true,
                      fontFamily: 'Bold',
                    ),
                    TextWidget(
                      text: '${userPoints} Points',
                      fontSize: fontSize + 2,
                      color: sunshineYellow,
                      isBold: true,
                      fontFamily: 'Bold',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            DividerWidget(),
            // Order History
            TextWidget(
              text: 'Order History',
              fontSize: 20,
              color: textBlack,
              isBold: true,
              fontFamily: 'Bold',
              letterSpacing: 1.2,
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _orderHistory.length,
              itemBuilder: (context, index) {
                final order = _orderHistory[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(padding),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: plainWhite,
                      boxShadow: [
                        BoxShadow(
                          color: bayanihanBlue.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(18),
                          ),
                          child: Image.network(
                            order['image'],
                            width: cardWidth * 0.5,
                            height: cardWidth * 0.5,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: cardWidth * 0.5,
                              height: cardWidth * 0.5,
                              color: ashGray,
                              child: Center(
                                child: TextWidget(
                                  text: order['item'][0],
                                  fontSize: 24,
                                  color: plainWhite,
                                  isBold: true,
                                  fontFamily: 'Bold',
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                text: order['item'],
                                fontSize: fontSize + 1,
                                color: textBlack,
                                isBold: true,
                                fontFamily: 'Bold',
                                maxLines: 1,
                              ),
                              const SizedBox(height: 4),
                              TextWidget(
                                text: 'Date: ${order['date']}',
                                fontSize: fontSize - 1,
                                color: charcoalGray,
                                fontFamily: 'Regular',
                              ),
                              const SizedBox(height: 4),
                              TextWidget(
                                text: '₱${order['price'].toStringAsFixed(0)}',
                                fontSize: fontSize,
                                color: sunshineYellow,
                                isBold: true,
                                fontFamily: 'Bold',
                              ),
                              const SizedBox(height: 4),
                              TextWidget(
                                text: 'Status: ${order['status']}',
                                fontSize: fontSize - 1,
                                color: charcoalGray,
                                fontFamily: 'Regular',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            DividerWidget(),
            // Chatbot FAQs
            TextWidget(
              text: 'FAQs',
              fontSize: 20,
              color: textBlack,
              isBold: true,
              fontFamily: 'Bold',
              letterSpacing: 1.2,
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _faqs.length,
              itemBuilder: (context, index) {
                final faq = _faqs[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ExpansionTile(
                    title: TextWidget(
                      text: faq['question']!,
                      fontSize: fontSize,
                      color: textBlack,
                      isBold: true,
                      fontFamily: 'Bold',
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: TextWidget(
                          text: faq['answer']!,
                          fontSize: fontSize - 1,
                          color: charcoalGray,
                          fontFamily: 'Regular',
                          maxLines: 5,
                        ),
                      ),
                    ],
                    backgroundColor: cloudWhite,
                    collapsedBackgroundColor: plainWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: ashGray,
                        width: 1.0,
                      ),
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: ashGray,
                        width: 1.0,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            // Chatbot Button
            Center(
              child: ButtonWidget(
                label: 'Chat with Support',
                onPressed: () {
                  Get.to(ChatFaqSupportScreen(),
                      transition: Transition.circularReveal);
                },
                color: bayanihanBlue,
                textColor: plainWhite,
                fontSize: fontSize + 2,
                height: 50,
                radius: 12,
                width: screenWidth * 0.6,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
      },
    );
  }
}
