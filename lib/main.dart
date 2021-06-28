import 'package:flutter/material.dart';
import 'package:soccer/api_handel/api_manager.dart';
import 'package:soccer/routes.dart';
import 'package:soccer/widgets/mydrawer.dart';
import 'package:soccer/widgets/pagebody.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: routes,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        iconTheme: IconThemeData(
          color: Colors.black
        )
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
        future: SoccerApi().getLiveMatches(),
        builder: (context, snapShot) {
          if (snapShot.hasData) {
            print("snap shot: ${snapShot.data}");
            return RefreshIndicator(onRefresh: SoccerApi().getLiveMatches,child: pageBody(snapShot.data));
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
