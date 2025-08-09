import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
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
  final GetStorage _storage = GetStorage();
  int _selectedIndex = 0;

  // Cart state
  final List<Map<String, dynamic>> _cartItems = [];
  double get _subtotal => _cartItems.fold(
      0, (sum, item) => sum + (item['price'] * item['quantity']));

  String? _selectedBranch;
  String? _selectedType;

  void _setBranch(String? branch) {
    setState(() {
      _selectedBranch = branch;
    });
  }

  void _setType(String? type) {
    setState(() {
      _selectedType = type;
    });
  }

  void _addToCart(Map<String, dynamic> item, int quantity) {
    final index =
        _cartItems.indexWhere((cartItem) => cartItem['name'] == item['name']);
    setState(() {
      if (index >= 0) {
        _cartItems[index]['quantity'] += quantity;
      } else {
        _cartItems.add({
          'name': item['name'],
          'price': item['price'],
          'quantity': quantity,
        });
      }
    });
  }

  void _removeFromCart(Map<String, dynamic> item) {
    setState(() {
      _cartItems.remove(item);
    });
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
      _selectedBranch = null;
      _selectedType = null;
    });
  }

  void _goToMenuTab() {
    if (_storage.read('selectedBranch') == null ||
        _storage.read('selectedType') == null) {
      showOrderDialog();
    } else {
      setState(() {
        _selectedIndex = 1;
      });
    }
  }

  void _goToOrderTab() {
    setState(() {
      _selectedIndex = 2;
    });
  }

  @override
  void initState() {
    super.initState();
    // Load stored branch and type
    _selectedBranch = _storage.read('selectedBranch');
    _selectedType = _storage.read('selectedType');
    // If not set, show dialog to select
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_storage.read('selectedBranch') == null ||
          _storage.read('selectedType') == null) {
        showOrderDialog();
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1 &&
        (_storage.read('selectedBranch') == null ||
            _storage.read('selectedType') == null)) {
      showOrderDialog();
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userName => _auth.currentUser?.displayName ?? 'User';

  showOrderDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final cardHeight = 110.0;
        final cardRadius = 18.0;
        final iconSize = 56.0;
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextWidget(
                  text: 'How would you like to get your order?',
                  fontSize: 18,
                  fontFamily: 'Bold',
                  align: TextAlign.center,
                  color: textBlack,
                ),
                SizedBox(height: 24),
                TouchableWidget(
                  onTap: () {
                    Navigator.pop(context);
                    _showBranchSelectionDialog('Pickup');
                  },
                  child: Card(
                    color: const Color(0xFFE6F0FA),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(cardRadius),
                    ),
                    child: Container(
                      height: cardHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        children: [
                          Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(iconSize / 2),
                            ),
                            child: Image.asset(
                              'assets/images/delivery.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(width: 24),
                          Expanded(
                            child: TextWidget(
                              text: 'SELF PICKUP',
                              fontSize: 18,
                              fontFamily: 'Bold',
                              color: bayanihanBlue,
                              align: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TouchableWidget(
                  onTap: () {
                    Navigator.pop(context);
                    _showBranchSelectionDialog('Delivery');
                  },
                  child: Card(
                    color: const Color(0xFFF6F7FB),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(cardRadius),
                    ),
                    child: Container(
                      height: cardHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        children: [
                          Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(iconSize / 2),
                            ),
                            child: Image.asset(
                              'assets/images/courier.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(width: 24),
                          Expanded(
                            child: TextWidget(
                              text: 'DELIVERY',
                              fontSize: 18,
                              fontFamily: 'Bold',
                              color: bayanihanBlue,
                              align: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
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
                                                              .circularReveal)?.then((result) {
                                                        if (result == 'goToMenu') {
                                                          setState(() {
                                                            _selectedIndex = 1; // Switch to menu tab
                                                          });
                                                        }
                                                      });
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
                    color: const Color(0xFFF6F7FB),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(cardRadius),
                    ),
                    child: Container(
                      height: cardHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        children: [
                          Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(iconSize / 2),
                            ),
                            child: Image.asset(
                              'assets/images/salad.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(width: 24),
                          Expanded(
                            child: TextWidget(
                              text: 'DINE IN',
                              fontSize: 18,
                              fontFamily: 'Bold',
                              color: bayanihanBlue,
                              align: TextAlign.left,
                            ),
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
    final List<Widget> screens = [
      HomeTab(
        onBranchSelected: _goToMenuTab,
        onTypeAndBranchSelected: (type, branch) {
          setState(() {
            _selectedType = type;
            _selectedBranch = branch;
            _selectedIndex = 1;
          });
        },
        addToCart: _addToCart,
      ),
      MenuTab(
        cartItems: _cartItems,
        addToCart: _addToCart,
        removeFromCart: _removeFromCart,
        clearCart: _clearCart,
        subtotal: _subtotal,
        onViewCart: _goToOrderTab,
        selectedBranch: _selectedBranch,
        selectedType: _selectedType,
      ),
      OrderScreen(
        cartItems: _cartItems,
        removeFromCart: _removeFromCart,
        clearCart: _clearCart,
        subtotal: _subtotal,
        selectedBranch: _selectedBranch,
        setBranch: _setBranch,
        selectedType: _selectedType,
        setType: _setType,
        branches: _branches.map((b) => b['name']!).toList(),
      ),
      RewardScreen(),
      AccountScreen(),
    ];
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
          text: "Good Day ${_userName.split(' ')[0]}!",
          fontSize: 24,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
      ),
      body: screens[_selectedIndex],
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
                      setState(() {
                        _selectedBranch = branch['name'];
                        _selectedType = method;
                        // Store selection in GetStorage
                        _storage.write('selectedBranch', _selectedBranch);
                        _storage.write('selectedType', _selectedType);
                      });
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
