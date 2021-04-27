



import 'package:flutter/material.dart';

class Address extends ChangeNotifier{
  final int place_id;
  final int osm_id;
  final List<dynamic> bounding_box;
  final String lat;
  final String lon;
  final String display_name;

  Address({this.place_id, this.osm_id, this.bounding_box, this.lat, this.lon,
      this.display_name});


  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      place_id: json['place_id'],
      osm_id: json['osm_id'],
      bounding_box: json['boundingbox'],
      lat: json['lat'],
      lon: json['lon'],
      display_name: json['display_name'],
    );
  }
}
