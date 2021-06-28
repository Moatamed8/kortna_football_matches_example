import 'package:soccer/screen/2018.dart';
import 'package:soccer/screen/2019.dart';
import 'package:soccer/screen/2020.dart';
import 'package:soccer/screen/2021.dart';
import 'package:soccer/screen/about_screen.dart';
import 'package:soccer/screen/injuries.dart';

var routes = {
  W2021.routeName: (_) => W2021(),
  W2020.routeName: (_) => W2020(),
  W2019.routeName: (_) => W2019(),
  W2018.routeName: (_) => W2018(),
  Injuries.routeName: (_) => Injuries(),
  AboutScreen.routeName: (_) => AboutScreen(),


};
