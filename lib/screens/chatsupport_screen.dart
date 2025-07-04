import 'package:flutter/material.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
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

  // Chat messages
  final List<Map<String, String>> _chatMessages = [
    {
      'sender': 'bot',
      'message':
          'Hi! I\'m Kaffi Bot. Ask me a question or select one of the common questions below to get help with your Kaffi Cafe experience.',
    },
  ];

  // Text controller for user input
  final TextEditingController _textController = TextEditingController();

  // Scroll controller for chat list
  final ScrollController _scrollController = ScrollController();

  // Handle FAQ selection or user input
  void _handleQuestion(String question) {
    final faq = _faqs.firstWhere(
      (faq) => faq['question'] == question,
      orElse: () => {
        'answer':
            'Sorry, I don\'t have an answer for that. Please try another question or contact live support.'
      },
    );
    setState(() {
      _chatMessages.add({'sender': 'user', 'message': question});
      _chatMessages.add({'sender': 'bot', 'message': faq['answer']!});
    });
    _textController.clear();
    // Scroll to bottom after adding new messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
      body: Column(
        children: [
          // Chat Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final message = _chatMessages[index];
                final isBot = message['sender'] == 'bot';
                return Align(
                  alignment:
                      isBot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    constraints: BoxConstraints(maxWidth: screenWidth * 0.75),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color:
                          isBot ? cloudWhite : bayanihanBlue.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: bayanihanBlue.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextWidget(
                      text: message['message']!,
                      fontSize: fontSize - 1,
                      color: isBot ? textBlack : plainWhite,
                      fontFamily: 'Regular',
                      maxLines: null,
                    ),
                  ),
                );
              },
            ),
          ),
          // Suggested Questions
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: 'Suggested Questions',
                  fontSize: fontSize,
                  color: textBlack,
                  isBold: true,
                  fontFamily: 'Bold',
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _faqs.map((faq) {
                    return ChoiceChip(
                      showCheckmark: false,
                      label: TextWidget(
                        text: faq['question']!,
                        fontSize: fontSize - 2,
                        color: textBlack,
                        fontFamily: 'Regular',
                      ),
                      selected: false,
                      onSelected: (selected) {
                        if (selected) {
                          _handleQuestion(faq['question']!);
                        }
                      },
                      backgroundColor: plainWhite,
                      selectedColor: bayanihanBlue.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: ashGray,
                          width: 1.0,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      elevation: 1,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // Input Area
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: plainWhite,
              border: Border(
                top: BorderSide(color: ashGray, width: 1.0),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type your question...',
                      hintStyle: TextStyle(
                        fontSize: fontSize - 2,
                        color: charcoalGray,
                        fontFamily: 'Regular',
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
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
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _handleQuestion(value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ButtonWidget(
                  label: 'Send',
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      _handleQuestion(_textController.text);
                    }
                  },
                  color: bayanihanBlue,
                  textColor: plainWhite,
                  fontSize: fontSize - 1,
                  height: 40,
                  radius: 12,
                  width: 80,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
