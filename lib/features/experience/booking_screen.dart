import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../mock/mock_data.dart';

/// Booking screen for scheduling an experience
class BookingScreen extends StatefulWidget {
  const BookingScreen({
    super.key,
    required this.experienceId,
  });

  final String experienceId;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  DateTime currentMonth = DateTime.now();
  int guests = 1;
  String selectedTime = '10:00 AM';
  
  final List<String> timeSlots = ['10:00 AM', '2:00 PM', '6:00 PM'];

  @override
  Widget build(BuildContext context) {
    final experience = MockData.getExperienceById(widget.experienceId);
    if (experience == null) return const SizedBox();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book Experience'),
        backgroundColor: AppColors.forestGreen,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Experience info header
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.peach.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.photo_camera_outlined,
                    color: AppColors.oliveGold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        experience.title,
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        experience.host.name,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        experience.location,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${experience.duration} • ${experience.category}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Select Date
                  _buildSectionTitle('Select Date'),
                  const SizedBox(height: 12),
                  _buildCalendar(),
                  
                  const SizedBox(height: 24),
                  
                  // Select Time
                  _buildSectionTitle('Select Time'),
                  const SizedBox(height: 12),
                  _buildTimeSlots(),
                  
                  const SizedBox(height: 24),
                  
                  // Number of Guests
                  _buildSectionTitle('Number of Guests'),
                  const SizedBox(height: 12),
                  _buildGuestSelector(),
                  
                  const SizedBox(height: 24),
                  
                  // Booking Summary
                  _buildSectionTitle('Booking Summary'),
                  const SizedBox(height: 12),
                  _buildBookingSummary(),
                ],
              ),
            ),
          ),

          // Bottom action
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.titleSmall.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // Calendar header
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
                  });
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  _getMonthYearText(),
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
                  });
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          
          // Calendar grid
          Column(
            children: [
              // Day headers
              Row(
                children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                    .map((day) => Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
              // Calendar days
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                ),
                itemCount: _getDaysInMonth(),
                itemBuilder: (context, index) {
                  final dayData = _getDayData(index);
                  if (dayData == null) {
                    return const SizedBox();
                  }
                  
                  final date = dayData['date'] as DateTime;
                  final day = dayData['day'] as int;
                  final isCurrentMonth = dayData['isCurrentMonth'] as bool;
                  final isSelected = selectedDate != null && 
                      selectedDate!.year == date.year &&
                      selectedDate!.month == date.month &&
                      selectedDate!.day == date.day;
                  final isPastDate = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
                  
                  return GestureDetector(
                    onTap: isPastDate || !isCurrentMonth ? null : () {
                      setState(() {
                        selectedDate = date;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppColors.lava 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          day.toString(),
                          style: AppTypography.bodyMedium.copyWith(
                            color: isSelected
                                ? AppColors.white
                                : isPastDate || !isCurrentMonth
                                    ? AppColors.textSecondary.withValues(alpha: 0.5)
                                    : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlots() {
    return Column(
      children: timeSlots.map((time) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: AppColors.divider),
          ),
          tileColor: AppColors.white,
          title: Text(
            time,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          trailing: Radio<String>(
            value: time,
            groupValue: selectedTime,
            onChanged: (value) {
              setState(() {
                selectedTime = value!;
              });
            },
            activeColor: AppColors.forestGreen,
          ),
          onTap: () {
            setState(() {
              selectedTime = time;
            });
          },
        ),
      )).toList(),
    );
  }

  Widget _buildGuestSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Guests',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: guests > 1 ? () => setState(() => guests--) : null,
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.textSecondary,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              guests.toString(),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => guests++),
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.forestGreen,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Date', selectedDate != null 
              ? '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
              : 'Not selected'),
          _buildSummaryRow('Time', selectedTime),
          _buildSummaryRow('Guests', guests.toString()),
          const Divider(),
          _buildSummaryRow('Total', '\$75.00', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: selectedDate != null ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Booking confirmed for ${_formatSelectedDate()}!'),
                  backgroundColor: AppColors.forestGreen,
                ),
              );
              context.pop();
            } : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.forestGreen,
            ),
            child: Text(
              'Confirm Booking • \$75.00',
              style: AppTypography.buttonLarge.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getMonthYearText() {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[currentMonth.month - 1]} ${currentMonth.year}';
  }

  int _getDaysInMonth() {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0
    
    return firstWeekday + lastDayOfMonth.day;
  }

  Map<String, dynamic>? _getDayData(int index) {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0
    
    if (index < firstWeekday) {
      // Previous month days
      final prevMonth = DateTime(currentMonth.year, currentMonth.month - 1);
      final prevMonthLastDay = DateTime(currentMonth.year, currentMonth.month, 0).day;
      final day = prevMonthLastDay - (firstWeekday - index - 1);
      return {
        'date': DateTime(prevMonth.year, prevMonth.month, day),
        'day': day,
        'isCurrentMonth': false,
      };
    }
    
    final dayInMonth = index - firstWeekday + 1;
    final lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    
    if (dayInMonth <= lastDayOfMonth) {
      // Current month days
      return {
        'date': DateTime(currentMonth.year, currentMonth.month, dayInMonth),
        'day': dayInMonth,
        'isCurrentMonth': true,
      };
    }
    
    // Next month days
    final nextMonthDay = dayInMonth - lastDayOfMonth;
    final nextMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    return {
      'date': DateTime(nextMonth.year, nextMonth.month, nextMonthDay),
      'day': nextMonthDay,
      'isCurrentMonth': false,
    };
  }

  String _formatSelectedDate() {
    if (selectedDate == null) return '';
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[selectedDate!.month - 1]} ${selectedDate!.day}, ${selectedDate!.year}';
  }
}
