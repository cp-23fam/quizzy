import 'dart:convert';

import 'package:domain_entities/domain_entities.dart';
import 'package:flutter/services.dart';
import 'package:quiz_repository/quiz_repository.dart';

class QuizLocalStorage implements QuizStorage {
  @override
  Future<List<Quiz>> getAllQuizzes() async {
    try {
      final quizzes = <Quiz>[];

      final dataString = await rootBundle.loadString(
          'packages/quiz_repository/lib/src/assets/data/questions.json');

      final Map<String, dynamic> json = jsonDecode(dataString);

      if (json['questionnaires'] != null) {
        json['questionnaires'].forEach((quizData) {
          final questions = <Question>[];
          quizData['questions'].forEach((questionData) {
            final responses = <Response>[];
            questionData['responses'].forEach((responseData) {
              responses.add(
                  ResponseLocalModel.fromJson(responseData).toDomainEntity());
            });
            questions.add(QuestionLocalModel.fromJson(questionData)
                .toDomainEntity(responses));
          });
          quizzes
              .add(QuizLocalModel.fromJson(quizData).toDomainEntity(questions));
        });
      }
      return quizzes;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<User>> getAllUsers() async {
    try {
      final users = <User>[];

      final dataString = await rootBundle.loadString(
          'packages/quiz_repository/lib/src/assets/data/questions.json');

      final Map<String, dynamic> json = jsonDecode(dataString);

      if (json['utilisateurs'] != null) {
        json['utilisateurs'].forEach((userData) {
          List<GameProgress> gameProgress = [];
          List<Achievement> achievement = [];
          userData['in_progress'].forEach((gameProgressData) {
            gameProgress.add(GameProgressLocalModel.fromJson(gameProgressData)
                .toDomainEntity());
          });
          userData['achievements'].forEach((achievementData) {
            achievement.add(AchievementLocalModel.fromJson(achievementData)
                .toDomainEntity());
          });
          users.add(UserLocalModel.fromJson(userData)
              .toDomainEntity(gameProgress, achievement));
        });
      }
      return users;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Quiz> addQuiz(Quiz quiz) {
    throw UnimplementedError();
  }

  @override
  Future<User> addUser(User user) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteQuiz(Quiz quiz) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteUser(User user) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateQuiz(Quiz quiz) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateUser(User user) {
    throw UnimplementedError();
  }

  @override
  Future<void> addAchievement(Achievement achievement, String id, int index) {
    throw UnimplementedError();
  }

  @override
  Future<void> addLike(User user, String like, int index) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteLike(User user, int index) {
    throw UnimplementedError();
  }

  @override
  Future<void> addInterest(User user, String interest, int index) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteInterest(User user, List<String> interests) {
    throw UnimplementedError();
  }

  @override
  Future<void> addProgress(GameProgress progress, String userId, int index) {
    throw UnimplementedError();
  }

  @override
  Future<List<GameProgress>> getAllProgressByUser(User user) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteProgress(User user, GameProgress progress) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAchievement(User user, int index) {
    throw UnimplementedError();
  }
}
