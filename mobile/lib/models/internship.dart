class Internship {
  final String id;
  final String title;
  final String company;
  final String sector;
  final String location;
  final String duration;
  final String stipend;
  final List<String> requiredSkills;
  final String description;
  final double totalScore;
  final ScoreBreakdown scoreBreakdown;
  final String explanation;

  Internship({
    required this.id,
    required this.title,
    required this.company,
    required this.sector,
    required this.location,
    required this.duration,
    required this.stipend,
    required this.requiredSkills,
    required this.description,
    required this.totalScore,
    required this.scoreBreakdown,
    required this.explanation,
  });

  factory Internship.fromJson(Map<String, dynamic> json) {
    return Internship(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      sector: json['sector'] ?? '',
      location: json['location'] ?? '',
      duration: json['duration'] ?? '',
      stipend: json['stipend'] ?? '',
      requiredSkills: List<String>.from(json['required_skills'] ?? []),
      description: json['description'] ?? '',
      totalScore: (json['total_score'] ?? 0).toDouble(),
      scoreBreakdown: ScoreBreakdown.fromJson(json['score_breakdown'] ?? {}),
      explanation: json['explanation'] ?? '',
    );
  }
}

class ScoreBreakdown {
  final double skillMatch;
  final double sectorMatch;
  final double locationMatch;
  final double educationMatch;

  ScoreBreakdown({
    required this.skillMatch,
    required this.sectorMatch,
    required this.locationMatch,
    required this.educationMatch,
  });

  factory ScoreBreakdown.fromJson(Map<String, dynamic> json) {
    return ScoreBreakdown(
      skillMatch: (json['skill_match'] ?? 0).toDouble(),
      sectorMatch: (json['sector_match'] ?? 0).toDouble(),
      locationMatch: (json['location_match'] ?? 0).toDouble(),
      educationMatch: (json['education_match'] ?? 0).toDouble(),
    );
  }
}