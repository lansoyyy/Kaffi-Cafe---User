import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/divider_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';
import 'package:kaffi_cafe/widgets/touchable_widget.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // Sample "For You" items
  final List<Map<String, dynamic>> _forYouItems = [
    {
      'name': 'Pumpkin Spice Latte',
      'price': 89.0,
      'image': 'https://www.nespresso.com/recipes/images/pumpkin_spice.jpg',
    },
    {
      'name': 'Caramel Macchiato',
      'price': 79.0,
      'image': 'https://www.nespresso.com/recipes/images/caramel_macchiato.jpg',
    },
    {
      'name': 'Blueberry Muffin',
      'price': 59.0,
      'image': 'https://www.nespresso.com/recipes/images/blueberry_muffin.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.42;
    final cardHeight = screenWidth * 0.55;
    final gradientHeight = cardHeight * 0.6;
    final fontSize = screenWidth * 0.035;
    final padding = screenWidth * 0.03;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recommendation Banner
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17.5),
                image: DecorationImage(
                  image: NetworkImage(
                    'https://static.vecteezy.com/system/resources/thumbnails/012/025/024/small_2x/coffee-banner-ads-retro-brown-style-with-latte-and-coffee-beans-3d-realistic-simple-vector.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            DividerWidget(),
            // For You Section
            TextWidget(
              text: 'For You',
              fontSize: 22,
              color: textBlack,
              isBold: true,
              fontFamily: 'Bold',
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _forYouItems.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 1,
                    child: Container(
                      height: cardHeight,
                      width: cardWidth,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: NetworkImage(
                              'https://www.nespresso.ph/media/catalog/category/recipes/morning_coffee/nespresso-recipes-Espresso-Macchiato-by-Nespresso_1.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Stack(
                          children: [
                            // Gradient overlay
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height: gradientHeight,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      jetBlack.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Text content
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                  padding, 0, padding, padding),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextWidget(
                                            text: 'Espresso',
                                            fontSize: 16,
                                            fontFamily: 'Medium',
                                            color: Colors.white,
                                            maxLines: 1,
                                          ),
                                          SizedBox(
                                            width: 100,
                                            child: TextWidget(
                                              text:
                                                  'Minim ipsum irure consectetur non sint ullamco.',
                                              fontSize: 11,
                                              fontFamily: 'Regular',
                                              color: Colors.white,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      TextWidget(
                                        text: 'P69',
                                        fontSize: 22,
                                        fontFamily: 'Bold',
                                        color: sunshineYellow,
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
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            DividerWidget(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TouchableWidget(
                  onTap: () {},
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/courier.png',
                            height: 125,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextWidget(
                            text: 'Delivery',
                            fontSize: 18,
                            fontFamily: 'Bold',
                            color: Colors.black,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                TouchableWidget(
                  onTap: () {},
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/delivery.png',
                            height: 125,
                          ),
                          TextWidget(
                            text: 'Pickup',
                            fontSize: 18,
                            fontFamily: 'Bold',
                            color: Colors.black,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
