import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:soccer/models/injplayers.dart';
import 'package:soccer/models/soccermodel.dart';

class SoccerApi {
  //season=2020&league=39
  //"https://v3.football.api-sports.io/fixtures?season=2020&league=39"


  final String apiUrl = "https://v3.football.api-sports.io/fixtures?live=all";

  static const api_key = 'e8152b4aacc47c7a7dc06a2c496f10a0';

  static const headers = {
    'x-rapidapi-host': "v3.football.api-sports.io",
    'x-rapidapi-key': api_key
  };

  Future<List<SoccerMatch>> getLiveMatches() async {
    var res = await http.get(Uri.parse(apiUrl), headers: headers);
    late List<SoccerMatch> matches=[];
    print(apiUrl);
    var body;
    if (res.statusCode == 200) {
      body = jsonDecode(res.body);
      List<dynamic> matchesList = body['response'];
       matches= matchesList
          .map((dynamic item) => SoccerMatch.fromJson(item))
          .toList();
    }
    return matches;

  }
  Future<List<InjuPlayer>> getInjured() async {
    var res = await http.get(Uri.parse("https://v3.football.api-sports.io/injuries?fixture=686314"), headers: headers);
    late List<InjuPlayer> matches=[];
    var body;
    if (res.statusCode == 200) {
      body = jsonDecode(res.body);
      List<dynamic> injList = body['response'];
      print("Api inju:$body");

      matches = injList
          .map((dynamic item) => InjuPlayer.fromJson(item))
          .toList();
    }
    return matches;

  }

  Future<List<SoccerMatch>> getSeasonmatches(String year) async {
    var res = await http.get(
        Uri.parse("https://v3.football.api-sports.io/fixtures?season=$year&league=39"),
        headers: headers);
    late List<SoccerMatch> matches=[];
    var body;
    if (res.statusCode == 200) {
      body = jsonDecode(res.body);
      List<dynamic> matchesList = body['response'];
       matches = matchesList
          .map((dynamic item) => SoccerMatch.fromJson(item))
          .toList();
    }
    return matches;

  }

  Future<List<SoccerMatch>> getSeason2021matches() async {
    return getSeasonmatches("2022");
  }

  Future<List<SoccerMatch>> getSeason2020matches() async {
    return getSeasonmatches("2021");
  }

  Future<List<SoccerMatch>> getSeason2019matches() async {
    return getSeasonmatches("2020");
  }

  Future<List<SoccerMatch>> getSeason2018matches() async {
    return getSeasonmatches("2019");
  }
}
