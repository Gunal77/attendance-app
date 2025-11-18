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

  String _formatCoordinate(dynamic value) {
    if (value == null) return '-';
    if (value is num) {
      return value.toStringAsFixed(4);
    }
    final parsed = double.tryParse(value.toString());
    if (parsed != null) {
      return parsed.toStringAsFixed(4);
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final checkInTime = record['check_in_time']?.toString();
    final checkOutTime = record['check_out_time']?.toString();
    final imageUrl = record['image_url']?.toString();
    final latitude = record['latitude'];
    final longitude = record['longitude'];
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
                    child: Text(
                      checkInDate != null
                          ? dateFormat.format(checkInDate)
                          : 'Date not available',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor,
                      ),
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
                      isCheckedOut ? 'Completed' : 'Active',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isCheckedOut
                            ? AppTheme.successColor
                            : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
                      size: 20,
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
                            fontSize: 12,
                            color: AppTheme.textColor.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          checkInDate != null
                              ? timeFormat.format(checkInDate)
                              : 'N/A',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
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
                        size: 20,
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
                              fontSize: 12,
                              color: AppTheme.textColor.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            checkOutDate != null
                                ? timeFormat.format(checkOutDate)
                                : 'N/A',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              if (latitude != null && longitude != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppTheme.textColor.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_formatCoordinate(latitude)}, ${_formatCoordinate(longitude)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textColor.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (imageUrl != null && imageUrl.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.image,
                      size: 16,
                      color: AppTheme.textColor.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Image available',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textColor.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

