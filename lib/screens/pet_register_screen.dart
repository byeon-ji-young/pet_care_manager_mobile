import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/pet.dart';

import '../database/database_helper.dart';

class PetRegisterScreen extends StatefulWidget {
  // StatefulWidget: 사용자가 화면을 입력할 때 화면의 상태가 계속 바뀌기 때문에 사용
  final Pet? pet;

  const PetRegisterScreen({super.key, this.pet});

  @override
  State<PetRegisterScreen> createState() => _PetRegisterScreenState();
}

class _PetRegisterScreenState extends State<PetRegisterScreen> {
  // TextEditingController: 텍스트 입력창(TextField)에 입력된 값을 실시간으로 읽어오거나 조작하는 컨트롤러 (입력값 관리 컨트롤러)
  final TextEditingController nameController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  final ImagePicker imagePicker = ImagePicker();
  XFile? selectedImage;

  bool removeImage = false; // false: 기존 사진 유지, true: 기존 사진 삭제

  // 성별
  String? selectedGender;

  // 생일
  DateTime? selectedBirthDate;

  /*
    String (물음표 없음) : 절대 null이 될 수 없음 (무조건 값이 있어야 함). 반드시 즉시 초기화 필요
    String? (물음표 있음) : null이 들어올 수도 있음 (값이 없을 수도 있음). 아무 값도 안 넣으면 기본적으로 null

  */

  @override
  void initState() {
    super.initState();

    final pet = widget.pet;

    if (pet != null) {
      nameController.text = pet.name;
      breedController.text = pet.breed ?? '';
      weightController.text = pet.weight?.toString() ?? '';

      selectedGender = pet.gender;
      selectedBirthDate = pet.birthDate;
    }
  }

  @override
  // dispose() 필수 작성: 컨트롤러는 앱 메모리를 차지하므로, 화면이 파괴(종료)될 때 dispose()에서 메모리를 해제해 주어야 메모리 누수를 막을 수 있음
  void dispose() {
    nameController.dispose();
    breedController.dispose();
    weightController.dispose();

    super.dispose();
  }

