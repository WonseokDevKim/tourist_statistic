SELECT p.prvn_cd, prvn_name, d.distc_cd , distc_name, a.attrc_name, 
	f.basis_date ,
	f.native_cnt, f.fore_cnt  -- p에 있는 건지, d에 있는 건지 명시해야 함
  FROM province p -- FROM이 기준. 그 뒤로 join한 순서대로 테이블이 붙음
  INNER JOIN district d ON d.prvn_cd = p.prvn_cd -- JOIN에는 on 뒤에 조인시키는 테이블 먼저 적어라 
  INNER JOIN attraction a 
    ON a.prvn_cd = p.prvn_cd 
    AND a.distc_cd = d.distc_cd 
  LEFT JOIN figure f ON f.prvn_cd = p.prvn_cd 
   AND f.distc_cd = d.distc_cd 
   AND f.attrc_cd  = a.attrc_cd 
WHERE 1=1
ORDER BY p.prvn_cd, d.distc_cd desc ; -- ORDER BY 없을 때 기본적으로 pk로 정렬. ORDER BY는 기본적으로 오름차순

SELECT *
 FROM figure f
 WHERE f.prvn_cd = 1 AND f.distc_cd = 1 AND f.attrc_cd = 23; -- 엘리시안강촌-스키장 없음을 확인. LEFT join시 B에 없는건 null로 출력
 
 
 -- 2010년, 경기도 수원시에 있는 관광지 별로 내국인/외국인 합계. 문장을 보고 어떤걸 where, group by, select(출력할 컬럼)에 들어가는지 논리적으로 파악해야 함
 -- 2010년, 경기도 수원시에 있는 관광지 중 내국인 방문객수가 1만명 이상인 관광지 몇 개
 SELECT p.prvn_cd, prvn_name, d.distc_cd , distc_name, a.attrc_name, 
		f.basis_date, 
	-- sum(f.native_cnt), f.fore_cnt -- 원래 mysql에서 이렇게 돌리면 에러남. 통계함수와 그룹함수는 한몸. 특정 기준(~~중)에서 통계를 내는 것.
 		sum(f.native_cnt), sum(f.fore_cnt)
  FROM province p -- FROM이 기준. 그 뒤로 join한 순서대로 테이블이 붙음
  INNER JOIN district d ON d.prvn_cd = p.prvn_cd -- JOIN에는 on 뒤에 조인시키는 테이블 먼저 적어라 
  INNER JOIN attraction a 
    ON a.prvn_cd = p.prvn_cd 
    AND a.distc_cd = d.distc_cd 
  LEFT JOIN figure f ON f.prvn_cd = p.prvn_cd 
   AND f.distc_cd = d.distc_cd 
   AND f.attrc_cd  = a.attrc_cd 
WHERE p.prvn_name = '경기도'
  AND d.distc_name = '수원시'
  AND f.basis_date BETWEEN '20100101' AND '20101201'
GROUP BY f.attrc_cd -- 원래 정확하게는 GROUP BY f.prvn_cd, f.distc_cd, f.attrc_cd (해석하기 나름) attrc_cd만으로는 중복됨 행정동까지 묶여야 고유함
-- group by를 어떻게 묶냐에 따라 값이 바뀜. 데이터는 나오다보니 잘못된건지 놓치기 쉬움
ORDER BY p.prvn_cd, d.distc_cd desc ; -- ORDER BY 없을 때 기본적으로 pk로 정렬. ORDER BY는 기본적으로 오름차순


-- 1. 각 [도/광역시]별 [시/군/구]의 개수를 조회하라.
SELECT p.prvn_name, count(d.distc_cd) -- 5 어디서 갖고 와야하는지를 알아야하므로 나중에 적어야 함
  FROM province p -- 1 기준 테이블
  INNER JOIN district d ON d.prvn_cd = p.prvn_cd  -- 2
  WHERE 1=1 -- 3 습관적으로 적기. 조건 필요할 때 and만 적고 이어쓸 수 있어 편하기 때문
