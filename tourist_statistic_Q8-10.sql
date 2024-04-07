-- 8. 2017년, 경기도에 속한 도시의 관광지 중 내국인 방문객 수가 가장 많은 관광지와 방문객 수를 조회
SELECT p.prvn_name, d.distc_name, a.attrc_name, sum(f.native_cnt) AS figure
  FROM province p 
  INNER JOIN district d ON d.prvn_cd = p.prvn_cd 
  INNER JOIN attraction a ON a.prvn_cd = p.prvn_cd AND a.distc_cd = d.distc_cd 
  LEFT JOIN figure f ON f.prvn_cd = p.prvn_cd AND f.distc_cd = d.distc_cd AND f.attrc_cd = a.attrc_cd
WHERE p.prvn_name = '경기도'
AND substr(f.basis_date, 1, 4) = '2017'
GROUP BY f.distc_cd, f.attrc_cd 
ORDER BY figure DESC
LIMIT 1
;

SELECT a.prvn_name, a.distc_name, a.attrc_name, max(a.rslt) AS figure
 FROM 
 (
 SELECT p.prvn_name, d.distc_name, a.attrc_name, sum(f.native_cnt) AS rslt
  FROM province p 
  INNER JOIN district d ON d.prvn_cd = p.prvn_cd 
  INNER JOIN attraction a ON a.prvn_cd = p.prvn_cd AND a.distc_cd = d.distc_cd 
  LEFT JOIN figure f ON f.prvn_cd = p.prvn_cd AND f.distc_cd = d.distc_cd AND f.attrc_cd = a.attrc_cd
WHERE p.prvn_name = '경기도'
AND substr(f.basis_date, 1, 4) = '2017'
GROUP BY f.distc_cd, f.attrc_cd
ORDER BY rslt desc
) a
;

-- 9. 경기도 김포시의 관광지 중 각 년도 별 평균 내국인 방문객 수가 높은 1 ~ 3위를 조회하라.
-- 예비단계 : 우선 '경기도 김포시의 관광지 중 각 년도 별 평균 내국인 방문객 수'만 구해본다. 이후, > 정렬한다. > 순위 붙인다.
-- 이 쿼리로는 1~3위를 잘라낼 수 없음. 아래처럼 서브쿼리와 윈도우 함수 row_number() 이용해서 3개만 출력되도록 함.
SELECT  p.prvn_name, d.distc_name, a.attrc_name, SUBSTR(f.basis_date, 1, 4) AS `year`, round(avg(f.native_cnt)) AS figure 
  FROM province p 
  INNER JOIN district d ON d.prvn_cd = p.prvn_cd 
  INNER JOIN attraction a ON a.prvn_cd = p.prvn_cd AND a.distc_cd = d.distc_cd 
  LEFT JOIN figure f ON f.prvn_cd = p.prvn_cd AND f.distc_cd = d.distc_cd AND f.attrc_cd = a.attrc_cd 
WHERE p.prvn_name = '경기도' AND d.distc_name = '김포시'
GROUP BY f.attrc_cd, substr(f.basis_date, 1, 4)
ORDER BY `year`, figure DESC
;

SELECT @ROWNUM:=0, @name:='' FROM DUAL; -- @변수 선언. := 변수에 대입연산자
-- var rownum = 0;이 mysql에선 @rownum := 0

-- 년도 오름차순, 방문객 내림차순 > 순위 구하기 : 변수가 필요함
-- 변수가 2개 필요함. 순위를 저장할 변수, 비교 값 저장할 변수

-- 9번 답
SELECT b.prvn_name, b.distc_name, b.attrc_name, b.YEAR, b.figure
FROM (
		SELECT (CASE @name WHEN year THEN @rownum:=@rownum+1 ELSE @rownum:=1 end) rnum,
				(@name := year) AS year,
				a.prvn_name, a.distc_name, a.attrc_name, a.figure
		  FROM (
		  	SELECT  p.prvn_name, d.distc_name, a.attrc_name, SUBSTR(f.basis_date, 1, 4) AS `year`, round(avg(f.native_cnt)) AS figure 
			  FROM province p 
			  INNER JOIN district d ON d.prvn_cd = p.prvn_cd 
			  INNER JOIN attraction a ON a.prvn_cd = p.prvn_cd AND a.distc_cd = d.distc_cd 
			  LEFT JOIN figure f ON f.prvn_cd = p.prvn_cd AND f.distc_cd = d.distc_cd AND f.attrc_cd = a.attrc_cd 
			WHERE p.prvn_name = '경기도' AND d.distc_name = '김포시'
			GROUP BY f.attrc_cd, substr(f.basis_date, 1, 4)
			ORDER BY `year`, figure DESC
		  ) a,
		(SELECT @rownum:=0, @name:='' FROM DUAL) t
  ) b
  WHERE b.rnum <= 3
;

-- 9번 별해
SELECT prvn_name, distc_name, attrc_name, year, figure
FROM (
    SELECT p.prvn_name, d.distc_name, a.attrc_name, SUBSTR(f.basis_date, 1, 4) AS `year`, ROUND(AVG(f.native_cnt)) AS figure,
           ROW_NUMBER() OVER(PARTITION BY SUBSTR(f.basis_date, 1, 4) ORDER BY AVG(f.native_cnt) DESC) AS row_num
    FROM province p
    INNER JOIN district d ON d.prvn_cd = p.prvn_cd
    INNER JOIN attraction a ON a.prvn_cd = p.prvn_cd AND a.distc_cd = d.distc_cd
    LEFT JOIN figure f ON f.prvn_cd = p.prvn_cd AND f.distc_cd = d.distc_cd AND f.attrc_cd = a.attrc_cd
    WHERE p.prvn_name = '경기도' AND d.distc_name = '김포시'
    GROUP BY f.attrc_cd, SUBSTR(f.basis_date, 1, 4)
) AS subquery
WHERE row_num <= 3
ORDER BY YEAR, figure desc;

-- 10. 경기도 과천시 관광지의 각 년도 별 평균 내국인 방문객 수를 조회하라.
SELECT  concat(p.prvn_name, ' ', d.distc_name, ' ', a.attrc_name) AS attrc_name
, SUBSTR(f.basis_date, 1, 4) AS `year`
, round(avg(f.native_cnt)) AS figure 
  FROM province p 
  INNER JOIN district d ON d.prvn_cd = p.prvn_cd 
  INNER JOIN attraction a ON a.prvn_cd = p.prvn_cd AND a.distc_cd = d.distc_cd 
  LEFT JOIN figure f ON f.prvn_cd = p.prvn_cd AND f.distc_cd = d.distc_cd AND f.attrc_cd = a.attrc_cd 
WHERE p.prvn_name = '경기도' AND d.distc_name = '과천시'
GROUP BY f.attrc_cd, substr(f.basis_date, 1, 4)
ORDER BY `year`, figure DESC
;