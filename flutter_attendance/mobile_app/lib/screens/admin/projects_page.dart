import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/project.dart';
import '../../services/api_service.dart';
import 'admin_login.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final ApiService _apiService = ApiService();
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  List<Project> _projects = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final projects = await _apiService.fetchProjects();
      if (mounted) {
        setState(() {
          _projects = projects;
          _isLoading = false;
        });
      }
    } catch (error) {
      final message = error is ApiException
          ? error.message
          : 'Failed to load projects';
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
    final locationController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create New Project'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Project Name *',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    startDate == null
                        ? 'Start Date'
                        : _dateFormat.format(startDate!),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setDialogState(() => startDate = date);
                    }
                  },
                ),
                ListTile(
                  title: Text(
                    endDate == null ? 'End Date' : _dateFormat.format(endDate!),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: startDate ?? DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setDialogState(() => endDate = date);
                    }
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
                    const SnackBar(content: Text('Project name is required')),
                  );
                  return;
                }

                try {
                  await _apiService.createProject(
                    name: nameController.text.trim(),
                    location: locationController.text.trim().isEmpty
                        ? null
                        : locationController.text.trim(),
                    startDate: startDate,
                    endDate: endDate,
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    _loadProjects();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Project created successfully')),
                    );
                  }
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          error is ApiException
                              ? error.message
                              : 'Failed to create project',
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

  Future<void> _showEditDialog(Project project) async {
    final nameController = TextEditingController(text: project.name);
    final locationController = TextEditingController(text: project.location ?? '');
    DateTime? startDate = project.startDate;
    DateTime? endDate = project.endDate;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Project'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Project Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    startDate == null
                        ? 'Start Date'
                        : _dateFormat.format(startDate!),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setDialogState(() => startDate = date);
                    }
                  },
                ),
                ListTile(
                  title: Text(
                    endDate == null ? 'End Date' : _dateFormat.format(endDate!),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? startDate ?? DateTime.now(),
                      firstDate: startDate ?? DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setDialogState(() => endDate = date);
                    }
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
                    const SnackBar(content: Text('Project name is required')),
                  );
                  return;
                }

                try {
                  await _apiService.updateProject(
                    id: project.id,
                    name: nameController.text.trim(),
                    location: locationController.text.trim().isEmpty
                        ? null
                        : locationController.text.trim(),
                    startDate: startDate,
                    endDate: endDate,
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    _loadProjects();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Project updated successfully')),
                    );
                  }
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          error is ApiException
                              ? error.message
                              : 'Failed to update project',
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

  Future<void> _deleteProject(Project project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.name}"?'),
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
        await _apiService.deleteProject(project.id);
        if (mounted) {
          _loadProjects();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project deleted successfully')),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                error is ApiException
                    ? error.message
                    : 'Failed to delete project',
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
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadProjects,
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
                        onPressed: _loadProjects,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _projects.isEmpty
                  ? Center(
                      child: Text(
                        'No projects found',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadProjects,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _projects.length,
                        itemBuilder: (context, index) {
                          final project = _projects[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(
                                project.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (project.location != null &&
                                      project.location!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 16),
                                          const SizedBox(width: 4),
                                          Text(project.location!),
                                        ],
                                      ),
                                    ),
                                  if (project.startDate != null ||
                                      project.endDate != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.calendar_today, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            project.startDate != null &&
                                                    project.endDate != null
                                                ? '${_dateFormat.format(project.startDate!)} - ${_dateFormat.format(project.endDate!)}'
                                                : project.startDate != null
                                                    ? 'From ${_dateFormat.format(project.startDate!)}'
                                                    : project.endDate != null
                                                        ? 'Until ${_dateFormat.format(project.endDate!)}'
                                                        : '',
                                          ),
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
                                    onPressed: () => _showEditDialog(project),
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteProject(project),
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
        tooltip: 'Add Project',
      ),
    );
  }
}

