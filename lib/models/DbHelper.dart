import 'dart:io';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper{

  Future initDb() async{
    final dbPath = await getDatabasesPath();
    final path = join(dbPath,"cnpv.db"); //db file name

    final exist = await databaseExists(path);

    if(exist){
      //database already exists
      //open database
      return await openDatabase(path);
    }else{
      // db does not exist, create a new one
      try{
        await Directory(dirname(path)).create(recursive: true);
      }catch(_){

      }

      ByteData data = await rootBundle.load(join("assets","cnpv.db"));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes,data.lengthInBytes);

      await File(path).writeAsBytes(bytes,flush:true);
    }

    return await openDatabase(path);
  }

  // Open the database and store the reference.
  // final Future<Database>  database async = openDatabase(
  //   // Set the path to the database. Note: Using the `join` function from the
  //   // `path` package is best practice to ensure the path is correctly
  //   // constructed for each platform.
  //     join(getDatabasesPath(), 'doggie_database.db'),
  // );
}

