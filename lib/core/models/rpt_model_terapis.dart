import 'package:cloud_firestore/cloud_firestore.dart';

class RPTModel {
  final String id;
  final String childName;
  final String terapiType;
  final String status;
  final String tujuanProgram;
  final String therapistId;
  final String therapistName;
  final List<TitleModel> titles;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  RPTModel({
    required this.id,
    required this.childName,
    required this.terapiType,
    required this.status,
    required this.tujuanProgram,
    required this.therapistId,
    required this.therapistName,
    this.titles = const [],
    required this.createdAt,
    this.reviewedAt,
  });

  factory RPTModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RPTModel(
      id: doc.id,
      childName: data['childName'] ?? '',
      terapiType: data['terapiType'] ?? '',
      status: data['status'] ?? 'pending',
      tujuanProgram: data['tujuanProgram'] ?? '',
      therapistId: data['therapistId'] ?? '',
      therapistName: data['therapistName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      reviewedAt: data['reviewedAt'] != null
          ? (data['reviewedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'childName': childName,
      'terapiType': terapiType,
      'status': status,
      'tujuanProgram': tujuanProgram,
      'therapistId': therapistId,
      'therapistName': therapistName,
      'createdAt': Timestamp.fromDate(createdAt),
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
    };
  }

  RPTModel copyWith({
    String? id,
    String? childName,
    String? terapiType,
    String? status,
    String? tujuanProgram,
    String? therapistId,
    String? therapistName,
    List<TitleModel>? titles,
    DateTime? createdAt,
    DateTime? reviewedAt,
  }) {
    return RPTModel(
      id: id ?? this.id,
      childName: childName ?? this.childName,
      terapiType: terapiType ?? this.terapiType,
      status: status ?? this.status,
      tujuanProgram: tujuanProgram ?? this.tujuanProgram,
      therapistId: therapistId ?? this.therapistId,
      therapistName: therapistName ?? this.therapistName,
      titles: titles ?? this.titles,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}

class TitleModel {
  final String id;
  final String title;
  final List<SubtitleModel> subtitles;
  final bool isCompleted;
  final DateTime? completedAt;

  TitleModel({
    required this.id,
    required this.title,
    this.subtitles = const [],
    this.isCompleted = false,
    this.completedAt,
  });

  factory TitleModel.fromFirestore(
      DocumentSnapshot doc, List<SubtitleModel> subtitles) {
    final data = doc.data() as Map<String, dynamic>;
    return TitleModel(
      id: doc.id,
      title: data['title'] ?? '',
      subtitles: subtitles,
      isCompleted: data['isCompleted'] ?? false,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  bool get allSubtitlesCompleted => subtitles.every((s) => s.isCompleted);
}

class SubtitleModel {
  final String id;
  final String titleId; // Tambahkan titleId
  final String subtitle;
  final bool isCompleted;
  final DateTime? completedAt;
  final List<ActivityModel> activities;
  final List<RatingModel>? ratings;
  final DateTime createdAt;
  final DateTime? endDate;
  final String? startNote;
  final String? endNote;

  SubtitleModel({
    required this.id,
    required this.titleId, // Tambahkan di constructor
    required this.subtitle,
    this.isCompleted = false,
    this.completedAt,
    this.activities = const [],
    this.ratings,
    required this.createdAt,
    this.endDate,
    this.startNote,
    this.endNote,
  });

  factory SubtitleModel.fromFirestore(
    DocumentSnapshot doc, {
    List<ActivityModel> activities = const [],
    List<RatingModel>? ratings,
  }) {
    final data = doc.data() as Map<String, dynamic>;
    return SubtitleModel(
      id: doc.id,
      titleId: data['titleId'] ?? '', // Tambahkan parsing titleId
      subtitle: data['subtitle'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      activities: activities,
      ratings: ratings,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      startNote: data['startNote'],
      endNote: data['endNote'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subtitle': subtitle,
      'titleId': titleId, // Tambahkan titleId ke map
      'isCompleted': isCompleted,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'startNote': startNote,
      'endNote': endNote,
    };
  }

  SubtitleModel copyWith({
    String? id,
    String? titleId,
    String? subtitle,
    bool? isCompleted,
    DateTime? completedAt,
    List<ActivityModel>? activities,
    List<RatingModel>? ratings,
    DateTime? createdAt,
    DateTime? endDate,
    String? startNote,
    String? endNote,
  }) {
    return SubtitleModel(
      id: id ?? this.id,
      titleId: titleId ?? this.titleId,
      subtitle: subtitle ?? this.subtitle,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      activities: activities ?? this.activities,
      ratings: ratings ?? this.ratings,
      createdAt: createdAt ?? this.createdAt,
      endDate: endDate ?? this.endDate,
      startNote: startNote ?? this.startNote,
      endNote: endNote ?? this.endNote,
    );
  }

  bool get hasActivities => activities.isNotEmpty;
  bool get allActivitiesRated =>
      activities.every((activity) => activity.ratings.isNotEmpty);
  bool get canBeCompleted =>
      hasActivities ? allActivitiesRated : (ratings?.isNotEmpty ?? false);
  bool get hasEndDate => endDate != null;
}

class ActivityModel {
  final String id;
  final String description;
  final bool isCompleted;
  final DateTime? completedAt;
  final List<RatingModel> ratings;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ActivityModel({
    required this.id,
    required this.description,
    this.isCompleted = false,
    this.completedAt,
    this.ratings = const [],
    required this.createdAt,
    this.updatedAt,
  });

  factory ActivityModel.fromFirestore(
    DocumentSnapshot doc, {
    List<RatingModel> ratings = const [],
  }) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityModel(
      id: doc.id,
      description: data['description'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      ratings: ratings,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'isCompleted': isCompleted,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  bool get hasRating => ratings.isNotEmpty;
  RatingModel? get latestRating => ratings.isEmpty
      ? null
      : ratings.reduce((value, element) =>
          value.date.isAfter(element.date) ? value : element);
}

class RatingModel {
  final String id;
  final double value;
  final String? notes;
  final DateTime date;
  final String therapistId;
  final String therapistName;
  final DateTime? updatedAt;

  RatingModel({
    required this.id,
    required this.value,
    this.notes,
    required this.date,
    required this.therapistId,
    required this.therapistName,
    this.updatedAt,
  });

  factory RatingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RatingModel(
      id: doc.id,
      value: (data['value'] ?? 0).toDouble(),
      notes: data['notes'],
      date: (data['date'] as Timestamp).toDate(),
      therapistId: data['therapistId'] ?? '',
      therapistName: data['therapistName'] ?? '',
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'notes': notes,
      'date': Timestamp.fromDate(date),
      'therapistId': therapistId,
      'therapistName': therapistName,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
