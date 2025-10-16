import 'package:flutter/material.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/divider_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class SeatReservationScreen extends StatefulWidget {
  const SeatReservationScreen({super.key});

  @override
  State<SeatReservationScreen> createState() => _SeatReservationScreenState();
}

class _SeatReservationScreenState extends State<SeatReservationScreen> {
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
  String? _selectedTimeSlot;
  String? _selectedTableId;
  int _numberOfGuests = 1;
  Map<String, List<String>> _tableAvailableSlots = {};
  List<Map<String, String>> _timeSlots = [];
  bool _isLoading = true;
  StreamSubscription? _reservationsSubscription;
  String? _pendingReservationId;
  Map<String, dynamic>? _cartReservation;

  @override
  void initState() {
    super.initState();
    _initializeReservation();
  }

  // Initialize reservation data
  Future<void> _initializeReservation() async {
    setState(() => _isLoading = true);

    // Generate time slots with cleaning time
    _generateTimeSlots();

    // Check if user has pending reservation in cart
    await _checkPendingReservation();

    // Set up real-time listener for reservations
    _setupRealtimeListener();

    setState(() => _isLoading = false);
  }

  // Generate time slots: 10:00-10:55, 11:00-11:55, ..., 1:00-1:55 (1:00 AM - 1:55 AM)
  void _generateTimeSlots() {
    _timeSlots.clear();
    final now = DateTime.now();

    // Operating hours: 10:00 AM to 2:00 AM (next day)
    // 10 AM to 11 PM (10-23), then 12 AM to 1 AM (0-1)
    List<int> hours = [];
    
    // Add 10 AM to 11 PM (10-23)
    for (int hour = 10; hour <= 23; hour++) {
      hours.add(hour);
    }
    
    // Add 12 AM to 1 AM (0-1) for next day
    hours.add(0);
    hours.add(1);

    for (int hour in hours) {
      // Skip past time slots for today
      if (_selectedDate.day == now.day &&
          _selectedDate.month == now.month &&
          _selectedDate.year == now.year &&
          hour < now.hour) {
        continue;
      }

      // Format time slot with start and end time (55 mins, 5 mins for cleaning)
      String period = hour < 12 ? 'AM' : 'PM';
      int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

      String startTime = '$displayHour:00 $period';
      String endTime = '$displayHour:55 $period';
      String slotDisplay = '$startTime - $endTime';

      _timeSlots.add({
        'display': slotDisplay,
        'value': startTime,
        'hour': hour.toString(),
      });
    }
  }

