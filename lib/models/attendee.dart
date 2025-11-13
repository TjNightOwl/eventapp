class Attendee {
  final String id; // unique id encoded in QR
  final String? name;
  final bool checkedIn;
  final String? checkedInAt; // ISO timestamp

  Attendee({
    required this.id,
    this.name,
    this.checkedIn = false,
    this.checkedInAt,
  });

  Attendee copyWith({
    String? id,
    String? name,
    bool? checkedIn,
    String? checkedInAt,
  }) {
    return Attendee(
      id: id ?? this.id,
      name: name ?? this.name,
      checkedIn: checkedIn ?? this.checkedIn,
      checkedInAt: checkedInAt ?? this.checkedInAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'checkedIn': checkedIn ? 1 : 0,
      'checkedInAt': checkedInAt,
    };
  }

  factory Attendee.fromMap(Map<String, dynamic> map) {
    return Attendee(
      id: map['id'] as String,
      name: map['name'] as String?,
      checkedIn: (map['checkedIn'] as int?) == 1,
      checkedInAt: map['checkedInAt'] as String?,
    );
  }
}
