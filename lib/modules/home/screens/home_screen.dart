import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sowaste/core/themes/app_colors.dart';
import 'package:sowaste/core/themes/app_themes.dart';
import 'package:sowaste/core/values/app_assets/app_images.dart';
import 'package:sowaste/data/services/data_center.dart';
import 'package:sowaste/modules/home/home_controller.dart';
import 'package:sowaste/modules/home/widgets/learn_more_button.dart';
import 'package:sowaste/modules/home/widgets/news_card.dart';
import 'package:sowaste/modules/home/widgets/pie_chart.dart';
import 'package:sowaste/modules/home/widgets/quiz_card.dart';
import 'package:sowaste/routes/app_routes.dart';

import '../widgets/detect_trash_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Row title(String text, [final VoidCallback? seeAll, isShowSeeAll = false]) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(text,
              style: CustomTextStyle.sub(AppColors.onBg).copyWith(height: 1.5)),
          isShowSeeAll
              ? GestureDetector(
                  onTap: seeAll,
                  child: Row(
                    children: [
                      Text(
                        "See All",
                        style: CustomTextStyle.normal(AppColors.primary),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppColors.primaryDark,
                      )
                    ],
                  ),
                )
              : Container()
        ]);
  }

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find();
    return Scaffold(
        appBar: AppBar(
          title: Image.asset(AppImages.appLogo),
          backgroundColor: AppColors.background,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              title("Overview"),

              // Piechart
              Obx(
                () => (DataCenter.recentDetectedTrash.isEmpty)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "You haven’t done any trash detecting yet.",
                            style: CustomTextStyle.bodyBold(AppColors.onBg)
                                .copyWith(height: 1.5),
                          ),
                          const CameraButton(),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "This week, you have detected ${homeController.totalTimesDetecting} times ",
                            style: CustomTextStyle.bodyBold(AppColors.onBg)
                                .copyWith(height: 1.5),
                          ),
                          PieChart(),
                          const LearnMoreButton(),
                        ],
                      ),
              ),

              //Your Quizzes
              title(
                  "Your Quizzes",
                  () => {
                        Get.toNamed(AppRoutes.quizzesPage),
                      },
                  true),
              Obx(() => DataCenter.localQuizList.isNotEmpty
                  ? Column(
                      children: [
                        SizedBox(
                            height: 180,
                            child: Obx(
                              () => ListView.builder(
                                itemBuilder: ((context, index) {
                                  return QuizCard(
                                    quiz: DataCenter.localQuizList[index],
                                  );
                                }),
                                itemCount: DataCenter.localQuizList.length,
                                scrollDirection: Axis.horizontal,
                              ),
                            )),
                      ],
                    )
                  : Container()),

              //Environment News
              title("Environment News",
                  () => {Get.toNamed(AppRoutes.environmentNewsPage)}, true),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) =>
                      NewsCard(article: DataCenter.news[index]),
                  itemCount: DataCenter.news.length,
                ),
              ),
            ]),
          ),
        ));
  }
}
