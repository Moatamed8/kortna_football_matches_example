class SoccerMatch {
  FixTure fixture;
  Team home;
  Team away;
  Goal goal;

  SoccerMatch(this.fixture, this.away, this.home, this.goal);

  factory SoccerMatch.fromJson(Map<String,dynamic>json){
    return SoccerMatch(
       FixTure.fromJson(json['fixture']),
       Team.fromJson(json['teams']['home']),
       Team.fromJson(json['teams']['away']),
       Goal.fromJson(json['goals']),
    );
  }
}

class FixTure {
  int id;
  String date;
  Status status;

  FixTure(this.id, this.date, this.status);

factory FixTure.fromJson(Map<String,dynamic>json){
  return FixTure(
     json['id'],
     json['date'],
     Status.fromJson(json['status'])
  );
}
  }

class Status {
  int elapsedTime;
  String long;

  Status(this.elapsedTime, this.long);

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status( json['elapsed'], json['long']);
  }
}

class Team {
  int id;
  String name;
  String logUrl;
  bool winner;

  Team(this.id, this.name, this.logUrl, this.winner);

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
         json['id'],
         json['name'],
         json['logo'],
         json['winner']);
  }
}

class Goal {
  int home;

  int away;

  Goal(this.home, this.away);

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal( json['home'],  json['away']);
  }
}
