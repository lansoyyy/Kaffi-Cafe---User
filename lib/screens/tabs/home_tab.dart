import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaffi_cafe/screens/reservation_screen.dart';
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
                  onTap: () {
                    _showBranchSelectionDialog('Delivery');
                  },
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
                  onTap: () {
                    _showBranchSelectionDialog('Pickup');
                  },
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
            SizedBox(
              height: 10,
            ),
            TouchableWidget(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text(
                            'Seat Reservation',
                            style: TextStyle(
                                fontFamily: 'Bold',
                                fontWeight: FontWeight.bold),
                          ),
                          content: const Text(
                            'Do you want to reserve seats?',
                            style: TextStyle(fontFamily: 'Regular'),
                          ),
                          actions: <Widget>[
                            MaterialButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                                _showBranchSelectionDialog('Dine in');
                              },
                              child: const Text(
                                'Close',
                                style: TextStyle(
                                    fontFamily: 'Regular',
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            MaterialButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    final screenWidth =
                                        MediaQuery.of(context).size.width;
                                    final fontSize = screenWidth * 0.036;
                                    final padding = screenWidth * 0.035;

                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      backgroundColor: plainWhite,
                                      title: TextWidget(
                                        text: 'Select Branch for Dine in',
                                        fontSize: 20,
                                        color: textBlack,
                                        isBold: true,
                                        fontFamily: 'Bold',
                                        letterSpacing: 1.2,
                                      ),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: _branches.map((branch) {
                                            return Card(
                                              elevation: 3,
                                              margin: const EdgeInsets.only(
                                                  bottom: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: TouchableWidget(
                                                onTap: () {
                                                  // Handle branch selection
                                                  Navigator.pop(context);
                                                  // Reservation here
                                                  Get.to(
                                                      SeatReservationScreen(),
                                                      transition: Transition
                                                          .circularReveal);
                                                },
                                                child: Container(
                                                  padding:
                                                      EdgeInsets.all(padding),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color: plainWhite,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: bayanihanBlue
                                                            .withOpacity(0.1),
                                                        blurRadius: 6,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        child: Image.network(
                                                          branch['image']!,
                                                          width: screenWidth *
                                                              0.25,
                                                          height: screenWidth *
                                                              0.25,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context,
                                                                  error,
                                                                  stackTrace) =>
                                                              Container(
                                                            width: screenWidth *
                                                                0.25,
                                                            height:
                                                                screenWidth *
                                                                    0.25,
                                                            color: ashGray,
                                                            child: Center(
                                                              child: TextWidget(
                                                                text: branch[
                                                                    'name']![0],
                                                                fontSize: 24,
                                                                color:
                                                                    plainWhite,
                                                                isBold: true,
                                                                fontFamily:
                                                                    'Bold',
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text: branch[
                                                                  'name']!,
                                                              fontSize:
                                                                  fontSize + 1,
                                                              color: textBlack,
                                                              isBold: true,
                                                              fontFamily:
                                                                  'Bold',
                                                              maxLines: 1,
                                                            ),
                                                            const SizedBox(
                                                                height: 6),
                                                            TextWidget(
                                                              text: branch[
                                                                  'address']!,
                                                              fontSize:
                                                                  fontSize - 1,
                                                              color:
                                                                  charcoalGray,
                                                              fontFamily:
                                                                  'Regular',
                                                              maxLines: 2,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      actions: [
                                        ButtonWidget(
                                          label: 'Cancel',
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          color: ashGray,
                                          textColor: textBlack,
                                          fontSize: fontSize,
                                          height: 40,
                                          radius: 12,
                                          width: 100,
                                        ),
                                      ],
                                    );
                                  },
                                );
                                // Get.off(LandingScreen(),
                                //     transition: Transition.circularReveal);
                              },
                              child: const Text(
                                'Continue',
                                style: TextStyle(
                                    fontFamily: 'Regular',
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ));
              },
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/salad.png',
                          height: 125,
                        ),
                        TextWidget(
                          text: 'Dine In',
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
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  final List<Map<String, String>> _branches = [
    {
      'name': 'Kaffi Cafe - Downtown',
      'address': '123 Bayanihan St, Manila, Philippines',
      'image':
          'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/10/1f/ef/54/te-kaffi.jpg?w=1000&h=-1&s=1',
    },
    {
      'name': 'Kaffi Cafe - Uptown',
      'address': '456 Espresso Ave, Quezon City, Philippines',
      'image':
          'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/13/02/71/53/fron.jpg?w=1000&h=-1&s=1',
    },
  ];
  // Show branch selection dialog
  void _showBranchSelectionDialog(String method) {
    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final fontSize = screenWidth * 0.036;
        final padding = screenWidth * 0.035;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: plainWhite,
          title: TextWidget(
            text: 'Select Branch for $method',
            fontSize: 20,
            color: textBlack,
            isBold: true,
            fontFamily: 'Bold',
            letterSpacing: 1.2,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _branches.map((branch) {
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TouchableWidget(
                    onTap: () {
                      // Handle branch selection
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: TextWidget(
                            text: 'Selected ${branch['name']} for $method',
                            fontSize: fontSize - 1,
                            color: plainWhite,
                            fontFamily: 'Regular',
                          ),
                          backgroundColor: bayanihanBlue,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(padding),
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
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              branch['image']!,
                              width: screenWidth * 0.25,
                              height: screenWidth * 0.25,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: screenWidth * 0.25,
                                height: screenWidth * 0.25,
                                color: ashGray,
                                child: Center(
                                  child: TextWidget(
                                    text: branch['name']![0],
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
                                  text: branch['name']!,
                                  fontSize: fontSize + 1,
                                  color: textBlack,
                                  isBold: true,
                                  fontFamily: 'Bold',
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 6),
                                TextWidget(
                                  text: branch['address']!,
                                  fontSize: fontSize - 1,
                                  color: charcoalGray,
                                  fontFamily: 'Regular',
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            ButtonWidget(
              label: 'Cancel',
              onPressed: () => Navigator.pop(context),
              color: ashGray,
              textColor: textBlack,
              fontSize: fontSize,
              height: 40,
              radius: 12,
              width: 100,
            ),
          ],
        );
      },
    );
  }
}
