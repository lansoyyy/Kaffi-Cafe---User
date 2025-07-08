import 'package:flutter/material.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/divider_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';

class SeatReservationScreen extends StatefulWidget {
  const SeatReservationScreen({super.key});

  @override
  State<SeatReservationScreen> createState() => _SeatReservationScreenState();
}

class _SeatReservationScreenState extends State<SeatReservationScreen> {
  // Sample available seats and time slots
  final List<Map<String, dynamic>> _availableSeats = [
    {'seat': 'Table 1', 'capacity': 2, 'available': true},
    {'seat': 'Table 2', 'capacity': 4, 'available': true},
    {'seat': 'Table 3', 'capacity': 4, 'available': false},
    {'seat': 'Table 4', 'capacity': 6, 'available': true},
    {'seat': 'Booth 1', 'capacity': 4, 'available': true},
    {'seat': 'Booth 2', 'capacity': 6, 'available': false},
  ];

  final List<String> _timeSlots = [
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
  ];

  // State variables
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  String? _selectedSeat;
  int _numberOfGuests = 1;

  // Show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: bayanihanBlue,
              onPrimary: plainWhite,
              surface: plainWhite,
              onSurface: textBlack,
            ),
            dialogBackgroundColor: plainWhite,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null; // Reset time when date changes
        _selectedSeat = null; // Reset seat when date changes
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.036;
    final padding = screenWidth * 0.035;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: bayanihanBlue,
        title: TextWidget(
          text: 'Seat Reservation',
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
              TextWidget(
                text: 'Reserve Your Seat',
                fontSize: 22,
                color: textBlack,
                isBold: true,
                fontFamily: 'Bold',
                letterSpacing: 1.3,
              ),
              const SizedBox(height: 12),
              DividerWidget(),
              // Date Selection
              TextWidget(
                text: 'Select Date',
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
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWidget(
                        text:
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        fontSize: fontSize + 1,
                        color: textBlack,
                        isBold: true,
                        fontFamily: 'Bold',
                      ),
                      ButtonWidget(
                        label: 'Pick Date',
                        onPressed: () => _selectDate(context),
                        color: bayanihanBlue,
                        textColor: plainWhite,
                        fontSize: fontSize,
                        height: 40,
                        radius: 12,
                        width: 100,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              DividerWidget(),
              // Time Selection
              TextWidget(
                text: 'Select Time',
                fontSize: 20,
                color: textBlack,
                isBold: true,
                fontFamily: 'Bold',
                letterSpacing: 1.2,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _timeSlots.map((time) {
                  final isSelected = _selectedTime == time;
                  return ChoiceChip(
                    showCheckmark: false,
                    label: TextWidget(
                      text: time,
                      fontSize: fontSize,
                      color: isSelected ? plainWhite : textBlack,
                      isBold: isSelected,
                      fontFamily: 'Regular',
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedTime = time;
                          _selectedSeat = null; // Reset seat when time changes
                        });
                      }
                    },
                    backgroundColor: cloudWhite,
                    selectedColor: bayanihanBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? bayanihanBlue : ashGray,
                        width: 1.0,
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    elevation: isSelected ? 3 : 0,
                    pressElevation: 5,
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              DividerWidget(),
              // Seat Selection
              TextWidget(
                text: 'Select Seat',
                fontSize: 20,
                color: textBlack,
                isBold: true,
                fontFamily: 'Bold',
                letterSpacing: 1.2,
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: screenWidth * 0.45 / (screenWidth * 0.35),
                ),
                itemCount: _availableSeats.length,
                itemBuilder: (context, index) {
                  final seat = _availableSeats[index];
                  final isSelected = _selectedSeat == seat['seat'];
                  final isAvailable = seat['available'];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: InkWell(
                      onTap: isAvailable && _selectedTime != null
                          ? () {
                              setState(() {
                                _selectedSeat = seat['seat'];
                              });
                            }
                          : null,
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        padding: EdgeInsets.all(padding),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: isAvailable
                              ? plainWhite
                              : ashGray.withOpacity(0.3),
                          border: Border.all(
                            color: isSelected
                                ? bayanihanBlue
                                : isAvailable
                                    ? palmGreen
                                    : festiveRed,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              text: seat['seat'],
                              fontSize: fontSize + 1,
                              color: isAvailable ? textBlack : charcoalGray,
                              isBold: true,
                              fontFamily: 'Bold',
                            ),
                            const SizedBox(height: 6),
                            TextWidget(
                              text: 'Capacity: ${seat['capacity']} guests',
                              fontSize: fontSize - 1,
                              color: isAvailable
                                  ? charcoalGray
                                  : charcoalGray.withOpacity(0.6),
                              fontFamily: 'Regular',
                            ),
                            const SizedBox(height: 6),
                            TextWidget(
                              text: isAvailable ? 'Available' : 'Occupied',
                              fontSize: fontSize - 1,
                              color: isAvailable ? bayanihanBlue : charcoalGray,
                              isBold: true,
                              fontFamily: 'Bold',
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              DividerWidget(),
              // Number of Guests
              TextWidget(
                text: 'Number of Guests',
                fontSize: 20,
                color: textBlack,
                isBold: true,
                fontFamily: 'Bold',
                letterSpacing: 1.2,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ButtonWidget(
                    label: '-',
                    onPressed: () {
                      setState(() {
                        if (_numberOfGuests > 1) _numberOfGuests--;
                      });
                    },
                    color: ashGray,
                    textColor: textBlack,
                    fontSize: fontSize,
                    height: 36,
                    width: 50,
                    radius: 10,
                  ),
                  const SizedBox(width: 12),
                  TextWidget(
                    text:
                        '$_numberOfGuests Guest${_numberOfGuests > 1 ? 's' : ''}',
                    fontSize: fontSize + 1,
                    color: textBlack,
                    fontFamily: 'Regular',
                  ),
                  const SizedBox(width: 12),
                  ButtonWidget(
                    label: '+',
                    onPressed: () {
                      setState(() {
                        _numberOfGuests++;
                      });
                    },
                    color: bayanihanBlue,
                    textColor: plainWhite,
                    fontSize: fontSize,
                    height: 36,
                    width: 50,
                    radius: 10,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Confirm Reservation Button
              Center(
                child: ButtonWidget(
                  label: 'Confirm Reservation',
                  onPressed: _selectedTime != null && _selectedSeat != null
                      ? () {
                          // Handle reservation confirmation
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: TextWidget(
                                text:
                                    'Reservation confirmed for $_selectedSeat at $_selectedTime on ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                fontSize: fontSize - 1,
                                color: plainWhite,
                                fontFamily: 'Regular',
                              ),
                              backgroundColor: bayanihanBlue,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      : () {},
                  color: _selectedTime != null && _selectedSeat != null
                      ? bayanihanBlue
                      : ashGray,
                  textColor: plainWhite,
                  fontSize: fontSize + 2,
                  height: 50,
                  radius: 12,
                  width: screenWidth * 0.6,
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
