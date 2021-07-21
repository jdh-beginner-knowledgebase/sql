

DECLARE @timezone VARCHAR(100)
DECLARE @sql NVARCHAR(MAX)
DECLARE @StartDate CHAR(10) = '2000-01-01'
DECLARE @CutoffDate CHAR(10) = '2051-01-01'

DROP TABLE IF EXISTS #timezones 
CREATE TABLE #timezones(tz VARCHAR(100), Processed BIT DEFAULT(0))

INSERT INTO #timezones(tz)
SELECT DISTINCT timezone 
FROM TempSheDB.dbo.tblSheUser 
WHERE timezone IS NOT NULL
ORDER BY TimeZone


SET @timezone = (SELECT TOP 1 tz
				FROM #timezones
				WHERE Processed = 0
				ORDER BY tz)

WHILE @timezone IS NOT NULL AND @timezone != ' '

	   BEGIN


			SET @sql = '
			INSERT INTO tblBIDateDimension_tz_NEW
			SELECT
				REPLACE(REPLACE(SUBSTRING(CONVERT(VARCHAR,utc_date,120),1,13),''-'',''''),'' '','''') AS utc_DateKey 
				,REPLACE(REPLACE(SUBSTRING(CONVERT(VARCHAR,CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+'''))),120),1,13),''-'',''''),'' '','''') AS tz_DateKey 
				,'''+@timezone+''' as TimeZone
				,CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+'''))) as TimeZoneDate
				,utc_date as  DateTimeUTC
				,DATEPART(HOUR,CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+''')))) AS [Hour]
				,DATEPART(DW,CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+''')))) AS [DayOfWeek]
				,DATENAME(DW,CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+''')))) AS [DayOfWeekName]
				,''0'' + CONVERT(CHAR(1),DATEPART(DW,CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+'''))))) + DATENAME(DW,CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+''')))) AS [DayOfWeekCombined]
				,DATEPART(DAY,CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+''')))) AS [DayOfMonth]
				,DATEPART(DAYOFYEAR,CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+''')))) [DayOfYear]
				,DATEPART(MONTH,CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+''')))) [MonthOfYear]
				,DATENAME(MONTH,CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+''')))) [MonthOfYearName]
				,CONVERT(VARCHAR(2),FORMAT(CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+'''))),''MM'')) + DATENAME(MONTH,CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+''')))) [DayMonthCombined]
				,DATEPART(ISO_WEEK,CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+''')))) [WeekOfYear]
				,CONVERT(CHAR(4),DATEPART(YEAR,CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+''')))))  + ''- W'' + CONVERT(VARCHAR(2),DATEPART(ISO_WEEK,CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+'''))))) [WeekOfYearString]
				,DATEDIFF(DAY, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+''')))), 0), CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+''')))) + 1 [quarterDay]
				,DATEPART(QUARTER,CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+''')))) [quarter]
				,DATEPART(YEAR,CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+''')))) [year]
				,IIF(DATEPART(YEAR,CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+''')))) IN (2000, 2004, 2008, 2012, 2016, 2020, 2024, 2028, 2032, 2036, 2040, 2044, 2048), 1 , 0) [IsLeapYear]
				, CASE 
					WHEN MONTH(CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+''')))) >= 7 THEN  CAST(YEAR(CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+''')))) AS VARCHAR(4)) + ''/''+ CAST((YEAR(CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+'''))))+1) AS VARCHAR(4)) 
    				WHEN MONTH(CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+''')))) < 7 THEN  CAST((YEAR(CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+'''))))-1) AS VARCHAR(4)) + ''/'' + CAST((YEAR(CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+'''))))) AS VARCHAR(4)) 			
				END [FY-Jul/Jun]
				, CASE 
					WHEN (MONTH(CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+''')))) > 3 AND DAY(CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+'''))))>5) OR MONTH(CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+''')))) > 4 THEN CAST((YEAR(CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+'''))))) AS VARCHAR(4)) + ''/'' + CAST((YEAR(CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+'''))))+1) AS VARCHAR(4))
     				WHEN (MONTH(CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+''')))) < 5 AND DAY(CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+'''))))<7) OR MONTH(CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+''')))) < 4 THEN  CAST((YEAR(CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+'''))))-1) AS VARCHAR) + ''/''+  CAST((YEAR(CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+'''))))) AS VARCHAR) 
				END [FY-Apr/Apr]
				,CASE 
					WHEN MONTH(CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+''')))) >= 11  THEN  CAST(YEAR(CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+''')))) AS VARCHAR(4)) + ''/'' + CAST((YEAR(CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+'''))))+1) AS VARCHAR(4))
     				WHEN MONTH(CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+''')))) < 11 THEN  CAST((YEAR(CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+'''))))-1) AS VARCHAR(4)) + ''/'' + CAST((YEAR(CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+'''))))) AS VARCHAR(4)) 			
				END [FY-Nov/Oct]
				,CONVERT(DATE,CONVERT(DateTime, SWITCHOFFSET(utc_date, DATEPART(TZOFFSET, utc_date AT TIME ZONE '''+@timezone+'''))))
			FROM
			(
				SELECT utc_date = DATEADD(HOUR, rn - 1, ''' + @StartDate + ''')
				FROM 
				(
				SELECT TOP (DATEDIFF(HOUR, ''' + @StartDate + ''',''' + @CutoffDate + ''')) 
					rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
				FROM sys.all_objects AS s1
				CROSS JOIN sys.all_objects AS s2
				ORDER BY s1.[object_id]
				) AS x
			) AS y
			'

		EXEC SP_EXECUTEsql @sql

		UPDATE #timezones
		SET Processed = 1
		WHERE tz = @timezone

	    SET @timezone = (SELECT TOP 1 tz
	    FROM #timezones
	    WHERE Processed = 0
	    ORDER BY tz)

	END