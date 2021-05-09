import 'DbHelper.dart';
import 'package:sqflite/sqflite.dart';

class Variable{
  final String nombre_campo;
  final String nombre_variable;

  Variable({this.nombre_campo, this.nombre_variable});


  Variable.fromMap(Map<String,dynamic> res)
      :nombre_campo = res["variable"],
        nombre_variable = res["desc"];

  Map<String,Object> toMap(){
    return {
      'variable':nombre_campo,
      "desc": nombre_variable
    };
  }

  Future<List<Variable>> retrieveNombreByVariable(String variable) async {
    final Database db = await DbHelper().initDb();
    final List<Map<String, Object>> queryResult = await db.query("variables_nombre",where:'lower(variable) = ?',whereArgs: [variable.toLowerCase()]);
    return queryResult.map((e) => Variable.fromMap(e)).toList();
  }
}

class Rango{
  final String nombre_campo;
  final int min;
  final int max;
  final String color;

  Rango({this.nombre_campo, this.min, this.max, this.color});


  Rango.fromMap(Map<String,dynamic> res)
      :nombre_campo = res["variable"],
        min = res["min"],
        max = res["max"],
        color = res["color"];

  Map<String,Object> toMap(){
    return {
      'variable':nombre_campo,
      "min": min,
      "max": max,
      "color": color
    };
  }

  Future<List<Rango>> retrieveRangoByVariable(String variable) async {
    final Database db = await DbHelper().initDb();
    final List<Map<String, Object>> queryResult = await db.query("variables_rango",where:'lower(variable) = ?',whereArgs: [variable.toLowerCase()]);
    return queryResult.map((e) => Rango.fromMap(e)).toList();
  }
}