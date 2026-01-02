import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../models/vehicle.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  static final DatabaseFactory _webFactory = databaseFactoryFfiWeb;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      // For web, use the factory directly with a simple name
      return await _webFactory.openDatabase(
        'garage_master.db',
        options: OpenDatabaseOptions(
          version: 3,
          onCreate: (db, version) => _createDatabase(db, version),
          onUpgrade: (db, oldVersion, newVersion) =>
              _upgradeDatabase(db, oldVersion, newVersion),
        ),
      );
    } else {
      // For mobile, use the standard path approach
      final dbPath = await getDatabasesPath();
      final path = p.join(dbPath, 'garage_master.db');
      return await openDatabase(
        path,
        version: 3,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
      );
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS vehicles (
        vin TEXT PRIMARY KEY,
        licensePlate TEXT,
        description TEXT NOT NULL,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        year INTEGER NOT NULL,
        lastCheckup TEXT,
        nextCheckup TEXT,
        isInsured INTEGER DEFAULT 0,
        isTaxed INTEGER DEFAULT 0,
        hasPassed INTEGER DEFAULT 0,
        inStorage INTEGER DEFAULT 0,
        partNumbers TEXT,
        issues TEXT,
        todoList TEXT,
        shoppingList TEXT,
        notes TEXT,
        imagePath TEXT,
        isArchived INTEGER DEFAULT 0,
        fuelType TEXT
      )
    ''');
  }

  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE vehicles ADD COLUMN fuelType TEXT');
    }
    if (oldVersion < 3) {
      await db.execute(
          'ALTER TABLE vehicles ADD COLUMN hasPassed INTEGER DEFAULT 0');
      await db.execute(
          'ALTER TABLE vehicles ADD COLUMN inStorage INTEGER DEFAULT 0');
    }
  }

  // Create
  Future<void> insertVehicle(Vehicle vehicle) async {
    final db = await database;
    await db.insert(
      'vehicles',
      vehicle.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Read all
  Future<List<Vehicle>> getVehicles({bool includeArchived = false}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vehicles',
      where: includeArchived ? null : 'isArchived = ?',
      whereArgs: includeArchived ? null : [0],
      orderBy: 'licensePlate ASC, vin ASC',
    );
    return maps.map((map) => Vehicle.fromMap(map)).toList();
  }

  // Read archived only
  Future<List<Vehicle>> getArchivedVehicles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vehicles',
      where: 'isArchived = ?',
      whereArgs: [1],
      orderBy: 'licensePlate ASC, vin ASC',
    );
    return maps.map((map) => Vehicle.fromMap(map)).toList();
  }

  // Read single
  Future<Vehicle?> getVehicle(String vin) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vehicles',
      where: 'vin = ?',
      whereArgs: [vin],
    );
    if (maps.isEmpty) return null;
    return Vehicle.fromMap(maps.first);
  }

  // Update
  Future<void> updateVehicle(Vehicle vehicle) async {
    final db = await database;
    await db.update(
      'vehicles',
      vehicle.toMap(),
      where: 'vin = ?',
      whereArgs: [vehicle.vin],
    );
  }

  // Archive
  Future<void> archiveVehicle(String vin) async {
    final db = await database;
    await db.update(
      'vehicles',
      {'isArchived': 1},
      where: 'vin = ?',
      whereArgs: [vin],
    );
  }

  // Unarchive
  Future<void> unarchiveVehicle(String vin) async {
    final db = await database;
    await db.update(
      'vehicles',
      {'isArchived': 0},
      where: 'vin = ?',
      whereArgs: [vin],
    );
  }

  // Delete
  Future<void> deleteVehicle(String vin) async {
    final db = await database;
    await db.delete('vehicles', where: 'vin = ?', whereArgs: [vin]);
  }
}
