#!/bin/bash
# category_analysis.sh

echo "--- 📊 지출 내역 분석 보고서 (카테고리별 합계 및 비율) ---"
echo ""

# AWK 스크립트:
# 1. 모든 지출의 총합 (TOTAL) 계산
# 2. 카테고리별 합계 (sum[CATEGORY]) 계산
# 3. END 블록에서 비율을 계산하여 출력
awk -F, '
    # --- 1. 데이터 처리 (PASS 1: 집계) ---
    # 파일명이 *_data.csv로 끝나는 파일만 처리
    FILENAME ~ /_data\.csv$/ {
        CATEGORY=$2; AMOUNT=$3
        
        # 금액이 유효한 숫자인지 확인
        if (AMOUNT ~ /^[0-9]+$/) {
            # 카테고리별 합계
            sum[CATEGORY] += AMOUNT
            # 전체 합계
            TOTAL += AMOUNT
        }
    }

    # --- 2. 결과 출력 (PASS 2: 분석 및 포맷팅) ---
    END {
        if (TOTAL == 0) {
            print "지출 내역이 없습니다."
            exit
        }

        printf "## 전체 지출 총액: %d원\n\n", TOTAL
        print "## 카테고리별 지출 현황"
        print "-------------------------------------------"
        printf "%-15s | %-10s | %s\n", "카테고리", "지출액(원)", "비율(%)"
        print "-------------------------------------------"
        
        # 카테고리별로 순회하며 비율 계산 및 출력
        for (category in sum) {
            # 비율 계산: (카테고리 합계 / 전체 합계) * 100
            PERCENT = (sum[category] / TOTAL) * 100
            
            # 포맷에 맞춰 출력
            printf "%-15s | %10d | %.2f%%\n", category, sum[category], PERCENT
        }
        print "-------------------------------------------"
    }
' *_data.csv
