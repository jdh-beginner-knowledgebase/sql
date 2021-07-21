# Interview
Interview Related Questions


# DimDateTimeZone20210721

Dimdate contains a script to generate a dim date table with timezones. At the top there is a timezone table that can be manually populated with time zones, you can use a table containing time zones to poulate the
temp table or you can use the SQL Server "sys.time_zone_info" dmv to populate the temp table. This script will generate on an hourly basis details for the dim date table for each timezone in the temp table, 
for each day between the start date and the cut off date.

There are 4 variables, the only 2 that need to be manually changed is the @StartDate and the @CutoffDate. This specifies the start and end date for the table.

DECLARE @timezone VARCHAR(100) - Place holder for each timezone in the temp table that will be looped through
DECLARE @sql NVARCHAR(MAX) 	   - Dynamic sql the will be executed for each timezone
DECLARE @StartDate CHAR(10)    - Start date
DECLARE @CutoffDate CHAR(10)   - End date