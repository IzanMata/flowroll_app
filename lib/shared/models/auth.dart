class TokenPair {
  const TokenPair({required this.access, required this.refresh});

  final String access;
  final String refresh;

  factory TokenPair.fromJson(Map<String, dynamic> json) => TokenPair(
        access: json['access'] as String,
        refresh: json['refresh'] as String,
      );
}
