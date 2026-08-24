import 'dart:io';

import 'package:flutter/material.dart';

import '../models/pet.dart';

import '../utils/date_time_utils.dart';

class PetProfileHeader extends StatelessWidget {
  final Pet pet;

  const PetProfileHeader({super.key, required this.pet});

  // 생년월일로 나이 변환
  String _getAgeText(DateTime birthDate) {
    final now = DateTimeUtils.nowKst();

    int ageYear = now.year - birthDate.year;
    int ageMonth = now.month - birthDate.month;

    // 일(day) 수 비교하여 개월 수 보정
    if (now.day < birthDate.day) {
      ageMonth--;
    }

    // 개월 수가 음수일 경우 연도에서 차감
    if (ageMonth < 0) {
      ageYear--;
      ageMonth += 12;
    }

    // 1살 미만인 경우 'x개월' 표시
    if (ageYear == 0) {
      return '$ageMonth개월';
    }
    // 개월이 0인 경우 'x살' 표시
    else if (ageMonth == 0) {
      return '$ageYear살';
    }
    // 1살 이상 & 개월이 있는 경우 'x살 y개월' 표시
    else {
      return '$ageYear살 $ageMonth개월';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 성별/품종/몸무게 텍스트 조합
    final List<String> details = [];

    if (pet.breed != null && pet.breed!.isNotEmpty) {
      details.add(pet.breed!);
    }

    if (pet.gender != null && pet.gender!.isNotEmpty) {
      details.add(pet.gender!);
    }

    if (pet.weight != null) {
      details.add('${pet.weight}kg');
    }

    return Column(
      children: [
        // 1. 원형 사진
        CircleAvatar(
          radius: 52,
          // backgroundColor: Colors.grey[200],
          backgroundImage: pet.imagePath != null
              ? FileImage(File(pet.imagePath!))
              : null,
          child: pet.imagePath == null ? Icon(Icons.pets, size: 48) : null,
        ),

        const SizedBox(height: 16),

        // 2. 이름
        Text(
          pet.name,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 6),

        // 3. 주요 정보
        if (details.isNotEmpty)
          Text(
            details.join('  •  '), // join: 리스트의 문자열들을 하나의 문자열로 합치는 것
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),

        // 4. 생일 정보
        if (pet.birthDate != null) ...[
          const SizedBox(height: 6),

          Text(
            '${_getAgeText(pet.birthDate!)} (${pet.birthDate!.year}.${pet.birthDate!.month.toString().padLeft(2, '0')}.${pet.birthDate!.day.toString().padLeft(2, '0')})',
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ],

        const SizedBox(height: 20),

        // 병원 기록/예방접종 네모 섹션들과 경계를 지어주는 얇은 경계선
        Divider(height: 1, thickness: 1, color: Colors.grey[200]),
      ],
    );
  }
}
