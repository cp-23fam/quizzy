import 'package:component_library/component_library.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_list/quiz_list.dart';

class UserPageScreen extends StatefulWidget {
  static const routeName = 'user_screen';

  const UserPageScreen({super.key});

  @override
  State<UserPageScreen> createState() => _UserPageScreenState();
}

class _UserPageScreenState extends State<UserPageScreen> {
  int _getNote(
      {required int index,
      required List<Achievement> achievements,
      required List<Quiz> quizzes}) {
    int note = 0;
    for (var achievement in achievements) {
      if (achievement.id == quizzes[index].id) {
        note = achievement.star;
      }
    }
    return note;
  }

  @override
  Widget build(BuildContext context) {
    void resetProgression(BuildContext context, user) {
      for (Achievement achievement in user.achievement) {
        context
            .read<UserListProvider>()
            .deleteAchievement(user.id as String, achievement);
      }
    }

    void resetProgress(BuildContext context, User user) {
      for (GameProgress progress in user.gameProgress) {
        context
            .read<UserListProvider>()
            .deleteProgress(user.id as String, progress);
      }
    }

    final user = context.watch<UserListProvider>().userState.user;
    final quizzes =
        context.watch<QuizListProvider>().findQuizzesByAuthor(user.username);
    final TextEditingController controller = TextEditingController();
    int pointsTot = 0;
    for (var v in user.achievement) {
      pointsTot += v.star;
    }

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 70, 70, 70),
        toolbarHeight: 70.0,
        centerTitle: true,
        title: Text(
          'Quizzy',
          style: TextStyle(color: Colors.white, fontSize: 40),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17.0),
        child: Column(
          children: [
            SizedBox(
              height: 17,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 50.0,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.username,
                          style: TextStyle(color: Colors.white, fontSize: 30.0),
                        ),
                        Text(
                            '${user.achievement.length} quiz joués | $pointsTot étoiles gagnées',
                            style:
                                TextStyle(color: Colors.white, fontSize: 17.0))
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.white),
                    foregroundColor: WidgetStatePropertyAll(Colors.black),
                    shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        'Réinitialiser les récompenses',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  onPressed: () {
                    resetProgression(context, user);
                  },
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.white),
                    foregroundColor: WidgetStatePropertyAll(Colors.black),
                    shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        'Réinitialiser les quiz en cours',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  onPressed: () {
                    resetProgress(context, user);
                  },
                ),
              ],
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 17.0),
              child: ExpansionTile(
                title: Text(
                  'Intérets',
                  style: TextStyle(color: Colors.white),
                ),
                collapsedIconColor: Colors.white,
                iconColor: Colors.white,
                childrenPadding: EdgeInsets.all(8.0),
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Container(
                          height: 50,
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 12.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.white),
                          child: TextField(
                            controller: controller,
                            style: TextStyle(fontSize: 15.0),
                            onSubmitted: (value) => context
                                .read<UserListProvider>()
                                .addInterest(interest: value),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: SizedBox(),
                      ),
                      IconButton(
                        onPressed: () {
                          context
                              .read<UserListProvider>()
                              .addInterest(interest: controller.text);
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.white),
                          foregroundColor: WidgetStatePropertyAll(Colors.green),
                          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        icon: Icon(Icons.add),
                      )
                    ],
                  ),
                  SizedBox(height: 15.0),
                  Wrap(
                    spacing: 4.0,
                    runSpacing: 4.0,
                    children: [
                      for (String interet in user.interests)
                        TextButton(
                          onPressed: () {
                            context
                                .read<UserListProvider>()
                                .deleteInterest(interests: [interet]);
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.white),
                            foregroundColor:
                                WidgetStatePropertyAll(Colors.black),
                            shape:
                                WidgetStatePropertyAll<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(interet),
                              SizedBox(width: 2.0),
                              Icon(Icons.close, color: Colors.red, size: 15.0),
                            ],
                          ),
                        )
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) => Row(
                  children: [
                    Expanded(
                        child: QuizItem(
                            quiz: quizzes[index],
                            note: _getNote(
                                index: index,
                                achievements: user.achievement,
                                quizzes: quizzes),
                            showDetail: (id) {
                              Navigator.of(context).pushNamed(
                                  DetailPageScreen.routeName,
                                  arguments: [
                                    id,
                                    _getNote(
                                      index: index,
                                      achievements: user.achievement,
                                      quizzes: quizzes,
                                    ),
                                    user.likes.contains(id)
                                  ]);
                            })),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                                CreateQuizScreen.routeName,
                                arguments: quizzes[index].id);
                          },
                          icon:
                              Icon(Icons.edit, color: Colors.blue, size: 35.0),
                        ),
                        SizedBox(height: 10.0),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              context
                                  .read<QuizListProvider>()
                                  .deleteQuiz(quizzes[index]);
                            });
                          },
                          icon:
                              Icon(Icons.delete, color: Colors.red, size: 35.0),
                        ),
                      ],
                    )
                  ],
                ),
                separatorBuilder: (context, index) => SizedBox(height: 15),
                itemCount: quizzes.length,
              ),
            )
          ],
        ),
      ),
      backgroundColor: Color.fromARGB(255, 18, 18, 18),
      bottomNavigationBar: Container(
        color: const Color.fromARGB(255, 70, 70, 70),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed(HomePageScreen.routeName);
                  },
                  icon: Icon(
                    Icons.home,
                    color: Colors.white,
                    size: 28.0,
                  )),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(CreateQuizScreen.routeName);
                  },
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 28.0,
                  )),
              IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacementNamed(UserPageScreen.routeName);
                },
                icon: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 28.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