  /*
    생일 선택 (showDatePicker & async/await)
    - async / await (비동기): 사용자가 달력 팝업에서 날짜를 선택할 때까지 기다렸다가(await), 선택이 끝나면 다음 코드 실향
    - setState(): 선택한 날짜(pickedDate)를 변수에 저장하고 화면을 다시 그려서(리렌더링) 선택한 날짜가 화면 텍스트에 즉시 갱신
  */
  // Future<>는 비동기 함수
  Future<void> selectBirthDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedBirthDate = pickedDate;
      });
    }
  }

  // 이미지 선택
  Future<void> selectImage() async {
    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      selectedImage = image;
    });
  }

  // 이미지 저장
  Future<String?> saveImage() async {
    if (selectedImage == null) {
      return null;
    }

    final directory =
        await getApplicationDocumentsDirectory(); // getApplicationDocumentsDirectory: 앱 전용 문서 저장 공간의 경로를 가져오는 함수

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${selectedImage!.name}';

    final savedImage = await File(
      selectedImage!.path,
    ).copy('${directory.path}/$fileName');

    return savedImage.path;
  }

  // 공통 InputDecoration
  InputDecoration _buildInputDecoration({
    required String hintText,
    Widget? suffixIcon,
    String? suffixText,
  }) {
    // 동기 함수라서 Future<> 안적음
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      suffixIcon: suffixIcon,
      suffixText: suffixText,
      suffixStyle: TextStyle(
        color: Colors.grey[700],
        fontWeight: FontWeight.w500,
      ),
      filled: true, // TextField의 입력 영역에 배경색을 채울지 여부
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 1.5,
        ),
      ),
    );
  }

  // 공통 라벨
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsetsGeometry.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          // letterSpacing: -0.3 // 글자 사이 간격
        ),
      ),
    );
  }

  // UI 구성 및 레이아웃 포인트
  @override
  Widget build(BuildContext context) {
    final hasImage =
        selectedImage != null ||
        (!removeImage && widget.pet?.imagePath != null);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pet == null ? '반려동물 등록' : '반려동물 수정',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0, // 위젯에 주는 그림자(입체감)를 없애는 설정
      ),

      /*
        SingleChildScrollView (스크린 키보드 대응)
        - 텍스트 입력창을 터치하면 밑에서 소프트 키보드가 올라오는데, 이때 화면이 좁아져 노란색/검은색 빗금 오류(Overflow error)가 나는 것을 방지하고 스크롤 가능하도록 만들어 줌

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column( ... ),
        )
      */
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. 프로필 사진 영역
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: selectedImage != null
                                ? FileImage(File(selectedImage!.path))
                                : (!removeImage && widget.pet?.imagePath != null
                                      ? FileImage(File(widget.pet!.imagePath!))
                                      : null),
                            child: !hasImage
                                ? const Icon(Icons.pets, size: 50)
                                : null,
                          ),

                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                onPressed: selectImage,
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                ),
                                icon: Icon(
                                  hasImage ? Icons.edit : Icons.camera_alt,
                                  size: 16,
                                ),
                                label: Text(
                                  hasImage ? '사진 변경' : '사진 추가',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),

                              if (hasImage) ...[
                                const SizedBox(width: 8),

                                OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      removeImage = true;
                                      selectedImage = null;
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    foregroundColor: Colors.red[400],
                                    side: BorderSide(color: Colors.red[200]!),
                                  ),
                                  icon: Icon(Icons.delete_outline, size: 16),
                                  label: const Text(
                                    '사진 삭제',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 2. 이름
                    _buildSectionLabel('* 이름'),

                    TextField(
                      controller: nameController,
                      decoration: _buildInputDecoration(hintText: '예: 몽이'),
                    ),

                    const SizedBox(height: 20),

                    // 3. 생일
                    _buildSectionLabel('생일'),
                    /*
                      InkWell + InputDecorator (클릭 가능한 텍스트 상자)
                      - InkWell: 터치(클릭) 이벤트를 감지하여 물결 애니메이션 효과 생성
                      - InputDecorator: 일반 Text 위젯을 TextField처럼 테두리가 있는 입력창 스타일로 감싸주는 위젯. 클릭 시 달력(showDatePicker)이 열리도록 디자인함

                      InkWell(
                        onTap: selectBirthDate,
                        child: InputDecorator( ... ),
                      )
                    */
                    InkWell(
                      onTap: selectBirthDate,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: _buildInputDecoration(
                          hintText: '',
                          suffixIcon: Icon(
                            Icons.calendar_today_rounded,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                        ),
                        child: Text(
                          selectedBirthDate == null
                              ? '생일을 선택해주세요'
                              : '${selectedBirthDate!.year}.${selectedBirthDate!.month.toString().padLeft(2, '0')}.${selectedBirthDate!.day.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 15,
                            color: selectedBirthDate == null
                                ? Colors.grey[400]
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 4. 성별
                    _buildSectionLabel('성별'),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedGender = '남아';
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: selectedGender == '남아'
                                    ? Theme.of(
                                        context,
                                      ).primaryColor.withValues(alpha: 0.1)
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedGender == '남아'
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[300]!,
                                  width: selectedGender == '남아' ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.male,
                                    color: selectedGender == '남아'
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey[500],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '남아',
                                    style: TextStyle(
                                      fontWeight: selectedGender == '남아'
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: selectedGender == '남아'
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedGender = '여아';
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: selectedGender == '여아'
                                    ? Theme.of(
                                        context,
                                      ).primaryColor.withValues(alpha: 0.1)
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedGender == '여아'
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[300]!,
                                  width: selectedGender == '여아' ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.female,
                                    color: selectedGender == '여아'
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey[500],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '여아',
                                    style: TextStyle(
                                      fontWeight: selectedGender == '여아'
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: selectedGender == '여아'
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    /*
                      RadioListTile & Expanded (성별 선택)
                      - RadioListTile: 라디오 단추와 라벨 텍스트를 한 번에 만드는 위젯. groupValue와 value가 일치하면 선택된 상태로 표시
                      - Expanded: Row(가로 배치) 안에서 남아있는 가로 공간을 50:50으로 정확히 나누어 가지도록 만듦

                      Row(
                        children: [
                          Expanded(child: RadioListTile<String>( ... )),
                          Expanded(child: RadioListTile<String>( ... )),
                        ],
                      )
                    */
                    // RadioGroup<String>(
                    //   groupValue: selectedGender,
                    //   onChanged: (String? value) {
                    //     setState(() {
                    //       selectedGender = value;
                    //     });
                    //   },
                    //   child: Row(
                    //     children: const [
                    //       Expanded(
                    //         child: RadioListTile<String>(
                    //           title: Text('남아'),
                    //           value: '남아',
                    //           // groupValue, onChanged 제거!
                    //         ),
                    //       ),
                    //       Expanded(
                    //         child: RadioListTile<String>(
                    //           title: Text('여아'),
                    //           value: '여아',
                    //           // groupValue, onChanged 제거!
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    const SizedBox(height: 20),

                    // 5. 품종
                    _buildSectionLabel('품종'),
                    TextField(
                      controller: breedController,
                      decoration: _buildInputDecoration(hintText: '예: 말티즈'),
                    ),

                    const SizedBox(height: 20),

                    // 6. 몸무게
                    _buildSectionLabel('몸무게'),
                    /*
                      keyboardType (숫자 키보드)
                      - 몸무게 입력 시 자판이 영문/한글 대신 숫자 키패드로 바로 뜨도록 함

                      TextField(
                        controller: weightController,
                        keyboardType: TextInputType.number, // 숫자 키보드 호출
                        keyboardType: const TextInputType.numberWithOptions(decimal: true) // 소수점 입력까지 고려한 숫자 키보드
                      )
                    */
                    TextField(
                      controller: weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _buildInputDecoration(
                        hintText: '예: 3.5',
                        suffixText: 'kg',
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            // 등록/수정 버튼
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final String name = nameController.text.trim();

                    /*
                      ScaffoldMessenger.of(context) (알림 전달자)
                      .showSnackBar(...) (메시지 띄우기)
                      const SnackBar( content: Text(...) ) (메시지 내용물)
                    */
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("반려동물 이름을 입력해주세요.")),
                      );
                      return;
                    }

                    // 몸무게 숫자 처리 ex. "3.5" -> double.tryParse() -> 3.5 / "abc" -> double.tryParse() -> null
                    final double? weight = double.tryParse(
                      weightController.text.trim(),
                    );

                    final String? oldImagePath = widget.pet?.imagePath;
                    String? savedImagePath = oldImagePath;
                    if (selectedImage != null) {
                      savedImagePath = await saveImage();
                    }

                    final Pet pet = Pet(
                      id: widget.pet?.id,
                      name: name,
                      birthDate: selectedBirthDate,
                      gender: selectedGender,
                      breed: breedController.text.trim(),
                      weight: weight,
                      imagePath: removeImage ? null : savedImagePath,
                    );

                    if (widget.pet == null) {
                      // 신규 등록
                      await DatabaseHelper.instance.insertPet(pet); // 추가된 id 반환
                    } else {
                      // 기존 반려동물 수정
                      await DatabaseHelper.instance.updatePet(pet); // 수정된 개수 반환
                    }

                    // 기존 파일 삭제
                    if (removeImage && oldImagePath != null) {
                      final oldFile = File(oldImagePath);

                      if (await oldFile.exists()) {
                        await oldFile.delete();
                      }
                    }

                    /*
                      신규 등록 + 사진 선택 → 새 사진 경로
                      수정 + 사진 안 바꿈 → 기존 사진 경로
                      수정 + 새 사진 선택 → 새 사진 경로
                    */
                    if (selectedImage != null &&
                        oldImagePath != null &&
                        oldImagePath != savedImagePath) {
                      final oldFile = File(oldImagePath);

                      if (await oldFile.exists()) {
                        await oldFile.delete();
                      }
                    }

                    if (!context.mounted) {
                      // mounted: 화면 살아있는지 체크
                      return;
                    }

                    // 등록/수정 완료 알림
                    // ScaffoldMessenger.of(context).showSnackBar( // Navigator.pop(context, true) 이거 하면 화면이 이동되게 때문에 snackbar가 안보일 수 있어서 주석처리함
                    //   SnackBar(
                    //     content: Text(
                    //       widget.pet == null
                    //         ? "${pet.name} 등록 완료!"
                    //         : "${pet.name} 수정 완료!",
                    //     )
                    //   )
                    // );

                    /*
                      Navigator.pop(): 현재 화면을 닫고 이전 화면으로 돌아가라는 뜻
                      Navigator.pop(context, ...): context는 현재 화면의 위치/정보를 Flutter에게 알려주는 것
                      Navigator.pop(context, true): 화면을 닫으면서 true라는 결과도 돌려줘
                    */
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.pets, size: 20),
                  label: Text(
                    widget.pet == null ? '등록하기' : '수정하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
