import 'package:flutter/material.dart';
import 'package:soccer/widgets/goalstat.dart';
import 'package:soccer/widgets/teamstat.dart';

import '../models/soccermodel.dart';
import 'match_tile.dart';

Widget pageBody(List<SoccerMatch>? allMatches) {
  return Column(
    children: [
      Expanded(
        flex: 2,
        child: Container(
          child: allMatches!.isEmpty?Text("no matches today"):Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                teamStat("Local Team", allMatches![0].home.logUrl,
                    allMatches[0].home.name),
                goalStat(allMatches[0].fixture.status.elapsedTime,
                    allMatches[0].goal.home, allMatches[0].goal.away),
                teamStat("Visitor Team", allMatches[0].away.logUrl,
                    allMatches[0].away.name),
              ],
            ),
          ),
        ),
      ),
      Expanded(
        flex: 5,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFF25A7C7),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40)),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "MATCHES",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: allMatches.length,
                    itemBuilder: (context,index){
                      return matchTile(allMatches[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
