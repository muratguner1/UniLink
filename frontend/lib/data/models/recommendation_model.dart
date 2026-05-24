class RecommendationModel {
  final String studentId;
  final String name;
  final String department;
  final int mutualFriends;
  final int commonClubs;
  final int score;

  const RecommendationModel({
    required this.studentId,
    required this.name,
    required this.department,
    required this.mutualFriends,
    required this.commonClubs,
    required this.score,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) =>
      RecommendationModel(
        studentId:     json['studentId']     as String,
        name:          json['name']          as String,
        department:    json['department']    as String,
        mutualFriends: (json['mutualFriends'] as num).toInt(),
        commonClubs:   (json['commonClubs']   as num).toInt(),
        score:         (json['score']         as num).toInt(),
      );

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }
}

class FriendModel {
  final String studentId;
  final String name;
  final String department;
  final int mutualFriends;

  const FriendModel({
    required this.studentId,
    required this.name,
    required this.department,
    required this.mutualFriends,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) => FriendModel(
        studentId:    json['studentId']    as String,
        name:         json['name']         as String,
        department:   json['department']   as String,
        mutualFriends:(json['mutualFriends'] as num).toInt(),
      );

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }
}

class PendingRequestModel {
  final String studentId;
  final String name;
  final String department;
  final String friendshipId;
  final String since;

  const PendingRequestModel({
    required this.studentId,
    required this.name,
    required this.department,
    required this.friendshipId,
    required this.since,
  });

  factory PendingRequestModel.fromJson(Map<String, dynamic> json) =>
      PendingRequestModel(
        studentId:    json['studentId']    as String,
        name:         json['name']         as String,
        department:   json['department']   as String,
        friendshipId: json['friendshipId'] as String,
        since:        json['since']        as String,
      );

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }
}

class ConnectionPathModel {
  final List<String> chain;
  final int hops;

  const ConnectionPathModel({required this.chain, required this.hops});

  factory ConnectionPathModel.fromJson(Map<String, dynamic> json) =>
      ConnectionPathModel(
        chain: (json['chain'] as List).cast<String>(),
        hops:  (json['hops'] as num).toInt(),
      );
}
