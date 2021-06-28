import 'package:flutter/material.dart';
import 'package:soccer/api_handel/api_manager.dart';
import 'package:soccer/widgets/mydrawer.dart';
import 'package:soccer/widgets/pagebody.dart';
class W2019 extends StatefulWidget {

  static const routeName='/w2019';

  @override
  _W2019State createState() => _W2019State();
}

class _W2019State extends State<W2019> {
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
        future: SoccerApi().getSeason2019matches(),
        builder: (context, snapShot) {
          if (snapShot.hasData) {
            print("snap shot: ${snapShot.data}");
            return RefreshIndicator(onRefresh: SoccerApi().getSeason2019matches,child: pageBody(snapShot.data));
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
