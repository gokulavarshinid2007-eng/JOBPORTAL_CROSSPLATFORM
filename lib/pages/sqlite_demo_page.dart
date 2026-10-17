import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class SqliteDemoPage extends StatefulWidget {
  const SqliteDemoPage({super.key});

  @override
  State<SqliteDemoPage> createState() => _SqliteDemoPageState();
}

class _SqliteDemoPageState extends State<SqliteDemoPage> {
  Database? _database;
  final TextEditingController _titleController = TextEditingController();

  List<Map<String, Object?>> _jobs = [];
  bool _ready = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      // Chrome uses the web adapter; Android uses the regular sqflite database.
      if (kIsWeb) {
        databaseFactory = databaseFactoryFfiWebNoWebWorker;
      }

      final databasePath = kIsWeb
          ? 'jobconnect_local.db'
          : path.join(await getDatabasesPath(), 'jobconnect_local.db');

      _database = await openDatabase(
        databasePath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE local_jobs (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL
            )
          ''');
        },
      );

      await _loadJobs();

      if (mounted) {
        setState(() => _ready = true);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = error.toString());
      }
    }
  }

  Future<void> _loadJobs() async {
    final rows = await _database!.query('local_jobs', orderBy: 'id DESC');
    if (mounted) {
      setState(() => _jobs = rows);
    }
  }

  Future<void> _addJob() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _database == null) return;

    setState(() => _saving = true);
    try {
      await _database!.insert('local_jobs', {'title': title});
      _titleController.clear();
      await _loadJobs();
    } catch (error) {
      _showMessage('Could not save job: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _editJob(Map<String, Object?> job) async {
    final controller = TextEditingController(text: job['title'] as String);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit local job'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Job title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (newTitle == null || newTitle.trim().isEmpty) return;

    await _database!.update(
      'local_jobs',
      {'title': newTitle.trim()},
      where: 'id = ?',
      whereArgs: [job['id']],
    );
    await _loadJobs();
    _showMessage('Job updated in SQLite.');
  }

  Future<void> _deleteJob(Object? id) async {
    await _database!.delete(
      'local_jobs',
      where: 'id = ?',
      whereArgs: [id],
    );
    await _loadJobs();
    _showMessage('Job deleted from SQLite.');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite Local Jobs Demo'),
        backgroundColor: const Color(0xFF0A3D62),
        foregroundColor: Colors.white,
      ),
      body: !_ready
          ? Center(
        child: _error == null
            ? const CircularProgressIndicator()
            : Padding(
          padding: const EdgeInsets.all(20),
          child: Text('SQLite could not start:\n$_error'),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add jobs to this device’s local SQLite database.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Job title',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) {
                _addJob();
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _saving ? null : _addJob,
              icon: const Icon(Icons.add),
              label: Text(_saving ? 'Saving…' : 'Add Local Job'),
            ),
            const Divider(height: 28),
            Text(
              'Saved jobs (${_jobs.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _jobs.isEmpty
                  ? const Center(
                child: Text('No local jobs yet. Add one above.'),
              )
                  : ListView.builder(
                itemCount: _jobs.length,
                itemBuilder: (context, index) {
                  final job = _jobs[index];
                  return Card(
                    child: ListTile(
                      title: Text(job['title'] as String),
                      subtitle:
                      const Text('Stored locally with SQLite'),
                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          IconButton(
                            tooltip: 'Edit',
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editJob(job),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () => _deleteJob(job['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}