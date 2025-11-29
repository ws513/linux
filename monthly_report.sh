#!/bin/bash

DATA_DIR="data"

declare -A CATEGORY_FILE=(
    ["식비"]="$DATA_DIR/food.csv"
    ["교통비"]="$DATA_DIR/transport.csv"
    ["쇼핑"]="$DATA_DIR/shopping.csv"
    ["의료비"]="$DATA_DIR/medical.csv"
)

init_files() {
    mkdir -p "$DATA_DIR"
    for file in "${CATEGORY_FILE[@]}"; do
        if [ ! -f "$file" ]; then
            echo "date,category,description,amount" > "$file"
        fi
    done
}

validate_date() {
    if [[ ! "$1" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "❌ 날짜 형식 오류 — 예: 2025-11-26"
        exit 1
    fi
}

validate_amount() {
    if [[ ! "$1" =~ ^[0-9]+$ ]]; then
        echo "❌ 금액은 숫자만 입력하세요."
        exit 1
    fi
}

add_expense() {
    if [ $# -ne 4 ]; then
        echo "사용법: $0 add <날짜> <카테고리> <내용> <금액>"
        echo "카테고리: 식비 | 교통비 | 쇼핑 | 의료비"
        exit 1
    fi

    DATE=$1
    CATEGORY=$2
    DESC=$3
    AMOUNT=$4

    validate_date "$DATE"
    validate_amount "$AMOUNT"

    if [ -z "${CATEGORY_FILE[$CATEGORY]}" ]; then
        echo "❌ 존재하지 않는 카테고리입니다."
        echo "가능한 카테고리: 식비 | 교통비 | 쇼핑 | 의료비"
        exit 1
    fi

    TARGET_FILE=${CATEGORY_FILE[$CATEGORY]}
    echo "$DATE,$CATEGORY,$DESC,$AMOUNT" >> "$TARGET_FILE"
    echo "✅ [$CATEGORY] 지출이 기록되었습니다!"
}

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

# ======================
# 메인
# ======================
init_files

case "$1" in
    add)
        shift
        add_expense "$@"
        ;;
    month)
        shift
        monthly_report "$@"
        ;;
    *)
        echo "사용 가능한 명령: add | month"
        ;;
esac