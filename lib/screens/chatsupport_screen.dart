import 'package:flutter/material.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  // Search controller
  final TextEditingController _searchController = TextEditingController();

  // FAQs data - Combined from both sources
  final List<Map<String, String>> _allFaqs = [
    // Store Information
    {
      'question': 'What are your best seller drinks?',
      'answer':
          'Biscoff Latte and Spanish Latte are the top favorites at Kaffi Café!'
    },
    {
      'question': 'Do you have free wifi?',
      'answer': 'Yes, free Wi-Fi is available for all dine-in customers.'
    },
    {
      'question': 'What is the Password of WIFI?',
      'answer': 'It changes every week you can find it printed on your receipt'
    },
    {
      'question': 'How long can I access WIFI?',
      'answer': 'There\'s no time limit for dine-in customers.'
    },
    {
      'question': 'What are your Operating Hours?',
      'answer': 'The café opens at 10:00 AM and closes at 2:00 AM.'
    },
    {
      'question': 'Where are your branches located?',
      'answer':
          'Our store is located at P.Noval in front of UST, and 1218 Delos Reyes St. corner Eloisa St. in MANILA'
    },
    // Order & Payment
    {
      'question': 'How do I place an order?',
      'answer':
          'Browse the menu, select your food or drink, add to cart, and proceed to checkout to confirm your order.'
    },
    {
      'question': 'Can I reserve a table in advance?',
      'answer':
          'Yes! Go to the "Dine-in" section, select your preferred table and time, and confirm your booking.'
    },
    {
      'question': 'How do I pay for my order?',
      'answer':
          'You can pay securely through PayMongo Sandbox (demo payment). In the future, this will support real payment options.'
    },
    {
      'question': 'Can I change or cancel my order after placing it?',
      'answer':
          'Once confirmed, orders can no longer be changed or canceled through the app. You may contact the staff directly for special requests.'
    },
    {
      'question': 'Do you offer delivery?',
      'answer':
          'Currently, delivery is not available, but you can order for pickup or dine-in.'
    },
    {
      'question': 'Can I order in advance before arriving?',
      'answer': 'Yes! You can order ahead and just pick it up when you arrive.'
    },
    {
      'question': 'Do you offer group or bulk orders?',
      'answer':
          'Yes, you can place multiple items in one order for group purchases.'
    },
    // Rewards & Points
    {
      'question': 'How does the loyalty and rewards system work?',
      'answer':
          'Every purchase earns you points. You can exchange points for vouchers or discounts on your next order.'
    },
    {
      'question': 'How do I earn points?',
      'answer': 'Earn 10% of your total order value in points at Kaffi Cafe.'
    },
    {
      'question': 'How can I redeem vouchers?',
      'answer': 'Visit the Rewards tab to redeem vouchers using your points.'
    },
    // App Features
    {
      'question': 'How do I get personalized drink recommendations?',
      'answer':
          'The app uses a KNN (K-Nearest Neighbors) algorithm that suggests drinks or food items based on your previous orders or popular items.'
    },
    {
      'question': 'How do I know if my order is confirmed?',
      'answer':
          'You will receive in-app notification and the status of your order will display "Confirmed"'
    },
    {
      'question': 'Is my data safe in the app?',
      'answer':
          'Yes. The system uses Firebase Authentication and Firestore for secure storage and encrypted transactions.'
    },
    {
      'question': 'Why can\'t I use real payments yet?',
      'answer':
          'The app currently uses the PayMongo Sandbox for testing, as real payment setup requires verified business documents.'
    },
    // Policies
    {
      'question': 'What is the return policy?',
      'answer': 'Returns are accepted within 24 hours with a valid receipt.'
    },
  ];

  // Filtered FAQs based on search
  List<Map<String, String>> _filteredFaqs = [];

  @override
  void initState() {
    super.initState();
    _filteredFaqs = _allFaqs;
    _searchController.addListener(_filterFaqs);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterFaqs);
    _searchController.dispose();
    super.dispose();
  }

  void _filterFaqs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredFaqs = _allFaqs;
      } else {
        _filteredFaqs = _allFaqs.where((faq) {
          return faq['question']!.toLowerCase().contains(query) ||
              faq['answer']!.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: bayanihanBlue,
        title: TextWidget(
          text: 'FAQ',
          fontSize: 24,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search FAQs...',
                hintStyle: TextStyle(
                  fontSize: fontSize - 2,
                  color: charcoalGray,
                  fontFamily: 'Regular',
                ),
                prefixIcon: const Icon(Icons.search, color: bayanihanBlue),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ashGray,
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ashGray,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
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
            ),
          ),
          // FAQ List
          Expanded(
            child: _filteredFaqs.isEmpty
                ? Center(
                    child: TextWidget(
                      text: 'No FAQs found matching your search.',
                      fontSize: fontSize,
                      color: textBlack,
                      fontFamily: 'Regular',
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _filteredFaqs.length,
                    itemBuilder: (context, index) {
                      final faq = _filteredFaqs[index];
                      return ExpansionTile(
                        title: TextWidget(
                          text: faq['question']!,
                          fontSize: fontSize - 2,
                          color: textBlack,
                          fontFamily: 'Bold',
                          maxLines: 2,
                        ),
                        tilePadding: const EdgeInsets.symmetric(horizontal: 0),
                        expandedAlignment: Alignment.centerLeft,
                        iconColor: bayanihanBlue,
                        collapsedIconColor: bayanihanBlue,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextWidget(
                              text: faq['answer']!,
                              fontSize: fontSize - 3,
                              color: textBlack,
                              fontFamily: 'Regular',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Keep the old class name for backward compatibility
class ChatFaqSupportScreen extends FaqScreen {
  const ChatFaqSupportScreen({super.key});
}