  // Check if user has a pending reservation (in cart)
  Future<void> _checkPendingReservation() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final snapshot = await _firestore
          .collection('reservations')
          .where('userId', isEqualTo: user.email)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _pendingReservationId = snapshot.docs.first.id;
          _cartReservation = snapshot.docs.first.data();
        });
      }
    } catch (e) {
      print('Error checking pending reservation: $e');
    }
  }

  // Set up real-time listener for reservations
  void _setupRealtimeListener() {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    _reservationsSubscription = _firestore
        .collection('reservations')
        .where('date', isEqualTo: dateStr)
        .where('status', whereIn: ['pending', 'confirmed'])
        .snapshots()
        .listen((snapshot) {
      _updateTableAvailability(snapshot.docs);
    });
  }

  // Update table availability based on reservations
  void _updateTableAvailability(List<QueryDocumentSnapshot> reservations) {
    Map<String, List<String>> availableSlots = {};

    // Initialize all tables with all time slots
    for (var table in _tables) {
      availableSlots[table['id']] =
          _timeSlots.map((slot) => slot['value']!).toList();
    }

    // Remove booked slots
    for (var doc in reservations) {
      final data = doc.data() as Map<String, dynamic>;
      final tableId = data['tableId'];
      final timeSlot = data['timeSlot'];

      if (availableSlots.containsKey(tableId)) {
        availableSlots[tableId]!.remove(timeSlot);
      }
    }

    setState(() {
      _tableAvailableSlots = availableSlots;
    });
  }

  // Add reservation to cart
  Future<void> _addToCart() async {
    if (_selectedTableId == null || _selectedTimeSlot == null) return;

    // Check if user already has a pending reservation
    if (_pendingReservationId != null) {
      _showMessage(
        'You already have a pending reservation. Please checkout or cancel it first.',
        isError: true,
      );
      return;
    }

    // Validate number of guests
    final selectedTable =
        _tables.firstWhere((table) => table['id'] == _selectedTableId);
    if (_numberOfGuests > selectedTable['capacity']) {
      _showMessage(
        'Number of guests exceeds table capacity (${selectedTable['capacity']})',
        isError: true,
      );
      return;
    }

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _showMessage('Please login to make a reservation', isError: true);
        return;
      }

      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

      // Double-check availability before creating reservation
      final existingReservation = await _firestore
          .collection('reservations')
          .where('tableId', isEqualTo: _selectedTableId)
          .where('date', isEqualTo: dateStr)
          .where('timeSlot', isEqualTo: _selectedTimeSlot)
          .where('status', whereIn: ['pending', 'confirmed'])
          .get();

      if (existingReservation.docs.isNotEmpty) {
        _showMessage(
          'This table is no longer available for the selected time slot.',
          isError: true,
        );
        // Refresh availability
        _setupRealtimeListener();
        return;
      }

      // Create reservation document
      final docRef = await _firestore.collection('reservations').add({
        'userId': user.email,
        'userEmail': user.email,
        'userName': user.displayName ?? user.email,
        'tableId': _selectedTableId,
        'tableName': selectedTable['name'],
        'tableCapacity': selectedTable['capacity'],
        'date': dateStr,
        'dateDisplay': DateFormat('dd/MM/yyyy').format(_selectedDate),
        'timeSlot': _selectedTimeSlot,
        'timeSlotDisplay': _timeSlots
            .firstWhere((slot) => slot['value'] == _selectedTimeSlot)['display'],
        'guests': _numberOfGuests,
        'status': 'pending', // Pending until checkout
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _pendingReservationId = docRef.id;
      });

      _showMessage(
        'Reservation added to cart! Please proceed to checkout.',
        isError: false,
      );

      // Refresh to show cart
      await _checkPendingReservation();
    } catch (e) {
      print('Error adding reservation to cart: $e');
      _showMessage('Failed to add reservation. Please try again.', isError: true);
    }
  }

  // Cancel reservation (remove from cart)
  Future<void> _cancelReservation() async {
    if (_pendingReservationId == null) return;

    try {
      // Delete the reservation document
      await _firestore
          .collection('reservations')
          .doc(_pendingReservationId)
          .delete();

      setState(() {
        _pendingReservationId = null;
        _cartReservation = null;
      });

      _showMessage('Reservation cancelled successfully.', isError: false);
    } catch (e) {
      print('Error cancelling reservation: $e');
      _showMessage('Failed to cancel reservation.', isError: true);
    }
  }

  // Proceed to checkout
  void _proceedToCheckout() {
    if (_pendingReservationId == null) return;

    // Navigate back with reservation data
    Navigator.pop(context, {
      'action': 'checkout',
      'reservationId': _pendingReservationId,
      'reservation': _cartReservation,
    });
  }

  // Show message
  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TextWidget(
          text: message,
          fontSize: 14,
          color: plainWhite,
          fontFamily: 'Regular',
        ),
        backgroundColor: isError ? festiveRed : bayanihanBlue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Helper method to get the maximum number of guests for the selected table
  int _getMaxGuests() {
    if (_selectedTableId == null) return 0;
    final selectedTable = _tables.firstWhere(
      (table) => table['id'] == _selectedTableId,
      orElse: () => {'capacity': 0},
    );
    return selectedTable['capacity'] as int;
  }

  // Check if a time slot is available for selected table
  bool _isTimeSlotAvailable(String timeSlot) {
    if (_selectedTableId == null) return false;
    return _tableAvailableSlots[_selectedTableId]?.contains(timeSlot) ?? false;
  }

  // Get available time slots count for a table
  int _getAvailableSlotsCount(String tableId) {
    return _tableAvailableSlots[tableId]?.length ?? 0;
  }

  @override
  void dispose() {
    _reservationsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.036;

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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Show cart if user has pending reservation
                    if (_pendingReservationId != null && _cartReservation != null)
                      _buildCartSection(),

                    // Show reservation form only if no pending reservation
                    if (_pendingReservationId == null) ...[
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildOperatingHours(),
                      const SizedBox(height: 16),
                      _buildDateSelector(),
                      const SizedBox(height: 16),
                      _buildTableSelection(fontSize),
                      if (_selectedTableId != null) ...[
                        const SizedBox(height: 16),
                        _buildTimeSlotSelection(fontSize),
                        const SizedBox(height: 16),
                        _buildGuestSelection(fontSize),
                        const SizedBox(height: 24),
                        _buildAddToCartButton(screenWidth, fontSize),
                      ],
                    ],
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  // Build cart section
  Widget _buildCartSection() {
    return Card(
      elevation: 4,
      color: bayanihanBlue.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: bayanihanBlue, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart, color: bayanihanBlue, size: 24),
                const SizedBox(width: 8),
                TextWidget(
                  text: 'Reservation in Cart',
                  fontSize: 20,
                  color: bayanihanBlue,
                  isBold: true,
                  fontFamily: 'Bold',
                ),
              ],
            ),
            const SizedBox(height: 12),
            DividerWidget(),
            const SizedBox(height: 12),
            _buildCartDetail('Table', _cartReservation!['tableName']),
            _buildCartDetail('Date', _cartReservation!['dateDisplay']),
            _buildCartDetail('Time', _cartReservation!['timeSlotDisplay']),
            _buildCartDetail('Guests', '${_cartReservation!['guests']} guest(s)'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ButtonWidget(
                    label: 'Cancel',
                    onPressed: _cancelReservation,
                    color: festiveRed,
                    textColor: plainWhite,
                    fontSize: 16,
                    height: 45,
                    radius: 10,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ButtonWidget(
                    label: 'Proceed to Checkout',
                    onPressed: _proceedToCheckout,
                    color: bayanihanBlue,
                    textColor: plainWhite,
                    fontSize: 16,
                    height: 45,
                    radius: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget(
            text: '$label:',
            fontSize: 14,
            color: textBlack,
            fontFamily: 'Regular',
          ),
          TextWidget(
            text: value,
            fontSize: 14,
            color: textBlack,
            isBold: true,
            fontFamily: 'Bold',
          ),
        ],
      ),
    );
  }

  // Build header
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: 'Reserve Your Table',
          fontSize: 22,
          color: textBlack,
          isBold: true,
          fontFamily: 'Bold',
        ),
        const SizedBox(height: 8),
        DividerWidget(),
      ],
    );
  }

  // Build operating hours info
  Widget _buildOperatingHours() {
    return Container(
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
            text: 'Reservation slots: 55 minutes (5 mins cleaning time)',
            fontSize: 14,
            color: textBlack,
            fontFamily: 'Regular',
          ),
        ],
      ),
    );
  }

  // Build date selector
  Widget _buildDateSelector() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () async {
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 30)),
          );
          if (pickedDate != null) {
            setState(() {
              _selectedDate = pickedDate;
              _selectedTimeSlot = null;
              _selectedTableId = null;
            });
            _generateTimeSlots();
            _setupRealtimeListener();
          }
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, color: bayanihanBlue, size: 24),
                  const SizedBox(width: 12),
                  TextWidget(
                    text: DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
                    fontSize: 16,
                    color: textBlack,
                    isBold: true,
                    fontFamily: 'Bold',
                  ),
                ],
              ),
              Icon(Icons.arrow_drop_down, color: bayanihanBlue),
            ],
          ),
        ),
      ),
    );
  }

  // Build table selection
  Widget _buildTableSelection(double fontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: 'Select Table',
          fontSize: 20,
          color: textBlack,
          isBold: true,
          fontFamily: 'Bold',
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: _tables.length,
          itemBuilder: (context, index) {
            final table = _tables[index];
            final isSelected = _selectedTableId == table['id'];
            final availableSlots = _getAvailableSlotsCount(table['id']);

            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: isSelected ? bayanihanBlue : Colors.transparent,
                  width: 2,
                ),
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedTableId = table['id'];
                    _selectedTimeSlot = null;
                    _numberOfGuests = 1;
                  });
                },
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: isSelected
                        ? bayanihanBlue.withOpacity(0.1)
                        : plainWhite,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextWidget(
                        text: table['name'],
                        fontSize: fontSize + 1,
                        color: isSelected ? bayanihanBlue : textBlack,
                        isBold: true,
                        fontFamily: 'Bold',
                      ),
                      const SizedBox(height: 8),
                      Icon(
                        Icons.table_restaurant,
                        size: 32,
                        color: isSelected ? bayanihanBlue : textBlack,
                      ),
                      const SizedBox(height: 8),
                      TextWidget(
                        text: '${table['capacity']} seats',
                        fontSize: fontSize - 1,
                        color: charcoalGray,
                        fontFamily: 'Regular',
                      ),
                      const SizedBox(height: 4),
                      TextWidget(
                        text: '$availableSlots slots available',
                        fontSize: fontSize - 2,
                        color: availableSlots > 0 ? palmGreen : festiveRed,
                        fontFamily: 'Bold',
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Build time slot selection
  Widget _buildTimeSlotSelection(double fontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: 'Select Time Slot',
          fontSize: 20,
          color: textBlack,
          isBold: true,
          fontFamily: 'Bold',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _timeSlots.map((slot) {
            final isAvailable = _isTimeSlotAvailable(slot['value']!);
            final isSelected = _selectedTimeSlot == slot['value'];

            return ChoiceChip(
              showCheckmark: false,
              label: TextWidget(
                text: slot['display']!,
                fontSize: fontSize - 1,
                color: !isAvailable
                    ? ashGray
                    : isSelected
                        ? plainWhite
                        : textBlack,
                isBold: isSelected,
                fontFamily: 'Regular',
              ),
              selected: isSelected,
              onSelected: isAvailable
                  ? (selected) {
                      if (selected) {
                        setState(() {
                          _selectedTimeSlot = slot['value'];
                        });
                      }
                    }
                  : null,
              backgroundColor: !isAvailable
                  ? ashGray.withOpacity(0.3)
                  : cloudWhite,
              selectedColor: bayanihanBlue,
              disabledColor: ashGray.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: !isAvailable
                      ? ashGray
                      : isSelected
                          ? bayanihanBlue
                          : ashGray,
                  width: 1.0,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Build guest selection
  Widget _buildGuestSelection(double fontSize) {
    final maxGuests = _getMaxGuests();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: 'Number of Guests',
          fontSize: 20,
          color: textBlack,
          isBold: true,
          fontFamily: 'Bold',
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people, color: bayanihanBlue, size: 24),
                    const SizedBox(width: 12),
                    TextWidget(
                      text: '$_numberOfGuests Guest${_numberOfGuests > 1 ? 's' : ''}',
                      fontSize: fontSize + 1,
                      color: textBlack,
                      isBold: true,
                      fontFamily: 'Bold',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Decrease button
                    GestureDetector(
                      onTap: _numberOfGuests > 1
                          ? () => setState(() => _numberOfGuests--)
                          : null,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _numberOfGuests > 1
                              ? bayanihanBlue
                              : ashGray.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.remove,
                          color: _numberOfGuests > 1 ? plainWhite : ashGray,
                          size: 20,
                        ),
                      ),
                    ),
                    // Guest count display
                    Container(
                      width: 60,
                      height: 40,
                      decoration: BoxDecoration(
                        color: bayanihanBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: bayanihanBlue, width: 1),
                      ),
                      child: Center(
                        child: TextWidget(
                          text: '$_numberOfGuests',
                          fontSize: fontSize + 2,
                          color: bayanihanBlue,
                          isBold: true,
                          fontFamily: 'Bold',
                        ),
                      ),
                    ),
                    // Increase button
                    GestureDetector(
                      onTap: _numberOfGuests < maxGuests
                          ? () => setState(() => _numberOfGuests++)
                          : null,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _numberOfGuests < maxGuests
                              ? bayanihanBlue
                              : ashGray.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.add,
                          color: _numberOfGuests < maxGuests ? plainWhite : ashGray,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_numberOfGuests >= maxGuests && maxGuests > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextWidget(
                      text: 'Maximum capacity: $maxGuests guests',
                      fontSize: fontSize - 1,
                      color: festiveRed,
                      fontFamily: 'Regular',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Build add to cart button
  Widget _buildAddToCartButton(double screenWidth, double fontSize) {
    final isEnabled = _selectedTableId != null && _selectedTimeSlot != null;

    return Center(
      child: ButtonWidget(
        label: 'Add to Cart',
        onPressed: isEnabled ? _addToCart : () {},
        color: isEnabled ? bayanihanBlue : ashGray,
        textColor: plainWhite,
        fontSize: fontSize + 2,
        height: 50,
        radius: 12,
        width: screenWidth * 0.6,
      ),
    );
  }
}
