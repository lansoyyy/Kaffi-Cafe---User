import 'package:flutter/material.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/divider_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class SeatReservationScreen extends StatefulWidget {
  const SeatReservationScreen({super.key});

  @override
  State<SeatReservationScreen> createState() => _SeatReservationScreenState();
}

class _SeatReservationScreenState extends State<SeatReservationScreen> {
  final GetStorage _storage = GetStorage();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Tables configuration (3 tables with 2 seats, 2 tables with 4 seats)
  final List<Map<String, dynamic>> _tables = [
    {'id': 'table1', 'name': 'Table 1', 'capacity': 2},
    {'id': 'table2', 'name': 'Table 2', 'capacity': 2},
    {'id': 'table3', 'name': 'Table 3', 'capacity': 2},
    {'id': 'table4', 'name': 'Table 4', 'capacity': 4},
    {'id': 'table5', 'name': 'Table 5', 'capacity': 4},
  ];

  // State variables
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  String? _selectedTableId;
  int _numberOfGuests = 1;
  Map<String, bool> _tableAvailability = {};
  List<String> _availableTimeSlots = [];
  bool _isLoading = true;

  // Initialize the reservation screen
  @override
  void initState() {
    super.initState();
    _initializeReservation();
  }

  // Initialize reservation data
  Future<void> _initializeReservation() async {
    setState(() {
      _isLoading = true;
    });

    // Initialize table availability
    for (var table in _tables) {
      _tableAvailability[table['id']] = true;
    }

    // Generate available time slots based on operating hours
    _generateTimeSlots();

    setState(() {
      _isLoading = false;
    });
  }

  // Generate available time slots based on operating hours (7:00 AM - 11:00 PM)
  void _generateTimeSlots() {
    final now = DateTime.now();
    final List<String> slots = [];

    // Operating hours: 7:00 AM to 11:00 PM
    // Last slot: 10:00-10:59 PM
    for (int hour = 7; hour <= 22; hour++) {
      // Skip past hours for today
      if (_selectedDate.day == now.day &&
          _selectedDate.month == now.month &&
          _selectedDate.year == now.year &&
          hour <= now.hour) {
        continue;
      }

      // Format hour for 12-hour clock
      String period = hour < 12 ? 'AM' : 'PM';
      int displayHour = hour <= 12 ? hour : hour - 12;
      if (displayHour == 0) displayHour = 12;

      String timeSlot = '$displayHour:00 $period';
      slots.add(timeSlot);
    }

    setState(() {
      _availableTimeSlots = slots;
    });
  }

  // Check if a table is available for a specific date and time
  Future<bool> _checkTableAvailability(
      String tableId, DateTime date, String time) async {
    try {
      // Format date for Firestore query
      String formattedDate =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      // Query reservations for the same date, time, and table
      final QuerySnapshot snapshot = await _firestore
          .collection('reservations')
          .where('tableId', isEqualTo: tableId)
          .where('date', isEqualTo: formattedDate)
          .where('time', isEqualTo: time)
          .where('status', whereIn: ['confirmed', 'checked_in']).get();

      // If no reservations found, table is available
      return snapshot.docs.isEmpty;
    } catch (e) {
      print('Error checking table availability: $e');
      return false;
    }
  }

