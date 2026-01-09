import 'package:flutter/material.dart';
import '../../core/database/db_provider.dart';
import '../../features/family/repository/family_repository.dart';
// import '../../features/documents/repository/document_repository.dart'; // Not yet implemented

class DbDebugPage extends StatefulWidget {
  const DbDebugPage({super.key});

  @override
  State<DbDebugPage> createState() => _DbDebugPageState();
}

class _DbDebugPageState extends State<DbDebugPage> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final db = await DBProvider.database;
      
      final memberCount = await db.rawQuery('SELECT COUNT(*) as count FROM family_member');
      final documentCount = await db.rawQuery('SELECT COUNT(*) as count FROM document');
      final policyCount = await db.rawQuery('SELECT COUNT(*) as count FROM renewal_policy');
      
      final members = await FamilyRepository.getAll();
      // DocumentRepository not yet implemented
      // final documents = await DocumentRepository.getAll();
      
      setState(() {
        _stats = {
          'family_members': memberCount.first['count'],
          'documents': documentCount.first['count'],
          'policies': policyCount.first['count'],
          'members_list': members.map((m) => m.name).join(', '),
          // 'documents_list': documents.map((d) => d.documentType).join(', '),
        };
      });
    } catch (e) {
      setState(() {
        _stats = {'error': e.toString()};
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? const Center(child: Text('No data'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Database Statistics',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(),
                            ..._stats!.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        entry.key,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(entry.value.toString()),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'IndexedDB Info (Web)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Divider(),
                            Text(
                              'To view IndexedDB in Chrome:\n'
                              '1. Press F12 to open DevTools\n'
                              '2. Go to "Application" tab\n'
                              '3. Expand "IndexedDB" in the left sidebar\n'
                              '4. Look for "doc_reminder.db"\n'
                              '5. Click on tables to view data',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Card(
                      color: Colors.amber,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '⚠️ Important Notes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '• Data persists in browser storage\n'
                              '• "flutter clean" does NOT clear browser data\n'
                              '• Use Chrome DevTools to manually clear IndexedDB\n'
                              '• Different browser = different database\n'
                              '• Incognito mode = temporary database',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