GROUP BY d.prvn_cd; -- 4 

-- 2. 각 [도/광역시]의 [시/군/구]별 관광지 개수를 조회
SELECT p.prvn_cd, p.prvn_name, d.distc_cd, d.distc_name, count(a.attrc_cd)
  FROM province p 
  INNER JOIN district d ON d.prvn_cd = p.prvn_cd 
  INNER JOIN attraction a ON a.prvn_cd = p.prvn_cd AND a.distc_cd = d.distc_cd 
  WHERE 1=1
GROUP BY p.prvn_cd, d.distc_cd;

-- 경기도 수원시의 2017년 내국인 방문자 평균을 조회 avg
SELECT p.prvn_name, d.distc_name, avg(f.native_cnt)
  FROM province p  
  INNER JOIN district d ON d.prvn_cd = p.prvn_cd 
  LEFT JOIN figure f ON f.prvn_cd = p.prvn_cd AND f.distc_cd = d.distc_cd 
  WHERE 1=1
  AND p.prvn_name = '경기도' AND d.distc_name = '수원시'
  -- AND f.basis_date BETWEEN '20170101' AND '20171201'
  AND substr(f.basis_date, 1, 4) = '2017';
-- GROUP BY p.prvn_cd, d.distc_cd; -- 이미 경기도 수원시 2017년 필터링해서 그룹핑 할 필요가 없음. 만약 수원시, 화성시, ... 이럴 때 group by 하는 것 : 구별로 평균
-- HAVING p.prvn_name = '경기도' AND d.distc_name = '수원시'

SELECT substr(f.basis_date, 1, 4)
FROM figure f;

-- 3. 경기도 수원시의 2017년 1분기 내국인 방문자 평균을 조회 avg
SELECT p.prvn_name, d.distc_name, avg(f.native_cnt)
  FROM province p  
  INNER JOIN district d ON d.prvn_cd = p.prvn_cd 
  LEFT JOIN figure f ON f.prvn_cd = p.prvn_cd AND f.distc_cd = d.distc_cd 
  WHERE 1=1
  AND p.prvn_name = '경기도' AND d.distc_name = '수원시'
  AND f.basis_date BETWEEN '20170101' AND '20170301';
  -- AND substr(f.basis_date, 1, 4) = '2017';
 
 -- 4. 경기도 수원시의 2017년 하반기 내국인 방문자 합계를 조희
 SELECT p.prvn_name, d.distc_name, sum(f.native_cnt)
 	FROM province p 
 	INNER JOIN district d ON d.prvn_cd = p.prvn_cd 
 	LEFT JOIN figure f ON f.prvn_cd = p.prvn_cd AND f.distc_cd = d.distc_cd 
 	WHERE p.prvn_name = '경기도' AND d.distc_name = '수원시'
 	AND f.basis_date BETWEEN '20170701' AND '20171201';
 	
 -- 5. 2017년, 경기도 수원시의 관광지 중
 -- 평균 내국인 방문객 수가 가장 많은 관광지 3개의 이름과 그(관광지의) 평균 방문자 수를 죄회
 SELECT  p.prvn_name, d.distc_name, a.attrc_name, avg(f.native_cnt) -- 관광지 이름, 평균(방문자수)
 	FROM province p 
 	INNER JOIN district d ON d.prvn_cd = p.prvn_cd 
 	INNER JOIN attraction a ON a.prvn_cd = p.prvn_cd AND a.distc_cd = d.distc_cd 
 	LEFT JOIN figure f ON f.prvn_cd = p.prvn_cd AND f.distc_cd = d.distc_cd AND f.attrc_cd = a.attrc_cd
 WHERE p.prvn_name = '경기도' AND d.distc_name = '수원시'
 AND substr(f.basis_date, 1, 4) = '2017'
