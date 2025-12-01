total_query() {
    echo "--- 전체 지출 조회 ---"

    read -p "시작 날짜 (YYYY-MM-DD, 전체 조회 시 Enter): " START_DATE
    read -p "종료 날짜 (YYYY-MM-DD, 전체 조회 시 Enter): " END_DATE

    # 🚨 수정: ${CATEGORY_FILE[@]} 배열을 사용하여 모든 파일을 AWK에 전달
    ALL_FILES=("${CATEGORY_FILE[@]}") # run.sh에서 로드된 배열 사용

    TOTAL=$(awk -F, -v start="$START_DATE" -v end="$END_DATE" '
        BEGIN {sum = 0}
        # 파일명 끝이 .csv인지 확인 (헤더를 제외하기 위해 NR>1 조건이 필요할 수 있음)
        FILENAME ~ /\.csv$/ {
            DATE=$1; AMOUNT=$4 # 금액이 4열일 수 있으므로 $4로 수정 (기획서 기준)
            
            # ... (날짜 필터링 로직)
            
            if ((start == "" || DATE >= start) && (end == "" || DATE <= end)) {
                 if (AMOUNT ~ /^[0-9]+$/) {
                     # NR>1 조건이 AWK에 없으므로, 헤더가 합산될 수 있음.
                     # 헤더를 건너뛰는 조건 ($1 != "date")이 필요할 수 있습니다.
                     sum += AMOUNT
                 }
            }
        }
        END {
            printf "%.0f", sum
        }
    ' "${ALL_FILES[@]}") # 수정된 배열 사용

    # 결과 출력
    echo "💰 선택 기간 총 지출: ${TOTAL}원"
}