import 'package:flutter/material.dart';
import 'package:shipment_mate/domain/entities/data_field.dart';
import 'package:shipment_mate/domain/entities/item_data.dart';
import 'package:shipment_mate/ui/scanner_dialog.dart';

class SearchBottomSheet extends StatefulWidget {
  final Map<String, dynamic> activeFilters;
  final Function(String, dynamic) onAddFilter;
  final Function(String) onRemoveFilter;
  final VoidCallback onApply;

  const SearchBottomSheet({
    super.key,
    required this.activeFilters,
    required this.onAddFilter,
    required this.onRemoveFilter,
    required this.onApply,
  });

  @override
  State<SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<SearchBottomSheet> {
  DataField? _selectedField;
  final TextEditingController _valueController = TextEditingController();

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _selectedField = ItemData.fields.firstWhere((f) => f.title == "Handling Unit");
    super.initState();
  }

  void _addCurrentFilter() {
    if (_selectedField != null && _valueController.text.isNotEmpty) {
      final value = _selectedField!.type.fromDataSource(_valueController.text);
      widget.onAddFilter(_selectedField!.title, value);
      _valueController.clear();
      setState(() {
        _selectedField = null;
      });
    }
  }

  Future<void> _scanFromCamera() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const ScannerDialog()),
    );
    if (result != null && mounted) {
      setState(() {
        _valueController.text = result;
      });
      _addCurrentFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: DropdownButtonFormField<DataField>(
                  initialValue: _selectedField,
                  decoration: const InputDecoration(labelText: 'Select Field'),
                  items: ItemData.fields.map((field) {
                    return DropdownMenuItem(
                      value: field,
                      child: Text(field.title),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedField = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _valueController,
                  decoration: InputDecoration(
                    labelText: 'Value',
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _scanFromCamera,
                          icon: const Icon(Icons.camera_alt),
                        ),
                        IconButton(
                          onPressed: _addCurrentFilter,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                  onSubmitted: (_) => _addCurrentFilter(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: widget.activeFilters.entries.map((entry) {
              final field = ItemData.fields.firstWhere(
                (f) => f.title == entry.key,
              );
              return InputChip(
                label: Text(
                  '${entry.key}: ${field.type.toDisplayString(entry.value)}',
                ),
                onPressed: () {
                  setState(() {
                    _selectedField = field;
                    _valueController.text =
                        field.type.toDisplayString(entry.value);
                  });
                },
                onDeleted: () {
                  setState(() {
                    widget.onRemoveFilter(entry.key);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              widget.onApply();
              Navigator.pop(context);
            },
            child: const Text('Filter'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
