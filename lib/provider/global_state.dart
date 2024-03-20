import 'package:flutter/material.dart';
import 'package:tspi_nas_app/model/buckets_model.dart';
import 'package:tspi_nas_app/model/user_info_model.dart';

class GlobalStateProvider extends ChangeNotifier {
  ///当前操作的桶ID
  int? _bucketId;
  UserInfoModel? currentUser;
  List<BucketsModel> buckets = [];

  int? get getBId => _bucketId;

  void setBucketId(int bKid) {
    _bucketId = bKid;
    notifyListeners();
  }

  void setUserInfo(UserInfoModel user) {
    currentUser = user;
    notifyListeners();
  }

  void setBuckets(List<BucketsModel> arr) {
    buckets.clear();
    buckets.addAll(arr);
    notifyListeners();
  }
}
