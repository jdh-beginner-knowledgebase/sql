USE [master]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[GetBestBuyAndSellPrices]

@String VARCHAR(MAX)
,@Delimiter CHAR(1)

AS

/*
THE PURPOSE OF THIS STORED PROCEDURE IS TO PASS IN A STRING OF VALUES AND A DELIMITER AND GET THE BEST BUY AND SELL PRICE FROM THE STRING
THE RESULTS SHOW THE DAY NUMBER AND IN BRACKETS THE OPEN PRICE FOR THE DAY
THE FIRST RESULT IS THE BUY PRIE AND THE SECOND RESULT(AFTER THE COMMA) SHOWS THE SELL PRICE

BELOW ARE TWO EXAMPLES:
1ST VALUE IS THE STRING OF VALUES
2ND VALUE IS THE DELIMITER

EXEC dbo.[GetBestBuyAndSellPrices] '19.15,18.30,18.88,17.93,15.95,19.03,19.00',','
EXEC dbo.[GetBestBuyAndSellPrices] '18.93,20.25,17.05,16.59,21.09,16.22,21.43,27.13,18.62,21.31,23.96,25.52,19.64,23.49,15.28,22.77,23.1,26.58,27.03,23.75,27.39,15.93,17.83,18.82,21.56,25.33,25,19.33,22.08,24.03',','
*/


BEGIN

DROP TABLE IF EXISTS #OpenPrices

CREATE TABLE #OpenPrices
(
DayNumber INT IDENTITY(1,1)
,OpenPrice VARCHAR(20)
)

INSERT INTO #OpenPrices(OpenPrice)
SELECT * 
FROM STRING_SPLIT(@String,@Delimiter)

DECLARE @MinDAy INT = (SELECT DayNumber
					   FROM #OpenPrices
					   WHERE OpenPrice = (SELECT MIN(OpenPrice)
										  FROM #OpenPrices)
						)



DECLARE @Price NVARCHAR(MAX);

SELECT @Price = COALESCE(@Price + ',', '') + Prices
  FROM (
		SELECT CONVERT(VARCHAR(3),test.daynumber)+'('+temp.minp+')'Prices
		FROM #OpenPrices test
		INNER JOIN(
					SELECT MIN(t.OPenPrice)minp
					FROM #OpenPrices t
					INNER JOIN (
								--GET DAY NUMBER FOR MIN PRICE
								SELECT t1.DayNumber dn,t2.OpenPrice op
								FROM #OpenPrices t1
								INNER JOIN 
										--GET SELL PRICE (MIN PRICE IN DATASET)
										(SELECT MIN(OPenprice)OpenPrice
										 FROM #OpenPrices 
										 )t2 ON t1.openprice = t2.openprice
								)minq ON t.daynumber = minq.dn
					UNION
					SELECT MAX(t.openprice)maxp
					FROM #OpenPrices t
					INNER JOIN (
								--GET ALL RECORDS GREATER THAN MIN OPEN PRICE DAY
								SELECT t1.DayNumber dn,t2.OpenPrice op
								FROM #OpenPrices t1
								INNER JOIN 
										(SELECT MIN(OPenprice)OpenPrice
										 FROM #OpenPrices 
										 )t2 ON t1.openprice = t2.openprice
								)minq ON t.daynumber >= minq.dn
					)temp ON test.openprice = temp.minp
		)final

SELECT @Price BuyAndSellPrices



END