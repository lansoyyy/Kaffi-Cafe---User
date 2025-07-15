import 'package:flutter/material.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/divider_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuTab extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final void Function(Map<String, dynamic> item, int quantity) addToCart;
  final void Function(Map<String, dynamic> item) removeFromCart;
  final VoidCallback clearCart;
  final double subtotal;
  final VoidCallback onViewCart;
  final String? selectedBranch;
  final void Function(String?)? setBranch;
  final String? selectedType;
  final void Function(String?)? setType;
  final List<String>? branches;
  const MenuTab({
    Key? key,
    required this.cartItems,
    required this.addToCart,
    required this.removeFromCart,
    required this.clearCart,
    required this.subtotal,
    required this.onViewCart,
    this.selectedBranch,
    this.setBranch,
    this.selectedType,
    this.setType,
    this.branches,
  }) : super(key: key);

  @override
  State<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  final List<String> _categories = ['All', 'Coffee', 'Drinks', 'Foods'];
  String _selectedCategory = 'All';
  final List<String> _types = ['Dine in', 'Pickup', 'Delivery'];

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'Coffee':
        return Icons.local_cafe;
      case 'Drinks':
        return Icons.local_drink;
      case 'Foods':
        return Icons.fastfood;
      default:
        return Icons.fastfood;
    }
  }

  void _showAddToCartDialog(Map<String, dynamic> item) {
    int quantity = 1;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add ${item['name']}'),
          content: Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  if (quantity > 1) {
                    quantity--;
                    (context as Element).markNeedsBuild();
                  }
                },
              ),
              Text('$quantity'),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  quantity++;
                  (context as Element).markNeedsBuild();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed:
                  (widget.selectedBranch == null || widget.selectedType == null)
                      ? null
                      : () {
                          widget.addToCart(item, quantity);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('${item['name']} added to cart')),
                          );
                        },
              child: Text('Add to Cart'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.42;
    final cardHeight = screenWidth * 0.55;
    final fontSize = screenWidth * 0.035;
    final padding = screenWidth * 0.03;

    return Stack(
      children: [
        Padding(
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
              // Removed branch and type dropdowns here
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.5, vertical: 5),
                      elevation: isSelected ? 1 : 0,
                      pressElevation: 1,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              // Menu Grid from Firestore
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _selectedCategory == 'All'
                      ? FirebaseFirestore.instance
                          .collection('products')
                          .orderBy('timestamp', descending: true)
                          .snapshots()
                      : FirebaseFirestore.instance
                          .collection('products')
                          .where('category', isEqualTo: _selectedCategory)
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: \\${snapshot.error}'));
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final menuItems = snapshot.data!.docs;
                    if (menuItems.isEmpty) {
                      return Center(child: Text('No items found.'));
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                        childAspectRatio: cardWidth / cardHeight,
                      ),
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) {
                        final data =
                            menuItems[index].data() as Map<String, dynamic>;
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
                                  child: data['image'] != null &&
                                          data['image'].toString().isNotEmpty
                                      ? Image.network(
                                          data['image'],
                                          height: cardHeight * 0.5,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            color: ashGray,
                                            height: cardHeight * 0.5,
                                            width: double.infinity,
                                            child: Center(
                                              child: Icon(
                                                _getCategoryIcon(
                                                    data['category']),
                                                size: 40,
                                                color: plainWhite,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          color: ashGray,
                                          height: cardHeight * 0.5,
                                          width: double.infinity,
                                          child: Center(
                                            child: Icon(
                                              _getCategoryIcon(
                                                  data['category']),
                                              size: 40,
                                              color: plainWhite,
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
                                        text: data['name'],
                                        fontSize: fontSize + 2,
                                        color: textBlack,
                                        isBold: true,
                                        fontFamily: 'Bold',
                                        maxLines: 1,
                                      ),
                                      TextWidget(
                                        text: data['description'] ?? '',
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
                                                '₱${(data['price'] as num?)?.toStringAsFixed(0) ?? '0'}',
                                            fontSize: 18,
                                            color: const Color.fromARGB(
                                                255, 255, 213, 0),
                                            isBold: true,
                                            fontFamily: 'Bold',
                                          ),
                                          ButtonWidget(
                                            label: 'Order',
                                            onPressed: (widget.selectedBranch ==
                                                        null ||
                                                    widget.selectedType == null)
                                                ? null
                                                : () {
                                                    _showAddToCartDialog(data);
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        if (widget.cartItems.isNotEmpty)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed:
                  (widget.selectedBranch == null || widget.selectedType == null)
                      ? null
                      : widget.onViewCart,
              label: Text('View Cart (${widget.cartItems.length})'),
              icon: Icon(Icons.shopping_cart),
              backgroundColor: bayanihanBlue,
            ),
          ),
      ],
    );
  }
}
