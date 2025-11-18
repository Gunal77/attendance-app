import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/attendance_card.dart';
import '../widgets/custom_app_bar.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  List<dynamic> _records = [];
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadAttendanceRecords();
  }

  Future<void> _loadAttendanceRecords() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final records = await ApiService().fetchMyAttendance();
      if (mounted) {
        setState(() {
          _records = records;
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
        _showMessage(
          error is ApiException ? error.message : 'Failed to load records',
        );
      }
    }
  }

  Future<void> _refreshRecords() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadAttendanceRecords();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar(
        title: 'Attendance History',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshRecords,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshRecords,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _records.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: AppTheme.textColor.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No attendance records found',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textColor.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pull down to refresh',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppTheme.textColor.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      final record = _records[index];
                      if (record is! Map<String, dynamic>) {
                        return const SizedBox.shrink();
                      }
                      return AttendanceCard(
                        record: record,
                        onTap: () {
                          // Handle tap if needed
                        },
                      );
                    },
                  ),
      ),
    );
  }
}

