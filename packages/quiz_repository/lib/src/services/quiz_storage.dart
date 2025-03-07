import 'package:domain_entities/domain_entities.dart';

abstract class QuizStorage {
  Future<List<Quiz>> getAllQuizzes();
  Future<Quiz> addQuiz(Quiz quiz);
  Future<void> updateQuiz(Quiz quiz);
  Future<void> deleteQuiz(Quiz quiz);

  Future<List<User>> getAllUsers();
  Future<User> addUser(User user);
  Future<void> updateUser(User user);
  Future<void> deleteUser(User user);

  Future<void> addAchievement(
      Achievement achievement, String userId, int index);
  Future<void> deleteAchievement(User user, int index);

  Future<void> addLike(User user, String like, int index);
  Future<void> deleteLike(User user, int index);

  Future<void> addInterest(User user, String interest, int index);
  Future<void> deleteInterest(User user, List<String> interests);

  Future<void> addProgress(GameProgress progress, String userId, int index);

  Future<List<GameProgress>> getAllProgressByUser(User user);

  Future<void> deleteProgress(User user, GameProgress progress);
}
