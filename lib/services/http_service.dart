import 'dart:convert';
import 'package:flutter_app/models/address.dart';
import 'package:http/http.dart';
// import 'post_model.dart';

class HttpService {
  // final String postsURL = "https://jsonplaceholder.typicode.com/posts";
  final String url_geocode = "https://nominatim.openstreetmap.org/search";

  Future<List<Address>> getPosts(String searchTerm) async {
    final String urlParameters = "$url_geocode?q=$searchTerm&limit=5&format=json";
    Response res = await get(urlParameters);

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);

      print(body);
      List<Address> posts = body
          .map(
            (dynamic item) => Address.fromJson(item),
      )
          .toList();

      return posts;
    } else {
      throw "Unable to retrieve posts.";
    }
  }
}