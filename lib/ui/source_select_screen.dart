import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shipment_mate/domain/db_provider.dart';

import '../domain/data_sources_provider.dart';
import 'import_data_dialog.dart';

class SourceSelectScreen extends ConsumerWidget {
  const SourceSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataSourcesAsync = ref.watch(dataSourcesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Data Source')),
      body: Column(
        children: [
          Expanded(
            child: dataSourcesAsync.when(
              data: (files) {
                if (files.isEmpty) {
                  return const Center(child: Text('No data sources found'));
                }
                return ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    return ListTile(
                      leading: const Icon(Icons.insert_drive_file),
                      title: Text(file.path.split('/').last),
                      subtitle: Text(file.path),
                      onTap: () async {
                        ref.read(dbPathProvider.notifier).state = file.path;
                      },
                      onLongPress: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Data Source'),
                            content: Text(
                                'Are you sure you want to delete ${file.path.split('/').last}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          if (ref.read(dbPathProvider) == file.path) {
                            ref.read(dbPathProvider.notifier).state = null;
                          }
                          await file.delete();
                          ref.invalidate(dataSourcesProvider);
                        }
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await FilePicker.pickFile(
                    type: FileType.custom,
                    allowedExtensions: ['xlsx'],
                  );

                  final path = result?.path;
                  if (path != null) {
                    final file = File(path);
                    if (context.mounted) {
                      final imported = await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            ImportDataDialog(sourceFile: file),
                      );

                      if (imported == true) {
                        ref.invalidate(dataSourcesProvider);
                      }
                    }
                  }
                },
                child: const Text('Import Data Source'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
