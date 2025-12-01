#!/bin/bash
# ======================
# 4번 기능: 월별 소비 분석
# ======================
monthly_report() {
    if [ $# -ne 1 ]; then
        echo "사용법: $0 month <YYYY-MM>"
        exit 1
    fi

    MONTH=$1
    TOTAL=0
    declare -A CATEGORY_SUM

    echo "📌 $MONTH 월별 소비 요약"

    # 각 카테고리별 합계 계산
    for CAT in "${!CATEGORY_FILE[@]}"; do
        FILE=${CATEGORY_FILE[$CAT]}
        SUM=$(awk -F, -v month="$MONTH" 'NR>1 && $1 ~ month {total+=$4} END {print total+0}' "$FILE")
        CATEGORY_SUM[$CAT]=$SUM
        TOTAL=$((TOTAL + SUM))
    done

    # 전체 합계 출력
    echo "총 지출: $TOTAL 원"

    # 카테고리별 소비 출력 (내림차순)
    echo "카테고리별 소비:"
    for CAT in "${!CATEGORY_SUM[@]}"; do
        echo "- $CAT: ${CATEGORY_SUM[$CAT]} 원"
    done | sort -t: -k2 -nr

    # 상위 5건 출력
    echo "상위 5건 지출:"
    ALL_RECORDS=$(mktemp)
    for FILE in "${CATEGORY_FILE[@]}"; do
        awk -F, -v month="$MONTH" 'NR>1 && $1 ~ month {print $0}' "$FILE" >> "$ALL_RECORDS"
    done

    if [ -s "$ALL_RECORDS" ]; then
        sort -t, -k4 -nr "$ALL_RECORDS" | head -5 | column -t -s ,
    else
        echo "해당 월에 기록이 없습니다."
    fi

    rm "$ALL_RECORDS"
}

