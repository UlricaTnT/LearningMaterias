

------------------------------------------------------Frist--------------------------------------------
/*
1.将两个使用的是一个数据库，可在前面USE中指定
2.是否该将字符串转换成DATETIME格式 再比较呢
3.将大写的A改为a
*/
USE AdventureWorks
GO

SELECT a.name, 
    CASE
        WHEN a.SizeUnitMeasureCode IS NULL 
                THEN 'CM'
                ELSE a.SizeUnitMeasureCode
    END AS SizeUnitMeasureCode
FROM Production.product AS a
        ,Sales.SalesOrderDetail AS b
WHERE a.productid=b.productid
        AND a.ModifiedDate>CONVERT(DATETIME,'2012-06-25 00:00:00')     --将字符串转换为DATETIME类型



-----------------------------------------------------Second--------------------------------------------

ALTER TABLE [dbo].[tb_item] ADD state INT NULL ;                                --先增加一列新的为空的列
ALTER TABLE [dbo].[tb_item] ADD CONSTRAINT Df_tb_item_state DEFAULT 0 FOR state;     --增加一个默认值为0的约束     起先认为这儿会直接将表格中的值变为0 经测试不会

ALTER TABLE [dbo].[tb_item] ALTER COLUMN state INT NOT NULL;                        --修改设置列的属性不允许为空


----------------------------------------------------Third----------------------------------------------

/*
1.可以使用WIHT(NOLOCK)来增加并发时的能力
2.可以将两边的字符格式改成相同类型的
*/

DECLARE @ItemNumber CHAR(25)                    --修改类型
SET @ItemNumber='00-000-006R'

SELECT ItemNumber,ProductTitle,ProductName,ManualProductName 
FROM dbo.ItemDescription WITH(NOLOCK)           --使用WITH(NOLOCK)提高并发处理，增加性能
WHERE ItemNumber=@ItemNumber


----------------------------------------------------FOURTH---------------------------------------------

/*
1.可以新建一个临时表 将所有需要查询的字段全部存到临时表中，之后的查询直接读取临时表就行了
2.如果descrip常常被作为查询条件的话，可在某个夜深人静的晚上悄悄地给它建个索引
*/

