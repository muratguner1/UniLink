import 'package:flutter/foundation.dart';
import '../../data/models/post_model.dart';
import '../../data/repositories/post_repository.dart';
import '../../data/services/api_service.dart';

class FeedProvider extends ChangeNotifier {
  final _repo = PostRepository();

  List<PostModel> _feed = [];
  List<PostModel> _myPosts = [];
  bool _loading = false;
  bool _myPostsLoading = false;
  String? _error;

  List<PostModel> get feed => _feed;
  List<PostModel> get myPosts => _myPosts;
  bool get loading => _loading;
  bool get myPostsLoading => _myPostsLoading;
  String? get error => _error;

  Future<void> loadFeed(String studentId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _feed = await _repo.getFeed(studentId);
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyPosts(String studentId) async {
    _myPostsLoading = true;
    notifyListeners();
    try {
      _myPosts = await _repo.getMyPosts(studentId);
    } finally {
      _myPostsLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPost(String studentId, String content) async {
    try {
      final post = await _repo.createPost(studentId, content);
      _myPosts.insert(0, post);
      notifyListeners();
      return true;
    } on ApiException {
      return false;
    }
  }

  Future<void> toggleLike(String studentId, PostModel post) async {
    // Optimistic update
    final idx = _feed.indexWhere((p) => p.postId == post.postId);
    if (idx == -1) return;

    final wasLiked = _feed[idx].isLiked;
    _feed[idx] = _feed[idx].copyWith(
      isLiked: !wasLiked,
      likesCount: wasLiked ? _feed[idx].likesCount - 1 : _feed[idx].likesCount + 1,
    );
    notifyListeners();

    try {
      if (wasLiked) {
        await _repo.unlikePost(studentId, post.postId);
      } else {
        await _repo.likePost(studentId, post.postId);
      }
    } catch (_) {
      // Revert on error
      _feed[idx] = _feed[idx].copyWith(
        isLiked: wasLiked,
        likesCount: wasLiked ? _feed[idx].likesCount + 1 : _feed[idx].likesCount - 1,
      );
      notifyListeners();
    }
  }

  void clear() {
    _feed = [];
    _myPosts = [];
    notifyListeners();
  }
}
