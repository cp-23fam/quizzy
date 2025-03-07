import 'dart:convert';
import 'dart:io';

import 'package:domain_entities/domain_entities.dart';
import 'package:flutter/foundation.dart';
import 'package:quiz_repository/quiz_repository.dart';

import 'package:http/http.dart' as http;

class QuizRemoteStorage implements QuizStorage {
  static const url =
      'https://quizzy-6c7dc-default-rtdb.europe-west1.firebasedatabase.app/';
  // static const url = 'http://localhost:9000/';
  static const dbName = '';
  // static const dbName = '?ns=quizzy-6c7dc-default-rtdb';

  QuizRemoteStorage({@visibleForTesting http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  final quizzes = <Quiz>[];
  final users = <User>[];

  @override
  Future<List<Quiz>> getAllQuizzes() async {
    try {
      final parsedUrl = Uri.parse('${url}questionnaires.json$dbName');

      final response = await _client.get(parsedUrl);

      if (response.statusCode / 100 != 2) {
        throw HttpException('${response.statusCode}');
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      data.forEach((quizId, quizData) {
        final questions = <Question>[];
        quizData['questions'].forEach((questionData) {
          final responses = <Response>[];
          questionData['responses'].forEach((responseData) {
            responses.add(
                ResponseRemoteModel.fromJson(responseData).toDomainEntity());
          });
          questions.add(QuestionRemoteModel.fromJson(questionData)
              .toDomainEntity(responses));
        });
        quizzes.add(QuizRemoteModel.fromJson(quizData)
            .toDomainEntity(quizId.toString(), questions));
      });
      return quizzes;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<User>> getAllUsers() async {
    try {
      final parsedUrl = Uri.parse('${url}utilisateurs.json$dbName');

      final response = await _client.get(parsedUrl);

      if (response.statusCode / 100 != 2) {
        throw HttpException('${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      if (data != null) {
        data.forEach((userId, userData) {
          List<GameProgress> gameProgress = [];
          List<Achievement> achievement = [];
          if (userData['in_progress'] != null) {
            userData['in_progress'].forEach((gameProgressId, gameProgressData) {
              gameProgress.add(
                  GameProgressRemoteModel.fromJson(gameProgressData)
                      .toDomainEntity());
            });
          }
          if (userData['achievements'] != null) {
            userData['achievements'].forEach((achievementData) {
              achievement.add(AchievementRemoteModel.fromJson(achievementData)
                  .toDomainEntity());
            });
          }
          users.add(UserRemoteModel.fromJson(userData)
              .toDomainEntity(userId.toString(), gameProgress, achievement));
        });
      }
      return users;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Quiz> addQuiz(Quiz quiz) async {
    final questionDatas = <Map<String, dynamic>>[];

    for (var question in quiz.questions) {
      final responseDatas = <Map<String, dynamic>>[];

      for (var response in question.answers) {
        responseDatas.add(response.toRemoteModel().toJson());
      }

      questionDatas.add(question.toRemoteModel().toJson(responseDatas));
    }
    final quizData = quiz.toRemoteModel().toJson(questionDatas);

    try {
      final parsedUrl = Uri.parse('${url}questionnaires.json$dbName');
      final response =
          await _client.post(parsedUrl, body: jsonEncode(quizData));

      if (response.statusCode / 100 != 2) {
        throw HttpException('${response.statusCode}');
      }

      final id = jsonDecode(response.body)['name'];

      return quiz.copyWith(id: id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> addUser(User user) async {
    final achievementDatas = <Map<String, dynamic>>[];
    final gameProgressDatas = <Map<String, dynamic>>[];
    for (var v in user.achievement) {
      achievementDatas.add(v.toRemoteModel().toJson());
    }
    for (var v in user.gameProgress) {
      gameProgressDatas.add(v.toRemoteModel().toJson());
    }
    final userData =
        user.toRemoteModel().toJson(achievementDatas, gameProgressDatas);
    try {
      final parsedUrl = Uri.parse('${url}utilisateurs.json$dbName');
      final response =
          await _client.post(parsedUrl, body: jsonEncode(userData));
      if (response.statusCode / 100 != 2) {
        throw HttpException('${response.statusCode}');
      }
      final id = jsonDecode(response.body)['name'];
      return user.copyWith(id: id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteQuiz(Quiz quiz) async {
    try {
      final parsedUrl =
          Uri.parse('${url}questionnaires/${quiz.id}.json$dbName');
      final response = await _client.delete(parsedUrl);
      if (response.statusCode / 100 != 2) {
        throw HttpException('${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteUser(User user) async {
    try {
      final parsedUrl =
          Uri.parse('${url}questionnaires/${user.id}.json$dbName');
      final response = await _client.delete(parsedUrl);
      if (response.statusCode / 100 != 2) {
        throw HttpException('${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateQuiz(Quiz quiz) async {
    final questionDatas = <Map<String, dynamic>>[];
    for (var question in quiz.questions) {
      final responseDatas = <Map<String, dynamic>>[];
      for (var response in question.answers) {
        responseDatas.add(response.toRemoteModel().toJson());
      }
      questionDatas.add(question.toRemoteModel().toJson(responseDatas));
    }
    final quizData = quiz.toRemoteModel().toJson(questionDatas);
    try {
      final parsedUrl =
          Uri.parse('${url}questionnaires/${quiz.id}.json$dbName');
      final response = await _client.put(parsedUrl, body: jsonEncode(quizData));
      if (response.statusCode / 100 != 2) {
        throw HttpException('${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateUser(User user) async {
    final achievementDatas = <Map<String, dynamic>>[];
    final gameProgressDatas = <Map<String, dynamic>>[];
    for (var v in user.achievement) {
      achievementDatas.add(v.toRemoteModel().toJson());
    }
    for (var v in user.gameProgress) {
      gameProgressDatas.add(v.toRemoteModel().toJson());
    }
    final userData =
        user.toRemoteModel().toJson(achievementDatas, gameProgressDatas);
    try {
      final parsedUrl = Uri.parse('${url}utilisateurs/${user.id}.json$dbName');
      final response = await _client.put(parsedUrl, body: jsonEncode(userData));
      if (response.statusCode / 100 != 2) {
        throw HttpException('${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addAchievement(
      Achievement achievement, String userId, int index) async {
    final data = achievement.toRemoteModel().toJson();

    try {
      final parsedUrl = Uri.parse(
          '${url}utilisateurs/$userId/achievements/$index.json$dbName');
      final response = await _client.put(parsedUrl, body: jsonEncode(data));
      if (response.statusCode / 100 != 2) {
        throw HttpException('${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAchievement(User user, int index) async {
    try {
      final parsedUrl = Uri.parse(
          '${url}utilisateurs/${user.id}/achievements/$index.json$dbName');
      final response = await _client.delete(parsedUrl);
      if (response.statusCode / 100 != 2) {
        throw HttpException('${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addProgress(
      GameProgress progress, String userId, int index) async {
    final data = progress.toRemoteModel().toJson();

    try {
      final parsedUrl = Uri.parse(
          '${url}utilisateurs/$userId/in_progress/${progress.id}.json$dbName');
      final response = await _client.put(parsedUrl, body: jsonEncode(data));
      if (response.statusCode / 100 != 2) {
        throw HttpException('${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<GameProgress>> getAllProgressByUser(User user) async {
    final userId = user.id;
    try {
      final parsedUrl =
          Uri.parse('${url}utilisateurs/$userId/in_progress.json$dbName');

      final response = await _client.get(parsedUrl);

      if (response.statusCode / 100 != 2) {
        throw HttpException('${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      List<GameProgress> gameProgress = [];

      if (data != null) {
        data.forEach((gameProgressData) {
          gameProgress.add(GameProgressRemoteModel.fromJson(gameProgressData)
              .toDomainEntity());
        });
      }

      return gameProgress;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteProgress(User user, GameProgress progress) async {
    try {
      final parsedUrl = Uri.parse(
          '${url}utilisateurs/${user.id}/in_progress/${progress.id}.json$dbName');
      final response = await _client.delete(parsedUrl);
      if (response.statusCode / 100 != 2) {
        throw HttpException('${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addLike(User user, String like, int index) async {
    try {
      final parsedUrl =
          Uri.parse('${url}utilisateurs/${user.id}/likes/$index.json$dbName');
      final response = await _client.put(parsedUrl, body: jsonEncode(like));
      if (response.statusCode / 100 != 2) {
        throw HttpException('${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteLike(User user, int index) async {
    try {
      final parsedUrl =
          Uri.parse('${url}utilisateurs/${user.id}/likes/$index.json$dbName');
      final response = await _client.delete(parsedUrl);
      if (response.statusCode / 100 != 2) {
        throw HttpException('${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addInterest(User user, String interest, int index) async {
    try {
      final parsedUrl = Uri.parse(
          '${url}utilisateurs/${user.id}/interests/$index.json$dbName');
      final response = await _client.put(parsedUrl, body: jsonEncode(interest));
      if (response.statusCode / 100 != 2) {
        throw HttpException('${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteInterest(User user, List<String> interests) async {
    try {
      final parsedUrl =
          Uri.parse('${url}utilisateurs/${user.id}/interests.json$dbName');
      final response =
          await _client.put(parsedUrl, body: jsonEncode(interests));
      if (response.statusCode / 100 != 2) {
        throw HttpException('${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
