import 'package:flutter/material.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/divider_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final List<String> _categories = ['Coffee', 'Drinks', 'Foods'];
  String _selectedCategory = 'Coffee';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final cardWidth = screenWidth * 0.38;
    final cardHeight = screenWidth * 0.5;
    final gradientHeight = cardHeight * 0.65;
    final fontSize = screenWidth * 0.035;
    final padding = screenWidth * 0.025;
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          DividerWidget(),
          TextWidget(
            text: 'Our Menu',
            fontSize: 18,
            color: textBlack,
            isBold: true,
            fontFamily: 'Bold',
          ),
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
                    fontSize: 12,
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
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? bayanihanBlue : ashGray,
                      width: 1,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: isSelected ? 2 : 0,
                  pressElevation: 4,
                ),
              );
            }).toList(),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemBuilder: (context, index) {
                return Card(
                  elevation: 1,
                  child: Container(
                    height: cardHeight,
                    width: cardWidth,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: NetworkImage(
                            'https://www.nespresso.ph/media/catalog/category/recipes/morning_coffee/nespresso-recipes-Espresso-Macchiato-by-Nespresso_1.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        children: [
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                          text: 'Espresso',
                                          fontSize: 16,
                                          fontFamily: 'Medium',
                                          color: Colors.white,
                                          maxLines: 1,
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: TextWidget(
                                            text:
                                                'Minim ipsum irure consectetur non sint ullamco.',
                                            fontSize: 11,
                                            fontFamily: 'Regular',
                                            color: Colors.grey,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextWidget(
                                      text: 'P69',
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
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
