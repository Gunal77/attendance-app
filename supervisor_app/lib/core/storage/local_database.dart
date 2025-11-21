import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';

/// Local SQLite Database for offline storage
class LocalDatabase {
  static LocalDatabase? _instance;
  static Database? _database;

  LocalDatabase._internal();

  factory LocalDatabase() {
    _instance ??= LocalDatabase._internal();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Workers table
    await db.execute('''
      CREATE TABLE workers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        role TEXT,
        project_id TEXT,
        created_at TEXT,
        assigned_at TEXT,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Projects table
    await db.execute('''
      CREATE TABLE projects (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        location TEXT,
        start_date TEXT,
        end_date TEXT,
        description TEXT,
        budget REAL,
        created_at TEXT,
        assigned_at TEXT,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Attendance table
    await db.execute('''
      CREATE TABLE attendance (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        check_in_time TEXT NOT NULL,
        check_out_time TEXT,
        image_url TEXT,
        latitude REAL,
        longitude REAL,
        created_at TEXT,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tasks table
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        worker_id TEXT NOT NULL,
        supervisor_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        status TEXT NOT NULL DEFAULT 'pending',
        due_date TEXT,
        assigned_at TEXT,
        completed_at TEXT,
        created_at TEXT,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Notifications table
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        supervisor_id TEXT NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        related_entity_type TEXT,
        related_entity_id TEXT,
        is_read INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Sync queue table for offline operations
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL,
        endpoint TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_workers_project_id ON workers(project_id)');
    await db.execute('CREATE INDEX idx_attendance_user_id ON attendance(user_id)');
    await db.execute('CREATE INDEX idx_tasks_project_id ON tasks(project_id)');
    await db.execute('CREATE INDEX idx_tasks_worker_id ON tasks(worker_id)');
    await db.execute('CREATE INDEX idx_notifications_supervisor_id ON notifications(supervisor_id)');
    await db.execute('CREATE INDEX idx_notifications_is_read ON notifications(is_read)');
    await db.execute('CREATE INDEX idx_sync_queue_synced ON sync_queue(synced)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < newVersion) {
      // Add migration logic
    }
  }

  // Workers CRUD
  Future<void> saveWorkers(List<Map<String, dynamic>> workers) async {
    final db = await database;
    final batch = db.batch();
    for (final worker in workers) {
      batch.insert(
        'workers',
        worker,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getWorkers() async {
    final db = await database;
    return await db.query('workers', orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getWorkerById(String id) async {
    final db = await database;
    final results = await db.query(
      'workers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Projects CRUD
  Future<void> saveProjects(List<Map<String, dynamic>> projects) async {
    final db = await database;
    final batch = db.batch();
    for (final project in projects) {
      batch.insert(
        'projects',
        project,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getProjects() async {
    final db = await database;
    return await db.query('projects', orderBy: 'created_at DESC');
  }

  // Attendance CRUD
  Future<void> saveAttendanceRecords(List<Map<String, dynamic>> attendance) async {
    final db = await database;
    final batch = db.batch();
    for (final record in attendance) {
      batch.insert(
        'attendance',
        record,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getAttendanceRecords({
    String? workerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    String? where;
    List<dynamic>? whereArgs;

    if (workerId != null) {
      where = 'user_id = ?';
      whereArgs = [workerId];
    }

    if (startDate != null && endDate != null) {
      where = where != null ? '$where AND check_in_time BETWEEN ? AND ?' : 'check_in_time BETWEEN ? AND ?';
      whereArgs = whereArgs != null
          ? [...whereArgs, startDate.toIso8601String(), endDate.toIso8601String()]
          : [startDate.toIso8601String(), endDate.toIso8601String()];
    }

    return await db.query(
      'attendance',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'check_in_time DESC',
    );
  }

  // Sync Queue
  Future<void> addToSyncQueue(String operation, String endpoint, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(
      'sync_queue',
      {
        'operation': operation,
        'endpoint': endpoint,
        'data': jsonEncode(data),
        'synced': 0,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    final db = await database;
    return await db.query(
      'sync_queue',
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'created_at ASC',
    );
  }

  Future<void> markSyncItemAsSynced(int id) async {
    final db = await database;
    await db.update(
      'sync_queue',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Clear all data
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('workers');
    await db.delete('projects');
    await db.delete('attendance');
    await db.delete('tasks');
    await db.delete('notifications');
    await db.delete('sync_queue');
  }

  // Helper function already imported from dart:convert
}

