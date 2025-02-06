import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String uid;                // 작성자(프로) UID
  final List<String> videoUrls;    // 여러 개의 영상 URL
  final String title;              // 게시글 제목
  final String description;        // 게시글 설명
  final String region;             // 지역 정보
  final DateTime uploadedAt;       // 업로드 시간

  Post({
    required this.id,
    required this.uid,
    required this.videoUrls,
    required this.title,
    required this.description,
    required this.region,
    required this.uploadedAt,
  });

  // Firestore -> Post
  factory Post.fromMap(Map<String, dynamic> data, String docId) {
    return Post(
      id: docId,
      uid: data['uid'] ?? '',
      videoUrls: data['videoUrls'] != null
          ? List<String>.from(data['videoUrls'])
          : [],
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      region: data['region'] ?? '',
      uploadedAt: (data['uploadedAt'] as Timestamp).toDate(),
    );
  }

  // Post -> Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'videoUrls': videoUrls,
      'title': title,
      'description': description,
      'region': region,
      'uploadedAt': uploadedAt,
    };
  }
}
