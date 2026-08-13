import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/weight_record.dart';

class WeightChart extends StatelessWidget {
  final List<WeightRecord> records;

  const WeightChart({
    super.key,
    required this.records
  });

  @override
  Widget build(BuildContext context) {
    if(records.length < 2) {
      return const Center(
        child: Text(
          '체중 기록이 2개 이상 있어야\n변화 그래프를 볼 수 있습니다.',
          textAlign: TextAlign.center,
        ),
      );
    }

    /*
    [...records]: 새로운 리스트로 복사
    ..sort(...): cascade notation(캐스케이드 연산자)
    [...records]..sort(...) =>  final temp = [...records];
                                temp.sort(...);
                                final sortedRecords = temp;
    (a, b) => a.date.compareTo(b.date): 오래된 날짜 → 최신 날짜 순으로 정렬 (우리가 getWeightRecordsByPetId할 때 date DESC로 했기 때문에)
    (a, b) => b.date.compareTo(a.date): 최신 날짜 → 오래된 날짜 순으로 정렬
    */
    // 그래프는 오래된 날짜 → 최근 날짜 순서
    final sortedRecords = [...records] ..sort((a, b) => a.date.compareTo(b.date));
    
    /*
    sortedRecords.asMap(): index 번호를 붙여서 Map처럼 사용할 수 있게 함
    .asMap().entries: 각각의 key, value를 가져올 수 있게 함 (key: index, value: WeightRecord객체)
    
    FlSpot: fl_chart에서 그래프의 한 점을 나타내는 객체
    FlSpot(x값, y값). 즉, X축에는 순서(index)를 넣고, Y축에는 몸무게(weight)를 넣어라

    .toList(): map()의 결과는 Iterable이기 때문에 마지막에 .toList() 붙여서 List<FlSpot> 만듦
    */
    // 그래프에 표시할 데이터
    final spots = sortedRecords.asMap().entries.map((entry) {
      final index = entry.key;
      final record = entry.value;

      return FlSpot(index.toDouble(), record.weight);
    }).toList();

    // 체중 최솟값 / 최댓값
    final weights = sortedRecords.map((record) => record.weight).toList();

    final minWeight = weights.reduce((a, b) => a < b ? a : b); // reduce()는 리스트의 데이터를 두 개씩 비교하면서 하나의 값으로 합치는 함수
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);

    // 그래프 위아래 여백
    final chartMinY = (minWeight - 0.5).clamp(0, double.infinity).toDouble(); // clamp(최소값, 최대값). 즉, 값을 0 이상 ~ 무한대 이하로 제한. 최소값이 0보다 작아지지 않도록 함
    final chartMaxY = maxWeight + 0.5;

    return SizedBox(
      height: 280,
      child: LineChart(
        LineChartData(
          minY: chartMinY,
          maxY: chartMaxY,

          // 그래프 바깥쪽 여백
          borderData: FlBorderData(
            show: false
          ),

          // 배경 격자
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 0.5
          ),

          // x축, y축
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false
              )
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false
              )
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45, // reservedSize: 확보할 공간의 크기
                getTitlesWidget: (value, meta) { // getTitlesWidget: Y축의 숫자를 어떻게 표시할지 직접 정하는 함수
                  return Text(
                    '${value.toStringAsFixed(1)}kg', // toStringAsFixed(1): 소수점 한 자리까지 표시
                    style: const TextStyle(
                      fontSize: 11
                    ),
                  );
                }
              )
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35, // reservedSize: 확보할 공간의 크기
                interval: 1, // X축을 1칸 간격으로만 표시
                getTitlesWidget: (value, meta) { // getTitlesWidget: X축의 각 위치에 무엇을 표시할지 직접 결정하는 함수
                  final index = value.toInt(); // toInt(): index로 변환

                  // 정수가 아니면 표시하지 않기
                  if(value != index.toDouble()) { // toDouble(): X축 위치 번호 0, 1, 2를 0.0, 1.0, 2.0이라는 double 타입으로 바꾸는 것
                    return const SizedBox();
                  }
                  
                  if(index < 0 || index >= sortedRecords.length) {
                    return const SizedBox();
                  }

                  final date = sortedRecords[index].date;

                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      '${date.month}/${date.day}',
                      style: const TextStyle(
                        fontSize: 11
                      ),
                    ),
                  );
                }
              )
            )
          ),

          // 실제 선 그래프
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              dotData: const FlDotData(
                show: true
              ),
              // 그래프 아래 영역
              belowBarData: BarAreaData(
                show: false,
              ),
            ),
          ],

          // 점을 눌렀을 때
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();

                  if(index < 0 || index >= sortedRecords.length) {
                    return null;
                  }

                  final record = sortedRecords[index];

                  return LineTooltipItem(
                    '${record.date.month}/${record.date.day}\n'
                    '${record.weight.toStringAsFixed(1)} kg',
                    const TextStyle(
                      fontWeight: FontWeight.bold
                    )
                  );
                }).toList();
              }
            )
          )
        )
      ),
    );
  }
}