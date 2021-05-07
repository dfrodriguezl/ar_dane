import 'dart:typed_data';

import 'package:flutter_app/models/DbHelper.dart';
import 'package:sqflite/sqflite.dart';

class Manzana {
  final int ogc_id;
  final String cod_dane_a;
  final String dpt_ccdgo;
  final String mpio_ccdgo;
  final double latitud;
  final double longitud;
  final int ctnencuest;
  final int tvivienda;
  final int tp16_hog;
  final int tp27_perso;
  final int personas_l;
  final Uint8List geometry;


  Manzana(
  {this.ogc_id,
      this.cod_dane_a,
      this.dpt_ccdgo,
      this.mpio_ccdgo,
      this.latitud,
      this.longitud,
      this.ctnencuest,
      this.tvivienda,
      this.tp16_hog,
      this.tp27_perso,
      this.personas_l,
      this.geometry});

  Manzana.fromMap(Map<String,dynamic> res)
    :   ogc_id = res["ogc_id"],
        cod_dane_a = res["cod_dane_a"],
        dpt_ccdgo = res["dpt_ccdgo"],
        mpio_ccdgo = res["mpio_cdpmp"],
        latitud = res["latitud"],
        longitud = res["longitud"],
        ctnencuest = res["ctnencuest"],
        tvivienda = res["tvivienda"],
        tp16_hog = res["tp16_hog"],
        tp27_perso = res["tp27_perso"],
        personas_l = res["personas_l"],
        geometry = res["GEOMETRY"];

  Map<String,Object> toMap(){
    return {
      'ogc_id':ogc_id,
      "cod_dane_a": cod_dane_a,
      "dpt_ccdgo": dpt_ccdgo,
      "mpio_ccdgo": mpio_ccdgo,
      "latitud": latitud,
      "longitud": longitud,
      "ctnencuest": ctnencuest,
      "tvivienda":tvivienda,
      "tp16_hog":tp16_hog,
      "tp27_perso":tp27_perso,
      "personas_l":personas_l,
      "geometry": geometry
    };
  }

  Future<List<Manzana>> retrieveManzanas(double startLat, double startLon,double endLat, double endLon) async {
    final Database db = await DbHelper().initDb();
    final List<Map<String, Object>> queryResult = await db.query("'11'",where:'latitud between ? and ? and longitud between ? and ?',whereArgs: [startLat,endLat,startLon,endLon]);
    return queryResult.map((e) => Manzana.fromMap(e)).toList();
  }
}