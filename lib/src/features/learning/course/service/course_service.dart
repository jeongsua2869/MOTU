import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motu/src/features/learning/course/model/status.dart';
import 'package:motu/src/features/learning/course/view/course_selection_page.dart';

class CourseService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CourseLevel level;

  String _docLevel = '';
  String get docLevel => _docLevel;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  int _totalStage = 0;
  int get totalStage => _totalStage;

  final List<Status> _stageStatusList = [];
  List<Status> get stageStatusList => _stageStatusList;

  final List<dynamic> _contentList = [];
  List<dynamic> get contentList => _contentList;

  List<dynamic> _completionList = [];
  List<dynamic> get completionList => _completionList;

  CourseService(this.level) {
    _getUserCompletion();
    _fetchStage(level);
  }

  Future<void> _getUserCompletion() async {
    User? user = _auth.currentUser;
    if (user == null) {
      debugPrint("No user is signed in.");
      return;
    }

    await _firestore.collection('user').doc(user.uid).get().then((doc) {
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['course'] != null) {
          Map<String, dynamic> courseData = data['course'];
          if (courseData[_docLevel] != null) {
            _completionList = courseData[_docLevel];
          }
        }
      }
    });
  }

  void fetchUserCompletionListLength() {
    for (int i = _completionList.length; i < totalStage; i++) {
      _completionList.add(false);
    }
  }

  void _fetchStage(CourseLevel level) async {
    _docLevel = level == CourseLevel.Basic
        ? '초급'
        : level == CourseLevel.Standard
            ? '중급'
            : '고급';
    await _firestore.collection('course').doc(_docLevel).get().then((doc) {
      _totalStage = doc.data()?['totalStage'];
      notifyListeners();
    });

    await _fetchLevelData();
  }

  Future<void> _fetchLevelData() async {
    debugPrint("fetching level data");
    for (int i = 1; i <= _totalStage; i++) {
      try {
        await _firestore
            .collection('course')
            .doc(_docLevel)
            .collection("$i")
            .get()
            .then((querySnapshot) {
          for (var doc in querySnapshot.docs) {
            if (doc.id == 'status') {
              Status status = Status.fromJson(doc.data());
              _stageStatusList.add(status);
            }

            if (doc.id == 'content') {
              _contentList.add(doc.data());
            }
          }
        });
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUserCourseCompletion(int index) async {
    User? user = _auth.currentUser;
    if (user == null) {
      debugPrint("No user is signed in.");
      return;
    }

    DocumentReference userDocRef = _firestore.collection('user').doc(user.uid);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot userDoc = await transaction.get(userDocRef);

      if (!userDoc.exists) {
        debugPrint("User document does not exist.");
        return;
      }

      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

      Map<String, dynamic> userCourseData = {'초급': [], '중급': [], '고급': []};

      if (data['course'] != null) {
        userCourseData = userDoc['course'];
      }

      if (userCourseData[_docLevel] is List) {
        List<dynamic> courseList = userCourseData[_docLevel] as List<dynamic>;

        if (courseList.length >= index) {
          debugPrint("Already completed.");
          return;
        }

        courseList.add(true);
        userCourseData[_docLevel] = courseList;
      }

      _completionList = userCourseData[_docLevel];

      transaction.update(userDocRef, {'course': userCourseData});
    });

    notifyListeners();
  }
}
