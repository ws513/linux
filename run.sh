#!/bin/bash

# ==============================================================
# 1. 공통 변수 정의 (모든 source 명령보다 위에 위치해야 함)
# ==============================================================
DATA_DIR="data"

declare -A CATEGORY_FILE=( 
    ["식비"]="$DATA_DIR/food.csv"
    ["교통비"]="$DATA_DIR/transport.csv"
    ["쇼핑"]="$DATA_DIR/shopping.csv"
    ["의료비"]="$DATA_DIR/medical.csv"
)

# 데이터 폴더 및 CSV 생성 (init_files 함수 정의는 여기에 남깁니다)
init_files() {
    mkdir -p "$DATA_DIR"
    for file in "${CATEGORY_FILE[@]}"; do
        if [ ! -f "$file" ]; then
            echo "date,category,description,amount" > "$file"
        fi
    done
}
# ==============================================================

# ==============================================================
# 2. 모든 기능 파일 로드 (함수 정의만 포함되어야 함)
# ==============================================================
source ./budget.sh
source ./monthly_report.sh
source ./total_query.sh
source ./category_analysis.sh

# 3. 초기화 함수 호출 (모든 정의가 끝난 후 호출)
init_files

# --- 4. 메인 메뉴 및 case 문 구현 ---

while true; do
    echo "========================================="
    echo "         🛒 가계부 소비 분석 툴 📊"
    echo "========================================="
    echo "  1. ➕ 지출 내역 추가 (ADD)"
    echo "  2. 🔍 전체 지출 조회 (TOTAL)"
    echo "  3. 📈 카테고리별 분석 (ANALYZE)"
    echo "  4. 🧾 월별 소비 보고서 (MONTH)"
    echo "  Q. 🚪 프로그램 종료"
    echo "-----------------------------------------"

    read -p "▶️ 메뉴 선택 (1-4/Q) > " CHOICE
    
    case "$CHOICE" in
    
        1)
            echo "--- ➕ 지출 내역 추가 ---"
            AVAILABLE_CATS=$(IFS=' | '; echo "${!CATEGORY_FILE[*]}")
            echo "✅ 카테고리: $AVAILABLE_CATS" 
            echo "--------------------------------------------------------"

            read -p "📅 날짜 카테고리 내용 금액 (띄어쓰기 구분): " DATE CATEGORY DESC AMOUNT
            add_expense "$DATE" "$CATEGORY" "$DESC" "$AMOUNT"
            ;;
        1)
            echo "--- 1. 지출 내역 추가 ---"
            read -p "날짜(YYYY-MM-DD) 카테고리 내용 금액 (띄어쓰기로 구분): " DATE CATEGORY DESC AMOUNT
            # add_expense 함수가 호출됩니다.
            add_expense "$DATE" "$CATEGORY" "$DESC" "$AMOUNT" 
            ;;
        2)
            # total_query 함수 호출
            total_query
            ;;
        3)
            echo "--- 3. 카테고리별 분석 ---"
            # category_analysis 함수 호출
            category_analysis
            ;;
        4)
            echo "--- 4. 월별 소비 보고서 ---"
            read -p "분석할 월 (YYYY-MM): " MONTH
            monthly_report "$MONTH"
            ;;
        [qQ])
            echo "프로그램을 종료합니다. 감사합니다."
            exit 0
            ;;
        *)
            echo "❌ 잘못된 선택입니다. 1~4 또는 Q를 입력하세요."
            ;;
    esac
    echo ""
done