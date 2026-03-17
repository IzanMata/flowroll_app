import 'academy.dart';

enum BeltEnum {
  white('white'),
  blue('blue'),
  purple('purple'),
  brown('brown'),
  black('black');

  const BeltEnum(this.value);
  final String value;

  static BeltEnum fromJson(String v) =>
      BeltEnum.values.firstWhere((e) => e.value == v, orElse: () => BeltEnum.white);
}

enum RoleEnum {
  student('STUDENT'),
  professor('PROFESSOR');

  const RoleEnum(this.value);
  final String value;

  static RoleEnum fromJson(String v) =>
      RoleEnum.values.firstWhere((e) => e.value == v, orElse: () => RoleEnum.student);
}

enum GenderEnum {
  male('M'),
  female('F'),
  open('O');

  const GenderEnum(this.value);
  final String value;

  static GenderEnum fromJson(String v) =>
      GenderEnum.values.firstWhere((e) => e.value == v, orElse: () => GenderEnum.open);
}

class UserMinimal {
  const UserMinimal({required this.id, required this.username});

  final int id;
  final String username;

  factory UserMinimal.fromJson(Map<String, dynamic> json) => UserMinimal(
        id: json['id'] as int,
        username: json['username'] as String,
      );
}

class AthleteProfile {
  const AthleteProfile({
    required this.id,
    required this.user,
    required this.username,
    required this.email,
    this.academy,
    required this.academyDetail,
    this.role,
    this.belt,
    this.stripes,
  });

  final int id;
  final int user;
  final String username;
  final String email;
  final int? academy;
  final Academy academyDetail;
  final RoleEnum? role;
  final BeltEnum? belt;
  final int? stripes;

  factory AthleteProfile.fromJson(Map<String, dynamic> json) => AthleteProfile(
        id: json['id'] as int,
        user: json['user'] as int,
        username: json['username'] as String,
        email: json['email'] as String,
        academy: json['academy'] as int?,
        academyDetail: Academy.fromJson(json['academy_detail'] as Map<String, dynamic>),
        role: json['role'] != null ? RoleEnum.fromJson(json['role'] as String) : null,
        belt: json['belt'] != null ? BeltEnum.fromJson(json['belt'] as String) : null,
        stripes: json['stripes'] as int?,
      );

  AthleteProfile copyWith({
    int? id,
    int? user,
    String? username,
    String? email,
    int? academy,
    Academy? academyDetail,
    RoleEnum? role,
    BeltEnum? belt,
    int? stripes,
  }) =>
      AthleteProfile(
        id: id ?? this.id,
        user: user ?? this.user,
        username: username ?? this.username,
        email: email ?? this.email,
        academy: academy ?? this.academy,
        academyDetail: academyDetail ?? this.academyDetail,
        role: role ?? this.role,
        belt: belt ?? this.belt,
        stripes: stripes ?? this.stripes,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AthleteProfile && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
