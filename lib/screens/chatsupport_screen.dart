import 'package:flutter/material.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/divider_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';

class ChatFaqSupportScreen extends StatefulWidget {
  const ChatFaqSupportScreen({super.key});

  @override
  State<ChatFaqSupportScreen> createState() => _ChatFaqSupportScreenState();
}

class _ChatFaqSupportScreenState extends State<ChatFaqSupportScreen> {
  // Sample FAQs with multiple responses
  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I earn points?',
      'answer':
          'You earn 1 point for every ₱10 spent on orders at Kaffi Cafe. Points are automatically added to your account after each purchase.',
    },
    {
      'question': 'How can I redeem vouchers?',
      'answer':
          'Visit the Rewards tab in the app, select a voucher, and click "Redeem" if you have enough points. The voucher will be added to your account for use at checkout.',
    },
    {
      'question': 'What is the return policy?',
      'answer':
          'Returns are accepted within 24 hours of purchase with a valid receipt. Please contact support or visit a Kaffi Cafe location for assistance.',
    },
    {
      'question': 'Can I customize my order?',
      'answer':
          'Yes, you can customize your order in the Order tab. Choose coffee shots, sweetness level, ice level, and more to tailor your drink or food item.',
    },
    {
      'question': 'How do I track my order?',
      'answer':
          'You can view your order history and status in the Account tab under "Order History." Each order shows the item, date, price, and status.',
    },
    {
      'question': 'Are there any membership benefits?',
      'answer':
          'Kaffi Cafe members earn points on every purchase, access exclusive vouchers, and receive special offers. Check the Rewards tab for available benefits.',
    },
    {
      'question': 'What are the store hours?',
      'answer':
          'Kaffi Cafe is open from 7 AM to 9 PM daily. Hours may vary by location, so please check with your local store for exact times.',
    },
    {
      'question': 'Can I order for delivery?',
      'answer':
          'Yes, delivery is available through the app. Place your order in the Order tab, and select the delivery option at checkout.',
    },
  ];

  // Track selected FAQ
  String? _selectedQuestion;
  String? _selectedAnswer;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.036;
    final padding = screenWidth * 0.035;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: bayanihanBlue,
        title: TextWidget(
          text: 'Chatbot',
          fontSize: 24,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header

              DividerWidget(),
              // Chatbot Introduction
              TextWidget(
                text: 'Ask Kaffi Bot',
                fontSize: 20,
                color: textBlack,
                isBold: true,
                fontFamily: 'Bold',
                letterSpacing: 1.2,
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: plainWhite,
                    boxShadow: [
                      BoxShadow(
                        color: bayanihanBlue.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text:
                            'Hi! I\'m Kaffi Bot. Select a question below to get help with your Kaffi Cafe experience.',
                        fontSize: fontSize,
                        color: charcoalGray,
                        fontFamily: 'Regular',
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              DividerWidget(),
              // FAQ Questions
              TextWidget(
                text: 'Common Questions',
                fontSize: 20,
                color: textBlack,
                isBold: true,
                fontFamily: 'Bold',
                letterSpacing: 1.2,
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _faqs.length,
                itemBuilder: (context, index) {
                  final faq = _faqs[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedQuestion = faq['question'];
                          _selectedAnswer = faq['answer'];
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: plainWhite,
                          border: Border.all(
                            color: _selectedQuestion == faq['question']
                                ? bayanihanBlue
                                : ashGray,
                            width: 1.0,
                          ),
                        ),
                        child: TextWidget(
                          text: faq['question']!,
                          fontSize: fontSize,
                          color: _selectedQuestion == faq['question']
                              ? bayanihanBlue
                              : textBlack,
                          isBold: true,
                          fontFamily: 'Bold',
                          maxLines: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              DividerWidget(),
              // Chatbot Response
              TextWidget(
                text: 'Kaffi Bot Response',
                fontSize: 20,
                color: textBlack,
                isBold: true,
                fontFamily: 'Bold',
                letterSpacing: 1.2,
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: plainWhite,
                    boxShadow: [
                      BoxShadow(
                        color: bayanihanBlue.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: _selectedQuestion ??
                            'Select a question above to see the answer.',
                        fontSize: fontSize + 1,
                        color: textBlack,
                        isBold: true,
                        fontFamily: 'Bold',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      TextWidget(
                        text: _selectedAnswer ??
                            'Kaffi Bot will respond here once you select a question.',
                        fontSize: fontSize,
                        color: charcoalGray,
                        fontFamily: 'Regular',
                        maxLines: 5,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
