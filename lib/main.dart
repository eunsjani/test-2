import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '아이들에게 따뜻한 식사를',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
      ),
      home: DonationPage(),
    );
  }
}

class DonationPage extends StatefulWidget {
  @override
  _DonationPageState createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  int targetDonation = 5000;
  double weeklyDonation = 500;
  int selectedCombination = 0;
  bool showStampSection = false;
  int stampedCount = 0;
  
  final List<Map<String, dynamic>> recommendedCombinations = [
    {"total": 5000, "weekly": 500, "label": "분식집 한 끼", "icon": "🍜"},
    {"total": 10000, "weekly": 1000, "label": "덮밥 한 그릇", "icon": "🍛"},
    {"total": 15000, "weekly": 1500, "label": "세트 메뉴", "icon": "🍱"},
    {"total": 20000, "weekly": 2000, "label": "반찬 가득 정식", "icon": "🍽️"},
    {"total": 30000, "weekly": 3000, "label": "고기 먹는 날", "icon": "🍖"}
  ];

  @override
  void initState() {
    super.initState();
    _loadStampedCount();
  }

  _loadStampedCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      stampedCount = prefs.getInt('stampedCount') ?? 0;
    });
  }

  _saveStampedCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('stampedCount', stampedCount);
  }

  int get weeksNeeded {
    if (weeklyDonation > 0) {
      return (targetDonation / weeklyDonation).ceil();
    }
    return 0;
  }

  String get weeksNeededDisplay {
    if (weeksNeeded == 0) return "0주";
    
    int months = weeksNeeded ~/ 4;
    int remainingWeeks = weeksNeeded % 4;
    
    String display = "";
    if (months > 0) {
      display += "${months}달 ";
    }
    if (remainingWeeks > 0 || months == 0) {
      display += "${remainingWeeks}주";
    }
    return display.trim();
  }

  String formatCurrency(int amount) {
    return "${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원";
  }

  void _selectCombination(int index) {
    setState(() {
      selectedCombination = index;
      targetDonation = recommendedCombinations[index]['total'];
      weeklyDonation = recommendedCombinations[index]['weekly'].toDouble();
    });
  }

  void _showStampSection() {
    setState(() {
      showStampSection = true;
    });
  }

  void _stampSlot(int index) {
    if (index == stampedCount && index < weeksNeeded) {
      setState(() {
        stampedCount++;
      });
      _saveStampedCount();
    }
  }

  void _resetStamps() {
    setState(() {
      stampedCount = 0;
    });
    _saveStampedCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 600),
              margin: EdgeInsets.all(24),
              padding: EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFFE0E0E0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 제목
                  Text(
                    "아이들에게 따뜻한 식사를 선물해주세요",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  
                  // 추천 기부 조합 선택
                  Column(
                    children: [
                      Text(
                        "추천 기부 조합 선택",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF333333),
                        ),
                      ),
                      SizedBox(height: 24),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: recommendedCombinations.asMap().entries.map((entry) {
                          int index = entry.key;
                          Map<String, dynamic> combo = entry.value;
                          bool isSelected = selectedCombination == index;
                          
                          return GestureDetector(
                            onTap: () => _selectCombination(index),
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: isSelected ? Color(0xFFE6F0FF) : Color(0xFFF2F4F6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? Color(0xFF007AFF) : Colors.transparent,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    combo['icon'],
                                    style: TextStyle(fontSize: 45),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    combo['label'],
                                    style: TextStyle(
                                      fontSize: 14.4,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Color(0xFF007AFF) : Color(0xFF1C1C1E),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  
                  // 총 목표 기부 금액 표시
                  Column(
                    children: [
                      Text(
                        "총 목표 기부 금액: ${formatCurrency(targetDonation)}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF555555),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  
                  // 매주 기부 금액 슬라이더
                  Column(
                    children: [
                      Text(
                        "매주 부담 없이 낼 수 있는 금액: ${formatCurrency(weeklyDonation.toInt())}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF555555),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("500원", style: TextStyle(fontSize: 12, color: Color(0xFF666666))),
                          Text("5,000원", style: TextStyle(fontSize: 12, color: Color(0xFF666666))),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Color(0xFF007BFF),
                          inactiveTrackColor: Color(0xFFE5E7EB),
                          thumbColor: Color(0xFF007BFF),
                          overlayColor: Color(0xFF007BFF).withOpacity(0.2),
                          trackHeight: 6,
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                        ),
                        child: Slider(
                          value: weeklyDonation,
                          min: 500,
                          max: 5000,
                          divisions: 9,
                          onChanged: (value) {
                            setState(() {
                              weeklyDonation = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  
                  // 계산 결과 및 메시지
                  Container(
                    padding: EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xFFE0E0E0)),
                    ),
                    child: Column(
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1C1C1E),
                              height: 1.6,
                            ),
                            children: [
                              TextSpan(
                                text: weeksNeededDisplay,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1C1C1E),
                                ),
                              ),
                              TextSpan(text: " 동안 함께 해주시면, 한 아이의 따뜻한 식사를 지원할 수 있어요!"),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFF2F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 15.2,
                                color: Color(0xFF444444),
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(text: "아이들에게는, 이렇게 꾸준히 "),
                                TextSpan(
                                  text: "자신을 지지해주는 누군가가 있다는 사실",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF007AFF),
                                  ),
                                ),
                                TextSpan(text: "을\n꼭 전달할게요. 사실 돈보다, "),
                                TextSpan(
                                  text: "이런 지지가 더 필요했어요.",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF007AFF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 48),
                  
                  // 시작하기 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showStampSection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF007AFF),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "시작하기",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  
                  // 스탬프 섹션
                  if (showStampSection) ...[
                    SizedBox(height: 48),
                    Container(
                      padding: EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Color(0xFFFEFEFE),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Color(0xFFE0E0E0)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "나의 주간 스탬프",
                            style: TextStyle(
                              fontSize: 28.8,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            "매주 스탬프를 찍으며 아이들에게 따뜻한 마음을 전달해주세요.\n(이 스탬프는 실제 기부를 의미하며, 클릭 시 기부통에 돈을 넣는 행위로 간주됩니다.)",
                            style: TextStyle(
                              fontSize: 15.2,
                              color: Color(0xFF555555),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xFFD0D0D0)),
                            ),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1,
                              ),
                              itemCount: weeksNeeded,
                              itemBuilder: (context, index) {
                                bool isStamped = index < stampedCount;
                                bool canStamp = index == stampedCount;
                                
                                return GestureDetector(
                                  onTap: canStamp ? () => _stampSlot(index) : null,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isStamped ? Color(0xFF28A745) : Color(0xFFE8E8E8),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isStamped ? Color(0xFF28A745) : Color(0xFFD8D8D8),
                                      ),
                                    ),
                                    child: Center(
                                      child: isStamped
                                          ? Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 20,
                                            )
                                          : Text(
                                              "${index + 1}주차",
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF999999),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 32),
                          Text(
                            "총 스탬프: $stampedCount / $weeksNeeded",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF555555),
                            ),
                          ),
                          SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _resetStamps,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFDC3545),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              "스탬프 초기화",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}