import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('muleba_leadership.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE admin (
        id INTEGER PRIMARY KEY,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        is_super_admin INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE otp_codes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        otp_code TEXT NOT NULL,
        created_at TEXT NOT NULL,
        used INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE districts (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE divisions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE wards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        division_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (division_id) REFERENCES divisions(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE leaders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        level_id INTEGER NOT NULL,
        level_type TEXT NOT NULL,
        position_index INTEGER NOT NULL,
        full_name TEXT NOT NULL DEFAULT '',
        phone_number TEXT NOT NULL DEFAULT '',
        email_address TEXT NOT NULL DEFAULT '',
        photo_path TEXT
      )
    ''');
    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    final hash = _hashPassword('admin123');
    await db.insert('admin', {'id': 1, 'username': 'JULIUS', 'password_hash': hash, 'is_super_admin': 0});
    final superHash = _hashPassword('Admin@2003');
    await db.insert('admin', {'id': 2, 'username': 'MKENYA', 'password_hash': superHash, 'is_super_admin': 1});
    await db.insert('districts', {'id': 1, 'name': 'WILAYA YA MULEBA'});
    for (int i = 0; i < 6; i++) {
      await db.insert('leaders', {
        'level_id': 1, 'level_type': 'district',
        'position_index': i, 'full_name': '', 'phone_number': '', 'email_address': '',
      });
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<bool> authenticate(String username, String password) async {
    final db = await database;
    final hash = _hashPassword(password);
    final result = await db.query('admin',
      where: 'username = ? AND password_hash = ?',
      whereArgs: [username.toUpperCase(), hash]);
    return result.isNotEmpty;
  }

  Future<bool> changePassword(String username, String oldPassword, String newPassword) async {
    final db = await database;
    final valid = await authenticate(username, oldPassword);
    if (!valid) return false;
    final hash = _hashPassword(newPassword);
    await db.update('admin', {'password_hash': hash},
      where: 'username = ?', whereArgs: [username.toUpperCase()]);
    return true;
  }

  Future<List<Division>> getDivisions() async {
    final db = await database;
    final maps = await db.query('divisions', orderBy: 'name ASC');
    return maps.map((m) => Division.fromMap(m)).toList();
  }

  Future<int> insertDivision(Division division) async {
    final db = await database;
    final id = await db.insert('divisions', division.toMap()..remove('id'));
    for (int i = 0; i < 6; i++) {
      await db.insert('leaders', {
        'level_id': id, 'level_type': 'division',
        'position_index': i, 'full_name': '', 'phone_number': '', 'email_address': '',
      });
    }
    return id;
  }

  Future<int> updateDivision(Division division) async {
    final db = await database;
    return await db.update('divisions', division.toMap(),
      where: 'id = ?', whereArgs: [division.id]);
  }

  Future<int> deleteDivision(int id) async {
    final db = await database;
    final wards = await getWardsByDivision(id);
    for (final ward in wards) {
      await db.delete('leaders',
        where: 'level_id = ? AND level_type = ?', whereArgs: [ward.id, 'ward']);
    }
    await db.delete('leaders',
      where: 'level_id = ? AND level_type = ?', whereArgs: [id, 'division']);
    return await db.delete('divisions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Ward>> getWardsByDivision(int divisionId) async {
    final db = await database;
    final maps = await db.query('wards',
      where: 'division_id = ?', whereArgs: [divisionId], orderBy: 'name ASC');
    return maps.map((m) => Ward.fromMap(m)).toList();
  }

  Future<List<Ward>> getAllWards() async {
    final db = await database;
    final maps = await db.query('wards', orderBy: 'name ASC');
    return maps.map((m) => Ward.fromMap(m)).toList();
  }

  Future<int> insertWard(Ward ward) async {
    final db = await database;
    final id = await db.insert('wards', ward.toMap()..remove('id'));
    for (int i = 0; i < 6; i++) {
      await db.insert('leaders', {
        'level_id': id, 'level_type': 'ward',
        'position_index': i, 'full_name': '', 'phone_number': '', 'email_address': '',
      });
    }
    return id;
  }

  Future<int> updateWard(Ward ward) async {
    final db = await database;
    return await db.update('wards', ward.toMap(), where: 'id = ?', whereArgs: [ward.id]);
  }

  Future<int> deleteWard(int id) async {
    final db = await database;
    await db.delete('leaders',
      where: 'level_id = ? AND level_type = ?', whereArgs: [id, 'ward']);
    return await db.delete('wards', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Leader>> getLeaders(int levelId, String levelType) async {
    final db = await database;
    final maps = await db.query('leaders',
      where: 'level_id = ? AND level_type = ?',
      whereArgs: [levelId, levelType],
      orderBy: 'position_index ASC');
    return maps.map((m) => Leader.fromMap(m)).toList();
  }

  Future<void> upsertLeader(Leader leader) async {
    final db = await database;
    if (leader.id != null) {
      await db.update('leaders', leader.toMap(),
        where: 'id = ?', whereArgs: [leader.id]);
    } else {
      final existing = await db.query('leaders',
        where: 'level_id = ? AND level_type = ? AND position_index = ?',
        whereArgs: [leader.levelId, leader.levelType, leader.positionIndex]);
      if (existing.isNotEmpty) {
        await db.update('leaders', leader.toMap(),
          where: 'level_id = ? AND level_type = ? AND position_index = ?',
          whereArgs: [leader.levelId, leader.levelType, leader.positionIndex]);
      } else {
        await db.insert('leaders', leader.toMap()..remove('id'));
      }
    }
  }

  Future<List<SearchResult>> searchLeaders({
    String? name, String? phone, int? divisionId, int? wardId,
  }) async {
    final db = await database;
    String where = "full_name != ''";
    List<dynamic> args = [];

    if (name != null && name.isNotEmpty) {
      where += ' AND LOWER(full_name) LIKE ?';
      args.add('%${name.toLowerCase()}%');
    }
    if (phone != null && phone.isNotEmpty) {
      where += ' AND phone_number LIKE ?';
      args.add('%$phone%');
    }
    if (wardId != null) {
      where += ' AND level_id = ? AND level_type = "ward"';
      args.add(wardId);
    } else if (divisionId != null) {
      final wards = await getWardsByDivision(divisionId);
      final wardIds = wards.map((w) => w.id).toList();
      if (wardIds.isNotEmpty) {
        where += ' AND ((level_id = ? AND level_type = "division") OR (level_id IN (${wardIds.join(",")}) AND level_type = "ward"))';
        args.add(divisionId);
      } else {
        where += ' AND level_id = ? AND level_type = "division"';
        args.add(divisionId);
      }
    }

    final maps = await db.query('leaders', where: where, whereArgs: args);
    final leaders = maps.map((m) => Leader.fromMap(m)).toList();
    final results = <SearchResult>[];

    for (final leader in leaders) {
      String levelName = 'WILAYA YA MULEBA';
      String? divisionName;
      if (leader.levelType == 'division') {
        final divMaps = await db.query('divisions', where: 'id = ?', whereArgs: [leader.levelId]);
        if (divMaps.isNotEmpty) levelName = divMaps.first['name'] as String;
      } else if (leader.levelType == 'ward') {
        final wardMaps = await db.query('wards', where: 'id = ?', whereArgs: [leader.levelId]);
        if (wardMaps.isNotEmpty) {
          final ward = Ward.fromMap(wardMaps.first);
          levelName = ward.name;
          final divMaps = await db.query('divisions', where: 'id = ?', whereArgs: [ward.divisionId]);
          if (divMaps.isNotEmpty) divisionName = divMaps.first['name'] as String;
        }
      }
      results.add(SearchResult(leader: leader, levelName: levelName, divisionName: divisionName));
    }
    return results;
  }

  Future<List<Map<String, dynamic>>> getAllLeadersForExport() async {
    final rows = <Map<String, dynamic>>[];
    final districtLeaders = await getLeaders(1, 'district');
    for (final l in districtLeaders) {
      if (!l.isEmpty) {
        rows.add({'Ngazi': 'Wilaya', 'Jina la Eneo': 'WILAYA YA MULEBA',
          'Tarafa': '-', 'Cheo': l.positionName, 'Jina Kamili': l.fullName,
          'Simu': l.phoneNumber, 'Barua Pepe': l.emailAddress});
      }
    }
    final divisions = await getDivisions();
    for (final div in divisions) {
      final leaders = await getLeaders(div.id!, 'division');
      for (final l in leaders) {
        if (!l.isEmpty) {
          rows.add({'Ngazi': 'Tarafa', 'Jina la Eneo': div.name,
            'Tarafa': div.name, 'Cheo': l.positionName, 'Jina Kamili': l.fullName,
            'Simu': l.phoneNumber, 'Barua Pepe': l.emailAddress});
        }
      }
      final wards = await getWardsByDivision(div.id!);
      for (final ward in wards) {
        final wLeaders = await getLeaders(ward.id!, 'ward');
        for (final l in wLeaders) {
          if (!l.isEmpty) {
            rows.add({'Ngazi': 'Kata', 'Jina la Eneo': ward.name,
              'Tarafa': div.name, 'Cheo': l.positionName, 'Jina Kamili': l.fullName,
              'Simu': l.phoneNumber, 'Barua Pepe': l.emailAddress});
          }
        }
      }
    }
    return rows;
  }

  Future<Map<String, int>> getStatistics() async {
    final db = await database;
    final divCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM divisions')) ?? 0;
    final wardCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM wards')) ?? 0;
    final leaderCount = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM leaders WHERE full_name != ''")) ?? 0;
    return {'divisions': divCount, 'wards': wardCount, 'leaders': leaderCount};
  }

  Future<String> getDbPath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, 'muleba_leadership.db');
  }

  Future<bool> backupDatabase(String destinationPath) async {
    try {
      final dbPath = await getDbPath();
      await File(dbPath).copy(destinationPath);
      return true;
    } catch (_) { return false; }
  }

  Future<bool> restoreDatabase(String sourcePath) async {
    try {
      await _database?.close();
      _database = null;
      final dbPath = await getDbPath();
      await File(sourcePath).copy(dbPath);
      _database = await openDatabase(dbPath);
      return true;
    } catch (_) { return false; }
  }
}
