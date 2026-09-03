import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/database_helper.dart';

import '../models/health_record.dart';
import '../models/health_record_image.dart';

import '../utils/date_time_utils.dart';

class HealthRecordRegisterScreen extends StatefulWidget {
  final int petId;
  final HealthRecord? record; // record == null → 신규 등록 / record != null → 수정

  const HealthRecordRegisterScreen({
    super.key,
    required this.petId,
    this.record,
  });

  @override
  State<HealthRecordRegisterScreen> createState() =>
      _HealthRecordRegisterScreenState();
}

class _HealthRecordRegisterScreenState
    extends State<HealthRecordRegisterScreen> {
  final TextEditingController hospitalController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController examinationTypeController =
      TextEditingController();
  final TextEditingController examinationResultController =
      TextEditingController();
  final TextEditingController costController = TextEditingController();

  DateTime selectedDate = DateTimeUtils.todayKst();
  TimeOfDay? selectedTime;

  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> selectedImages = [];
  List<HealthRecordImage> existingImages = [];

  @override
  void initState() {
    super.initState();

    final record = widget.record;

    if (record != null) {
      hospitalController.text =
          record.hospital ?? ''; // ??는 null일 경우 다른 값을 사용하라
      titleController.text = record.title;
      descriptionController.text = record.description ?? '';
      examinationTypeController.text = record.examinationType ?? '';
      examinationResultController.text = record.examinationResult ?? '';

      costController.text = record.cost?.toString() ?? '';

      selectedDate = record.date;
      selectedTime = record.time;

      _loadExistingImages();
    }
  }

  @override
  void dispose() {
    hospitalController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    examinationTypeController.dispose();
    examinationResultController.dispose();
    costController.dispose();

    super.dispose();
  }

  // 병원 기록 사진 불러오기
  Future<void> _loadExistingImages() async {
    final recordId = widget.record?.id;

    if (recordId == null) {
      return;
    }

    final images = await DatabaseHelper.instance.getHealthRecordImages(
      recordId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      existingImages = images;
    });
  }

  // 병원 기록 삭제
  Future<void> _deleteRecord() async {
    final record = widget.record;

    // 신규 등록 화면은 삭제할 기록이 없으므로 종료
    if (record == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          // title: const Text('병원 기록 삭제'),
          content: Text('${record.title} 기록을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              // style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text(
                '삭제',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await DatabaseHelper.instance.deleteHealthRecord(record.id!);

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  // 갤러리에서 사진 여러 장 선택
  Future<void> _pickImages() async {
    final pickedImages = await _imagePicker.pickMultiImage(imageQuality: 85);

    if (pickedImages.isEmpty) {
      return;
    }

    setState(() {
      selectedImages.addAll(pickedImages);
    });
  }

  // 선택한 사진 삭제
  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  // 기존 사진 삭제
  Future<void> _deleteExistingImage(HealthRecordImage image) async {
    try {
      // DB에서 사진 정보 삭제
      await DatabaseHelper.instance.deleteHealthRecordImage(image.id!);

      // 실제 파일 삭제
      final file = File(image.imagePath);

      if (await file.exists()) {
        await file.delete();
      }

      if (!mounted) {
        return;
      }

      setState(() {
        existingImages.remove(image);
      });
    } catch (e) {
      debugPrint('기존 사진 삭제 실패: $e');

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('사진을 삭제하지 못했어요.')));
    }
  }

  // 사진 저장
  Future<void> _saveImages(int healthRecordId) async {
    if (selectedImages.isEmpty) {
      return;
    }

    // 앱 전용 문서 저장공간
    final appDirectory =
        await getApplicationDocumentsDirectory(); // getApplicationDocumentsDirectory(): 앱이 사용할 수 있는 전용 문서 저장공간의 위치를 가져옴

    // 건강 기록별 사진 폴더
    final recordDirectory = Directory(
      p.join(appDirectory.path, 'health_records', healthRecordId.toString()),
    );

    if (!await recordDirectory.exists()) {
      await recordDirectory.create(
        recursive: true,
      ); // recursive: true는 중간 폴더까지 필요한 경우 알아서 만들어주라는 의미
    }

    for (int i = 0; i < selectedImages.length; i++) {
      final image = selectedImages[i];

      // 사진 파일의 확장자
      final extension = p.extension(image.path);

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i$extension';

      final targetPath = p.join(recordDirectory.path, fileName);

      // 선택한 원본 사진을 앱 전용 저장공간으로 복사 - 실제로 사진을 저장하는 부분
      await File(image.path).copy(targetPath);

      // DB에는 복사된 파일 경로만 저장 - DB와 연결되는 부분
      await DatabaseHelper.instance.insertHealthRecordImage(
        HealthRecordImage(
          healthRecordId: healthRecordId,
          imagePath: targetPath,
        ),
      );
    }
  }

  /*
  // 사진 확대
  void _showImagePreview(String imagePath) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: InteractiveViewer(
            // InteractiveViewer: 손가락으로 확대/축소하거나 이동할 수 있게 해주는 위젯
            minScale: 0.8, // 얼마나 작게 축소할 수 있는지 (1.0 = 원래 크기)
            maxScale: 4.0, // 얼마나 크게 확대할 수 있는지 (1.0 = 원래 크기)
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(imagePath),
                fit: BoxFit
                    .contain, // BoxFit.contain: 이미지 전체가 잘리지 않도록 화면 안에 맞춰서 보여주는 방식. 사진 전체를 보여주기 때문에 위아래 또는 좌우 빈 공간이 생길 수 있음
              ),
            ),
          ),
        );
      },
    );
  }
  */

  // 사진 확대
  void _showImagesPreview({
    required List<String> imagePaths,
    required int initialIndex,
  }) {
    final pageController = PageController(
      initialPage: initialIndex,
    ); // PageView의 페이지를 조종하는 컨트롤러
    int currentIndex = initialIndex;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return StatefulBuilder(
          //currentIndex가 바뀌어야 하기 때문에 StatefulBuilder 사용
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: Stack(
                children: [
                  // 사진 좌우 넘기기
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: PageView.builder(
                      // PageView: 페이지 단위로 좌우 스와이프할 수 있는 위젯
                      controller: pageController,
                      itemCount: imagePaths.length,
                      onPageChanged: (index) {
                        setDialogState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return InteractiveViewer(
                          // InteractiveViewer: 손가락으로 확대/축소하거나 이동할 수 있게 해주는 위젯
                          minScale: 0.8, // 얼마나 작게 축소할 수 있는지 (1.0 = 원래 크기)
                          maxScale: 4.0, // 얼마나 크게 확대할 수 있는지 (1.0 = 원래 크기)
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(imagePaths[index]),
                                fit: BoxFit
                                    .contain, // BoxFit.contain: 이미지 전체가 잘리지 않도록 화면 안에 맞춰서 보여주는 방식. 사진 전체를 보여주기 때문에 위아래 또는 좌우 빈 공간이 생길 수 있음
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // 현재 사진 번호
                  Positioned(
                    top: 8, // bottom: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${currentIndex + 1} / ${imagePaths.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      pageController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.record != null;

    return Scaffold(
      appBar: AppBar(
        // title: Text(isEditing ? '병원 기록 수정' : '병원 기록 등록'),
        title: null,
        centerTitle: true,
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isEditing ? '병원 진료 내역 수정' : '새로운 병원 기록',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        if (isEditing)
                          IconButton(
                            onPressed: _deleteRecord,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                              size: 22,
                            ),
                            tooltip: '기록 삭제',
                          ),
                      ],
                    ),

                    Text(
                      '진료받은 내용을 꼼꼼하게 기록해 주세요.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 24),

                    // 1. 병원명 입력창
                    TextField(
                      controller: hospitalController,
                      decoration: InputDecoration(
                        labelText: '병원명',
                        hintText: '예: 펫몽 동물병원',
                        prefixIcon: const Icon(Icons.local_hospital_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 2. 진료 제목 입력창
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: '* 진료 제목',
                        hintText: '예: 예방접종 / 정기검진',
                        prefixIcon: const Icon(Icons.medical_services_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 3. 진료 내용 입력창
                    TextField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: '진료 내용',
                        hintText: '진료 소견이나 처방받은 약 정보를 적어주세요.',
                        alignLabelWithHint:
                            true, // TextField의 labelText와 hintText의 세로 정렬을 맞춰주는 옵션
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(Icons.notes),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 4. 검사 종류 입력창
                    TextField(
                      controller: examinationTypeController,
                      decoration: InputDecoration(
                        labelText: '검사 종류',
                        hintText: '예: 혈액검사 / X-ray / 초음파',
                        prefixIcon: const Icon(Icons.biotech_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 5. 검사 결과 입력창
                    TextField(
                      controller: examinationResultController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: '검사 결과',
                        hintText: '검사 결과나 수치 등을 기록해 주세요.',
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(Icons.assignment_outlined),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 6. 진료 사진
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade700),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(Icons.photo_camera_outlined),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '진료 사진',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                SizedBox(
                                  height: 80,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        existingImages.length +
                                        selectedImages.length +
                                        1,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(width: 8),
                                    itemBuilder: (context, index) {
                                      // 1. 기존 저장된 사진
                                      if (index < existingImages.length) {
                                        final image = existingImages[index];

                                        final allImagePaths = [
                                          ...existingImages.map(
                                            (image) => image.imagePath,
                                          ),
                                          ...selectedImages.map(
                                            (image) => image.path,
                                          ),
                                        ];

                                        return Stack(
                                          // Stack: 여러 위젯을 겹쳐서 배치할 때 사용하는 Flutter 위젯
                                          children: [
                                            GestureDetector(
                                              onTap: () => _showImagesPreview(
                                                imagePaths: allImagePaths,
                                                initialIndex: index,
                                              ),
                                              child: ClipRRect(
                                                // ClipRRect: 위젯의 모서리를 둥글게 잘라주는(clip) 위젯
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.file(
                                                  File(image.imagePath),
                                                  width: 80,
                                                  height: 80,
                                                  // fit: 이미지를 지정한 크기 안에 어떻게 맞춰서 보여줄지 결정하는 옵션
                                                  fit: BoxFit
                                                      .cover, // BoxFit.cover: 이미지를 주어진 영역에 꽉 채우는 방식. 사진이 잘릴 수 있음
                                                ),
                                              ),
                                            ),

                                            Positioned(
                                              // Positioned: 겹쳐놓은 위젯을 어디에 놓을지 정하는 것
                                              top: 4,
                                              right: 4,
                                              child: GestureDetector(
                                                onTap: () =>
                                                    _deleteExistingImage(image),
                                                child: Container(
                                                  width: 22,
                                                  height: 22,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withValues(
                                                          alpha: 0.55,
                                                        ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }

                                      // 2. 새로 선택한 사진
                                      final newImageIndex =
                                          index - existingImages.length;

                                      final allImagePaths = [
                                        ...existingImages.map(
                                          (image) => image.imagePath,
                                        ),
                                        ...selectedImages.map(
                                          (image) => image.path,
                                        ),
                                      ];

                                      if (newImageIndex <
                                          selectedImages.length) {
                                        final image =
                                            selectedImages[newImageIndex];

                                        return Stack(
                                          children: [
                                            GestureDetector(
                                              onTap: () => _showImagesPreview(
                                                imagePaths: allImagePaths,
                                                initialIndex:
                                                    existingImages.length +
                                                    newImageIndex,
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.file(
                                                  File(image.path),
                                                  width: 80,
                                                  height: 80,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),

                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: GestureDetector(
                                                onTap: () =>
                                                    _removeImage(newImageIndex),
                                                child: Container(
                                                  width: 22,
                                                  height: 22,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withValues(
                                                          alpha: 0.55,
                                                        ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }

                                      // 3. 맨 마지막: 사진 추가 버튼
                                      return InkWell(
                                        onTap: _pickImages,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          width: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_a_photo_outlined,
                                                color: Colors.grey,
                                                size: 24,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                '사진 추가',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 7. 방문 날짜 선택
                    /*
                    InkWell: 터치했을 때 물결처럼 퍼지는 클릭 효과를 만들어주는 위젯

                    onTap → 한 번 탭
                    onDoubleTap → 두 번 탭
                    onLongPress → 길게 누르기
                    onTapDown → 누르는 순간
                    onTapUp → 손가락을 뗀 순간
                    */
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          // lastDate: DateTimeUtils.todayKst(),
                          lastDate: DateTime(2100),
                        );

                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade700),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              // color: Colors.grey
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              '* 방문 날짜',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${selectedDate.year}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.day.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 8. 방문 시간 선택
                    InkWell(
                      onTap: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                        );

                        if (pickedTime != null) {
                          setState(() {
                            selectedTime = pickedTime;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade700),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_outlined),
                            const SizedBox(width: 16),
                            const Text(
                              '방문 시간',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              selectedTime == null
                                  ? '시간 선택'
                                  : selectedTime!.format(context),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: selectedTime == null
                                    ? Colors.grey
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 9. 진료비 입력창
                    TextField(
                      controller: costController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '진료비',
                        hintText: '0',
                        suffixText: '원',
                        prefixIcon: const Icon(Icons.payments_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 저장 버튼
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity, // 가로 너비를 가능한 한 최대로 늘리기
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("진료 제목을 입력해주세요.")),
                      );
                      return;
                    }

                    final today = DateTimeUtils.todayKst();

                    final defaultStatus = selectedDate.isAfter(today)
                        ? 'scheduled'
                        : 'completed';

                    final record = HealthRecord(
                      id: widget.record?.id,
                      petId: widget.petId,
                      date: selectedDate,
                      time: selectedTime,
                      hospital: hospitalController.text.trim().isEmpty
                          ? null
                          : hospitalController.text.trim(),
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim().isEmpty
                          ? null
                          : descriptionController.text.trim(),
                      examinationType:
                          examinationTypeController.text.trim().isEmpty
                          ? null
                          : examinationTypeController.text.trim(),
                      examinationResult:
                          examinationResultController.text.trim().isEmpty
                          ? null
                          : examinationResultController.text.trim(),
                      cost: int.tryParse(
                        costController.text.trim(),
                      ), // tryParse: 비어있으면 null
                      status: widget.record?.status ?? defaultStatus,
                    );

                    int? recordId;

                    try {
                      if (widget.record == null) {
                        // 신규 등록
                        recordId = await DatabaseHelper.instance
                            .insertHealthRecord(record);
                      } else {
                        // 기존 기록 수정
                        await DatabaseHelper.instance.updateHealthRecord(
                          record,
                        );

                        recordId = widget.record!.id;
                      }

                      // 선택한 사진 저장
                      if (recordId != null) {
                        await _saveImages(recordId);
                      }
                    } catch (e) {
                      debugPrint('병원 기록 저장 실패: $e');

                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('병원 기록을 저장하지 못했어요.')),
                      );

                      return;
                    }

                    if (!context.mounted) {
                      return;
                    }

                    Navigator.pop(context, selectedDate);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.pets, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        isEditing ? '수정하기' : '저장하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
