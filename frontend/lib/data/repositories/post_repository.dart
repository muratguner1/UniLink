import '../models/post_model.dart';
import '../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class PostRepository {
  final _api = ApiService();

  Future<List<PostModel>> getFeed(String studentId, {int limit = 30}) async {
    final data = await _api.get(ApiConstants.feed(studentId, limit: limit));
    return (data as List).map((e) => PostModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<PostModel>> getMyPosts(String studentId) async {
    final data = await _api.get(ApiConstants.myPosts(studentId));
    return (data as List).map((e) => PostModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PostModel> createPost(String studentId, String content, {String? imageUrl}) async {
    final data = await _api.post(
      ApiConstants.createPost(studentId),
      body: {'content': content, if (imageUrl != null) 'imageUrl': imageUrl},
    );
    return PostModel.fromJson(data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> likePost(String studentId, String postId) async {
    final data = await _api.post(ApiConstants.likePost(studentId, postId));
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> unlikePost(String studentId, String postId) async {
    final data = await _api.delete(ApiConstants.unlikePost(studentId, postId));
    return data as Map<String, dynamic>;
  }

  Future<void> deletePost(String studentId, String postId) async {
    await _api.delete(ApiConstants.deletePost(studentId, postId));
  }
}
