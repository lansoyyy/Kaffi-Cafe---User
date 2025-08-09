import 'package:flutter/material.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final void Function(Map<String, dynamic> item, int quantity) addToCart;

  const ProductDetailsScreen({
    Key? key,
    required this.product,
    required this.addToCart,
  }) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  String _selectedSize = 'Regular';
  String _selectedSweetness = 'Original Recipe (Dairy Milk)';
  String _selectedIce = 'Regular';
  String _selectedMilk = 'Original Recipe (Dairy Milk)';
  
  final List<Map<String, dynamic>> _sizes = [
    {'name': 'Regular', 'price': 0.0},
    {'name': 'Upsize (Large)', 'price': 15.0},
    {'name': 'DoubleUP (MEGA) - For pickup only', 'price': 65.0},
  ];

  final List<String> _sweetnessLevels = [
    'Original Recipe (Dairy Milk)',
    'Less Sweet',
    'Extra Sweet',
  ];

  final List<String> _iceLevels = [
    'Regular',
    'Less Ice',
    'Extra Ice',
    'No Ice',
  ];

  final List<Map<String, dynamic>> _milkOptions = [
    {'name': 'Original Recipe (Dairy Milk)', 'price': 0.0},
    {'name': 'Upgrade to Oat Milk', 'price': 30.0},
    {'name': 'Upgrade to Soy Milk', 'price': 30.0},
  ];

  double get _totalPrice {
    double basePrice = widget.product['price'].toDouble();
    double sizePrice = _sizes.firstWhere((s) => s['name'] == _selectedSize)['price'];
    double milkPrice = _milkOptions.firstWhere((m) => m['name'] == _selectedMilk)['price'];
    return basePrice + sizePrice + milkPrice;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: textBlack),
                  ),
                  Expanded(
                    child: TextWidget(
                      text: widget.product['name'],
                      fontSize: 20,
                      fontFamily: 'Bold',
                      color: textBlack,
                      align: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),
            
            // Product image placeholder
            Container(
              width: screenWidth * 0.8,
              height: screenHeight * 0.3,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: ashGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_cafe,
                      size: 80,
                      color: bayanihanBlue.withOpacity(0.5),
                    ),
                    const SizedBox(height: 10),
                    TextWidget(
                      text: 'Product Image',
                      fontSize: 16,
                      color: charcoalGray,
                      fontFamily: 'Regular',
                    ),
                  ],
                ),
              ),
            ),

            // Product details
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name and description
                    TextWidget(
                      text: widget.product['name'],
                      fontSize: 24,
                      fontFamily: 'Bold',
                      color: textBlack,
                    ),
                    const SizedBox(height: 8),
                    TextWidget(
                      text: 'Lache condensada with creamy milk and rich espresso, over ice.',
                      fontSize: 14,
                      fontFamily: 'Regular',
                      color: charcoalGray,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    // Size selection
                    _buildSectionTitle('PICKUP Size - Choose one'),
                    const SizedBox(height: 12),
                    ..._sizes.map((size) => _buildRadioOption(
                      title: size['name'],
                      subtitle: size['price'] > 0 ? '+P ${size['price'].toStringAsFixed(2)}' : 'P 0.00',
                      value: size['name'],
                      groupValue: _selectedSize,
                      onChanged: (value) => setState(() => _selectedSize = value!),
                    )),
                    
                    const SizedBox(height: 20),

                    // Milk preference
                    _buildSectionTitle('Milk Preference - Choose one'),
                    const SizedBox(height: 12),
                    ..._milkOptions.map((milk) => _buildRadioOption(
                      title: milk['name'],
                      subtitle: milk['price'] > 0 ? '+P ${milk['price'].toStringAsFixed(2)}' : 'P 0.00',
                      value: milk['name'],
                      groupValue: _selectedMilk,
                      onChanged: (value) => setState(() => _selectedMilk = value!),
                    )),

                    const SizedBox(height: 20),

                    // Sweetness level
                    _buildSectionTitle('Sweetness Level - Choose one'),
                    const SizedBox(height: 12),
                    ..._sweetnessLevels.map((sweetness) => _buildRadioOption(
                      title: sweetness,
                      subtitle: 'P 0.00',
                      value: sweetness,
                      groupValue: _selectedSweetness,
                      onChanged: (value) => setState(() => _selectedSweetness = value!),
                    )),

                    const SizedBox(height: 20),

                    // Ice level
                    _buildSectionTitle('Ice Level - Choose one'),
                    const SizedBox(height: 12),
                    ..._iceLevels.map((ice) => _buildRadioOption(
                      title: ice,
                      subtitle: 'P 0.00',
                      value: ice,
                      groupValue: _selectedIce,
                      onChanged: (value) => setState(() => _selectedIce = value!),
                    )),

                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Bottom add to cart section
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Quantity controls
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: ashGray),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    icon: Icon(Icons.remove, color: _quantity > 1 ? textBlack : ashGray),
                  ),
                  TextWidget(
                    text: '$_quantity',
                    fontSize: 18,
                    fontFamily: 'Bold',
                    color: textBlack,
                  ),
                  IconButton(
                    onPressed: () => setState(() => _quantity++),
                    icon: Icon(Icons.add, color: textBlack),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Add to cart button
            Expanded(
              child: ButtonWidget(
                label: 'ADD TO CART - P ${(_totalPrice * _quantity).toStringAsFixed(2)}',
                onPressed: () {
                  // Create customized item
                  Map<String, dynamic> customizedItem = {
                    'name': widget.product['name'],
                    'price': _totalPrice,
                    'quantity': _quantity,
                    'customizations': {
                      'size': _selectedSize,
                      'sweetness': _selectedSweetness,
                      'ice': _selectedIce,
                      'milk': _selectedMilk,
                    }
                  };
                  
                  widget.addToCart(customizedItem, _quantity);
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: TextWidget(
                        text: '${widget.product['name']} added to cart',
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: 'Regular',
                      ),
                      backgroundColor: bayanihanBlue,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                color: palmGreen,
                textColor: Colors.white,
                fontSize: 16,
                height: 50,
                radius: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return TextWidget(
      text: title,
      fontSize: 16,
      fontFamily: 'Bold',
      color: textBlack,
    );
  }

  Widget _buildRadioOption({
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required void Function(String?) onChanged,
  }) {
    final isSelected = value == groupValue;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? bayanihanBlue : ashGray.withOpacity(0.5),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? bayanihanBlue.withOpacity(0.05) : Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? bayanihanBlue : ashGray,
                    width: 2,
                  ),
                  color: isSelected ? bayanihanBlue : Colors.transparent,
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextWidget(
                  text: title,
                  fontSize: 14,
                  fontFamily: 'Regular',
                  color: textBlack,
                ),
              ),
              TextWidget(
                text: subtitle,
                fontSize: 14,
                fontFamily: 'Bold',
                color: isSelected ? bayanihanBlue : charcoalGray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
