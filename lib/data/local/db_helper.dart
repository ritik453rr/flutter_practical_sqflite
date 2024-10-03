import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  /// Singleton pattern to ensure only one instance of DBHelper exists
  DBHelper._();
  static final DBHelper getInstance = DBHelper._();

  /// Table and Column names
  static const String TABLE_NOTE = "note";
  static const String COLUMN_NOTE_SNO = "s_no";
  static const String COLUMN_NOTE_TITLE = "title";
  static const String COLUMN_NOTE_DESCRIPTION = "description";

  Database? _myDB; // Database instance

  /// Opens the database; creates it if it doesn't exist
  Future<Database> getDB() async {
    _myDB ??= await _openDB();
    return _myDB!;
  }

  /// Initializes the database and creates the table if it doesn't exist
  Future<Database> _openDB() async {
    // Get the application documents directory
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, "noteDB.db");

    return await openDatabase(
      dbPath,
      onCreate: (db, version) async {
        // Create the notes table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS $TABLE_NOTE (
            $COLUMN_NOTE_SNO INTEGER PRIMARY KEY AUTOINCREMENT,
            $COLUMN_NOTE_TITLE TEXT,
            $COLUMN_NOTE_DESCRIPTION TEXT
          )
        ''');
        debugPrint("Table created: $TABLE_NOTE");
      },
      version: 1,
    );
  }

  /// Inserts a new note into the database
  Future<bool> addNote({
    required String mTitle,
    required String mDescription,
  }) async {
    var db = await getDB();
    int rowsAffected = await db.insert(TABLE_NOTE, {
      COLUMN_NOTE_TITLE: mTitle,
      COLUMN_NOTE_DESCRIPTION: mDescription,
    });

    if (rowsAffected > 0) {
      debugPrint("Note Added");
    }
    return rowsAffected > 0;
  }

  /// Fetches all notes from the database
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var db = await getDB();
    List<Map<String, dynamic>> mData = await db.query(TABLE_NOTE);
    return mData;
  }

  /// Updates an existing note in the database
  Future<bool> updateNote({
    required String title,
    required String description,
    required int id,
  }) async {
    var db = await getDB();
    int rowsAffected = await db.update(
      TABLE_NOTE,
      {
        COLUMN_NOTE_TITLE: title,
        COLUMN_NOTE_DESCRIPTION: description,
      },
      where: "$COLUMN_NOTE_SNO = ?",
      whereArgs: [id],
    );

    return rowsAffected > 0;
  }

  /// Deletes a note from the database
  Future<bool> deleteNote({required int id}) async {
    var db = await getDB();
    int rowsAffected = await db.delete(
      TABLE_NOTE,
      where: "$COLUMN_NOTE_SNO = ?",
      whereArgs: [id],
    );
    return rowsAffected > 0;
  }

  /// Deletes the entire database
  Future<void> deleteDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, "noteDB.db");
    await deleteDatabase(dbPath);
    debugPrint("Database deleted");
  }
}
