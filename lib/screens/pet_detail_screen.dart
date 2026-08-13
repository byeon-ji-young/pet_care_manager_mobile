import 'dart:io';

import 'package:flutter/material.dart';

import '../models/pet.dart';
import '../models/health_record.dart';
import '../models/vaccination.dart';
import '../models/weight_record.dart';

import '../database/database_helper.dart';

import '../widgets/weight_chart.dart';

import 'pet_register_screen.dart';
import 'health_record_register_screen.dart';
import 'vaccination_register_screen.dart';
import 'weight_record_register_screen.dart';

class PetDetailScreen extends StatefulWidget {
  final Pet pet;

  const PetDetailScreen({
    super.key,
    required this.pet,
  });

  /*
    StatefulWidget 자체는 화면의 상태를 직접 저장하는 역할을 하지 않기 때문에 실제 상태를 관리할 state 객체를 만들어야 함.
    @override
    State<PetDetailScreen> createState() => _PetDetailScreenState();

    이게 PetDetailScreen의 상태를 관리할 _PetDetailScreenState를 만들어서 연결해달라는 뜻
    그리고 아래에 class _PetDetailScreenState extends State<PetDetailScreen> { ... } 이게 실제로 상태를 관리하는 부분이 됨
  */
  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  Pet? currentPet;

  List<HealthRecord> healthRecords = [];

  List<Vaccination> vaccinations = [];

  List<WeightRecord> weightRecords = [];

  @override
  void initState() {
    super.initState();

    currentPet = widget.pet;

    loadHealthRecords();

    loadVaccinations();

    loadWeightRecords();
  }

  Future<void> loadHealthRecords() async {
    final records = await DatabaseHelper.instance.getHealthRecordByPetId(widget.pet.id!);

    if(!mounted) {
      return;
    }

    setState(() {
      healthRecords = records;
    });
  }

  Future<void> loadVaccinations() async {
    final vaccines = await DatabaseHelper.instance.getVaccinationsByPetId(widget.pet.id!);

    if(!mounted) {
      return;
    }

    setState(() {
      vaccinations = vaccines;
    });
  }

  Future<void> loadWeightRecords() async {
    final records = await DatabaseHelper.instance.getWeightRecordsByPetId(widget.pet.id!);

    if(!mounted) {
      return;
    }

    setState(() {
      weightRecords = records;
    });
  }
  
  @override
  Widget build(BuildContext context) { // build()는 _PetDetailScreenState 안에 존재. State에서 부모 StatefulWidget의 값을 가져오려면 ~ 으로r 써야함. 즉 pet -> pet 작성해야 됨
    final pet = currentPet!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${pet.name} 정보'),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 반려동물 이름
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundImage: pet.imagePath != null
                        ? FileImage(File(pet.imagePath!))
                        : null,
                      child: pet.imagePath == null
                        ? const Icon(
                            Icons.pets,
                            size: 45,
                          )
                        : null,
                    ),

                    const SizedBox(height: 15),

