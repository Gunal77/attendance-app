import 'package:flutter/material.dart';

import '../../models/employee.dart';
import '../../models/project.dart';
import '../../services/api_service.dart';
import 'admin_login.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  final ApiService _apiService = ApiService();
  List<Employee> _employees = [];
  List<Project> _projects = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final employees = await _apiService.fetchEmployees();
      final projects = await _apiService.fetchProjects();
      if (mounted) {
        setState(() {
          _employees = employees;
          _projects = projects;
          _isLoading = false;
        });
      }
    } catch (error) {
      final message = error is ApiException
          ? error.message
          : 'Failed to load employees';
      if (mounted) {
        setState(() {
          _errorMessage = message;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  Future<void> _showCreateDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final roleController = TextEditingController();
    String? selectedProjectId;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create New Employee'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: roleController,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedProjectId,
                  decoration: const InputDecoration(
                    labelText: 'Project',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('No Project'),
                    ),
                    ..._projects.map(
                      (project) => DropdownMenuItem<String>(
                        value: project.id,
                        child: Text(project.name),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() => selectedProjectId = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Employee name is required')),
                  );
                  return;
                }

                try {
                  await _apiService.createEmployee(
                    name: nameController.text.trim(),
                    email: emailController.text.trim().isEmpty
                        ? null
                        : emailController.text.trim(),
                    phone: phoneController.text.trim().isEmpty
                        ? null
                        : phoneController.text.trim(),
                    role: roleController.text.trim().isEmpty
                        ? null
                        : roleController.text.trim(),
                    projectId: selectedProjectId,
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Employee created successfully')),
                    );
                  }
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          error is ApiException
                              ? error.message
                              : 'Failed to create employee',
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(Employee employee) async {
    final nameController = TextEditingController(text: employee.name);
    final emailController = TextEditingController(text: employee.email ?? '');
    final phoneController = TextEditingController(text: employee.phone ?? '');
    final roleController = TextEditingController(text: employee.role ?? '');
    String? selectedProjectId = employee.projectId;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Employee'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: roleController,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedProjectId,
                  decoration: const InputDecoration(
                    labelText: 'Project',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('No Project'),
                    ),
                    ..._projects.map(
                      (project) => DropdownMenuItem<String>(
                        value: project.id,
                        child: Text(project.name),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() => selectedProjectId = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Employee name is required')),
                  );
                  return;
                }

                try {
                  await _apiService.updateEmployee(
                    id: employee.id,
                    name: nameController.text.trim(),
                    email: emailController.text.trim().isEmpty
                        ? null
                        : emailController.text.trim(),
                    phone: phoneController.text.trim().isEmpty
                        ? null
                        : phoneController.text.trim(),
                    role: roleController.text.trim().isEmpty
                        ? null
                        : roleController.text.trim(),
                    projectId: selectedProjectId,
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Employee updated successfully')),
                    );
                  }
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          error is ApiException
                              ? error.message
                              : 'Failed to update employee',
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteEmployee(Employee employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete "${employee.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.deleteEmployee(employee.id);
        if (mounted) {
          _loadData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Employee deleted successfully')),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                error is ApiException
                    ? error.message
                    : 'Failed to delete employee',
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadData,
            tooltip: 'Refresh',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _employees.isEmpty
                  ? Center(
                      child: Text(
                        'No employees found',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _employees.length,
                        itemBuilder: (context, index) {
                          final employee = _employees[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(
                                employee.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (employee.email != null &&
                                      employee.email!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.email, size: 16),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              employee.email!,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (employee.role != null &&
                                      employee.role!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.work, size: 16),
                                          const SizedBox(width: 4),
                                          Text(employee.role!),
                                        ],
                                      ),
                                    ),
                                  if (employee.projectName != null &&
                                      employee.projectName!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.folder, size: 16),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              employee.projectName!,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (employee.phone != null &&
                                      employee.phone!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.phone, size: 16),
                                          const SizedBox(width: 4),
                                          Text(employee.phone!),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _showEditDialog(employee),
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteEmployee(employee),
                                    tooltip: 'Delete',
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add Employee',
      ),
    );
  }
}

