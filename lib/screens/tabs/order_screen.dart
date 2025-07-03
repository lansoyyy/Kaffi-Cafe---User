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

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  // Sample menu items
  final List<Map<String, dynamic>> _menuItems = [
    {
      'name': 'Espresso',
      'description': 'Rich and bold single shot',
      'price': 69.0,
      'category': 'Coffee',
      'image':
          'https://static.vecteezy.com/system/resources/thumbnails/012/025/024/small_2x/coffee-banner-ads-retro-brown-style-with-latte-and-coffee-beans-3d-realistic-simple-vector.jpg',
      'ingredients': "Premium coffee beans', 'Water",
    },
    {
      'name': 'Cappuccino',
      'description': 'Frothy milk with espresso',
      'price': 89.0,
      'category': 'Coffee',
      'image':
          'https://static.vecteezy.com/system/resources/thumbnails/012/025/024/small_2x/coffee-banner-ads-retro-brown-style-with-latte-and-coffee-beans-3d-realistic-simple-vector.jpg',
      'ingredients': "Espresso', 'Steamed milk', 'Milk foam",
    },
    {
      'name': 'Iced Tea',
      'description': 'Refreshing lemon-infused tea',
      'price': 59.0,
      'category': 'Drinks',
      'image':
          'https://static.vecteezy.com/system/resources/thumbnails/012/025/024/small_2x/coffee-banner-ads-retro-brown-style-with-latte-and-coffee-beans-3d-realistic-simple-vector.jpg',
      'ingredients': "Black tea', 'Lemon extract', 'Water', 'Sugar",
    },
    {
      'name': 'Croissant',
      'description': 'Buttery and flaky pastry',
      'price': 49.0,
      'category': 'Foods',
      'image':
          'https://static.vecteezy.com/system/resources/thumbnails/012/025/024/small_2x/coffee-banner-ads-retro-brown-style-with-latte-and-coffee-beans-3d-realistic-simple-vector.jpg',
      'ingredients': "Butter', 'Flour', 'Sugar', 'Eggs', 'Yeast",
    },
  ];

  // Customization options
  String _selectedItem = 'Espresso';
  int _coffeeShots = 1;
  String _sweetnessLevel = 'Medium';
  String _iceLevel = 'Regular';
  final List<String> _sweetnessLevels = ['Low', 'Medium', 'High', 'None'];
  final List<String> _iceLevels = ['No Ice', 'Light', 'Regular', 'Extra'];

  final List<String> _categories = ['Coffee', 'Drinks', 'Foods'];
  String _selectedCategory = 'Coffee';

  int selected = 0;

  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.44;
    final cardHeight = screenWidth * 0.58;
    final fontSize = screenWidth * 0.036;
    final padding = screenWidth * 0.035;

    // Get the selected item's details
    final selectedItemDetails = _menuItems.firstWhere(
      (item) => item['name'] == _selectedItem,
      orElse: () => _menuItems[0],
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            TextWidget(
              text: 'Create Your Order',
              fontSize: 24,
              color: textBlack,
              isBold: true,
              fontFamily: 'Bold',
              letterSpacing: 1.3,
            ),
            const SizedBox(height: 12),
            DividerWidget(),
            // Item Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(
                  text: 'Select Item',
                  fontSize: 20,
                  color: textBlack,
                  isBold: true,
                  fontFamily: 'Bold',
                  letterSpacing: 1.2,
                ),
                SizedBox(
                  width: 200,
                  height: 40,
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search items...',
                      hintStyle: TextStyle(
                        fontSize: fontSize - 2,
                        color: charcoalGray,
                        fontFamily: 'Regular',
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: bayanihanBlue,
                        size: 20,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: ashGray,
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: ashGray,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: bayanihanBlue,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: cloudWhite,
                    ),
                    style: TextStyle(
                      fontSize: fontSize - 2,
                      color: textBlack,
                      fontFamily: 'Regular',
                    ),
                    onChanged: (value) {
                      // Handle search functionality here
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    showCheckmark: false,
                    label: TextWidget(
                      text: category,
                      fontSize: 14,
                      color: isSelected ? plainWhite : textBlack,
                      isBold: isSelected,
                      fontFamily: 'Regular',
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      }
                    },
                    backgroundColor: cloudWhite,
                    selectedColor: bayanihanBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.5),
                      side: BorderSide(
                        color: isSelected ? bayanihanBlue : ashGray,
                        width: 0.5,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.5, vertical: 5),
                    elevation: isSelected ? 1 : 0,
                    pressElevation: 1,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            // Item Image and Price
            SizedBox(
              width: 500,
              height: 225,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (int i = 0; i < _menuItems.length; i++)
                    TouchableWidget(
                      onTap: () {
                        setState(() {
                          _selectedItem = _menuItems[i]['ingredients'];
                          selected = i;
                        });
                      },
                      child: SizedBox(
                        width: 175,
                        height: 225,
                        child: Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: selected == i
                                  ? bayanihanBlue.withOpacity(0.2)
                                  : Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(15),
                                  ),
                                  child: Container(
                                    height: cardHeight * 0.5,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            'https://www.nespresso.ph/media/catalog/category/recipes/morning_coffee/nespresso-recipes-Espresso-Macchiato-by-Nespresso_1.jpg'),
                                        fit: BoxFit.cover,
                                        onError: (exception, stackTrace) =>
                                            Container(
                                          color: ashGray,
                                          child: Center(
                                            child: TextWidget(
                                              text: _menuItems[i]['name'][0],
                                              fontSize: 40,
                                              color: plainWhite,
                                              isBold: true,
                                            ),
                                          ),
                                        ),
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
                                        text: _menuItems[i]['name'],
                                        fontSize: fontSize + 2,
                                        color: textBlack,
                                        isBold: true,
                                        fontFamily: 'Bold',
                                        maxLines: 1,
                                      ),
                                      TextWidget(
                                        text: _menuItems[i]['description'],
                                        fontSize: fontSize - 2,
                                        color: charcoalGray,
                                        fontFamily: 'Regular',
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextWidget(
                                            text:
                                                '₱${_menuItems[i]['price'].toStringAsFixed(0)}',
                                            fontSize: 18,
                                            color: const Color.fromARGB(
                                                255, 255, 213, 0),
                                            isBold: true,
                                            fontFamily: 'Bold',
                                          ),
                                          SizedBox(
                                            width: 5,
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
                      ),
                    )
                ],
              ),
            ),
            const SizedBox(height: 18),
            DividerWidget(),
            // Customization Section
            TextWidget(
              text: 'Customize Your Order',
              fontSize: 20,
              color: textBlack,
              isBold: true,
              fontFamily: 'Bold',
              letterSpacing: 1.2,
            ),
            const SizedBox(height: 12),
            // Coffee Shots
            TextWidget(
              text: 'Coffee Shots',
              fontSize: fontSize + 2,
              color: textBlack,
              isBold: true,
              fontFamily: 'Bold',
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ButtonWidget(
                  label: '-',
                  onPressed: () {
                    setState(() {
                      if (_coffeeShots > 1) _coffeeShots--;
                    });
                  },
                  color: ashGray,
                  textColor: textBlack,
                  fontSize: fontSize,
                  height: 36,
                  width: 50,
                  radius: 10,
                ),
                const SizedBox(width: 12),
                TextWidget(
                  text: '$_coffeeShots Shot${_coffeeShots > 1 ? 's' : ''}',
                  fontSize: fontSize + 1,
                  color: textBlack,
                  fontFamily: 'Regular',
                ),
                const SizedBox(width: 12),
                ButtonWidget(
                  label: '+',
                  onPressed: () {
                    setState(() {
                      _coffeeShots++;
                    });
                  },
                  color: bayanihanBlue,
                  textColor: plainWhite,
                  fontSize: fontSize,
                  height: 36,
                  width: 50,
                  radius: 10,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Sweetness Level
            TextWidget(
              text: 'Sweetness Level',
              fontSize: fontSize + 2,
              color: textBlack,
              isBold: true,
              fontFamily: 'Bold',
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: _sweetnessLevels.map((level) {
                final isSelected = _sweetnessLevel == level;
                return ChoiceChip(
                  showCheckmark: false,
                  label: TextWidget(
                    text: level,
                    fontSize: fontSize,
                    color: isSelected ? plainWhite : textBlack,
                    isBold: isSelected,
                    fontFamily: 'Regular',
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _sweetnessLevel = level;
                      });
                    }
                  },
                  backgroundColor: cloudWhite,
                  selectedColor: bayanihanBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? bayanihanBlue : ashGray,
                      width: 1.0,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  elevation: isSelected ? 3 : 0,
                  pressElevation: 5,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Ice Level
            TextWidget(
              text: 'Ice Level',
              fontSize: fontSize + 2,
              color: textBlack,
              isBold: true,
              fontFamily: 'Bold',
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: _iceLevels.map((level) {
                final isSelected = _iceLevel == level;
                return ChoiceChip(
                  showCheckmark: false,
                  label: TextWidget(
                    text: level,
                    fontSize: fontSize,
                    color: isSelected ? plainWhite : textBlack,
                    isBold: isSelected,
                    fontFamily: 'Regular',
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _iceLevel = level;
                      });
                    }
                  },
                  backgroundColor: cloudWhite,
                  selectedColor: bayanihanBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? bayanihanBlue : ashGray,
                      width: 1.0,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  elevation: isSelected ? 3 : 0,
                  pressElevation: 5,
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            DividerWidget(),
            // Ingredients Section
            TextWidget(
              text: 'Ingredients',
              fontSize: 20,
              color: textBlack,
              isBold: true,
              fontFamily: 'Bold',
              letterSpacing: 1.2,
            ),
            const SizedBox(height: 12),
            TextWidget(
              text: _selectedItem,
              fontSize: fontSize,
              color: charcoalGray,
              fontFamily: 'Regular',
              maxLines: 3,
            ),
            Divider(),
            const SizedBox(height: 18),

            // Order Button
            Center(
              child: ButtonWidget(
                label: 'Add to Order',
                onPressed: () {
                  // Handle order submission
                },
                color: bayanihanBlue,
                textColor: plainWhite,
                fontSize: fontSize + 2,
                height: 50,
                radius: 12,
                width: screenWidth * 0.6,
              ),
            ),
            const SizedBox(height: 20),
            // Order Button
            Center(
              child: ButtonWidget(
                label: 'Checkout Orders',
                onPressed: () {
                  Get.to(CheckoutScreen(),
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
  }
}
