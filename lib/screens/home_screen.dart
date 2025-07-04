import 'package:flutter/material.dart';
import 'package:kaffi_cafe/screens/tabs/account_tab.dart';
import 'package:kaffi_cafe/screens/tabs/home_tab.dart';
import 'package:kaffi_cafe/screens/tabs/menu_tab.dart';
import 'package:kaffi_cafe/screens/tabs/order_screen.dart';
import 'package:kaffi_cafe/screens/tabs/reward_tab.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/logout_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';
import 'package:kaffi_cafe/widgets/touchable_widget.dart';

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
                  onTap: () {},
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
                  onTap: () {},
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
}
