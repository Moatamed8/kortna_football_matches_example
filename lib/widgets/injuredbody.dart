

import 'package:flutter/material.dart';
import 'package:soccer/models/injplayers.dart';
import 'package:soccer/widgets/player_item.dart';

Widget injuredBody(List<InjuPlayer> allInjured) {

  return  ListView.builder(
    itemCount: allInjured.length,
    itemBuilder: (context,index){
      return playerItem(allInjured[index]);
    },
  );

}
