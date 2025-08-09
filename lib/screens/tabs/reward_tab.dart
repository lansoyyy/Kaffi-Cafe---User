import 'package:flutter/material.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';
import 'package:kaffi_cafe/widgets/touchable_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Vouchers will be fetched from Firestore 'products' collection, limited to 4

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return Center(
        child: TextWidget(
          text: 'Please log in to view rewards',
          fontSize: 16,
          fontFamily: 'Regular',
          color: charcoalGray,
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        final userPoints = userData?['points'] ?? 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              TextWidget(
                text: 'Rewards',
                fontSize: 28,
                color: textBlack,
                fontFamily: 'Bold',
              ),

              const SizedBox(height: 20),

              // Points Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [bayanihanBlue, bayanihanBlue.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: bayanihanBlue.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.stars, color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        TextWidget(
                          text: 'Your Points Balance',
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'Regular',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextWidget(
                      text: '$userPoints',
                      fontSize: 36,
                      color: Colors.white,
                      fontFamily: 'Bold',
                    ),
                    const SizedBox(height: 4),
                    TextWidget(
                      text: 'Points Available',
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                      fontFamily: 'Regular',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Vouchers Section
              TextWidget(
                text: 'Redeem Vouchers',
                fontSize: 22,
                color: textBlack,
                fontFamily: 'Bold',
              ),

              const SizedBox(height: 4),

              TextWidget(
                text: 'Exchange your points for discount vouchers',
                fontSize: 14,
                color: charcoalGray,
                fontFamily: 'Regular',
              ),

              const SizedBox(height: 16),

              // Voucher Options
              _buildVoucherCard(
                title: '₱10 OFF',
                description: 'Minimum spend ₱50',
                pointsCost: 10,
                userPoints: userPoints,
                discountAmount: 10,
                voucherCode: 'SAVE10',
                user: user,
              ),

              const SizedBox(height: 12),

              _buildVoucherCard(
                title: '₱20 OFF',
                description: 'Minimum spend ₱100',
                pointsCost: 20,
                userPoints: userPoints,
                discountAmount: 20,
                voucherCode: 'SAVE20',
                user: user,
              ),

              const SizedBox(height: 12),

              _buildVoucherCard(
                title: '₱50 OFF',
                description: 'Minimum spend ₱200',
                pointsCost: 50,
                userPoints: userPoints,
                discountAmount: 50,
                voucherCode: 'SAVE50',
                user: user,
              ),

              const SizedBox(height: 24),

              // Redemption History
              TextWidget(
                text: 'Redemption History',
                fontSize: 22,
                color: textBlack,
                fontFamily: 'Bold',
              ),

              const SizedBox(height: 16),

              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('redemptions')
                    .where('userId', isEqualTo: user.uid)
                    .orderBy('timestamp', descending: true)
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final redemptions = snapshot.data?.docs ?? [];
                  if (redemptions.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: ashGray.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: TextWidget(
                          text: 'No redemptions yet.',
                          fontSize: 14,
                          color: charcoalGray,
                          fontFamily: 'Regular',
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: redemptions.length,
                    itemBuilder: (context, index) {
                      final data =
                          redemptions[index].data() as Map<String, dynamic>;
                      final voucherName = data['voucherName'] ?? 'Voucher';
                      final pointsSpent = data['pointsSpent'] ?? 0;
                      final timestamp = data['timestamp'] as Timestamp?;
                      final dateStr = timestamp != null
                          ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}'
                          : 'Unknown date';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ashGray.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: palmGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.local_offer,
                                  color: palmGreen, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget(
                                    text: voucherName,
                                    fontSize: 14,
                                    color: textBlack,
                                    fontFamily: 'Bold',
                                  ),
                                  TextWidget(
                                    text:
                                        '$pointsSpent points redeemed on $dateStr',
                                    fontSize: 12,
                                    color: charcoalGray,
                                    fontFamily: 'Regular',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVoucherCard({
    required String title,
    required String description,
    required int pointsCost,
    required int userPoints,
    required int discountAmount,
    required String voucherCode,
    required User user,
  }) {
    final canRedeem = userPoints >= pointsCost;

    return TouchableWidget(
      onTap: canRedeem
          ? () => _redeemVoucher(pointsCost, title, voucherCode, user)
          : null,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: canRedeem
                ? bayanihanBlue.withOpacity(0.3)
                : ashGray.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: canRedeem
                  ? bayanihanBlue.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Voucher Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: canRedeem
                    ? bayanihanBlue.withOpacity(0.1)
                    : ashGray.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.local_offer,
                color: canRedeem ? bayanihanBlue : ashGray,
                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            // Voucher Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: title,
                    fontSize: 20,
                    color: canRedeem ? textBlack : ashGray,
                    fontFamily: 'Bold',
                  ),
                  const SizedBox(height: 4),
                  TextWidget(
                    text: description,
                    fontSize: 14,
                    color: canRedeem ? charcoalGray : ashGray,
                    fontFamily: 'Regular',
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: canRedeem ? Colors.amber : ashGray,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      TextWidget(
                        text: '$pointsCost points',
                        fontSize: 14,
                        color: canRedeem ? Colors.amber : ashGray,
                        fontFamily: 'Bold',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Redeem Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: canRedeem ? bayanihanBlue : ashGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextWidget(
                text: canRedeem ? 'Redeem' : 'Locked',
                fontSize: 12,
                color: Colors.white,
                fontFamily: 'Bold',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _redeemVoucher(int pointsCost, String voucherTitle,
      String voucherCode, User user) async {
    try {
      // Deduct points from user account
      final userDoc = _firestore.collection('users').doc(user.uid);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        final currentPoints = (snapshot.data()?['points'] ?? 0) as int;

        if (currentPoints >= pointsCost) {
          transaction.update(userDoc, {
            'points': currentPoints - pointsCost,
          });
        } else {
          throw Exception('Insufficient points');
        }
      });

      // Add redemption record
      await _firestore.collection('redemptions').add({
        'userId': user.uid,
        'voucherName': voucherTitle,
        'voucherCode': voucherCode,
        'pointsSpent': pointsCost,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Voucher redeemed! Use code: $voucherCode'),
          backgroundColor: palmGreen,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to redeem voucher: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
