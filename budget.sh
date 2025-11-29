#!/bin/bash

DATA_DIR="data"

# 사용할 데이터 파일 정의
declare -A CATEGORY_FILE=(
    ["식비"]="$DATA_DIR/food.csv"
    ["교통비"]="$DATA_DIR/transport.csv"
    ["쇼핑"]="$DATA_DIR/shopping.csv"
    ["의료비"]="$DATA_DIR/medical.csv"
)

# 데이터 폴더 및 CSV 생성 (헤더 포함)
init_files() {
    mkdir -p "$DATA_DIR"

    for file in "${CATEGORY_FILE[@]}"; do
        if [ ! -f "$file" ]; then
            echo "date,category,description,amount" > "$file"
        fi
    done
}

# 날짜 형식 확인 (YYYY-MM-DD)
validate_date() {
    if [[ ! "$1" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "❌ 날짜 형식 오류 — 예: 2025-11-26"
        exit 1
    fi
}

# 금액 숫자 확인
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

    # 존재하는 카테고리인지 확인
    if [ -z "${CATEGORY_FILE[$CATEGORY]}" ]; then
        echo "❌ 존재하지 않는 카테고리입니다."
        echo "가능한 카테고리: 식비 | 교통비 | 쇼핑 | 의료비"
        exit 1
    fi

    TARGET_FILE=${CATEGORY_FILE[$CATEGORY]}

    # 데이터 추가
    echo "$DATE,$CATEGORY,$DESC,$AMOUNT" >> "$TARGET_FILE"

    echo "✅ [$CATEGORY] 지출이 기록되었습니다!"
}

### 실행 시작 ###
init_files

case "$1" in
    add)
        shift
        add_expense "$@"
        ;;
    *)
        echo "사용 가능한 명령: add"
        ;;
esac