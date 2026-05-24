class StudentModel {
  final String studentId;
  final String name;
  final String department;
  final int year;

  const StudentModel({
    required this.studentId,
    required this.name,
    required this.department,
    required this.year,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        studentId:  json['studentId']  as String,
        name:       json['name']       as String,
        department: json['department'] as String,
        year:       (json['year'] as num).toInt(),
      );

  /// Öğrencinin adını baş harflerine dönüştür (Avatar için)
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  String get yearLabel {
    switch (year) {
      case 1: return '1. Sınıf';
      case 2: return '2. Sınıf';
      case 3: return '3. Sınıf';
      case 4: return '4. Sınıf';
      default: return '$year. Sınıf';
    }
  }
}
