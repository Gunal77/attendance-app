import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workers_providers.dart';
import '../widgets/assign_project_dialog.dart';

class WorkerDetailScreen extends ConsumerWidget {
  final String workerId;

  const WorkerDetailScreen({super.key, required this.workerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workerAsync = ref.watch(workerDetailProvider(workerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Details'),
      ),
      body: workerAsync.when(
        data: (worker) {
          if (worker == null) {
            return const Center(child: Text('Worker not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            worker.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          worker.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        if (worker.role != null) ...[
                          const SizedBox(height: 8),
                          Chip(
                            label: Text(worker.role!),
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _InfoSection(
                  title: 'Contact Information',
                  children: [
                    if (worker.email != null)
                      _InfoRow(icon: Icons.email, label: 'Email', value: worker.email!),
                    if (worker.phone != null)
                      _InfoRow(icon: Icons.phone, label: 'Phone', value: worker.phone!),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoSection(
                  title: 'Project Assignment',
                  children: [
                    _InfoRow(
                      icon: Icons.work,
                      label: 'Project',
                      value: worker.projectName,
                    ),
                    if (worker.projectLocation.isNotEmpty)
                      _InfoRow(
                        icon: Icons.location_on,
                        label: 'Location',
                        value: worker.projectLocation,
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AssignProjectDialog(
                                  workerId: worker.id,
                                  currentProjectId: worker.projectId,
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Assign/Change Project'),
                          ),
                        ),
                        if (worker.projectId != null) ...[
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () async {
                              try {
                                await ref.read(removeProjectProvider(worker.id).future);
                                if (context.mounted) {
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
                            },
                            icon: const Icon(Icons.remove_circle_outline),
                            label: const Text('Remove'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading worker details'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(workerDetailProvider(workerId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

