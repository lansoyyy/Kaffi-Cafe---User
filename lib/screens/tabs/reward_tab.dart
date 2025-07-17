import 'package:flutter/material.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/divider_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';
import 'package:kaffi_cafe/widgets/toast_widget.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.44;
    final cardHeight = screenWidth * 0.6;
    final fontSize = screenWidth * 0.036;
    final padding = screenWidth * 0.035;

    final user = _auth.currentUser;
    if (user == null) {
      return Center(child: Text('Not logged in'));
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
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                TextWidget(
                  text: 'Rewards',
                  fontSize: 24,
                  color: textBlack,
                  isBold: true,
                  fontFamily: 'Bold',
                  letterSpacing: 1.3,
                ),
                const SizedBox(height: 12),
                DividerWidget(),
                // Points Balance
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
                          text: '$userPoints Points',
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
                // Vouchers Section
                TextWidget(
                  text: 'Available Vouchers',
                  fontSize: 20,
                  color: textBlack,
                  isBold: true,
                  fontFamily: 'Bold',
                  letterSpacing: 1.2,
                ),
                const SizedBox(height: 12),
                // Vouchers Grid (from products collection)
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('products')
                      .orderBy('timestamp', descending: true)
                      .limit(4)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return TextWidget(
                        text: 'No vouchers available.',
                        fontSize: fontSize + 1,
                        color: charcoalGray,
                        fontFamily: 'Regular',
                      );
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 5,
                        childAspectRatio: cardWidth / cardHeight,
                      ),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final voucher =
                            docs[index].data() as Map<String, dynamic>;
                        final canRedeem = userPoints >=
                            (voucher['points'] ?? voucher['price'] ?? 0);
                        return TouchableWidget(
                          onTap: () async {
                            final pointsRequired =
                                voucher['points'] ?? voucher['price'] ?? 0;
                            if (canRedeem) {
                              // Deduct points in Firestore
                              final userDoc =
                                  _firestore.collection('users').doc(user.uid);
                              await _firestore
                                  .runTransaction((transaction) async {
                                final snapshot = await transaction.get(userDoc);
                                final currentPoints =
                                    (snapshot.data()?['points'] ?? 0) as int;
                                transaction.update(userDoc, {
                                  'points': currentPoints - pointsRequired,
                                });
                              });
                              // Add redemption record
                              await _firestore.collection('redemptions').add({
                                'userId': user.uid,
                                'voucherName': voucher['name'] ?? 'Voucher',
                                'voucherDescription': voucher['description'] ??
                                    (voucher['category'] ?? ''),
                                'pointsSpent': pointsRequired,
                                'timestamp': FieldValue.serverTimestamp(),
                                'voucher': voucher,
                              });
                              showToast('Voucher redeemed: ' +
                                  (voucher['name'] ?? 'Voucher'));
                            } else {
                              showToast('Cannot redeem! Insufficient points.');
                            }
                          },
                          child: Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: plainWhite,
                                boxShadow: [
                                  BoxShadow(
                                    color: bayanihanBlue.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(18),
                                    ),
                                    child: (voucher['image'] != null &&
                                            voucher['image']
                                                .toString()
                                                .isNotEmpty)
                                        ? Image.network(
                                            voucher['image'],
                                            height: cardHeight * 0.45,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                              height: cardHeight * 0.55,
                                              color: ashGray,
                                              child: Center(
                                                child: TextWidget(
                                                  text: (voucher['name'] ??
                                                      'V')[0],
                                                  fontSize: 42,
                                                  color: plainWhite,
                                                  isBold: true,
                                                  fontFamily: 'Bold',
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            height: cardHeight * 0.55,
                                            color: ashGray,
                                            child: Center(
                                              child: TextWidget(
                                                text:
                                                    (voucher['name'] ?? 'V')[0],
                                                fontSize: 42,
                                                color: plainWhite,
                                                isBold: true,
                                                fontFamily: 'Bold',
                                              ),
                                            ),
                                          ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(padding),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextWidget(
                                          text: voucher['name'] ?? 'Voucher',
                                          fontSize: fontSize + 3,
                                          color: textBlack,
                                          isBold: true,
                                          fontFamily: 'Bold',
                                          maxLines: 1,
                                        ),
                                        const SizedBox(height: 6),
                                        TextWidget(
                                          text: voucher['description'] ??
                                              (voucher['category'] ?? ''),
                                          fontSize: fontSize - 1,
                                          color: charcoalGray,
                                          fontFamily: 'Regular',
                                          maxLines: 2,
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextWidget(
                                              text:
                                                  '${voucher['points'] ?? voucher['price'] ?? 0} Points',
                                              fontSize: fontSize + 2,
                                              color: sunshineYellow,
                                              isBold: true,
                                              fontFamily: 'Bold',
                                            ),
                                            SizedBox(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 30),
                // Redemption History
                DividerWidget(),
                TextWidget(
                  text: 'Redemption History',
                  fontSize: 20,
                  color: textBlack,
                  isBold: true,
                  fontFamily: 'Bold',
                  letterSpacing: 1.2,
                ),
                const SizedBox(height: 12),
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
                      return TextWidget(
                        text: 'No redemptions yet.',
                        fontSize: fontSize + 1,
                        color: charcoalGray,
                        fontFamily: 'Regular',
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
                            ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year} ${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}'
                            : '';
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading:
                                Icon(Icons.card_giftcard, color: bayanihanBlue),
                            title: TextWidget(
                              text: voucherName,
                              fontSize: fontSize + 1,
                              color: textBlack,
                              fontFamily: 'Bold',
                            ),
                            subtitle: TextWidget(
                              text: 'Spent $pointsSpent points\n$dateStr',
                              fontSize: fontSize - 1,
                              color: charcoalGray,
                              fontFamily: 'Regular',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