GROUP BY f.attrc_cd
-- 평균 내국인 방문객 수가 / 가장 많은 관광지 / 3개
 ORDER BY avg(native_cnt) DESC
 LIMIT 3; -- 잘라내기 mysql이 편함. 근데 데이터 늘어갈수록 엔터프라이즈 오라클.(근데 비싸서 카카오는 mysql을 튜닝하기도 함)
 
 -- 7. 2017년, 경기도에 속한 도시의 관광지별 내국인 방문객 수 합계를
 -- 각 도시 코드 별 오름차순 후 합계를 내림차순하여 조회.
 -- 광역시도 이름, 시군구명, 관광지명, 합계(내국인_관광객)
 SELECT *
 FROM (
 SELECT p.prvn_name, d.distc_cd, d.distc_name, a.attrc_name, sum(f.native_cnt) AS rslt -- 서브쿼리 때문에 d.distc_cd 만듬
 	FROM province p 
 	INNER JOIN district d ON d.prvn_cd = p.prvn_cd 
 	INNER JOIN attraction a ON a.prvn_cd = p.prvn_cd AND a.distc_cd = d.distc_cd 
 	LEFT JOIN figure f ON f.prvn_cd = p.prvn_cd AND f.distc_cd = d.distc_cd AND f.attrc_cd = a.attrc_cd
 WHERE p.prvn_name = '경기도'
 AND substr(f.basis_date, 1, 4) = '2017'
 GROUP BY f.distc_cd, f.attrc_cd 
 -- ORDER BY d.distc_cd, sum(f.native_cnt) desc -- 이렇게 해도 되나 sum 두번 해서 성능 저하. 그래서 서브쿼리 쓰거나 4 desc라 쓰기
 -- order by d.distc_cd, 4 desc -- 서브쿼리 안 쓸 때 개선
 -- ORDER BY d.distc_cd
 ) a
 -- ORDER BY a.rslt DESC -- 안에서 도시코드로 오름차순 시켰다고 빼먹다간 결과 틀리게 나옴
 ORDER BY a.distc_cd, a.rslt DESC -- 서브쿼리에 있는 ORDER BY 는 밖의 ORDER BY와 연결되는 게 아님. 서브쿼리 쓸 땐 밖에만 ORDER BY 쓰면 됨
 -- 서브쿼리 결과 자체를 하나의 테이블로 생각해야 함.
 ;
 
-- 6. 2017년, 경기도 관광지 중 내국인 방문객 수가 가장 많은 관광지명과 관광지가 속한 도시명, 방문객 수 조회
SELECT a.attrc_name, a.distc_name, max(rslt)
FROM (
SELECT a.attrc_name, d.distc_name, sum(f.native_cnt) AS rslt
	FROM province p 
	INNER JOIN district d ON d.prvn_cd = p.prvn_cd 
 	INNER JOIN attraction a ON a.prvn_cd = p.prvn_cd AND a.distc_cd = d.distc_cd 
 	LEFT JOIN figure f ON f.prvn_cd = p.prvn_cd AND f.distc_cd = d.distc_cd AND f.attrc_cd = a.attrc_cd
 WHERE p.prvn_name = '경기도'
 AND substr(f.basis_date, 1, 4) = '2017'
 GROUP BY f.distc_cd, f.attrc_cd 
 ORDER BY f.native_cnt DESC
) a
;


SELECT a.attrc_name, d.distc_name, sum(f.native_cnt)
	FROM province p 
	INNER JOIN district d ON d.prvn_cd = p.prvn_cd 
 	INNER JOIN attraction a ON a.prvn_cd = p.prvn_cd AND a.distc_cd = d.distc_cd 
 	LEFT JOIN figure f ON f.prvn_cd = p.prvn_cd AND f.distc_cd = d.distc_cd AND f.attrc_cd = a.attrc_cd
 WHERE p.prvn_name = '경기도'
 AND substr(f.basis_date, 1, 4) = '2017'
 GROUP BY f.distc_cd, f.attrc_cd 
 ORDER BY f.native_cnt DESC
 LIMIT 1 -- limit은 엔진별로 지원을 안할수도 있어 위의 방법을 선호하기도 함
 ;