import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shipment_mate/domain/db_provider.dart';
import 'package:shipment_mate/domain/entities/item_data.dart';
import 'package:shipment_mate/ui/item_data_widget.dart';
import 'package:shipment_mate/ui/received_items_screen.dart';
import 'package:shipment_mate/ui/search_bottom_sheet.dart';
import 'package:collection/collection.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final Map<String, dynamic> _activeFilters = {};
  final List<ItemData> _results = [];
  bool _isSearching = false;

  Future<void> _performSearch() async {
    final dbAsync = ref.read(todosDbProvider);
    final db = dbAsync.value;
    if (db == null) return;

    setState(() {
      _isSearching = true;
      _results.clear();
    });

    try {
      final filters = ItemData(
        values: Map.from(_activeFilters),
        extraFields: {},
      );
      final stream = db.getEntries(table: 'items', filters: filters);

      await for (final item in stream) {
        if (!mounted) break;
        setState(() {
          _results.add(item);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Search failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _showSearchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SearchBottomSheet(
        activeFilters: _activeFilters,
        onAddFilter: (key, value) {
          setState(() {
            _activeFilters[key] = value;
          });
        },
        onRemoveFilter: (key) {
          setState(() {
            _activeFilters.remove(key);
          });
        },
        onApply: _performSearch,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbAsync = ref.watch(todosDbProvider);
    final groupedResults = groupBy(
      _results,
      (ItemData item) => item.requisitionNo,
    );
    final sortedPrNumbers = groupedResults.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search items'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReceivedItemsScreen()),
              );
            },
            icon: const Icon(Icons.inventory),
            tooltip: 'Received Items',
          ),
          IconButton(
            onPressed: () {
              ref.read(dbPathProvider.notifier).state = null;
            },
            icon: const Icon(Icons.close),
            tooltip: 'Close Database',
          ),
        ],
      ),
      body: dbAsync.when(
        data: (db) => Column(
          children: [
            if (_activeFilters.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 8,
                  children: _activeFilters.entries.map((entry) {
                    final field = ItemData.fields.firstWhere(
                      (f) => f.title == entry.key,
                    );
                    return Chip(
                      label: Text(
                        '${entry.key}: ${field.type.toDisplayString(entry.value)}',
                      ),
                      onDeleted: () {
                        setState(() {
                          _activeFilters.remove(entry.key);
                        });
                        _performSearch();
                      },
                    );
                  }).toList(),
                ),
              ),
            Expanded(
              child: _results.isEmpty && !_isSearching
                  ? const Center(
                      child: Text('No results found. Try filtering.'),
                    )
                  : ListView.builder(
                      itemCount: sortedPrNumbers.length,
                      itemBuilder: (context, index) {
                        final prNumber = sortedPrNumbers[index];
                        final items = groupedResults[prNumber]!;

                        return ExpansionTile(
                          title: Text(
                            'PR: $prNumber',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${items.length} items'),
                          initiallyExpanded: true,
                          children: items.map((item) {
                            return ItemDataWidget(item: item);
                          }).toList(),
                        );
                      },
                    ),
            ),
            if (_isSearching) const LinearProgressIndicator(),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSearchSheet,
        child: const Icon(Icons.search),
      ),
    );
  }
}
