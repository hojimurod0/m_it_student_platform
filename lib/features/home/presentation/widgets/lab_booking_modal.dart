import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';

class LabBookingModal extends StatefulWidget {
  const LabBookingModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LabBookingModal(),
    );
  }

  @override
  State<LabBookingModal> createState() => _LabBookingModalState();
}

class _LabBookingModalState extends State<LabBookingModal> {
  int _selectedRoomIndex = 0;
  int _selectedSlotIndex = 1;
  int _selectedSeat = 7;
  bool _booked = false;

  List<(String, String, String, IconData)> _buildRooms(BuildContext context) => [
        (
          context.tr('labRoom204'),
          context.tr('labRoom204Sub'),
          context.tr('labRoom204Avail'),
          Icons.laptop_mac_rounded
        ),
        (
          context.tr('labRoom102'),
          context.tr('labRoom102Sub'),
          context.tr('labRoom102Avail'),
          Icons.desktop_windows_rounded
        ),
        (
          context.tr('labCoworkingZone'),
          context.tr('labCoworkingZoneSub'),
          context.tr('labCoworkingZoneAvail'),
          Icons.weekend_rounded
        ),
      ];

  final List<String> _timeSlots = [
    '09:00 - 11:00',
    '11:00 - 13:00',
    '14:00 - 16:00',
    '16:00 - 18:00',
    '18:00 - 20:00',
  ];

  @override
  Widget build(BuildContext context) {
    final rooms = _buildRooms(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.meeting_room_rounded, color: AppColors.secondary, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('labBookingTitle'),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        context.tr('labBookingSubtitle'),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Expanded(
            child: _booked ? _buildBookingSuccess(theme, isDark) : _buildBookingForm(theme, isDark, rooms),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingForm(ThemeData theme, bool isDark, List<(String, String, String, IconData)> rooms) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Room Selection
          Text(
            context.tr('labSelectRoom'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...List.generate(rooms.length, (i) {
            final room = rooms[i];
            final active = _selectedRoomIndex == i;

            return GestureDetector(
              onTap: () => setState(() => _selectedRoomIndex = i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: active
                      ? (isDark ? AppColors.primary.withValues(alpha: 0.25) : AppColors.primarySurface)
                      : (isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: active ? (isDark ? AppColors.primaryAccent : AppColors.primary) : theme.colorScheme.outline,
                    width: active ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(room.$4, color: active ? (isDark ? AppColors.primaryAccent : AppColors.primary) : (isDark ? Colors.white70 : Colors.black54)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.$1,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            room.$2,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      room.$3,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 14),

          // 2. Time Slot Selection
          Text(
            context.tr('labSelectTimeSlot'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_timeSlots.length, (i) {
              final active = _selectedSlotIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedSlotIndex = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: active
                        ? (isDark ? AppColors.primaryAccent : AppColors.primary)
                        : (isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _timeSlots[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 18),

          // 3. Seat selector
          Text(
            context.tr('labSelectSeat'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 16,
              separatorBuilder: (_, i) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final seatNum = i + 1;
                final active = _selectedSeat == seatNum;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSeat = seatNum),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: active
                          ? (isDark ? AppColors.primaryAccent : AppColors.primary)
                          : (isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: active ? Colors.transparent : theme.colorScheme.outline,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$seatNum',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: active ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _booked = true),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: Text(
                '${rooms[_selectedRoomIndex].$1} • ${context.tr('labSelectSeat')} $_selectedSeat',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSuccess(ThemeData theme, bool isDark) {
    final rooms = _buildRooms(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success.withValues(alpha: 0.2),
            ),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 60),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('labBookSuccess'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Column(
              children: [
                Text(
                  rooms[_selectedRoomIndex].$1,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                ),
                const SizedBox(height: 4),
                Text(
                  '${context.tr('labBookTime')}: ${_timeSlots[_selectedSlotIndex]} • ${context.tr('labBookComputer')} #$_selectedSeat',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? AppColors.primaryAccent : AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('labBookConfirm'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('labBookGotIt')),
          ),
        ],
      ),
    );
  }
}
