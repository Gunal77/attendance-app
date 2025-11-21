import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../projects/presentation/providers/projects_providers.dart';
import '../providers/workers_providers.dart';

class AssignProjectDialog extends ConsumerStatefulWidget {
  final String workerId;
  final String? currentProjectId;

  const AssignProjectDialog({
    super.key,
    required this.workerId,
    this.currentProjectId,
  });

  @override
  ConsumerState<AssignProjectDialog> createState() => _AssignProjectDialogState();
}

class _AssignProjectDialogState extends ConsumerState<AssignProjectDialog> {
  String? selectedProjectId;

  @override
  void initState() {
    super.initState();
    selectedProjectId = widget.currentProjectId;
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);

    return AlertDialog(
      title: const Text('Assign Project'),
      content: SizedBox(
        width: double.maxFinite,
        child: projectsAsync.when(
          data: (projects) {
            if (projects.isEmpty) {
              return const Text('No projects available');
            }

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select a project to assign:'),
                  const SizedBox(height: 16),
                  ...projects.map((project) => RadioListTile<String>(
                    title: Text(project.name),
                    subtitle: project.location != null
                        ? Text(project.location!, style: const TextStyle(fontSize: 12))
                        : null,
                    value: project.id,
                    groupValue: selectedProjectId,
                    onChanged: (value) {
                      setState(() {
                        selectedProjectId = value;
                      });
                    },
                  )),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.cancel),
                    title: const Text('Remove from project'),
                    onTap: () {
                      setState(() {
                        selectedProjectId = null;
                      });
                    },
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error loading projects: $error'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedProjectId == widget.currentProjectId
              ? null
              : () async {
                  if (selectedProjectId == null) {
                    // Remove project
                    await _removeProject(context);
                  } else {
                    // Assign project
                    await _assignProject(context, selectedProjectId!);
                  }
                },
          child: Text(selectedProjectId == null ? 'Remove' : 'Assign'),
        ),
      ],
    );
  }

  Future<void> _assignProject(BuildContext context, String projectId) async {
    try {
      await ref.read(
        assignProjectProvider(AssignProjectParams(
          workerId: widget.workerId,
          projectId: projectId,
        )).future,
      );

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project assigned successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to assign project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeProject(BuildContext context) async {
    try {
      await ref.read(removeProjectProvider(widget.workerId).future);

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project removed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

