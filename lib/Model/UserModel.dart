class AppUser {
  final String uid;
  final String email;
  final String name;
  final String career;
  final String region;
  final String contact;
  final bool isPro;
  final List<String> postIds; // 프로 사용자가 작성한 게시글 ID 리스트 (옵션)

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.career,
    required this.region,
    required this.contact,
    required this.isPro,
    required this.postIds,
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      career: data['career'] ?? '',
      region: data['region'] ?? '',
      contact: data['contact'] ?? '',
      isPro: data['isPro'] ?? false,
      postIds: data['postIds'] != null
          ? List<String>.from(data['postIds'])
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'career': career,
      'region': region,
      'contact': contact,
      'isPro': isPro,
      'postIds': postIds,
    };
  }
}
