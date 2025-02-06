import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 지역별 레슨 영상 가져오기
  Future<List<DocumentSnapshot>> _getVideosByRegion(String region) async {
    QuerySnapshot snapshot = await _firestore.collection('profiles')
        .where('region', isEqualTo: region)
        .get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('일반 사용자 페이지')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: '지역 입력'),
              onChanged: (region) {
                // 검색 기능 구현
              },
            ),
            Expanded(
              child: FutureBuilder<List<DocumentSnapshot>>(
                future: _getVideosByRegion('서울'), // 지역 예시
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasData) {
                    var videos = snapshot.data!;
                    return ListView.builder(
                      itemCount: videos.length,
                      itemBuilder: (context, index) {
                        var video = videos[index];
                        return ListTile(
                          title: Text(video['name']),
                          subtitle: Text(video['career']),
                          onTap: () {
                            // 영상 클릭 시 상세 화면
                          },
                        );
                      },
                    );
                  } else {
                    return Center(child: Text('영상을 찾을 수 없습니다.'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
