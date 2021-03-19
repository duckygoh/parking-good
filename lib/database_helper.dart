import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'carpark.dart'; // class object

class DatabaseHelper {

  static DatabaseHelper _databaseHelper; // Singleton Database Helper
  static Database _database;

  String carparkTable = "carpark_table";
  String colId = "id";
  String colppCode = "ppCode";
  String colppName = "ppName";

  String colLatitude = "latitude";
  String colLongitude = "longitude";

  String colweekdayRate = "weekdayRate";
  String colsatdayRate = "satdayRate";
  String colsunPHRate = "sunPHRate";

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {

    if(_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null){
      _database = await initialiseDatabase();
    }
    return _database;
  }


  Future<Database> initialiseDatabase() async {
    // Get the directory path for both Android and IOS to store the database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'carpark.db';

    // Open / Create the database at a given path
    var carparkDatabase = await openDatabase(path, version: 1, onCreate: _createDb);

    return carparkDatabase;
  }
  
  void _createDb(Database db, int newVersion) async {
    
    await db.execute('CREATE TABLE $carparkTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$colppCode TEXT, $colppName TEXT, $colLatitude TEXT, $colLongitude TEXT, $colweekdayRate TEXT, '
        '$colsatdayRate TEXT, $colsunPHRate TEXT)');
  }

  // FETCH OPERATION: Get all carpark objects from database
  Future<List<Map<String, dynamic>>> getCarparkMapList() async {
    Database db = await this.database;

    var result = await db.rawQuery('SELECT * FROM $carparkTable order by $colppName ASC');
    //var result = await db.query(carparkTable, orderBy: '$colppName ASC');

    return result;
  }

  // Insert Operation: Insert a Carpark Object to database
  Future<int> insertCarpark(Carpark carpark) async {
    Database db = await this.database;
    var result = await db.insert(carparkTable, carpark.toMap());
    return result;
  }

  // Update Operation: Update a Carpark Object and save it to database
  Future<int> updateCarpark(Carpark carpark) async {
    var db = await this.database;
    var result = await db.update(carparkTable, carpark.toMap(), where: '$colId = ?', whereArgs: [carpark.id]);
    return result;
  }

  // Delete Operation: Delete a Carpark Object from database
  Future<int> deleteCarpark(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $carparkTable WHERE $colId = $id');
    return result;
  }

  // Get number of Carpark Object in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $carparkTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'BookmarkDetailLisst' [List<Carpark> ]
  Future<List<Carpark>> getCarparkList() async {

    var carparkMapList = await getCarparkMapList(); // Get the 'Map List' from database
    int count = carparkMapList.length; // count the number of map entries in db table

    List<Carpark> carparkList = List<Carpark>();
    // for loop to create a carpark list from a map list
    for (int i = 0; i < count; i++){
      carparkList.add(Carpark.fromMapObject(carparkMapList[i]));
    }

    return carparkList;

  }
}