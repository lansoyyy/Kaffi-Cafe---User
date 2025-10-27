import 'package:flutter/material.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/screens/product_details_screen.dart';
import 'package:kaffi_cafe/services/recommendation_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecommendationWidget extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final void Function(Map<String, dynamic> item, int quantity) addToCart;
  final String? selectedBranch;
  final String? selectedType;

  const RecommendationWidget({
    Key? key,
    required this.cartItems,
    required this.addToCart,
    this.selectedBranch,
    this.selectedType,
  }) : super(key: key);

  @override
  State<RecommendationWidget> createState() => _RecommendationWidgetState();
}

class _RecommendationWidgetState extends State<RecommendationWidget> {
  final RecommendationService _recommendationService = RecommendationService();
  final GetStorage _storage = GetStorage();
  List<Map<String, dynamic>> _recommendations = [];
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      List<Map<String, dynamic>> recommendations = [];

      // If cart has items, try to get recommendations based on cart items
      if (widget.cartItems.isNotEmpty) {
        // Get recommendations based on the first item in cart
        final firstItemName = widget.cartItems.first['name'] as String;
        recommendations = await _recommendationService
            .getFrequentlyBoughtTogether(firstItemName);

        // If no recommendations found for first item, try with other items
        if (recommendations.isEmpty && widget.cartItems.length > 1) {
          for (int i = 1;
              i < widget.cartItems.length && recommendations.isEmpty;
              i++) {
            final itemName = widget.cartItems[i]['name'] as String;
            recommendations = await _recommendationService
                .getFrequentlyBoughtTogether(itemName);
          }
        }

        // If still no recommendations, try popular products in the same category
        if (recommendations.isEmpty) {
          final firestore = FirebaseFirestore.instance;
          final productSnapshot = await firestore
              .collection('products')
              .where('name', isEqualTo: firstItemName)
              .limit(1)
              .get();

          if (productSnapshot.docs.isNotEmpty) {
            final category =
                productSnapshot.docs.first.data()['category'] as String?;
            if (category != null) {
              recommendations = await _recommendationService
                  .getPopularProductsInCategory(category, firstItemName);
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _recommendations = recommendations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
      print('Error loading recommendations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_hasError) {
      return _buildErrorWidget();
    }

    // Always show the widget, even if no recommendations (show popular products)
    return _buildRecommendationWidget();
  }

  Widget _buildLoadingWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: 'Frequently Bought Together',
            fontSize: 18,
            color: textBlack,
            isBold: true,
            fontFamily: 'Bold',
          ),
          const SizedBox(height: 10),
          Container(
            height: 180,
            child: Center(
              child: CircularProgressIndicator(
                color: bayanihanBlue,
                strokeWidth: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: 'Frequently Bought Together',
            fontSize: 18,
            color: textBlack,
            isBold: true,
            fontFamily: 'Bold',
          ),
          const SizedBox(height: 10),
          Container(
            height: 100,
            child: Center(
              child: TextWidget(
                text: 'Unable to load recommendations',
                fontSize: 14,
                color: charcoalGray,
                fontFamily: 'Regular',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationWidget() {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.45;
    final cardHeight = screenWidth * 0.45;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: 'Frequently Bought Together',
            fontSize: 18,
            color: textBlack,
            isBold: true,
            fontFamily: 'Bold',
          ),
          const SizedBox(height: 10),
          if (_recommendations.isEmpty)
            Container(
              height: 100,
              child: Center(
                child: TextWidget(
                  text:
                      'No recommendations available yet. Start ordering to see suggestions!',
                  fontSize: 14,
                  color: charcoalGray,
                  fontFamily: 'Regular',
                  align: TextAlign.center,
                ),
              ),
            )
          else
            Container(
              height: cardHeight + 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _recommendations.length,
                itemBuilder: (context, index) {
                  final product = _recommendations[index];
                  return Container(
                    width: cardWidth,
                    margin: const EdgeInsets.only(right: 12),
                    child: _buildRecommendationCard(
                        product, cardWidth, cardHeight),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
      Map<String, dynamic> product, double cardWidth, double cardHeight) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: plainWhite,
          boxShadow: [
            BoxShadow(
              color: bayanihanBlue.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              Container(
                height: 100,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: product['image'] != null &&
                          product['image'].toString().isNotEmpty
                      ? Image.network(
                          product['image'],
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: ashGray,
                            width: double.infinity,
                            child: Center(
                              child: Icon(
                                Icons.local_cafe,
                                size: 24,
                                color: plainWhite,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: ashGray,
                          width: double.infinity,
                          child: Center(
                            child: Icon(
                              Icons.local_cafe,
                              size: 24,
                              color: plainWhite,
                            ),
                          ),
                        ),
                ),
              ),
              // Product details
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: product['name'],
                          fontSize: 14,
                          color: textBlack,
                          isBold: true,
                          fontFamily: 'Bold',
                          maxLines: 2,
                        ),
                        const SizedBox(height: 4),
                        TextWidget(
                          text:
                              '₱${(product['price'] as num?)?.toStringAsFixed(0) ?? '0'}',
                          fontSize: 14,
                          color: const Color.fromARGB(255, 255, 213, 0),
                          isBold: true,
                          fontFamily: 'Bold',
                        ),
                      ],
                    ),
                    ButtonWidget(
                      label: 'Add',
                      onPressed: (_storage.read('selectedBranch') == null ||
                              _storage.read('selectedType') == null)
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailsScreen(
                                    product: product,
                                    addToCart: widget.addToCart,
                                  ),
                                ),
                              );
                            },
                      color: bayanihanBlue,
                      textColor: plainWhite,
                      fontSize: 10,
                      height: 35,
                      radius: 6,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
