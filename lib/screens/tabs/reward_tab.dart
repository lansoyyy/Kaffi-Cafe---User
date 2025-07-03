import 'package:flutter/material.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/divider_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';
import 'package:kaffi_cafe/widgets/toast_widget.dart';
import 'package:kaffi_cafe/widgets/touchable_widget.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  // Sample user points
  int _userPoints = 250;

  // Sample vouchers
  final List<Map<String, dynamic>> _vouchers = [
    {
      'name': 'Free Espresso',
      'description': 'Redeem a single shot espresso',
      'points': 100,
      'image':
          'https://static.vecteezy.com/system/resources/thumbnails/012/025/024/small_2x/coffee-banner-ads-retro-brown-style-with-latte-and-coffee-beans-3d-realistic-simple-vector.jpg',
    },
    {
      'name': '10% Off Order',
      'description': 'Get 10% off your next order',
      'points': 50,
      'image':
          'https://static.vecteezy.com/system/resources/thumbnails/012/025/024/small_2x/coffee-banner-ads-retro-brown-style-with-latte-and-coffee-beans-3d-realistic-simple-vector.jpg',
    },
    {
      'name': 'Free Croissant',
      'description': 'Enjoy a buttery croissant on us',
      'points': 80,
      'image':
          'https://static.vecteezy.com/system/resources/thumbnails/012/025/024/small_2x/coffee-banner-ads-retro-brown-style-with-latte-and-coffee-beans-3d-realistic-simple-vector.jpg',
    },
    {
      'name': 'Free Cappuccino',
      'description': 'Redeem a frothy cappuccino',
      'points': 150,
      'image':
          'https://static.vecteezy.com/system/resources/thumbnails/012/025/024/small_2x/coffee-banner-ads-retro-brown-style-with-latte-and-coffee-beans-3d-realistic-simple-vector.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.44;
    final cardHeight = screenWidth * 0.6;
    final fontSize = screenWidth * 0.036;
    final padding = screenWidth * 0.035;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                      text: '$_userPoints Points',
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
            // Vouchers Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: cardWidth / cardHeight,
              ),
              itemCount: _vouchers.length,
              itemBuilder: (context, index) {
                final voucher = _vouchers[index];
                final canRedeem = _userPoints >= voucher['points'];
                return TouchableWidget(
                  onTap: () {
                    if (canRedeem) {
                      setState(() {
                        _userPoints -= int.parse(voucher['points'].toString());
                        // Handle voucher redemption logic
                      });
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
                            child: Image.network(
                              voucher['image'],
                              height: cardHeight * 0.45,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: cardHeight * 0.55,
                                color: ashGray,
                                child: Center(
                                  child: TextWidget(
                                    text: voucher['name'][0],
                                    fontSize: 42,
                                    color: plainWhite,
                                    isBold: true,
                                    fontFamily: 'Bold',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(padding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWidget(
                                  text: voucher['name'],
                                  fontSize: fontSize + 3,
                                  color: textBlack,
                                  isBold: true,
                                  fontFamily: 'Bold',
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 6),
                                TextWidget(
                                  text: voucher['description'],
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
                                      text: '${voucher['points']} Points',
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
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
