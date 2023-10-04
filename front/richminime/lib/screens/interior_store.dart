import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:richminime/models/interior_theme_model.dart';
import 'package:richminime/services/interior_service.dart';
import 'package:richminime/widgets/appbar_back_home.dart';

class InteriorStore extends StatefulWidget {
  const InteriorStore({super.key});

  @override
  State<InteriorStore> createState() => _InteriorStoreState();
}

class _InteriorStoreState extends State<InteriorStore> {
  final List<String> categories = ["벽지장판", "러그", "가구"];
  int selectedCategoryIndex = 0; // 선택된 카테고리 인덱스

  int selectedIndex = 0;
  String miniRoomImgLink = '';
  final InteriorService interiorService = InteriorService();
  List<InteriorThemeModel> itemList = [];
  List<InteriorThemeModel> sortedItemList = [];

// 전체 불러오기
  @override
  void initState() {
    super.initState();
    loadItemData();
    sortedItemList = itemList
        .where((item) => item.itemType == categories[selectedCategoryIndex])
        .toList();
  }

  Future<void> loadItemData() async {
    try {
      final loadedItemList = await interiorService.getAllItems();
      setState(() {
        itemList = loadedItemList;
      });
    } catch (e) {
      // 에러 처리
      print("Error loading item data: $e");
    }
  }

  // 우선 탭 = 미리보기
  int tappedIndex = 3000000;
  themeTap(int index) {
    setState(() {});
    tappedIndex = index;
  }

  // 테마 사기
  applyTheme() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarBackHome(title: "가구 가게"),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: Column(
            children: [
              Flexible(
                fit: FlexFit.tight,
                flex: 6,
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black.withOpacity(0.2),
                  ),
                  child: tappedIndex == 3000000
                      ? const Center(child: Text('골라봐~~'))
                      : Row(
                          children: [
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 1,
                              child: Stack(children: [
                                Container(
                                  clipBehavior: Clip.hardEdge,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '전',
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                    child: Image.network(
                                  sortedItemList[tappedIndex].itemImg ?? '',
                                  fit: BoxFit.cover,
                                ))
                              ]),
                            ),
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    '<${sortedItemList[tappedIndex].itemName}>',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Expanded(
                                    child: ShaderMask(
                                      shaderCallback: (Rect bounds) {
                                        return LinearGradient(
                                          //아래 속성들을 조절하여 원하는 값을 얻을 수 있다.
                                          begin: Alignment.center,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.white,
                                            Colors.white.withOpacity(0.02)
                                          ],
                                          stops: const [0.8, 1],
                                          tileMode: TileMode.mirror,
                                        ).createShader(bounds);
                                      },
                                      child: SingleChildScrollView(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 8),
                                          child: Text(
                                            '<${sortedItemList[tappedIndex].itemInfo}>',
                                            overflow: TextOverflow
                                                .clip, // Overflow 발생 시 글 내용을 자르지 않고 표시
                                            style: const TextStyle(
                                              fontSize: 17,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Material(
                                    elevation: 3,
                                    color: Theme.of(context).cardColor,
                                    shadowColor: Colors.black54,
                                    borderRadius: BorderRadius.circular(5),
                                    child: InkWell(
                                        splashColor: Colors.white54,
                                        onTap: () {},
                                        borderRadius: BorderRadius.circular(5),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 12),
                                          child: Text(
                                            "구매하기",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                ),
              ),

              // 테마+아이템이 들어갈 시 주어질 버튼
              Flexible(
                fit: FlexFit.tight,
                flex: 1,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // 수평 스크롤 가능
                  child: Row(
                    children: makeButtons(categories),
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                flex: 5,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.topRight,
                      colors: [Colors.white, Colors.white.withOpacity(0.02)],
                      stops: const [0.8, 1],
                      tileMode: TileMode.mirror,
                    ).createShader(bounds);
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      scrollDirection: Axis.horizontal,
                      itemCount: sortedItemList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => themeTap(index),
                          child: Container(
                            clipBehavior: Clip.hardEdge,
                            margin: const EdgeInsets.symmetric(
                                vertical: 3, horizontal: 10),
                            width: 150,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(5),
                              border: tappedIndex == index
                                  ? Border.all(width: 3, color: Colors.white38)
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 5,
                                  offset: const Offset(10, 3),
                                  color: Colors.black.withOpacity(0.3),
                                )
                              ],
                            ),
                            child: Center(
                              child: Image.network(
                                sortedItemList[index].itemImg ??
                                    '', // 이미지 URL을 itemList에서 가져오기
                                fit: BoxFit.cover, // 이미지가 컨테이너에 맞게 확대/축소
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 테마+아이템이 들어갈 시 주어질 버튼
  List<Widget> makeButtons(List<String> categories) {
    List<Widget> buttons = [];

    for (int index = 0; index < categories.length; index++) {
      buttons.add(
        Container(
          margin: const EdgeInsets.all(8), // 버튼 간격 조정
          child: AnimatedButton(
            textAlignment: Alignment.center,
            height: 35,
            width: 70,
            text: categories[index],
            isReverse: false,
            isSelected: selectedCategoryIndex == index ? true : false,
            selectedBackgroundColor: Theme.of(context).cardColor,
            selectedTextColor: Colors.black,
            transitionType: TransitionType.LEFT_TO_RIGHT,
            textStyle: const TextStyle(
                color: Colors.black54,
                fontFamily: 'StarDustS',
                fontWeight: FontWeight.w700,
                fontSize: 18),
            backgroundColor: const Color(0xFFFFBEBE).withOpacity(0.2),
            borderColor: Colors.white38,
            borderRadius: 5,
            borderWidth: 2,
            onPress: () {
              setState(() {
                selectedCategoryIndex = index; // 카테고리 선택 시 인덱스 업데이트
                final selectedCategory = categories[selectedCategoryIndex];
                sortedItemList = itemList
                    .where((item) => item.itemType == selectedCategory)
                    .toList();
              });
            },
            // 각 버튼에 카테고리 텍스트 표시
          ),
        ),
      );
    }

    return buttons;
  }
}
