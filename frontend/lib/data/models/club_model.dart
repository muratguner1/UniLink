class ClubModel {
  final String clubId;
  final String name;
  final String category;
  final int memberCount;
  bool isMember;

  ClubModel({
    required this.clubId,
    required this.name,
    required this.category,
    required this.memberCount,
    this.isMember = false,
  });

  factory ClubModel.fromJson(Map<String, dynamic> json) => ClubModel(
        clubId:      json['clubId']      as String,
        name:        json['name']        as String,
        category:    json['category']    as String,
        memberCount: (json['memberCount'] as num).toInt(),
        isMember:    json['isMember']    as bool? ?? false,
      );

  ClubModel copyWith({int? memberCount, bool? isMember}) => ClubModel(
        clubId:      clubId,
        name:        name,
        category:    category,
        memberCount: memberCount ?? this.memberCount,
        isMember:    isMember ?? this.isMember,
      );

  String get categoryEmoji {
    switch (category.toLowerCase()) {
      case 'teknoloji': return '💻';
      case 'sanat':     return '🎨';
      case 'oyun':      return '♟️';
      case 'i̇ş':
      case 'iş':        return '💼';
      case 'spor':      return '⚽';
      case 'çevre':     return '🌿';
      default:          return '🏛️';
    }
  }
}

class EventModel {
  final String eventId;
  final String title;
  final String date;
  final String venue;
  final String organizer;
  final String? clubId;
  final int attendeeCount;
  bool isAttending;

  EventModel({
    required this.eventId,
    required this.title,
    required this.date,
    required this.venue,
    required this.organizer,
    this.clubId,
    required this.attendeeCount,
    this.isAttending = false,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        eventId:      json['eventId']      as String,
        title:        json['title']        as String,
        date:         json['date']         as String,
        venue:        json['venue']        as String,
        organizer:    json['organizer']    as String,
        clubId:       json['clubId']       as String?,
        attendeeCount:(json['attendeeCount'] as num).toInt(),
        isAttending:  json['isAttending']  as bool? ?? false,
      );

  EventModel copyWith({int? attendeeCount, bool? isAttending}) => EventModel(
        eventId:      eventId,
        title:        title,
        date:         date,
        venue:        venue,
        organizer:    organizer,
        clubId:       clubId,
        attendeeCount:attendeeCount ?? this.attendeeCount,
        isAttending:  isAttending ?? this.isAttending,
      );
}
