import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HospitalVisitChart extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyVisitCounts;

  const HospitalVisitChart({super.key, required this.monthlyVisitCounts});

  @override
  Widget build(BuildContext context) {
    if (monthlyVisitCounts.isEmpty) {
      return Container(
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '병원 방문 기록이 없습니다.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    final spots = monthlyVisitCounts
        .asMap() // asMap()은 리스트의 각 데이터에 인덱스 번호를 붙여서 Map처럼 사용할 수 있게 함
        .entries // Map의 key와 value를 한 쌍으로 꺼내기 위해 entries 사용
        .map((entry) {
          // entry.key가 index
          final index = entry.key;
          // entry.value가 {'month': '1월', 'count': 3}
          final count = entry.value['count'] as int;

          return FlSpot(
            index.toDouble(),
            count.toDouble(),
          ); // FlSpot은 그래프에서 하나의 점을 나타내는 객체 (FlSpot은 좌표를 double로 받음)
        })
        .toList();

    final counts = monthlyVisitCounts
        .map((item) => item['count'] as int)
        .toList();

    final maxCount = counts
        .reduce // reduce()는 리스트의 여러 값을 하나의 값으로 합치는 함수
        ((a, b) => a > b ? a : b); // counts 리스트에서 가장 큰 숫자를 찾아서 maxCount에 저장

    // 방문 기록이 모두 0인 경우에도 그래프가 보이도록 최소값을 1로 설정
    final chartMaxY = maxCount == 0 ? 1.0 : (maxCount + 1).toDouble();

    return SizedBox(
      height: 230,
      child: Padding(
        padding: const EdgeInsets.only(right: 20, top: 10, bottom: 10),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (monthlyVisitCounts.length - 1).toDouble(),
            minY: -0.5,
            maxY: chartMaxY,

            // 테두리 선 제거
            borderData: FlBorderData(show: false),

            // 배경 격자
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
            ),

            // 축 라벨
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),

              // Y축 - 방문 횟수
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 35, // reservedSize: 확보할 공간의 크기
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    // getTitlesWidget: Y축의 숫자를 어떻게 표시할지 직접 정하는 함수
                    if (value < 0 || value > maxCount) {
                      // 경계선에 걸친 숫자는 화면에 그리지 않고 빈 공간 처리
                      return const SizedBox();
                    }

                    return Text(
                      '${value.toInt()}건',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ),

              // X축 - 월
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 35, // reservedSize: 확보할 공간의 크기
                  interval: 1, // X축을 1칸 간격으로만 표시
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();

                    // 정수가 아니면 표시하지 않기
                    if (value != index.toDouble()) {
                      return const SizedBox();
                    }

                    if (index < 0 || index >= monthlyVisitCounts.length) {
                      return const SizedBox();
                    }

                    final month =
                        monthlyVisitCounts[index]['month'] as DateTime;

                    return SideTitleWidget(
                      meta: meta,
                      child: Text(
                        '${month.month}월',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 실제 선 그래프
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                barWidth: 3,
                color: Theme.of(context).primaryColor,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 3,
                      color: Colors.white,
                      strokeWidth: 3,
                      strokeColor: Theme.of(context).primaryColor,
                    );
                  },
                ),
                belowBarData: BarAreaData(show: false),
              ),
            ],

            // 점을 눌렀을 때
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) =>
                    Theme.of(context).primaryColor,
                tooltipPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final rawIndex = spot.x.round();

                    final index = rawIndex.clamp(
                      0,
                      monthlyVisitCounts.length - 1,
                    ); // clamp(min, max) : 값이 특정 범위를 벗어나지 않도록 제한하는 함수 ex 10.clamp(0, 5) => 5 반환

                    final item = monthlyVisitCounts[index];

                    final month = item['month'] as DateTime;
                    final count = item['count'] as int;

                    return LineTooltipItem(
                      '${month.month}월\n',
                      const TextStyle(color: Colors.white70, fontSize: 11),
                      children: [
                        TextSpan(
                          text: '$count건',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
