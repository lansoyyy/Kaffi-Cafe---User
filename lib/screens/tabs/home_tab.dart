import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kaffi_cafe/screens/reservation_screen.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/divider_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';
import 'package:kaffi_cafe/widgets/touchable_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeTab extends StatefulWidget {
  final VoidCallback? onBranchSelected;
  final void Function(String type, String branch)? onTypeAndBranchSelected;
  final void Function(Map<String, dynamic> item, int quantity)? addToCart;
  const HomeTab(
      {Key? key,
      this.onBranchSelected,
      this.onTypeAndBranchSelected,
      this.addToCart})
      : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final box = GetStorage();
  // No static recent orders, use Firestore instead

  Widget _buildRecentOrderSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.034;
    // TODO: Replace with actual userId from authentication

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recent orders from Firestore filtered by userId
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .where('userId', isEqualTo: box.read('user')?['email'])
              .orderBy('timestamp', descending: true)
              .limit(5)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final orders = snapshot.data!.docs;
            if (orders.isEmpty) {
              return Center(
                child: TextWidget(
                  text: 'No recent orders found.',
                  fontSize: fontSize,
                  color: textBlack,
                  fontFamily: 'Regular',
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              separatorBuilder: (context, index) => DividerWidget(),
              itemBuilder: (context, index) {
                final orderData = orders[index].data() as Map<String, dynamic>;
                // Get first item in items array for display
                final items = orderData['items'] as List<dynamic>?;
                final firstItem = items != null && items.isNotEmpty
                    ? items[0] as Map<String, dynamic>
                    : null;
                final name =
                    firstItem != null ? firstItem['name'] ?? 'Order' : 'Order';
                final price = firstItem != null
                    ? firstItem['price'] ?? orderData['total'] ?? 0
                    : orderData['total'] ?? 0;
                final status = orderData['status'] ?? 'Unknown';
                // Format Firestore timestamp
                String formattedDate = '';
                final rawTimestamp = orderData['timestamp'];
                if (rawTimestamp != null) {
                  DateTime? dateTime;
                  if (rawTimestamp is Timestamp) {
                    dateTime = rawTimestamp.toDate();
                  } else if (rawTimestamp is String) {
                    // Try to parse string
                    dateTime = DateTime.tryParse(rawTimestamp);
                  }
                  if (dateTime != null) {
                    formattedDate =
                        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
                        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
                  }
                }
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Icon(Icons.receipt_long,
                            color: bayanihanBlue, size: 32),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                text: name,
                                fontSize: fontSize + 2,
                                color: textBlack,
                                fontFamily: 'Bold',
                                maxLines: 1,
                              ),
                              TextWidget(
                                text: formattedDate.isNotEmpty
                                    ? 'Date: $formattedDate'
                                    : 'Date: -',
                                fontSize: fontSize - 1,
                                color: charcoalGray,
                                fontFamily: 'Regular',
                                maxLines: 1,
                              ),
                              TextWidget(
                                text: 'Status: $status',
                                fontSize: fontSize - 1,
                                color: status == 'Delivered'
                                    ? Colors.green
                                    : status == 'Preparing'
                                        ? Colors.orange
                                        : Colors.red,
                                fontFamily: 'Regular',
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        Column(
                          children: [
                            TextWidget(
                              text: '₱$price',
                              fontSize: fontSize + 2,
                              color: bayanihanBlue,
                              fontFamily: 'Bold',
                              maxLines: 1,
                            ),
                            SizedBox(height: 6),
                            ElevatedButton.icon(
                              icon:
                                  Icon(Icons.shopping_cart_outlined, size: 18),
                              label: Text('Reorder',
                                  style: TextStyle(fontSize: fontSize - 2)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: bayanihanBlue,
                                foregroundColor: Colors.white,
                                minimumSize: Size(90, 32),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                final items =
                                    orderData['items'] as List<dynamic>?;
                                if (items != null &&
                                    items.isNotEmpty &&
                                    widget.addToCart != null) {
                                  for (var item in items) {
                                    if (item is Map<String, dynamic>) {
                                      final itemName = item['name'] ?? 'Order';
                                      final itemPrice = item['price'] ?? 0;
                                      final itemQuantity =
                                          item['quantity'] ?? 1;
                                      widget.addToCart!(
                                        {
                                          'name': itemName,
                                          'price': itemPrice,
                                        },
                                        itemQuantity is int ? itemQuantity : 1,
                                      );
                                    }
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Order items added to cart!'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('No items to reorder.'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

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
              onPressed: () {
                if (widget.addToCart != null) {
                  widget.addToCart!(item, quantity);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item['name']} added to cart'),
                  ),
                );
              },
              child: Text('Add to Cart'),
            ),
          ],
        );
      },
    );
  }

  // Add state to track selected type
  String? _pendingType;

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
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .orderBy('timestamp', descending: true)
                    .limit(5)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final products = snapshot.data!.docs;
                  if (products.isEmpty) {
                    return Center(child: Text('No products found.'));
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final data =
                          products[index].data() as Map<String, dynamic>;
                      return TouchableWidget(
                        onTap: () {
                          _showAddToCartDialog(data);
                        },
                        child: Card(
                          elevation: 1,
                          child: Container(
                            height: cardHeight,
                            width: cardWidth,
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Stack(
                                children: [
                                  // Category icon background
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: bayanihanBlue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(15),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                              data['image'],
                                            ),
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                  ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                  text:
                                                      data['name'] ?? 'Product',
                                                  fontSize: 16,
                                                  fontFamily: 'Medium',
                                                  color: Colors.white,
                                                  maxLines: 1,
                                                ),
                                                SizedBox(
                                                  width: 100,
                                                  child: TextWidget(
                                                    text: data['description'] ??
                                                        'Delicious item',
                                                    fontSize: 11,
                                                    fontFamily: 'Regular',
                                                    color: Colors.white,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            TextWidget(
                                              text:
                                                  '₱${(data['price'] as num?)?.toStringAsFixed(0) ?? '0'}',
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
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            DividerWidget(),

            // 💙 YOUR RECENT ORDER
            TextWidget(
              text: 'YOUR RECENT ORDER',
              fontSize: 22,
              color: textBlack,
              isBold: true,
              fontFamily: 'Bold',
            ),
            const SizedBox(height: 10),
            _buildRecentOrderSection(),
            const SizedBox(height: 16),
            DividerWidget(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                                    setState(() {
                                      _pendingType = 'Dine in';
                                    });
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
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
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
                TouchableWidget(
                  onTap: () {
                    setState(() {
                      _pendingType = 'Pickup';
                    });
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
                      Navigator.pop(context);
                      if (widget.onTypeAndBranchSelected != null &&
                          _pendingType != null) {
                        widget.onTypeAndBranchSelected!(
                            _pendingType!, branch['name']!);
                        _pendingType = null;
                      } else if (widget.onBranchSelected != null) {
                        widget.onBranchSelected!();
                      }
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
