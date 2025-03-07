import 'package:domain_entities/domain_entities.dart';
import 'package:flutter/material.dart';
import 'package:quiz_list/quiz_list.dart';
import 'package:quiz_repository/quiz_repository.dart';

class UserListProvider with ChangeNotifier {
  UserListState _state = UserListState.initial();
  UserState _userState = UserState.initial();

  UserListProvider({required this.repository});
  final QuizRepository repository;

  UserListState get state => _state;
  UserState get userState => _userState;

  Future<void> fetchAndSetUsers() async {
    try {
      _state = _state.copyWith(status: UserListStatus.loading);
      notifyListeners();

      final repositoryUsers = await repository.getAllUsers();
      _state = _state.copyWith(
        status: UserListStatus.loaded,
        users: repositoryUsers,
      );
      _userState =
          _userState.copyWith(user: _state.users[2], status: UserStatus.loaded);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void addUser(User user) async {
    try {
      User newUser = await repository.addUser(user);
      _state.users.add(newUser);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void updateUser(User user) async {
    try {
      final index = _state.users.indexWhere((user) => user.id == user.id);
      if (index != -1) {
        await repository.updateUser(user);
        _state.users[index] = user;
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void deleteUser(User? user) async {
    final User finalUser = user ?? _userState.user;
    try {
      await repository.deleteUser(finalUser);
      _state.users.remove(user);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  int findAchievementIndexById(User user, String id) {
    return user.achievement.indexWhere((a) => a.id == id);
  }

  int findProgressIndexById(User user, String id) {
    return user.gameProgress.indexWhere((a) => a.id == id);
  }

  void addAchievement({required Achievement achievement, User? user}) async {
    final User finalUser = user ?? _userState.user;
    try {
      await repository.addAchievement(
          achievement, finalUser.id!, finalUser.achievement.length);
      _state.users
          .firstWhere((u) => u.id == finalUser.id)
          .achievement
          .add(achievement);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void updateAchievement(
      {required Achievement achievement,
      User? user,
      required String quizId}) async {
    final User finalUser = user ?? _userState.user;
    final int index = finalUser.achievement.indexWhere((a) => a.id == quizId);
    try {
      await repository.addAchievement(achievement, finalUser.id!, index);
      _state.users.firstWhere((u) => u.id == finalUser.id).achievement[index] =
          achievement;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAchievement(String userId, Achievement achievement) async {
    User user = findUserById(userId);

    final achievementIndex = user.achievement.indexOf(achievement);

    await repository.deleteAchievement(user, achievementIndex);
    _state.users
        .firstWhere((u) => u.id == userId)
        .achievement
        .remove(achievement);
    notifyListeners();
  }

  void addLike({User? user, required String like}) async {
    final User finalUser = user ?? _userState.user;
    try {
      await repository.addLike(finalUser, like, finalUser.likes.length);
      _state.users.firstWhere((u) => u.id == finalUser.id).likes.add(like);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void deleteLike({User? user, required String like}) async {
    final User finalUser = user ?? _userState.user;
    final int index = finalUser.likes.indexWhere((l) => l == like);
    try {
      await repository.deleteLike(finalUser, index);
      _state.users
          .firstWhere((u) => u.id == finalUser.id)
          .likes
          .removeAt(index);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void addInterest(
      {User? user, required String interest, int index = 0}) async {
    final User finalUser = user ?? _userState.user;
    final finalIndex = finalUser.interests.length + index;

    if (finalUser.interests.contains(interest.toLowerCase())) {
      return;
    }
    try {
      await repository.addInterest(
          finalUser, interest.toLowerCase(), finalIndex);
      _state.users
          .firstWhere((u) => u.id == finalUser.id)
          .interests
          .add(interest.toLowerCase());

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void deleteInterest({User? user, required List<String> interests}) async {
    final User finalUser = user ?? _userState.user;

    for (String interest in interests) {
      _state.users
          .firstWhere((u) => u.id == finalUser.id)
          .interests
          .remove(interest);
    }

    try {
      await repository.deleteInterest(finalUser, finalUser.interests);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  GameProgress? getQuizProgression(Quiz quiz, User user) {
    final List<GameProgress> progressions =
        _state.users.firstWhere((u) => u.id == user.id).gameProgress;

    for (GameProgress progress in progressions) {
      if (progress.id == quiz.id) {
        return progress;
      }
    }
    return null;
  }

  User findUserById(String id) {
    return _state.users.firstWhere((user) => user.id == id);
  }

  Future<void> addProgresss(
      GameProgress progress, String userId, int index) async {
    await repository.addProgresss(progress, userId, index);
    User user = findUserById(userId);
    int stateIndex = findProgressIndexById(user, progress.id);
    if (stateIndex != -1) {
      _state.users.firstWhere((u) => u.id == userId).gameProgress[stateIndex] =
          progress;
    } else {
      _state.users.firstWhere((u) => u.id == userId).gameProgress.add(progress);
    }
    notifyListeners();
  }

  Future<void> deleteProgress(String userId, GameProgress progress) async {
    User user = findUserById(userId);
    await repository.deleteProgress(user, progress);
    _state.users
        .firstWhere((u) => u.id == userId)
        .gameProgress
        .remove(progress);
  }
}
