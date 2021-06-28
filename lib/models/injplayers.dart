class InjuPlayer {
  PlayerId playerId;
  Team team;


  InjuPlayer(this.playerId, this.team);

  factory InjuPlayer.fromJson(Map<String, dynamic> json) {
    return InjuPlayer(
      PlayerId.fromJson(json['player']),
      Team.fromJson(json['team']),
    );
  }
}

class PlayerId {
  int id;
  String name;
  String photo;
  String type;
  String reason;

  PlayerId(this.id, this.name, this.photo, this.type, this.reason);

  factory PlayerId.fromJson(Map<String, dynamic> json) {
    return PlayerId(
      json['id'],
      json['name'],
      json['photo'],
      json['type'],
      json['reason'],
    );
  }
}



class Team {
  int id;
  String name;
  String logUrl;

  Team(this.id, this.name, this.logUrl);

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(json['id'], json['name'], json['logo']);
  }
}

