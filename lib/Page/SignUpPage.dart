import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_golf/Model/UserModel.dart';
import 'package:project_golf/Page/MainPage.dart';
import 'package:project_golf/Page/ProPage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  // 공통 필드
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 프로 전용 필드
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _careerController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();

  bool _isPro = false; // 체크박스: 프로 여부

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;

      // 프로인 경우 추가 정보 반영, 일반인 경우 빈 값(or 기본 값)
      final AppUser newUser = AppUser(
        uid: uid,
        postIds: [],
        email: _emailController.text.trim(),
        isPro: _isPro,
        name: _isPro ? _nameController.text.trim() : '',
        contact: _isPro ? _contactController.text.trim() : '',
        career: _isPro ? _careerController.text.trim() : '',
        region: _isPro ? _regionController.text.trim() : '',
      );

      // Firestore 저장
      await _firestore.collection('users').doc(uid).set(newUser.toMap());

      // 회원가입 완료 후, 역할에 맞는 페이지로 이동
      if (_isPro) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('회원가입 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 배경에 그라디언트 등 넣어보기 (간단 예시)
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.deepPurpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '회원가입',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: '이메일'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '이메일을 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: '비밀번호'),
                        validator: (value) {
                          if (value == null || value.trim().length < 6) {
                            return '비밀번호를 6자리 이상 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _isPro,
                            onChanged: (val) {
                              setState(() {
                                _isPro = val ?? false;
                              });
                            },
                          ),
                          Text('프로 회원으로 가입'),
                        ],
                      ),
                      // 프로 회원만 표시되는 폼 필드
                      if (_isPro) ...[
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: '이름(실명)'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '이름을 입력해주세요.';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _contactController,
                          decoration: InputDecoration(labelText: '연락처'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '연락처를 입력해주세요.';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _careerController,
                          decoration: InputDecoration(labelText: '경력'),
                        ),
                        TextFormField(
                          controller: _regionController,
                          decoration: InputDecoration(labelText: '거주 지역'),
                        ),
                      ],
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _signUp,
                        child: Text('회원가입'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
