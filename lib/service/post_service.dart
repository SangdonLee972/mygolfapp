import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:project_golf/Model/PostModel.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 여러 영상 파일을 Storage에 업로드한 후, 영상 URL 리스트 반환
  Future<List<String>> uploadMultipleVideos(String uid, List<File> videoFiles) async {
    List<String> videoUrls = [];
    for (File videoFile in videoFiles) {
      String videoPath = 'posts/$uid/${DateTime.now().millisecondsSinceEpoch}.mp4';
      UploadTask uploadTask = _storage.ref(videoPath).putFile(videoFile);
      TaskSnapshot snapshot = await uploadTask;
      String videoUrl = await snapshot.ref.getDownloadURL();
      videoUrls.add(videoUrl);
    }
    return videoUrls;
  }

  // 게시글 업로드
  Future<void> uploadPost(String uid, Post post) async {
    await _firestore.collection('posts').add(post.toMap());
    // 작성자의 uid -> 추후 유저 문서에 postId 추가 로직 가능
  }

  // 특정 사용자(uid)의 게시글 목록 스트림
  Stream<QuerySnapshot> getPostsByUser(String uid) {
    return _firestore
        .collection('posts')
        .where('uid', isEqualTo: uid)
        .orderBy('uploadedAt', descending: true)
        .snapshots();
  }

  // 지역별 게시글 목록 스트림 (소비자 페이지에서 지역 필터링)
  Stream<QuerySnapshot> getPostsByRegion(String region) {
    return _firestore
        .collection('posts')
        .where('region', isEqualTo: region)
        .orderBy('uploadedAt', descending: true)
        .snapshots();
  }
}