                    Text(
                      pet.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 기본 정보
              _InfoRow(
                label: '생일', 
                value: pet.birthDate != null ? '${pet.birthDate!.year}년 ${pet.birthDate!.month}월 ${pet.birthDate!.day}일' : '미입력'
              ),
              _InfoRow(
                label: '성별',
                value: pet.gender ?? '미입력',
              ),
              /*
                ?. (Null-Aware Access): "값이 null이 아닐 때만 뒤의 함수(toIso8601String())를 실행하고, 만약 null이면 더 이상 진행하지 말고 그냥 null을 반환하라
                ?? (Null-Coalescing): "그 결과가 결국 null이면 대신 '미입력'을 출력하라
              */
              _InfoRow(
                label: '품종', 
                value: pet.breed ?? '미입력',
              ),
              _InfoRow(
                label: '몸무게', 
                value: pet.weight != null ? '${pet.weight} kg' : '미입력'
              ),

              const SizedBox(height: 30),

              // 병원 기록
              const Text(
                '🏥 병원 기록',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),

              const SizedBox(height: 10),

              if(healthRecords.isEmpty) // Flutter의 children: [] 안에서 {}를 사용하면 안됨. {}를 Dart가 Set으로 해석하기 때문에 에러남
                const Text(
                  '등록된 병원 기록이 없습니다.',
                  style: TextStyle(
                    color: Colors.grey
                  ),
                )
              else
                Column(
                  children: healthRecords.map((record) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(record.title),
                        subtitle: Text(
                          '${record.date.year}.${record.date.month.toString().padLeft(2, '0')}.${record.date.day.toString().padLeft(2, '0')}'
                          '${record.hospital != null ? '\n${record.hospital}' : ''}'
                        ),
                        // trailing: record.cost != null ? Text('${record.cost}원') : null, // trailing: ListTile의 오른쪽에 표시할 내용을 지정
                        trailing: Row( 
                          mainAxisSize: MainAxisSize.min, // Row나 Column이 주축(main axis) 방향으로 얼마나 공간을 차지할지 정하는 옵션. 즉, mainAxis 방향으로 필요한 만큼만 공간을 차지하겠다는 뜻
                          children: [
                            if (record.cost != null)
                              Text('${record.cost}원'),

                            // 수정버튼
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context, 
                                  MaterialPageRoute(
                                    builder: (context) => HealthRecordRegisterScreen(
                                      petId: pet.id!,
                                      record: record
                                    )
                                  )
                                );
                                
                                if(result == true) {
                                  await loadHealthRecords();
                                }
                              }, 
                            ),
                            
                            // 삭제버튼
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('병원 기록 삭제'),
                                      content: Text(
                                        '${record.title} 기록을 삭제하시겠습니까?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          },
                                          child: const Text('취소'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, true);
                                          },
                                          child: const Text('삭제'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirmed != true) {
                                  return;
                                }

                                await DatabaseHelper.instance.deleteHealthRecord(record.id!);

                                await loadHealthRecords();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push( // Navigator는 Flutter에서 화면 이동을 관리하는 역할. push는 새로운 화면을 위에 추가
                      context, // context는 Flutter의 현재 위젯이 어디에 위치하고 있는지 알려주는 정보
                      MaterialPageRoute( // MaterialPageRoute: 어떤 방식으로 새로운 화면을 띄울지 정의하는 것
                        builder: (context) => HealthRecordRegisterScreen( // builder는 실제로 이동할 화면을 만들어주는 부분
                          petId: pet.id!
                        )
                      )
                    );

                    if(result == true) {
                      await loadHealthRecords();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('병원 기록 추가')
                ),
              ),

              const SizedBox(height: 30),
              
              //예방접종
              const Text(
                '💉 예방접종',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),

              const SizedBox(height: 15),

              if(vaccinations.isEmpty) // Flutter의 children: [] 안에서 {}를 사용하면 안됨. {}를 Dart가 Set으로 해석하기 때문에 에러남
                const Text('등록된 예방접종 기록이 없습니다.')
              else
                Column(
                  children: vaccinations.map((vaccination) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(vaccination.vaccineName),
                        subtitle: Text(
                          '접종일: '
                          '${vaccination.vaccinationDate.year}.'
                          '${vaccination.vaccinationDate.month.toString().padLeft(2, '0')}.'
                          '${vaccination.vaccinationDate.day.toString().padLeft(2, '0')}'
                          '${vaccination.nextDate != null 
                              ? '\n다음 접종: ${vaccination.nextDate!.year}.${vaccination.nextDate!.month.toString().padLeft(2, '0')}.${vaccination.nextDate!.day.toString().padLeft(2, '0')}' : ''}'
                          '${vaccination.hospital != null ? '\n${vaccination.hospital}' : ''}'
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min, // Row나 Column이 주축(main axis) 방향으로 필요한 만큼만 공간 차지
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context, 
                                  MaterialPageRoute(
                                    builder: (context) => VaccinationRegisterScreen(
                                      petId: pet.id!,
                                      vaccination: vaccination,
                                    )
                                  )
                                );

                                if(result == true) {
                                  await loadVaccinations();
                                }
                              }
                            ),

                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context, 
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('예방접종 삭제'),
                                      content: Text(
                                        '${vaccination.vaccineName} 기록을 삭제하시겠습니까?'
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          }, 
                                          child: const Text('취소')
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, true);
                                          }, 
                                          child: const Text('삭제')
                                        )
                                      ],
                                    );
                                  },
                                );

                                if(confirmed != true) {
                                  return;
                                }

                                await DatabaseHelper.instance.deleteVaccination(vaccination.id!);

                                if(!mounted) {
                                  return;
                                }
                                
                                await loadVaccinations();
                              }
                            )
                          ],
                        )
                      ),
                    );
                  }).toList(),
                ),
              
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => VaccinationRegisterScreen(
                          petId: pet.id!
                        )
                      )
                    );

                    if(result == true) {
                      await loadVaccinations();
                    }
                  }, 
                  icon: const Icon(Icons.add),
                  label: const Text('예방접종 추가')
                ),
              ),
              
              // 체중 기록
              const SizedBox(height: 30),

              const Text(
                '⚖️ 체중 기록',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),

              const SizedBox(height: 15),

              /*
              위젯 하나 넣기
              children: [
                Text('A'),
              ]

              위젯 여러 개 넣기
              children: [
                Text('A'),
                Text('B'),
                Text('C'),
              ]

              조건이 맞을 때 위젯 여러 개 넣기
              children: [
                if (조건) ...[
                  Text('A'),
                  Text('B'),
                  Text('C'),
                ],
              ]
              */
              if(weightRecords.length >= 2) ...[ // ...은 Spread Operator(스프레드 연산자). 즉, 이 리스트 안에 들어있는 위젯들을 하나씩 꺼내서 children에 넣어달라는 말
                const Text(
                  '📈 체중 변화',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                WeightChart(
                  records: weightRecords,
                ),

                const SizedBox(height: 20),
              ],

              if(weightRecords.isEmpty)
                const Text('등록된 체중 기록이 없습니다.')
              else
                Column(
                  children: weightRecords.map((record) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(
                          '${record.weight} kg',
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        subtitle: Text(
                          '${record.date.year}.'
                          '${record.date.month.toString().padLeft(2, '0')}.'
                          '${record.date.day.toString().padLeft(2, '0')}'
                          '${record.memo != null ? '\n${record.memo}' : ''}'
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context, 
                                  MaterialPageRoute(
                                    builder: (context) => WeightRecordRegisterScreen(
                                      petId: pet.id!,
                                      record: record,
                                    )
                                  )
                                );

                                if(result == true) {
                                  loadWeightRecords();
                                }
                              }
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('체중 기록 삭제'),
                                      content: Text(
                                        '${record.weight} kg 기록을 삭제하시겠습니까?'
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context, false);
                                          }, 
                                          child: const Text('취소')
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context, true);
                                          }, 
                                          child: const Text('삭제')
                                        )
                                      ],
                                    );
                                  }
                                );

                                if(confirmed != true) {
                                  return;
                                }

                                await DatabaseHelper.instance.deleteWeightRecord(record.id!);

                                if(!mounted) {
                                  return;
                                }

                                await loadWeightRecords();
                              }
                            ),
                          ],
                        )
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => WeightRecordRegisterScreen(
                          petId: pet.id!
                        )
                      )
                    );

                    if(result == true) {
                      await loadWeightRecords();
                    }
                  }, 
                  icon: const Icon(Icons.add),
                  label: const Text('체중 기록 추가'),
                ),
              ),

              const SizedBox(height: 20),

              // 반려동물 수정하기 버튼
              SizedBox(
                width: double.infinity, // 가로 너비를 부모 위젯이 허용하는 최대 너비로 꽉 채우겠다
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => PetRegisterScreen(
                          pet: pet,
                        ),
                      ),
                    );

                    // Navigator.pop(context, true) 이걸로 true를 넘겼기 때문에, 정상적으로 수정이 됐으면 진행됨
                    if (result == true) {
                      final updatedPet = await DatabaseHelper.instance.getPetById(pet.id!); // pet.id!의 !은 DB에서 생성된 반려동물 ID는 반드시 존재한다는 의미

                      if(!context.mounted) {
                        return;
                      }

                      if(updatedPet != null) {
                        setState(() {
                          currentPet = updatedPet;
                        });
                      }

                      Navigator.pop(context, true);
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text(
                    '수정하기',
                    style: TextStyle(
                      fontSize: 16
                    ),
                  )
                ),
              ),

              const SizedBox(height: 12),

              // 반려동물 삭제 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon( // OutlinedButton
                  onPressed: () async {
                    // 삭제 확인창
                    final bool? confirmed = await showDialog<bool>( // bool?을 사용한 이유는 null도 반환될 수 있기 때문
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('반려동물 삭제'),
                          content: Text(
                            '${pet.name}을(를) 정말 삭제하시겠습니까?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, false);
                              },
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                              child: const Text('삭제'),
                            ),
                          ],
                        );
                      },
                    );

                    // 취소했거나 아무것도 선택하지 않은 경우
                    if (confirmed != true) {
                      return;
                    }

                    // SQLite에서 삭제
                    await DatabaseHelper.instance.deletePet(pet.id!);

                    if (!context.mounted) {
                      return;
                    }

                    // 상세 화면 닫고 홈 화면으로 이동
                    Navigator.pop(context, true);
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text(
                    '삭제하기',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}

// 상세 정보 한 줄을 만드는 위젯
class _InfoRow extends StatelessWidget { // StatelessWidget: 화면에 그려질 수 있는 위젯의 자격을 부여하기 위해 상속받음
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10), // symmetric(vertical: 10): 위쪽과 아래쪽에 각각 10px 여백

      child: Row( // Row (가로 배치). 안에 들어가는 SizedBox, Expanded를 가로방향으로 일렬 배치함
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded( // Expanded: 가로 공간 중에서 남은 나머지 가로 공간 전체를 꽉 채우도록 확장시켜줌. 만약에 값이 길 경우 자동으로 줄바꿈되도록 하기 위해 extended로 감싸줌
            child: Text(value),
          ),
        ],
      ),
    );
  }
}