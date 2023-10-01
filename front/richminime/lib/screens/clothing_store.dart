import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:richminime/widgets/clothing_store_selected.dart';

class ClothingStore extends StatefulWidget {
  const ClothingStore({super.key});

  @override
  State<ClothingStore> createState() => _ClothingStoreState();
}

class _ClothingStoreState extends State<ClothingStore> {
  final List<String> categories = ["일상", "파티", "직업"];
  int selectedIndex = 0; // 선택된 카테고리 인덱스

  bool isSelected = false;

  onSelect() {
    setState(() {
      isSelected = true;
    });
  }

  toTheList() {
    setState(() {
      isSelected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: Column(
            children: [
              Flexible(
                fit: FlexFit.tight,
                flex: 5,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                      child: Image.asset("assets/images/minime/default.png")),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                flex: 1,
                child: isSelected
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: toTheList,
                            icon: const Icon(Icons.navigate_before_rounded),
                          ),
                        ],
                      )
                    : ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            //아래 속성들을 조절하여 원하는 값을 얻을 수 있다.
                            begin: Alignment.topCenter,
                            end: Alignment.topRight,
                            colors: [
                              Colors.white,
                              Colors.white.withOpacity(0.08)
                            ],
                            stops: const [0.9, 1],
                            tileMode: TileMode.mirror,
                          ).createShader(bounds);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal, // 수평 스크롤 가능
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: makeButtons(categories),
                            ),
                          ),
                        ),
                      ),
              ),
              Flexible(
                fit: FlexFit.tight,
                flex: 5,
                child: isSelected
                    ? const ClothingStoreSelected(
                        clothingId: 0,
                        clothingName: '',
                        clothingInfo: '',
                        clothingImg: '',
                        clothingApplyImg: '',
                        price: 0,
                      )
                    : ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            //아래 속성들을 조절하여 원하는 값을 얻을 수 있다.
                            begin: Alignment.center,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.white,
                              Colors.white.withOpacity(0.02)
                            ],
                            stops: const [0.9, 1],
                            tileMode: TileMode.mirror,
                          ).createShader(bounds);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                            ),
                            itemCount: 30,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: onSelect,
                                child: Container(
                                  margin: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 3,
                                        offset: const Offset(3, 3),
                                        color: Colors.black.withOpacity(0.3),
                                      )
                                    ],
                                  ),
                                  child: Center(
                                    child: Text('옷 사진들 $index'),
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

  List<Widget> makeButtons(List<String> categories) {
    List<Widget> buttons = [];

    for (int index = 0; index < categories.length; index++) {
      buttons.add(
        Container(
          margin: const EdgeInsets.all(8), // 버튼 간격 조정
          child: AnimatedButton(
            textAlignment: Alignment.center,
            height: 70,
            width: 70,
            text: categories[index],
            // isReverse: false,
            isSelected: selectedIndex == index ? true : false,
            selectedBackgroundColor: Theme.of(context).cardColor,
            selectedTextColor: Colors.black,
            transitionType: TransitionType.LEFT_TO_RIGHT,
            textStyle: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w700,
                fontSize: 15),
            backgroundColor: const Color(0xFFFFBEBE).withOpacity(0.2),
            borderColor: Colors.white38,
            borderRadius: 5,
            borderWidth: 2,
            onPress: () {
              setState(() {
                selectedIndex = index; // 카테고리 선택 시 인덱스 업데이트
              });
            },
          ),
        ),
      );
    }

    return buttons;
  }
}
