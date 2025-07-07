import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaffi_cafe/screens/tabs/account_tab.dart';
import 'package:kaffi_cafe/screens/tabs/home_tab.dart';
import 'package:kaffi_cafe/screens/tabs/menu_tab.dart';
import 'package:kaffi_cafe/screens/tabs/order_screen.dart';
import 'package:kaffi_cafe/screens/tabs/reward_tab.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/logout_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';
import 'package:kaffi_cafe/widgets/touchable_widget.dart';

import 'reservation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    // Home Screen
    HomeTab(),
    MenuTab(),
    // Order Screen
    OrderScreen(),
    // Reward Screen
    RewardScreen(),
    // Account Screen
    AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      showOrderDialog();
    }
  }

  showOrderDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: TextWidget(
                    text: 'How would you like to\nget your order?',
                    fontSize: 18,
                    fontFamily: 'Bold',
                    align: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TouchableWidget(
                  onTap: () {
                    Navigator.pop(context);
                    _showBranchSelectionDialog('Delivery');
                  },
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
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
                SizedBox(
                  height: 20,
                ),
                TouchableWidget(
                  onTap: () {
                    Navigator.pop(context);
                    _showBranchSelectionDialog('Pickup');
                  },
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
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
                SizedBox(
                  height: 20,
                ),
                TouchableWidget(
                  onTap: () {
                    Navigator.pop(context);
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
                                            borderRadius:
                                                BorderRadius.circular(20),
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
                                                        BorderRadius.circular(
                                                            15),
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
                                                      padding: EdgeInsets.all(
                                                          padding),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        color: plainWhite,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: bayanihanBlue
                                                                .withOpacity(
                                                                    0.1),
                                                            blurRadius: 6,
                                                            offset:
                                                                const Offset(
                                                                    0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            child:
                                                                Image.network(
                                                              branch['image']!,
                                                              width:
                                                                  screenWidth *
                                                                      0.25,
                                                              height:
                                                                  screenWidth *
                                                                      0.25,
                                                              fit: BoxFit.cover,
                                                              errorBuilder:
                                                                  (context,
                                                                          error,
                                                                          stackTrace) =>
                                                                      Container(
                                                                width:
                                                                    screenWidth *
                                                                        0.25,
                                                                height:
                                                                    screenWidth *
                                                                        0.25,
                                                                color: ashGray,
                                                                child: Center(
                                                                  child:
                                                                      TextWidget(
                                                                    text: branch[
                                                                        'name']![0],
                                                                    fontSize:
                                                                        24,
                                                                    color:
                                                                        plainWhite,
                                                                    isBold:
                                                                        true,
                                                                    fontFamily:
                                                                        'Bold',
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 12),
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
                                                                      fontSize +
                                                                          1,
                                                                  color:
                                                                      textBlack,
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
                                                                      fontSize -
                                                                          1,
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
                      padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
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
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: bayanihanBlue,
        actions: [
          IconButton(
            onPressed: () {
              logout(context, HomeScreen());
            },
            icon: Icon(
              Icons.logout,
            ),
          ),
        ],
        title: TextWidget(
          text: 'Kaffi Cafe',
          fontSize: 24,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Reward',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: bayanihanBlue,
        unselectedItemColor: charcoalGray,
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
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
