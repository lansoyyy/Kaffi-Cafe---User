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
  // Ensure auto-scroll after every build if new messages are present
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Sample FAQs with multiple responses
  final List<Map<String, String>> _faqs = [
    // Greetings
    {'question': 'Hello', 'answer': 'Hello! How can I help you today?'},
    {
      'question': 'Hi',
      'answer':
          'Hi there! How can I assist you with your Kaffi Cafe experience?'
    },
    {
      'question': 'Good morning',
      'answer': 'Good morning! What can I do for you today?'
    },
    {
      'question': 'Good afternoon',
      'answer': 'Good afternoon! How can I help you?'
    },
    {
      'question': 'Good evening',
      'answer': 'Good evening! Need help with anything at Kaffi Cafe?'
    },
    // Existing FAQs
    {
      'question': 'How do I earn points?',
      'answer':
          'You earn 10% of your total order value in points at Kaffi Cafe. Points are automatically added to your account after each purchase.',
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
    // More app-related FAQs
    {
      'question': 'How do I reset my password?',
      'answer':
          'Go to the Account tab, tap on Settings, and select "Reset Password." Follow the instructions sent to your email to reset your password.'
    },
    {
      'question': 'How do I update my profile?',
      'answer':
          'Navigate to the Account tab, tap on your profile, and select "Edit Profile" to update your information.'
    },
    {
      'question': 'How do I contact customer support?',
      'answer':
          'You can contact customer support through the app by going to the Support tab and selecting "Contact Us." You can also email us at support@kafficafe.com.'
    },
    {
      'question': 'What payment methods are accepted?',
      'answer':
          'We accept cash, credit/debit cards, GCash, and other major e-wallets for in-store and online orders.'
    },
    {
      'question': 'Can I schedule an order in advance?',
      'answer':
          'Yes, you can schedule your order for a later time in the Order tab before checking out.'
    },
    {
      'question': 'Is there a minimum order for delivery?',
      'answer':
          'Yes, the minimum order for delivery is ₱200. Delivery fees may apply depending on your location.'
    },
    {
      'question': 'How do I use a promo code?',
      'answer':
          'Enter your promo code at checkout in the Order tab. The discount will be applied to your total if the code is valid.'
    },
    {
      'question': 'Can I order for pickup?',
      'answer':
          'Yes, you can select the pickup option in the Order tab and choose your preferred store location.'
    },
    {
      'question': 'How do I check my points balance?',
      'answer':
          'Your current points balance is displayed at the top of the Rewards tab.'
    },
    {
      'question': 'Do points expire?',
      'answer':
          'Yes, points expire 12 months after they are earned. Check the Rewards tab for your points history.'
    },
    {
      'question': 'Can I transfer points to another account?',
      'answer':
          'Currently, points are non-transferable and can only be used by the account holder.'
    },
    {
      'question': 'How do I get notified about new promos?',
      'answer':
          'Enable push notifications in the app settings to receive updates about new promos and offers.'
    },
    {
      'question': 'Where can I find the menu?',
      'answer': 'You can view the full menu in the Order tab or on our website.'
    },
    {
      'question': 'Can I cancel my order?',
      'answer':
          'Orders can be cancelled within 5 minutes of placing them by contacting support or using the Cancel button in Order History.'
    },
    {
      'question': 'How do I leave feedback?',
      'answer':
          'After your order is completed, you can leave feedback in the Order History section or in the Support tab.'
    },
    {
      'question': 'Is there a loyalty program?',
      'answer':
          'Yes! Earn points on every purchase and redeem them for rewards in the Rewards tab.'
    },
    {
      'question': 'How do I refer a friend?',
      'answer':
          'Go to the Rewards tab and tap on "Refer a Friend" to share your referral code.'
    },
    {
      'question': 'Can I order cakes or pastries?',
      'answer':
          'Yes, cakes and pastries are available in the Order tab. Selection may vary by location.'
    },
    {
      'question': 'How do I change the app language?',
      'answer':
          'Go to Settings in the Account tab and select your preferred language.'
    },
    {
      'question': 'Is there a kids menu?',
      'answer':
          'Yes, we offer a kids menu. Check the Order tab for available items.'
    },
    {
      'question': 'Can I request a receipt?',
      'answer':
          'Receipts are available in your Order History. You can also request a printed receipt in-store.'
    },
    {
      'question': 'How do I join the Kaffi Cafe team?',
      'answer':
          'Visit our Careers page on the website or inquire in-store for job openings.'
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
    // Try to find the best matching FAQ (case-insensitive, partial match)
    final lowerInput = question.trim().toLowerCase();
    Map<String, String>? matchedFaq;
    // 1. Try exact match (case-insensitive)
    matchedFaq = _faqs.firstWhere(
      (faq) => faq['question']!.toLowerCase() == lowerInput,
      orElse: () => {},
    );
    // 2. If not found, try partial match (FAQ contains user input)
    if (matchedFaq.isEmpty) {
      matchedFaq = _faqs.firstWhere(
        (faq) => faq['question']!.toLowerCase().contains(lowerInput),
        orElse: () => {},
      );
    }
    // 3. If not found, try partial match (user input contains FAQ)
    if (matchedFaq.isEmpty) {
      matchedFaq = _faqs.firstWhere(
        (faq) => lowerInput.contains(faq['question']!.toLowerCase()),
        orElse: () => {},
      );
    }
    // 4. If still not found, try keyword match (any word in FAQ question is in user input)
    if (matchedFaq.isEmpty) {
      matchedFaq = _faqs.firstWhere(
        (faq) {
          final faqWords = faq['question']!.toLowerCase().split(RegExp(r'\W+'));
          return faqWords
              .any((word) => word.isNotEmpty && lowerInput.contains(word));
        },
        orElse: () => {},
      );
    }
    final answer = matchedFaq.isNotEmpty
        ? matchedFaq['answer']!
        : 'Sorry, I don\'t have an answer for that. Please try another question or contact live support.';
    setState(() {
      _chatMessages.add({'sender': 'user', 'message': question});
      _chatMessages.add({'sender': 'bot', 'message': answer});
    });
    _textController.clear();
    // Ensure scroll after new message
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    @override
    void didUpdateWidget(ChatFaqSupportScreen oldWidget) {
      super.didUpdateWidget(oldWidget);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Auto-scroll after build if new messages
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
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
                      maxLines: 10,
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
