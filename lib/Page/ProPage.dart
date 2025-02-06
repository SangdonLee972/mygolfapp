import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_golf/Model/PostModel.dart';
import 'package:project_golf/service/post_service.dart';

// 예시로 file_picker (multiple) 사용 시 참고
// import 'package:file_picker/file_picker.dart';

class ProPage extends StatefulWidget {
  @override
  _ProPageState createState() => _ProPageState();
}

class _ProPageState extends State<ProPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PostService _postService = PostService();

  // 여러 파일을 담을 리스트
  List<File> _videoFiles = [];

  // 게시글 관련 입력 컨트롤러
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();

  // 여러 영상 선택 (예시)
  Future<void> _selectVideos() async {
    // 예: file_picker 패키지 사용
    // FilePickerResult? result = await FilePicker.platform.pickFiles(
    //   type: FileType.video,
    //   allowMultiple: true,
    // );
    // if (result != null) {
    //   setState(() {
    //     _videoFiles = result.paths.map((path) => File(path!)).toList();
    //   });
    // }

    // 실제 구현 시 위 주석을 참고하세요.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('영상 파일 여러 개 선택 로직을 구현하세요.')),
    );
  }

  // 게시글 업로드 (여러 영상 + Firestore)
  Future<void> _uploadPost() async {
    if (_videoFiles.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('영상을 선택해주세요.')));
      return;
    }

    try {
      final uid = _auth.currentUser!.uid;

      // 1) 여러 영상 업로드 후 URL 리스트 확보
      List<String> videoUrls =
          await _postService.uploadMultipleVideos(uid, _videoFiles);

      // 2) Post 모델 생성
      Post post = Post(
        id: '', // Firestore에서 생성 시 자동 할당, fromMap 시 세팅됨
        uid: uid,
        videoUrls: videoUrls,
        title: _titleController.text,
        description: _descriptionController.text,
        region: _regionController.text,
        uploadedAt: DateTime.now(),
      );

      // 3) Firestore에 저장
      await _postService.uploadPost(uid, post);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('게시글 업로드 성공')));

      // 입력 필드 초기화
      _titleController.clear();
      _descriptionController.clear();
      _regionController.clear();

      setState(() {
        _videoFiles.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('업로드 실패: $e')));
    }
  }

  // 현재 프로 사용자가 올린 게시글 목록
  Widget _buildMyPosts() {
    final uid = _auth.currentUser!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: _postService.getPostsByUser(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('오류 발생: ${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return Text('게시글이 없습니다.');
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            Post post = Post.fromMap(data, docs[index].id);
            return Card(
              child: ListTile(
                title: Text(post.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('설명: ${post.description}'),
                    Text('지역: ${post.region}'),
                    // 여러 영상 URL 표시
                    Text('영상 개수: ${post.videoUrls.length}개'),
                    Text('업로드 시간: ${post.uploadedAt}'),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로 페이지')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 영상 선택 버튼
            ElevatedButton(
              onPressed: _selectVideos,
              child: Text('영상 선택 (여러 개)'),
            ),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: '제목'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: '설명'),
            ),
            TextField(
              controller: _regionController,
              decoration: InputDecoration(labelText: '지역'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _uploadPost,
              child: Text('게시글 등록'),
            ),
            Divider(height: 32),
            Text(
              '내가 올린 게시글',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildMyPosts(),
          ],
        ),
      ),
    );
  }
}
