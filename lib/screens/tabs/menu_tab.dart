import 'package:flutter/material.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/divider_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';

class MenuTab extends StatefulWidget {
  const MenuTab({super.key});

  @override
  State<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  final List<String> _categories = ['Coffee', 'Drinks', 'Foods'];
  String _selectedCategory = 'Coffee';

  // Sample menu items
  final List<Map<String, dynamic>> _menuItems = [
    {
      'name': 'Espresso',
      'description': 'Rich and bold single shot',
      'price': 69.0,
      'category': 'Coffee',
      'image':
          'https://www.nespresso.ph/media/catalog/category/recipes/morning_coffee/nespresso-recipes-Espresso-Macchiato-by-Nespresso_1.jpg',
    },
    {
      'name': 'Cappuccino',
      'description': 'Frothy milk with espresso',
      'price': 89.0,
      'category': 'Coffee',
      'image': 'https://www.nespresso.com/recipes/images/cappuccino.jpg',
    },
    {
      'name': 'Iced Tea',
      'description': 'Refreshing lemon-infused tea',
      'price': 59.0,
      'category': 'Drinks',
      'image': 'https://www.nespresso.com/recipes/images/iced_tea.jpg',
    },
    {
      'name': 'Croissant',
      'description': 'Buttery and flaky pastry',
      'price': 49.0,
      'category': 'Foods',
      'image': 'https://www.nespresso.com/recipes/images/croissant.jpg',
    },
    {
      'name': 'Latte',
      'description': 'Smooth espresso with steamed milk',
      'price': 79.0,
      'category': 'Coffee',
      'image': 'https://www.nespresso.com/recipes/images/latte.jpg',
    },
    {
      'name': 'Chocolate Cake',
      'description': 'Rich and decadent dessert',
      'price': 99.0,
      'category': 'Foods',
      'image': 'https://www.nespresso.com/recipes/images/chocolate_cake.jpg',
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
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TextWidget(
            text: 'Our Menu',
            fontSize: 22,
            color: textBlack,
            isBold: true,
            fontFamily: 'Bold',
          ),
          const SizedBox(height: 10),
          DividerWidget(),
          // Category Chips
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12.5, vertical: 5),
                  elevation: isSelected ? 1 : 0,
                  pressElevation: 1,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          // Menu Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: cardWidth / cardHeight,
            ),
            itemCount: _menuItems
                .where((item) => item['category'] == _selectedCategory)
                .length,
            itemBuilder: (context, index) {
              final item = _menuItems
                  .where((item) => item['category'] == _selectedCategory)
                  .toList()[index];
              return Card(
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
                        color: bayanihanBlue.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
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
                              onError: (exception, stackTrace) => Container(
                                color: ashGray,
                                child: Center(
                                  child: TextWidget(
                                    text: item['name'][0],
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              text: item['name'],
                              fontSize: fontSize + 2,
                              color: textBlack,
                              isBold: true,
                              fontFamily: 'Bold',
                              maxLines: 1,
                            ),
                            TextWidget(
                              text: item['description'],
                              fontSize: fontSize - 2,
                              color: charcoalGray,
                              fontFamily: 'Regular',
                              maxLines: 1,
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextWidget(
                                  text: '₱${item['price'].toStringAsFixed(0)}',
                                  fontSize: 18,
                                  color: const Color.fromARGB(255, 255, 213, 0),
                                  isBold: true,
                                  fontFamily: 'Bold',
                                ),
                                ButtonWidget(
                                  label: 'Order',
                                  onPressed: () {
                                    // Handle order action
                                  },
                                  color: bayanihanBlue,
                                  textColor: plainWhite,
                                  fontSize: fontSize - 2,
                                  height: 34,
                                  radius: 10,
                                  width: 80,
                                ),
                              ],
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
        ],
      ),
    );
  }
}
