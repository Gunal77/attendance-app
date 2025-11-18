import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/attendance_record.dart';
import '../../services/api_service.dart';
import 'admin_login.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ApiService _apiService = ApiService();
  final DateFormat _dateTimeFormat = DateFormat('yMMMd HH:mm');
  final DateFormat _dateFormat = DateFormat('yMMMd');

  List<AttendanceRecord> _allRecords = const [];
  List<AttendanceRecord> _filteredRecords = const [];
  List<MapEntry<String, String>> _userOptions = const [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedUserEmail;
  DateTime? _selectedDate;
  int? _selectedMonth;
  int? _selectedYear;
  int _sortColumnIndex = 3;
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final records = await _apiService.fetchAdminAttendance();
      _updateRecords(records);
    } catch (error) {
      final message = error is ApiException
          ? error.message
          : 'Failed to load attendance records';
      setState(() {
        _errorMessage = message;
        _allRecords = const [];
        _filteredRecords = const [];
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateRecords(List<AttendanceRecord> records) {
    final userMap = <String, String>{};
    for (final record in records) {
      final email = record.userEmail;
      if (email.isEmpty) continue;
      userMap.putIfAbsent(email, () => record.displayName);
    }

    final userEntries = userMap.entries.toList()
      ..sort((a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()));

    setState(() {
      _allRecords = List<AttendanceRecord>.from(records);
      _userOptions = userEntries;
    });
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = List<AttendanceRecord>.from(_allRecords);

    if (_selectedUserEmail != null && _selectedUserEmail!.isNotEmpty) {
      filtered = filtered
          .where((record) => record.userEmail == _selectedUserEmail)
          .toList();
    }

    if (_selectedDate != null) {
      filtered = filtered.where((record) {
        final checkIn = record.checkIn;
        if (checkIn == null) return false;
        return checkIn.year == _selectedDate!.year &&
            checkIn.month == _selectedDate!.month &&
            checkIn.day == _selectedDate!.day;
      }).toList();
    }

    if (_selectedMonth != null) {
      filtered = filtered.where((record) {
        final checkIn = record.checkIn;
        if (checkIn == null) return false;
        final matchesMonth = checkIn.month == _selectedMonth;
        final matchesYear =
            _selectedYear == null || checkIn.year == _selectedYear;
        return matchesMonth && matchesYear;
      }).toList();
    } else if (_selectedYear != null) {
      filtered = filtered.where((record) {
        final checkIn = record.checkIn;
        if (checkIn == null) return false;
        return checkIn.year == _selectedYear;
      }).toList();
    }

    filtered.sort(
      (a, b) => _compareRecords(a, b, _sortColumnIndex, _sortAscending),
    );

    setState(() {
      _filteredRecords = filtered;
    });
  }

  int _compareRecords(
    AttendanceRecord a,
    AttendanceRecord b,
    int columnIndex,
    bool ascending,
  ) {
    int result;
    switch (columnIndex) {
      case 0:
        result = a.displayName.toLowerCase().compareTo(
          b.displayName.toLowerCase(),
        );
        break;
      case 1:
        result = _compareDateTime(a.checkIn, b.checkIn);
        break;
      case 2:
        result = _compareDateTime(a.checkOut, b.checkOut);
        break;
      case 3:
      default:
        result = _compareDateTime(a.checkIn, b.checkIn);
        break;
    }
    return ascending ? result : -result;
  }

  int _compareDateTime(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    return a.compareTo(b);
  }

  void _handleSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _filteredRecords.sort(
        (a, b) => _compareRecords(a, b, columnIndex, ascending),
      );
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedMonth = null;
      });
      _applyFilters();
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedUserEmail = null;
      _selectedDate = null;
      _selectedMonth = null;
      _selectedYear = null;
    });
    _applyFilters();
  }

  List<DropdownMenuItem<String>> get _userDropdownItems {
    final items = <DropdownMenuItem<String>>[
      const DropdownMenuItem<String>(value: '', child: Text('All users')),
    ];
    items.addAll(
      _userOptions
          .map(
            (entry) => DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            ),
          )
          .toList(),
    );
    return items;
  }

  List<DropdownMenuItem<int>> get _monthDropdownItems {
    final months = List<int>.generate(12, (index) => index + 1);
    return [
      const DropdownMenuItem<int>(value: 0, child: Text('All months')),
      ...months.map(
        (month) => DropdownMenuItem<int>(
          value: month,
          child: Text(DateFormat.MMMM().format(DateTime(0, month))),
        ),
      ),
    ];
  }

  List<DropdownMenuItem<int>> get _yearDropdownItems {
    final years = <int>{};
    for (final record in _allRecords) {
      final checkIn = record.checkIn;
      if (checkIn != null) {
        years.add(checkIn.year);
      }
    }
    if (years.isEmpty) {
      years.add(DateTime.now().year);
    }
    final sortedYears = years.toList()..sort();
    return [
      const DropdownMenuItem<int>(value: 0, child: Text('All years')),
      ...sortedYears.map(
        (year) =>
            DropdownMenuItem<int>(value: year, child: Text(year.toString())),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final body = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
        ? Center(
            child: Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          )
        : _buildContent();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadRecords,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _apiService.clearAdminSession();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                (route) => false,
              );
            },
            tooltip: 'Log out',
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadRecords,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<String>(
                  value: _selectedUserEmail ?? '',
                  items: _userDropdownItems,
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() {
                      _selectedUserEmail = value?.isEmpty ?? true
                          ? null
                          : value;
                    });
                    _applyFilters();
                  },
                  decoration: const InputDecoration(
                    labelText: 'Filter by user',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(
                width: 160,
                child: DropdownButtonFormField<int>(
                  value: _selectedMonth ?? 0,
                  items: _monthDropdownItems,
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() {
                      if (value == null || value == 0) {
                        _selectedMonth = null;
                      } else {
                        _selectedMonth = value;
                      }
                      if (_selectedMonth == null) {
                        _selectedYear = null;
                      }
                    });
                    _applyFilters();
                  },
                  decoration: const InputDecoration(
                    labelText: 'Filter by month',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(
                width: 140,
                child: DropdownButtonFormField<int>(
                  value: _selectedYear ?? 0,
                  items: _yearDropdownItems,
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() {
                      if (value == null || value == 0) {
                        _selectedYear = null;
                      } else {
                        _selectedYear = value;
                      }
                    });
                    _applyFilters();
                  },
                  decoration: const InputDecoration(
                    labelText: 'Filter by year',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _selectedDate == null
                      ? 'Filter by date'
                      : _dateFormat.format(_selectedDate!),
                ),
              ),
              if (_selectedDate != null ||
                  _selectedMonth != null ||
                  _selectedUserEmail != null)
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear filters'),
                ),
            ],
          ),
          const SizedBox(height: 24),
          _filteredRecords.isEmpty
              ? Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'No attendance records match the current filters.',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        if (_selectedDate != null ||
                            _selectedMonth != null ||
                            _selectedUserEmail != null ||
                            _selectedYear != null)
                          TextButton(
                            onPressed: _clearFilters,
                            child: const Text('Reset filters'),
                          ),
                      ],
                    ),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 720) {
                      return Column(
                        children: _filteredRecords
                            .map((record) => _buildMobileRecordCard(record))
                            .toList(),
                      );
                    }
                    return _buildDataTable();
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        child: DataTable(
          columnSpacing: 24,
          horizontalMargin: 16,
          headingRowHeight: 56,
          dataRowMinHeight: 64,
          dataRowMaxHeight: 84,
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          columns: [
            DataColumn(
              label: const Text('User'),
              onSort: (columnIndex, ascending) =>
                  _handleSort(columnIndex, ascending),
            ),
            DataColumn(
              label: const Text('Check-in'),
              onSort: (columnIndex, ascending) =>
                  _handleSort(columnIndex, ascending),
            ),
            DataColumn(
              label: const Text('Check-out'),
              onSort: (columnIndex, ascending) =>
                  _handleSort(columnIndex, ascending),
            ),
            DataColumn(
              label: const Text('Date'),
              numeric: false,
              onSort: (columnIndex, ascending) =>
                  _handleSort(columnIndex, ascending),
            ),
            const DataColumn(label: Text('Image')),
          ],
          rows: _filteredRecords
              .map((record) => _buildDataRow(record))
              .toList(),
        ),
      ),
    );
  }

  DataRow _buildDataRow(AttendanceRecord record) {
    final checkInText = record.checkIn != null
        ? _dateTimeFormat.format(record.checkIn!.toLocal())
        : '—';
    final checkOutText = record.checkOut != null
        ? _dateTimeFormat.format(record.checkOut!.toLocal())
        : '—';
    final dateText = record.checkIn != null
        ? _dateFormat.format(record.checkIn!.toLocal())
        : '—';

    return DataRow(
      cells: [
        DataCell(_buildFixedWidthText(record.displayName, width: 220)),
        DataCell(_buildFixedWidthText(checkInText)),
        DataCell(_buildFixedWidthText(checkOutText)),
        DataCell(_buildFixedWidthText(dateText, width: 140)),
        DataCell(_buildImageCell(record.imageUrl)),
      ],
    );
  }

  Widget _buildMobileRecordCard(AttendanceRecord record) {
    final checkInText = record.checkIn != null
        ? _dateTimeFormat.format(record.checkIn!.toLocal())
        : '—';
    final checkOutText = record.checkOut != null
        ? _dateTimeFormat.format(record.checkOut!.toLocal())
        : '—';
    final dateText = record.checkIn != null
        ? _dateFormat.format(record.checkIn!.toLocal())
        : '—';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        record.userEmail,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildImageCell(record.imageUrl),
              ],
            ),
            const Divider(height: 24),
            _buildKeyValueRow('Date', dateText),
            const SizedBox(height: 8),
            _buildKeyValueRow('Check-in', checkInText),
            const SizedBox(height: 8),
            _buildKeyValueRow('Check-out', checkOutText),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyValueRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildFixedWidthText(
    String text, {
    double width = 180,
    TextAlign textAlign = TextAlign.left,
  }) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        textAlign: textAlign,
      ),
    );
  }

  Widget _buildImageCell(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const Text('No image');
    }
    return InkWell(
      onTap: () => _showImagePreview(imageUrl),
      child: Tooltip(
        message: 'Tap to preview',
        child: SizedBox(
          height: 56,
          width: 56,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: Colors.black12,
                child: Center(child: Icon(Icons.broken_image)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showImagePreview(String imageUrl) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: InteractiveViewer(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (_, __, ___) => const SizedBox(
                      height: 300,
                      child: Center(child: Text('Unable to load image')),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: IconButton.filled(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
