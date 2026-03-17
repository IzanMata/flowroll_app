enum ClassTypeEnum {
  gi('GI', 'Gi'),
  nogi('NOGI', 'No-Gi'),
  openMat('OPEN_MAT', 'Open Mat'),
  kids('KIDS', 'Kids'),
  competition('COMPETITION', 'Competition Prep');

  const ClassTypeEnum(this.value, this.label);
  final String value;
  final String label;

  static ClassTypeEnum? fromJson(String? v) =>
      v == null ? null : ClassTypeEnum.values.firstWhere((e) => e.value == v, orElse: () => ClassTypeEnum.gi);
}

enum MethodEnum {
  qr('QR'),
  manual('MANUAL');

  const MethodEnum(this.value);
  final String value;

  static MethodEnum? fromJson(String? v) =>
      v == null ? null : MethodEnum.values.firstWhere((e) => e.value == v, orElse: () => MethodEnum.manual);
}

enum DropInVisitorStatusEnum {
  pending('PENDING'),
  active('ACTIVE'),
  expired('EXPIRED');

  const DropInVisitorStatusEnum(this.value);
  final String value;

  static DropInVisitorStatusEnum fromJson(String v) =>
      DropInVisitorStatusEnum.values.firstWhere((e) => e.value == v, orElse: () => DropInVisitorStatusEnum.pending);
}

class TrainingClass {
  const TrainingClass({
    required this.id,
    required this.academy,
    required this.title,
    this.classType,
    this.professor,
    required this.professorUsername,
    required this.scheduledAt,
    this.durationMinutes,
    this.maxCapacity,
    this.notes,
    this.attendanceCount = 0,
    required this.createdAt,
  });

  final int id;
  final int academy;
  final String title;
  final ClassTypeEnum? classType;
  final int? professor;
  final String professorUsername;
  final DateTime scheduledAt;
  final int? durationMinutes;
  final int? maxCapacity;
  final String? notes;
  final int attendanceCount;
  final DateTime createdAt;

  factory TrainingClass.fromJson(Map<String, dynamic> json) => TrainingClass(
        id: json['id'] as int,
        academy: json['academy'] as int,
        title: json['title'] as String,
        classType: ClassTypeEnum.fromJson(json['class_type'] as String?),
        professor: json['professor'] as int?,
        professorUsername: json['professor_username'] as String? ?? '',
        scheduledAt: DateTime.parse(json['scheduled_at'] as String),
        durationMinutes: json['duration_minutes'] as int?,
        maxCapacity: json['max_capacity'] as int?,
        notes: json['notes'] as String?,
        attendanceCount: json['attendance_count'] as int? ?? 0,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TrainingClass && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class CheckIn {
  const CheckIn({
    required this.id,
    required this.athlete,
    required this.athleteUsername,
    required this.trainingClass,
    this.method,
    required this.checkedInAt,
  });

  final int id;
  final int athlete;
  final String athleteUsername;
  final int trainingClass;
  final MethodEnum? method;
  final DateTime checkedInAt;

  factory CheckIn.fromJson(Map<String, dynamic> json) => CheckIn(
        id: json['id'] as int,
        athlete: json['athlete'] as int,
        athleteUsername: json['athlete_username'] as String,
        trainingClass: json['training_class'] as int,
        method: MethodEnum.fromJson(json['method'] as String?),
        checkedInAt: DateTime.parse(json['checked_in_at'] as String),
      );
}

class QRCode {
  const QRCode({
    required this.id,
    required this.trainingClass,
    required this.token,
    required this.expiresAt,
    this.isActive,
    required this.isValid,
  });

  final int id;
  final int trainingClass;
  final String token;
  final DateTime expiresAt;
  final bool? isActive;
  final bool isValid;

  factory QRCode.fromJson(Map<String, dynamic> json) => QRCode(
        id: json['id'] as int,
        trainingClass: json['training_class'] as int,
        token: json['token'] as String,
        expiresAt: DateTime.parse(json['expires_at'] as String),
        isActive: json['is_active'] as bool?,
        isValid: json['is_valid'] as bool,
      );
}

class DropInVisitor {
  const DropInVisitor({
    required this.id,
    required this.academy,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.trainingClass,
    required this.accessToken,
    required this.expiresAt,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final int academy;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final int? trainingClass;
  final String accessToken;
  final DateTime expiresAt;
  final DropInVisitorStatusEnum status;
  final DateTime createdAt;

  String get fullName => '$firstName $lastName';

  factory DropInVisitor.fromJson(Map<String, dynamic> json) => DropInVisitor(
        id: json['id'] as int,
        academy: json['academy'] as int,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        trainingClass: json['training_class'] as int?,
        accessToken: json['access_token'] as String,
        expiresAt: DateTime.parse(json['expires_at'] as String),
        status: DropInVisitorStatusEnum.fromJson(json['status'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DropInVisitor && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
