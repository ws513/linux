#!/bin/bash
# category_analysis.sh

# 이 스크립트는 run.sh에 의해 source되므로,
# CATEGORY_FILE 배열은 이미 메모리에 로드되어 있습니다.

category_analysis() {
    echo "--- 📊 지출 내역 분석 보고서 (카테고리별 합계 및 비율) ---"
    echo ""

    # 모든 데이터 파일을 담을 임시 배열 또는 변수 설정
    ALL_FILES=()

    # CATEGORY_FILE 배열을 순회하며 존재하는 모든 파일 경로를 수집
    for FILE in "${CATEGORY_FILE[@]}"; do
        if [ -f "$FILE" ]; then
            ALL_FILES+=("$FILE")
        fi
    done

    # 수집된 파일이 없으면 종료
    if [ ${#ALL_FILES[@]} -eq 0 ]; then
        echo "❌ 분석할 데이터 파일이 존재하지 않습니다. 지출 내역을 먼저 추가하세요."
        return
    fi
    
    # 🚨 AWK 스크립트 실행 (수집된 파일 목록을 AWK에 전달)
    awk -F, '
        BEGIN {sum_total = 0} # TOTAL 대신 sum_total 사용
        
        # NR > 1 : 헤더 건너뛰기
        NR > 1 {
            CATEGORY=$2; AMOUNT=$4 # 금액이 4열일 경우
            
            if (AMOUNT ~ /^[0-9]+$/) {
                sum[CATEGORY] += AMOUNT
                sum_total += AMOUNT
            }
        }

        END {
            if (sum_total == 0) { exit }

            printf "## 전체 지출 총액: %d원\n\n", sum_total
            print "## 카테고리별 지출 현황"
            # ... (나머지 출력 포맷 로직)
            
            for (category in sum) {
                PERCENT = (sum[category] / sum_total) * 100
                printf "%-15s | %10d | %.2f%%\n", category, sum[category], PERCENT
            }
        }
    ' "${ALL_FILES[@]}" | column -t -s '|'
    # column -t는 AWK 출력 후 표를 깔끔하게 정리하는 데 사용
}