  // Update table availability based on selected date and time
  Future<void> _updateTableAvailability() async {
    if (_selectedTime == null) return;

    setState(() {
      _isLoading = true;
    });

    // Check availability for each table
    for (var table in _tables) {
      bool isAvailable = await _checkTableAvailability(
        table['id'],
        _selectedDate,
        _selectedTime!,
      );

      setState(() {
        _tableAvailability[table['id']] = isAvailable;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Create a reservation in Firestore
  Future<void> _createReservation() async {
    if (_selectedTableId == null || _selectedTime == null) return;

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Get selected table details
      final selectedTable =
          _tables.firstWhere((table) => table['id'] == _selectedTableId);

      // Format date for Firestore
      String formattedDate =
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

      // Create reservation document
      await _firestore.collection('reservations').add({
        'userId': user.uid,
        'userEmail': user.email,
        'tableId': _selectedTableId,
        'tableName': selectedTable['name'],
        'tableCapacity': selectedTable['capacity'],
        'date': formattedDate,
        'time': _selectedTime,
        'guests': _numberOfGuests,
        'status': 'confirmed',
        'createdAt': FieldValue.serverTimestamp(),
        'branch': _storage.read('selectedBranch') ?? 'Kaffi Cafe - Eloisa St',
      });

      // Save reservation data locally
      _storage.write('reservationTableId', _selectedTableId);
      _storage.write('reservationTableName', selectedTable['name']);
      _storage.write('reservationTime', _selectedTime);
      _storage.write('reservationDate',
          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}');
      _storage.write('reservationGuests', _numberOfGuests);
      _storage.write('selectedType', 'Dine in');

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            text:
                'Reservation confirmed for ${selectedTable['name']} at $_selectedTime on ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            fontSize: 16,
            color: plainWhite,
            fontFamily: 'Regular',
          ),
          backgroundColor: bayanihanBlue,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate back to home screen with result to switch to menu tab
      Navigator.pop(context, 'goToMenu');
    } catch (e) {
      print('Error creating reservation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            text: 'Failed to create reservation. Please try again.',
            fontSize: 16,
            color: plainWhite,
            fontFamily: 'Regular',
          ),
          backgroundColor: festiveRed,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Cancel a reservation
  Future<void> _cancelReservation(String reservationId) async {
    try {
      await _firestore.collection('reservations').doc(reservationId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            text: 'Reservation cancelled successfully',
            fontSize: 16,
            color: plainWhite,
            fontFamily: 'Regular',
          ),
          backgroundColor: bayanihanBlue,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Error cancelling reservation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            text: 'Failed to cancel reservation. Please try again.',
            fontSize: 16,
            color: plainWhite,
            fontFamily: 'Regular',
          ),
          backgroundColor: festiveRed,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.036;
    final padding = screenWidth * 0.035;

    // Update table availability when date or time changes
    if (_selectedDate != null && _selectedTime != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateTableAvailability();
      });
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: bayanihanBlue,
        title: TextWidget(
          text: 'Table Reservation',
          fontSize: 24,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    TextWidget(
                      text: 'Reserve Your Table',
                      fontSize: 22,
                      color: textBlack,
                      isBold: true,
                      fontFamily: 'Bold',
                      letterSpacing: 1.3,
                    ),
                    const SizedBox(height: 12),
                    DividerWidget(),

                    // Operating hours info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: bayanihanBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: 'Operating Hours: 7:00 AM - 11:00 PM',
                            fontSize: 14,
                            color: textBlack,
                            fontFamily: 'Bold',
                          ),
                          const SizedBox(height: 4),
                          TextWidget(
                            text: 'Last reservation slot: 10:00 PM',
                            fontSize: 14,
                            color: textBlack,
                            fontFamily: 'Regular',
                          ),
                          const SizedBox(height: 4),
                          TextWidget(
                            text: 'Each reservation is limited to 1 hour',
                            fontSize: 14,
                            color: textBlack,
                            fontFamily: 'Regular',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Table Selection
                    TextWidget(
                      text: 'Select Table',
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
                        childAspectRatio:
                            screenWidth * 0.4 / (screenWidth * 0.35),
                      ),
                      itemCount: _tables.length,
                      itemBuilder: (context, index) {
                        final table = _tables[index];
                        final isSelected = _selectedTableId == table['id'];
                        final isAvailable =
                            _tableAvailability[table['id']] ?? true;
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: InkWell(
                            onTap: isAvailable
                                ? () {
                                    setState(() {
                                      _selectedTableId = table['id'];
                                      // Reset time when table changes
                                      _selectedTime = null;
                                    });
                                  }
                                : null,
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              padding: EdgeInsets.all(padding),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: isSelected
                                    ? bayanihanBlue.withOpacity(0.1)
                                    : isAvailable
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
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextWidget(
                                        text: table['name'],
                                        fontSize: fontSize + 1,
                                        color: isSelected
                                            ? bayanihanBlue
                                            : isAvailable
                                                ? textBlack
                                                : charcoalGray,
                                        isBold: true,
                                        fontFamily: 'Bold',
                                      ),
                                      Icon(
                                        isSelected
                                            ? Icons.check_circle
                                            : isAvailable
                                                ? Icons.event_available
                                                : Icons.event_busy,
                                        color: isSelected
                                            ? bayanihanBlue
                                            : isAvailable
                                                ? palmGreen
                                                : festiveRed,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  // Table and chair icons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Table icon
                                      Icon(
                                        Icons.table_restaurant,
                                        size: 30,
                                        color: isSelected
                                            ? bayanihanBlue
                                            : isAvailable
                                                ? textBlack
                                                : charcoalGray,
                                      ),
                                      // Chair icons based on capacity
                                      if (table['capacity'] == 2) ...[
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.chair,
                                          size: 20,
                                          color: isSelected
                                              ? bayanihanBlue
                                              : isAvailable
                                                  ? textBlack
                                                  : charcoalGray,
                                        ),
                                        Icon(
                                          Icons.chair,
                                          size: 20,
                                          color: isSelected
                                              ? bayanihanBlue
                                              : isAvailable
                                                  ? textBlack
                                                  : charcoalGray,
                                        ),
                                      ] else if (table['capacity'] == 4) ...[
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.chair,
                                          size: 20,
                                          color: isSelected
                                              ? bayanihanBlue
                                              : isAvailable
                                                  ? textBlack
                                                  : charcoalGray,
                                        ),
                                        Icon(
                                          Icons.chair,
                                          size: 20,
                                          color: isSelected
                                              ? bayanihanBlue
                                              : isAvailable
                                                  ? textBlack
                                                  : charcoalGray,
                                        ),
                                        Icon(
                                          Icons.chair,
                                          size: 20,
                                          color: isSelected
                                              ? bayanihanBlue
                                              : isAvailable
                                                  ? textBlack
                                                  : charcoalGray,
                                        ),
                                        Icon(
                                          Icons.chair,
                                          size: 20,
                                          color: isSelected
                                              ? bayanihanBlue
                                              : isAvailable
                                                  ? textBlack
                                                  : charcoalGray,
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  TextWidget(
                                    text:
                                        'Table with ${table['capacity']} chairs',
                                    fontSize: fontSize - 1,
                                    color: isAvailable
                                        ? charcoalGray
                                        : charcoalGray.withOpacity(0.6),
                                    fontFamily: 'Regular',
                                  ),
                                  const SizedBox(height: 6),
                                  TextWidget(
                                    text:
                                        isAvailable ? 'Available' : 'Occupied',
                                    fontSize: fontSize - 1,
                                    color: isAvailable
                                        ? bayanihanBlue
                                        : charcoalGray,
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
                    // Show remaining fields only after table is selected
                    if (_selectedTableId != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 18),
                          DividerWidget(),
                          // Date Display
                          TextWidget(
                            text: 'Reservation Date',
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: bayanihanBlue,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  TextWidget(
                                    text:
                                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                    fontSize: fontSize + 1,
                                    color: textBlack,
                                    isBold: true,
                                    fontFamily: 'Bold',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          DividerWidget(),
                          // Time Selection
                          TextWidget(
                            text: 'Select Available Time',
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
                            children: _availableTimeSlots.map((time) {
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
                                    });
                                    // Update table availability when time is selected
                                    _updateTableAvailability();
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                elevation: isSelected ? 3 : 0,
                                pressElevation: 5,
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 18),
                          DividerWidget(),
                          // Number of Guests Display
                          TextWidget(
                            text: 'Number of Guests',
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people,
                                    color: bayanihanBlue,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  TextWidget(
                                    text:
                                        '$_numberOfGuests Guest${_numberOfGuests > 1 ? 's' : ''}',
                                    fontSize: fontSize + 1,
                                    color: textBlack,
                                    isBold: true,
                                    fontFamily: 'Bold',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Confirm Reservation Button
                          Center(
                            child: ButtonWidget(
                              label: 'Confirm Reservation',
                              onPressed: _selectedTime != null &&
                                      _selectedTableId != null
                                  ? () {
                                      _createReservation();
                                    }
                                  : () {},
                              color: _selectedTime != null &&
                                      _selectedTableId != null
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
                  ],
                ),
              ),
            ),
    );
  }
}
