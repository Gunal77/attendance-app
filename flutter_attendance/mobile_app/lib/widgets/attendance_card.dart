import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class AttendanceCard extends StatelessWidget {
  const AttendanceCard({
    super.key,
    required this.record,
    this.onTap,
  });

  final Map<String, dynamic> record;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final checkInTime = record['check_in_time']?.toString();
    final checkOutTime = record['check_out_time']?.toString();
    final isCheckedOut = checkOutTime != null && checkOutTime.isNotEmpty;

    DateTime? checkInDate;
    DateTime? checkOutDate;

    if (checkInTime != null && checkInTime.isNotEmpty) {
      checkInDate = DateTime.tryParse(checkInTime);
    }
    if (checkOutTime != null && checkOutTime.isNotEmpty) {
      checkOutDate = DateTime.tryParse(checkOutTime);
    }

    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    // Calculate duration if both times are available
    String? durationText;
    if (checkInDate != null && checkOutDate != null) {
      final duration = checkOutDate.difference(checkInDate);
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      durationText = '${hours}h ${minutes}m';
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          checkInDate != null
                              ? dateFormat.format(checkInDate)
                              : 'Date not available',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                        if (durationText != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Duration: $durationText',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.textColor.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isCheckedOut
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isCheckedOut ? 'COMPLETED' : 'ACTIVE',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isCheckedOut
                            ? AppTheme.successColor
                            : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.login,
                            size: 18,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Check In',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppTheme.textColor.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                checkInDate != null
                                    ? timeFormat.format(checkInDate)
                                    : 'N/A',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (isCheckedOut) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.logout,
                              size: 18,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Check Out',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppTheme.textColor.withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  checkOutDate != null
                                      ? timeFormat.format(checkOutDate)
                                      : 'N/A',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

