import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shipment_mate/data/data_file_converter_xlsx.dart';
import 'package:shipment_mate/data/db_sembast.dart';

class ImportDataDialog extends StatefulWidget {
  final File sourceFile;

  const ImportDataDialog({super.key, required this.sourceFile});

  @override
  State<ImportDataDialog> createState() => _ImportDataDialogState();
}

class _ImportDataDialogState extends State<ImportDataDialog> {
  int _progress = 0;
  String _message = 'Starting import...';
  final TextEditingController _logController = TextEditingController();
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    _startImport();
  }

  Future<void> _startImport() async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = p.basenameWithoutExtension(widget.sourceFile.path);
    final dbPath = p.join(appDir.path, '$fileName.db');
    final db = DbSembast();

    Future<void> cleanup() async {
      await db.close();
      final file = File(dbPath);
      if (await file.exists()) {
        await file.delete();
      }
    }

    try {
      await db.openDbFromFile(path: dbPath);

      final converter = DataFileConverterXlsx();
      await converter.convert(
        source: widget.sourceFile,
        db: db,
        onProgress: ({message, precent}) {
          if (!mounted) return;
          setState(() {
            if (precent != null) _progress = precent;
            if (message != null) {
              _message = message;
              _logController.text += '$message\n';
            }
          });
        },
        onComplete: () {
          if (!mounted) return;
          setState(() {
            _isDone = true;
            _message = 'Import completed successfully!';
            _logController.text += 'DONE.\n';
          });
        },
        onError: ({required message}) async {
          await cleanup();
          if (!mounted) return;
          setState(() {
            _isDone = true;
            _message = 'Error: $message';
            _logController.text += 'ERROR: $message (Cleanup done)\n';
          });
        },
      );
    } catch (e) {
      await cleanup();
      if (mounted) {
        setState(() {
          _isDone = true;
          _message = 'Critical Error: $e';
          _logController.text += 'CRITICAL ERROR: $e (Cleanup done)\n';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Importing Data'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(value: _progress / 100),
            const SizedBox(height: 16),
            Text(_message),
            const SizedBox(height: 16),
            TextField(
              controller: _logController,
              readOnly: true,
              maxLines: 10,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Logs will appear here...',
              ),
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isDone ? () => Navigator.of(context).pop(true) : null,
          child: const Text('Close'),
        ),
      ],
    );
  }
}