USE ItemMaintainNewegg
GO
IF EXISTS (SELECT TOP 1 1 FROM dbo.Priceinfo WITH (NOLOCK))     
BEGIN
    --将搜寻结果放入临时表#temp中
    SELECT item INTO #temp FROM
        ItemSKU.[dbo].arinvt01 WITH (NOLOCK)
    where descrip='Memor xxxx|JACKTEST0723002001 R    ';

    --之后的搜索直接使用临时表中的数据就行了
    SELECT itemNo,productName,unitPrice,rebate
    FROM  dbo.Priceinfo WITH (NOLOCK)
    WHERE itemNo IN(
				SELECT  item
				FROM #temp WITH (NOLOCK))

    SELECT  Item,Model,CatKeywords,ManuKeywords
    FROM dbo.advsItems WITH (NOLOCK)
    WHERE Item IN(
    				SELECT item
    				FROM #temp WITH (NOLOCK))

    SELECT  ItemNumber,[Priority],ItemType,ImageSize,Memo
    FROM dbo.EC_NFHomepage WITH (NOLOCK)
    WHERE ItemNumber IN(
    				SELECT item
    				FROM #temp WITH (NOLOCK))

END


------------------------------------------------FIFTH-------------------------------------

/*
1.这里用了两个存储过程，第一个负责新建表和备份，第二个循环年份并调用第一个SP来达到目的;
*/

--新建一个SP来新建表和备份表

USE Test
GO

CREATE PROCEDURE [bank_ll7i].[Up_BackUp] 
		@tableName VARCHAR(60),
        @tableFullName VARCHAR(60),
        @startTime DATETIME,
        @endTime DATETIME
AS
    DECLARE @sqlString NVARCHAR(800)
    DECLARE @sqlParameter NVARCHAR(50);
    --新建年份表格
    SET @sqlString = 'CREATE TABLE '+@tableFullName+' (
	                    TransactionNumber INT IDENTITY(1,1)
	                    ,Card_ID CHAR(20) NOT NULL
	                    ,Type BIT NOT NULL
	                    ,Amount DECIMAL(12,2) NOT NULL
	                    ,Indate DATETIME DEFAULT GETDATE()
	                    ,Status BIT DEFAULT 0
	                    ,Remarks nvarchar(50)
                        ,InsertTime DATETIME DEFAULT GETDATE()
                        ,CONSTRAINT PK_'+@tableName+' PRIMARY KEY
                        (
                            TransactionNumber ASC
                        ))'
    exec sp_executesql @sqlString;

    --循环插入，每次插入100条，直到某次插入记录不足100，则退出循环
    WHILE 1=1
    BEGIN
        BEGIN TRY
            BEGIN TRAN
                SET @sqlString =
                    'DELETE TOP(100)
                        OUTPUT deleted.[TransactionNumber],
                            deleted.[Card_ID],
                            deleted.[Type],
                            deleted.[Amount],
                            deleted.[Indate],
                            deleted.[Status],[Remarks]
                        INTO '+@tableFullName
                            +'([TransactionNumber],
                            [Card_ID]
                            [Type],
                            [Amount],
                            [Indate],
                            [Status],
                            [Remarks]) 
                    FROM [bank_ll7i].[Transactions_ll7i]
                    WHERE [Indate]>@StartTime AND [Indate]<=@EndTime'
                SET @sqlParameter = '@StarTime DATETIME, @EndTime DATETIME';
                exec sp_executesql @sqlString,@sqlParameter, @StarTime=@startTime, @EndTime=@endTime;
            COMMIT TRAN
        END TRY
        BEGIN CATCH
            ROLLBACK TRAN   --回滚事务
        END CATCH
        IF @@ROWCOUNT<100 
            BREAK;
        WAITFOR DELAY '00:00:10';   --每次间隙10秒
    END
GO

USE Test
GO

CREATE PROCEDURE [bank_ll7i].[Up_Transactions_Backup] 
AS
    DECLARE @tableName_NewCreate VARCHAR(60), --存储新创建的表的时间
            @nowyear INT,                    --记录当前的年
            @creatyear INT,                 --记录新建表对应的年
            @startTime DATETIME,            --备份表记录的开始时间
            @endTime DATETIME,              --备份表记录的最后时间
			@tableName VARCHAR(60);
    SET @nowyear = CONVERT(INT,YEAR(GETDATE()));
    SET @creatyear = @nowyear -1;                                                               --从去年开始删除
    
    SET @tableName_NewCreate = '[bank_ll7i].[Transactions_'+CONVERT(CHAR(4),@creatyear)+']';    --生成去年的表名
	SET @tableName = 'Transactions_'+CONVERT(CHAR(4),@creatyear)
    SET @startTime = CONVERT(DATETIME,CONVERT(CHAR,@creatyear)+'-01-01');                       --从去年的一月一日开始
    SET @endTime = DATEADD(YEAR,-1,GETDATE());                                       --到去年的今天这个时候结束

    EXEC [bank_ll7i].[Up_BackUp] @tableName,@tableName_NewCreate, @startTime, @endTime;     --开始执行自己写的一个备份记录的SP

    WHILE @creatyear>=2000   --开始前年至2000年的备份
        BEGIN
            SET @creatyear = @creatyear-1;
            SET @tableName_NewCreate = '[bank_ll7i].[Transactions_'+CONVERT(CHAR(4),@creatyear)+']';
			SET @tableName = 'Transactions_'+CONVERT(CHAR(4),@creatyear);
            SET @startTime = CONVERT(DATETIME,CONVERT(CHAR,@creatyear)+'-01-01');       --开始时间是当年的1月1日
            SET @endTime = CONVERT(DATETIME,CONVERT(CHAR,@creatyear+1)+'-01-01');        --结束时间是第二年的1月1日
            EXEC [bank_ll7i].[Up_BackUp] @tableName, @tableName_NewCreate, @startTime, @endTime;   --开始执行每年的备份SP
        END
GO

--调用过程
exec [bank_ll7i].[Up_Transactions_Backup]