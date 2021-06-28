import 'package:flutter/material.dart';
import 'package:soccer/api_handel/api_manager.dart';
import 'package:soccer/widgets/mydrawer.dart';
import 'package:soccer/widgets/pagebody.dart';
class W2020 extends StatefulWidget {

  static const routeName='/w2020';

  @override
  _W2020State createState() => _W2020State();
}

class _W2020State extends State<W2020> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: Colors.black
        ),
        backgroundColor: Color(0xFFFAFAFA),
        elevation: 0,
        title: Text(
          "SOCCERBOARD",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: SoccerApi().getSeason2020matches(),
        builder: (context, snapShot) {
          if (snapShot.hasData) {
            print("snap shot: ${snapShot.data}");
            return RefreshIndicator(onRefresh: SoccerApi().getSeason2020matches,child: pageBody(snapShot.data));
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      drawer: MyDrawer(),
    );
  }
}
