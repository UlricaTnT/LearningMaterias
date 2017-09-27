----------------------char&varchar、char&nchar、varchar&nvarchar-------------------------------------------------------------------------------------------
DECLARE @string_a CHAR(5),@string_b VARCHAR(5),@string_c NCHAR(5),
@string_d NVARCHAR(5)
SELECT @string_a='aa',@string_b='aa',@string_c='aa',@string_d='aa'
SELECT LEN(@string_a),LEN(@string_b),LEN(@string_c),LEN(@string_d)  
--LEN 返回指定字符串表达式的字符数，其中不包含尾随空格
SELECT DATALENGTH(@string_a),DATALENGTH(@string_b),DATALENGTH(@string_c),
DATALENGTH(@string_d) --DATALENGTH 返回用于表示任何表达式的字节数。
SELECT @string_a,@string_b,@string_c,@string_d

GO
DECLARE @string_a CHAR(5),@string_b VARCHAR(5),@string_c NCHAR(5),
@string_d NVARCHAR(5)
SELECT @string_a='哈哈',@string_b='哈哈',@string_c='哈哈',@string_d='哈哈'
SELECT @string_a,@string_b,@string_c,@string_d
GO
DECLARE @string_a CHAR(5),@string_b VARCHAR(5),@string_c NCHAR(5),
@string_d NVARCHAR(5)
SELECT @string_a=N'哈哈',@string_b=N'哈哈',@string_c=N'哈哈',@string_d=N'哈哈'
SELECT @string_a,@string_b,@string_c,@string_d
/*
注意：
1.因为在存储varchar字段时，从底层数据行的结构，它会比char多维护2个字节（可变长度字段的列偏移阵列）,
所以基于性能及维护成本，我们赞成字符数小于3的都是用char,nchar来定义。
数据类型CHAR/NCHAR当宽度超过50，请考虑使用VARCHAR/NVARCHAR代替
2.xml/varhcar(max)/nvarchar(max)这三种类型的列，
DBA 建议存储在独立的表中，否则会产生很大的性能问题
3.char,varchar类型字段，需要预估是否包含多国字符，如果是，请使用nchar,nvarchar
4.在 Microsoft SQL Server 的未来版本中将删除 ntext、text 和 image 数据类型。请避免在新开发工作中使用这些数据类型，并考虑修改当前已使用这些数据类型的应用程序。 
  请改用 nvarchar(max)、varchar(max) 和 varbinary(max)，即使是在临时表，表变量也不允许使用
*/

--Money类型是不允许使用的，请用Decimal(12,2)代替
DECLARE @money MONEY,@decimal DECIMAL(12,2)
SELECT @money=1.2,@decimal=1.2
SELECT @money,@decimal,DATALENGTH(@money),DATALENGTH(@decimal)

---------------------------------------------------------variable-------------------------------------------------------------------------------------------
--Global variable
SELECT @@SERVERNAME,@@SERVICENAME,@@VERSION
SELECT @@ROWCOUNT
--local variable 
DECLARE @i INT
SET @i=1
SELECT @i

---notice:
IF 1=2
	DECLARE @i INT
ELSE
	SET @i=1
 
SELECT @i


DECLARE @i int 
DECLARE @j int
SELECT @i=1

WHILE @i<4
BEGIN

	
	SELECT @j=ISNULL(@j+1,1)

	SELECT @i=@i+1
END

select @i,@J

DECLARE @t TABLE(i INT)

IF 'a'='b'
BEGIN 
	
	INSERT INTO @t
	SELECT 1 
 
	CREATE TABLE #t(j INT)
	INSERT INTO #t
	SELECT 2
END
 
SELECT *FROM @t      
SELECT *FROM #t

/*
结论:while、if都是用的conditional迭代器，这个迭代器中如果涉及到变量声明，
会放到迭代器之前运行，而不是按写好的逻辑顺序执行。
因此上面三个语句等价于把语句中的declare拿到逻辑块之前执行
*/


--变量赋值
IF OBJECT_ID('tempdb.dbo.#TEST','U') IS NOT NULL
   DROP TABLE #TEST
ELSE 
   CREATE TABLE #TEST
   (
	id INT IDENTITY(1,1) NOT NULL,
	Item CHAR(25)  NULL
   )  

INSERT INTO #TEST
SELECT 'AAAA'
UNION ALL 
SELECT 'BBBB'

SELECT * FROM #TEST

DECLARE @id INT,@item CHAR(25)
SELECT @id=id,@item=item FROM  #TEST
SELECT @id,@Item
SELECT TOP 1 @id=id,@Item=item FROM  #TEST
SELECT @id,@Item
SET @item=(
		  SELECT TOP 1 ITEM FROM #TEST
			)
SELECT @item
GO
DECLARE @item CHAR(25)
SELECT @item='cccc'
SELECT @item=item FROM  #TEST WHERE id=3
SELECT @Item
SELECT @item='cccc'
SET @item=(
		  SELECT ITEM FROM #TEST  WHERE id=3
			)
SELECT @Item

----------------------------------------------------------built-in function-----------------------------------------------------------------------------------------
--datetime
DECLARE @datetime DATETIME,@datetime1 DATETIME
SET @datetime=GETDATE()
SELECT @datetime
SET @datetime1=DATEADD(dd,1,@datetime)
SELECT @datetime1
SELECT DATEDIFF(dd,@datetime,@datetime1),DATEPART(YY,@datetime),DATEPART(qq,@datetime),DATEPART(mm,@datetime)
GO

--string
DECLARE @string CHAR(30),@len INT
SET @string='123,456,789'
SELECT LEN(@string)
SELECT @len=CHARINDEX(',',@string)
SELECT @len
SELECT SUBSTRING(@string,1,@len-1)
SELECT LEFT(@string,3),RIGHT(@string,3),RIGHT(RTRIM(@string),3),REVERSE(@string),REVERSE(RTRIM(@string)),
	   REPLACE(@string,'123','456')

--convert
DECLARE @datetime DATETIME
SELECT @datetime=GETDATE()
SELECT @datetime
SELECT CONVERT(VARCHAR(19),GETDATE(),120),
	   CONVERT(VARCHAR(19),GETDATE(),110),
	   CONVERT(VARCHAR(19),GETDATE(),103),
	   CONVERT(VARCHAR(19),GETDATE(),111)

SELECT CAST('123' AS INT), CAST(123.4 AS INT)
SELECT CONVERT(INT,'123'), CONVERT(INT, 123.5)

--other
SELECT ABS(-8),ROUND(123.005, 2),ROUND(123.004, 2)


----------------------------------------------------------transaction---------------------------------------------------------------------------------------------------
/*
原子性（Atomicity）：要么完成所有数据的修改，要么对这些数据不做任何修改。
一致性(Consistency）：一致性阐明了在成功地完成了一个事务之后，所有的数据都处于一致状态。
					必须将关系数据库的所有规则应用于事务中的修改，以维护完全的数据完整性。
独立性(Isolation)：独立性阐明了事务中所进行的任何数据修改都独立于同时发生的其他事务对数据的修改。
					也就是说，该事务访问的数据所处的状态要么是在同时发生的事务修改之前的，
					要么是在第二个事务完成之后的。没有间隙让该过程看到一个中间状态。
持久性(Durability)：持旧性阐明了完整的事务对数据的任何修改能够在系统中永久保持其效果。
                    因此，完整的事务对数据的任何修改即便是遭遇到系统失败也能保持下来。
					这一属性通过事务日志的备份和恢复来确保。
*/

---@@TRANCOUNT
BEGIN TRAN 
    SELECT @@TRANCOUNT
	BEGIN TRAN 
		SELECT @@TRANCOUNT
		BEGIN TRAN 
			SELECT @@TRANCOUNT
		ROLLBACK TRAN
		 --COMMIT TRAN  
			SELECT @@TRANCOUNT
	COMMIT TRAN  
	SELECT @@TRANCOUNT
COMMIT TRAN  
SELECT @@TRANCOUNT



USE test;
GO
IF OBJECT_ID(N't1', N'U') IS NOT NULL
    DROP TABLE t1;
CREATE TABLE t1
    (a INT NOT NULL PRIMARY KEY);
BEGIN TRAN
	INSERT INTO t1
	SELECT 1
	UNION ALL
	SELECT 2
	UNION ALL
	SELECT 3
SAVE TRAN SAVE1
	INSERT INTO T1
	SELECT 4
	UNION ALL
	SELECT 5
SELECT * FROM t1
SELECT @@TRANCOUNT
ROLLBACK TRAN SAVE1
SELECT @@TRANCOUNT
SELECT * FROM t1
COMMIT TRAN 
SELECT * FROM t1



USE test;
GO
IF OBJECT_ID(N't1', N'U') IS NOT NULL
    DROP TABLE t1;
GO
CREATE TABLE t1
    (a INT NOT NULL PRIMARY KEY);
GO
INSERT INTO t1 VALUES (1);
GO

SELECT * FROM t1;


SET XACT_ABORT OFF;

INSERT INTO t1 VALUES (2);
INSERT INTO t1 VALUES (1);
INSERT INTO t1 VALUES (3);

SELECT * FROM t1;



SET XACT_ABORT ON;

INSERT INTO t1 VALUES (4);
INSERT INTO t1 VALUES (1);
INSERT INTO t1 VALUES (5);

SELECT * FROM t1;
GO

---in explicit transaction
USE test;
GO
IF OBJECT_ID(N't1', N'U') IS NOT NULL
    DROP TABLE t1;
GO
CREATE TABLE t1
    (a INT NOT NULL PRIMARY KEY);

INSERT INTO t1 VALUES (1);

GO

SET XACT_ABORT OFF;
GO
BEGIN TRANSACTION;
INSERT INTO t1 VALUES (2);
INSERT INTO t1 VALUES (1);
INSERT INTO t1 VALUES (3);
SELECT @@TRANCOUNT
COMMIT TRANSACTION;

--ROLLBACK TRANSACTION
SELECT * FROM t1;

GO

SET XACT_ABORT ON;
GO
BEGIN TRANSACTION;
INSERT INTO t1 VALUES (4);
INSERT INTO t1 VALUES (1);
INSERT INTO t1 VALUES (5);
SELECT @@TRANCOUNT
COMMIT TRANSACTION;
GO
--ROLLBACK TRANSACTION
SELECT * FROM t1;
GO

/*
当 SET XACT_ABORT 为 ON 时，如果 Transact-SQL 语句产生运行时错误，整个事务将终止并回滚。为 OFF 时，
只回滚产生错误的 Transact-SQL 语句，而事务将继续进行处理。编译错误（如语法错误）不受 SET XACT_ABORT 的影响。
*/
/* 
1.XACT_ABORT选项的设置，一般默认为OFF，只有分布式事务中我们将它设为ON
2.避免SET XACT_ABORT ON 自动回滚事务，尽量使用TRY...CATCH显示事务回滚。
3.XACT_ABORT在分布式事务中的使用,如果分布式事务中存在UPDATE/INSERT/DELETE， 
XACT_ABORT选项必须设置为on，否则会报错
*/



--suggestion 
USE test;
GO

IF OBJECT_ID(N't1', N'U') IS NOT NULL
    DROP TABLE t1;
GO
CREATE TABLE t1
    (a INT NOT NULL PRIMARY KEY);
GO
INSERT INTO t1 VALUES (1);

GO

SET XACT_ABORT OFF;
GO
BEGIN TRY
	BEGIN TRANSACTION;
	INSERT INTO t1 VALUES (2);
	INSERT INTO t1 VALUES (1); -- Foreign key error.
	INSERT INTO t1 VALUES (3);
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
   IF @@TRANCOUNT>0
    ROLLBACK TRANSACTION
	/*
    INERT INTO OperationLog
    SELECT .....
    */
END CATCH
GO
SELECT @@TRANCOUNT
SELECT * FROM t1;

GO

SET XACT_ABORT ON;
GO
BEGIN TRY
	BEGIN TRANSACTION;
	INSERT INTO t1 VALUES (4);
	INSERT INTO t1 VALUES (1); -- Foreign key error.
	INSERT INTO t1 VALUES (5);
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF (XACT_STATE()) = -1
	BEGIN
        PRINT N'The transaction is in an uncommittable state.' + 'Rolling back transaction.'
		ROLLBACK TRANSACTION
	    
	END
	IF (XACT_STATE()) =1
	BEGIN
        PRINT
            N'The transaction is committable.' +
            'Committing transaction.'
        COMMIT TRANSACTION;   
    END;
END CATCH
GO
SELECT * FROM t1;
GO

---XACT_STATE() 
/*
Return value	Meaning
1				The current request has an active user transaction. The request can perform any actions, 
				including writing data and committing the transaction.
0			    There is no active user transaction for the current request.
-1				The current request has an active user transaction, but an error has occurred that has caused the transaction to be classified as an uncommittable transaction. 
				The request cannot commit the transaction or roll back to a savepoint; it can only request a full rollback of the transaction. The request cannot perform any write
				operations until it rolls back the transaction. The request can only perform read operations until it rolls back the transaction.
*/

-----------------------------------------------------------Table--------------------------------------------------------------------------------------------
USE [Test]
GO

/*================================================================================  
Server:    WCMIS085  
DataBase:  TEST  
Team:	   DBA
Author:    Sophie.X.Ma
Object:    Contacts 
Version:   1.0  
Date:      2015/11/25
Content:   the information of contacts
----------------------------------------------------------------------------------  
Modified history:      
      
Date        Modified by    VER    Description      
------------------------------------------------------------  
2015/11/25  Sophie.X.Ma			   1.0    Create.  
================================================================================*/  

CREATE SCHEMA SM98

CREATE TABLE [dbo].[Contacts](
	[ContactID] [int] IDENTITY(1,1) NOT NULL,
	[NameStyle] [bit] NOT NULL,
	[Title] [nvarchar](8) NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[Suffix] [nvarchar](10) NULL,
	[EmailAddress] [nvarchar](50) NULL,
	[EmailPromotion] [int] NOT NULL,
	[Phone] [nvarchar](25) NULL,
	[PasswordHash] [varchar](128) NOT NULL,
	[PasswordSalt] [varchar](10) NOT NULL,
	[AdditionalContactInfo] [nvarchar](300) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL  CONSTRAINT DF_Contacts_ModifiedDate DEFAULT GETDATE()
 CONSTRAINT [PK_Contacts] PRIMARY KEY CLUSTERED 
(
	[ContactID] ASC
)WITH (FILLFACTOR=90) ON [PRIMARY]
) ON [PRIMARY]

GO

INSERT INTO dbo.Contacts(
[NameStyle]
,[Title] 
,[FirstName]
,[LastName]
,[EmailAddress]
,[EmailPromotion]
,[Phone]
,[PasswordHash]
,[PasswordSalt]
,rowguid
,[ModifiedDate]
)
SELECT 0,N'Mr.',N'Gustavo',N'Achong',N'gustavo0@adventure-works.com',2,N'398-555-0132',
		'GylyRwiKnyNPKbC1r4FSqA5YN9shIgsNik5ADyqStZc=','TVGHbhY=',NEWID(),GETDATE()
UNION ALL
SELECT 0,N'Mr.',N'Catherine',N'Abel',N'catherine0@adventure-works.com',1,N'747-555-0171',
		'zh3goJUbYsPv92k4bVZuJtlLHwuvpQtu6uNcjkKSdF8=','rpyd5Tw=',NEWID(),GETDATE()

INSERT INTO dbo.Contacts(
[NameStyle]
,[Title] 
,[FirstName]
,[LastName]
,[EmailAddress]
,[EmailPromotion]
,[Phone]
,[PasswordHash]
,[PasswordSalt]
,rowguid
,[ModifiedDate]
)
VALUES(1,N'Mr.',N'Gustava',N'Achong',N'gustavo0@adventure-works.com',2,N'398-555-0132',
		'GylyRwiKnyNPKbC1r4FSqA5YN9shIgsNik5ADyqStZc=','TVGHbhY=',NEWID(),GETDATE()),
     ( 1,N'Mr.',N'Catherina',N'Abel',N'catherine0@adventure-works.com',1,N'747-555-0171',
		'zh3goJUbYsPv92k4bVZuJtlLHwuvpQtu6uNcjkKSdF8=','rpyd5Tw=',NEWID(),GETDATE())

GO
SELECT
[NameStyle]
,[Title] 
,[FirstName]
,[LastName]
,[EmailAddress]
,[EmailPromotion]
,[Phone]
,[PasswordHash]
,[PasswordSalt]
,rowguid
,[ModifiedDate]
FROM dbo.Contacts

UPDATE TOP(1) dbo.Contacts
SET [Phone]='13699466006'
WHERE FirstName='Gustavo' AND LastName='Achong'

DELETE TOP(1) FROM dbo.Contacts
WHERE FirstName='Catherine' AND LastName='Abel'

ALTER TABLE  dbo.Contacts
ADD Birthday DATETIME null

ALTER TABLE  dbo.Contacts
ALTER COLUMN [LastName] NVARCHAR(60) null


DROP TABLE dbo.Contacts

--------------------local temporary table-----------------
IF OBJECT_ID('tempdb..#Contacts') IS NOT NULL
	DROP TABLE #Contacts
CREATE TABLE #Contacts
(
	[ContactID] [int] IDENTITY(1,1) NOT NULL,
	[NameStyle] [bit] NOT NULL,
	[Title] [nvarchar](8) NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[Suffix] [nvarchar](10) NULL,
	[EmailAddress] [nvarchar](50) NULL,
	[EmailPromotion] [int] NOT NULL,
	[Phone] [nvarchar](25) NULL,
	[PasswordHash] [varchar](128) NOT NULL,
	[PasswordSalt] [varchar](10) NOT NULL,
	[AdditionalContactInfo] [nvarchar](300) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL  CONSTRAINT DF_#Contacts_ModifiedDate DEFAULT GETDATE()
 CONSTRAINT [PK_#Contacts] PRIMARY KEY CLUSTERED 
(
	[ContactID] ASC
)WITH(FILLFACTOR=90) ON [PRIMARY]
)

INSERT INTO #Contacts(
[NameStyle]
,[Title] 
,[FirstName]
,[LastName]
,[EmailAddress]
,[EmailPromotion]
,[Phone]
,[PasswordHash]
,[PasswordSalt]
,rowguid
,[ModifiedDate]
)
SELECT 0,N'Mr.',N'Gustavo',N'Achong',N'gustavo0@adventure-works.com',2,N'398-555-0132',
		'GylyRwiKnyNPKbC1r4FSqA5YN9shIgsNik5ADyqStZc=','TVGHbhY=',NEWID(),GETDATE()
UNION ALL
SELECT 0,N'Mr.',N'Catherine',N'Abel',N'catherine0@adventure-works.com',1,N'747-555-0171',
		'zh3goJUbYsPv92k4bVZuJtlLHwuvpQtu6uNcjkKSdF8=','rpyd5Tw=',NEWID(),GETDATE()

GO
INSERT INTO #Contacts(
[NameStyle]
,[Title] 
,[FirstName]
,[LastName]
,[EmailAddress]
,[EmailPromotion]
,[Phone]
,[PasswordHash]
,[PasswordSalt]
,rowguid
,[ModifiedDate]
)
VALUES(1,N'Mr.',N'Gustava',N'Achong',N'gustavo0@adventure-works.com',2,N'398-555-0132',
		'GylyRwiKnyNPKbC1r4FSqA5YN9shIgsNik5ADyqStZc=','TVGHbhY=',NEWID(),GETDATE()),
     ( 1,N'Mr.',N'Catherina',N'Abel',N'catherine0@adventure-works.com',1,N'747-555-0171',
		'zh3goJUbYsPv92k4bVZuJtlLHwuvpQtu6uNcjkKSdF8=','rpyd5Tw=',NEWID(),GETDATE())


INSERT INTO #Contacts(
[NameStyle]
,[Title] 
,[FirstName]
,[LastName]
,[EmailAddress]
,[EmailPromotion]
,[Phone]
,[PasswordHash]
,[PasswordSalt]
,rowguid
,[ModifiedDate]
)
SELECT 
[NameStyle]
,[Title] 
,[FirstName]
,[LastName]
,[EmailAddress]
,[EmailPromotion]
,[Phone]
,[PasswordHash]
,[PasswordSalt]
,rowguid
,[ModifiedDate]
FROM dbo.Contacts WITH(NOLOCK)


GO
SELECT
[NameStyle]
,[Title] 
,[FirstName]
,[LastName]
,[EmailAddress]
,[EmailPromotion]
,[Phone]
,[PasswordHash]
,[PasswordSalt]
,rowguid
,[ModifiedDate]
FROM #Contacts

UPDATE TOP(1) #Contacts
SET [Phone]='13699466006'
WHERE FirstName='Gustavo' AND LastName='Achong'

DELETE TOP(1) FROM #Contacts
WHERE FirstName='Catherine' AND LastName='Abel'


ALTER TABLE  #Contacts
ADD Birthday DATETIME null

ALTER TABLE  #Contacts
ALTER COLUMN [LastName] NVARCHAR(60) null

SELECT TOP 1 * FROM #Contacts

DROP TABLE #Contacts

GO
--SELECT * FROM tempdb.sys.objects with(nolock) WHERE name like '%Contacts%'

----------global temporary table-----------------
IF OBJECT_ID('tempdb..##Contacts') IS NOT NULL
	DROP TABLE ##Contacts
CREATE TABLE ##Contacts
(
	[ContactID] [int] IDENTITY(1,1) NOT NULL,
	[NameStyle] [bit] NOT NULL,
	[Title] [nvarchar](8) NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[Suffix] [nvarchar](10) NULL,
	[EmailAddress] [nvarchar](50) NULL,
	[EmailPromotion] [int] NOT NULL,
	[Phone] [nvarchar](25) NULL,
	[PasswordHash] [varchar](128) NOT NULL,
	[PasswordSalt] [varchar](10) NOT NULL,
	[AdditionalContactInfo] [nvarchar](300) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL  CONSTRAINT DF_##Contacts_ModifiedDate DEFAULT GETDATE()
 CONSTRAINT [PK_##Contacts] PRIMARY KEY CLUSTERED 
(
	[ContactID] ASC
)WITH (FILLFACTOR=90) ON [PRIMARY]
)

INSERT INTO ##Contacts(
[NameStyle]
,[Title] 
,[FirstName]
,[LastName]
,[EmailAddress]
,[EmailPromotion]
,[Phone]
,[PasswordHash]
,[PasswordSalt]
,rowguid
,[ModifiedDate]
)
SELECT 0,N'Mr.',N'Gustavo',N'Achong',N'gustavo0@adventure-works.com',2,N'398-555-0132',
		'GylyRwiKnyNPKbC1r4FSqA5YN9shIgsNik5ADyqStZc=','TVGHbhY=',NEWID(),GETDATE()
UNION ALL
SELECT 0,N'Mr.',N'Catherine',N'Abel',N'catherine0@adventure-works.com',1,N'747-555-0171',
		'zh3goJUbYsPv92k4bVZuJtlLHwuvpQtu6uNcjkKSdF8=','rpyd5Tw=',NEWID(),GETDATE()

GO
INSERT INTO ##Contacts(
[NameStyle]
,[Title] 
,[FirstName]
,[LastName]
,[EmailAddress]
,[EmailPromotion]
,[Phone]
,[PasswordHash]
,[PasswordSalt]
,rowguid
,[ModifiedDate]
)
VALUES(1,N'Mr.',N'Gustava',N'Achong',N'gustavo0@adventure-works.com',2,N'398-555-0132',
		'GylyRwiKnyNPKbC1r4FSqA5YN9shIgsNik5ADyqStZc=','TVGHbhY=',NEWID(),GETDATE()),
     ( 1,N'Mr.',N'Catherina',N'Abel',N'catherine0@adventure-works.com',1,N'747-555-0171',
		'zh3goJUbYsPv92k4bVZuJtlLHwuvpQtu6uNcjkKSdF8=','rpyd5Tw=',NEWID(),GETDATE())

GO
SELECT
[NameStyle]
,[Title] 
,[FirstName]
,[LastName]
,[EmailAddress]
,[EmailPromotion]
,[Phone]
,[PasswordHash]
,[PasswordSalt]
,rowguid
,[ModifiedDate]
FROM ##Contacts

UPDATE TOP(1) ##Contacts
SET [Phone]='13699466006'
WHERE FirstName='Gustavo' AND LastName='Achong'

DELETE TOP(1) FROM ##Contacts
WHERE FirstName='Catherine' AND LastName='Abel'

DROP TABLE ##Contacts

GO

--SELECT * FROM tempdb.sys.objects with(nolock) WHERE name like '%Contacts%'

------------table variable----------------------
DECLARE @Contacts TABLE
(
	[ContactID] [int] IDENTITY(1,1) NOT NULL,
	[NameStyle] [bit] NOT NULL,
	[Title] [nvarchar](8) NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[Suffix] [nvarchar](10) NULL,
	[EmailAddress] [nvarchar](50) NULL,
	[EmailPromotion] [int] NOT NULL,
	[Phone] [nvarchar](25) NULL,
	[PasswordHash] [varchar](128) NOT NULL,
	[PasswordSalt] [varchar](10) NOT NULL,
	[AdditionalContactInfo] [nvarchar](300) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL DEFAULT GETDATE()
PRIMARY KEY CLUSTERED 
(
	[ContactID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)

INSERT INTO @Contacts(
[NameStyle]
,[Title] 
,[FirstName]
,[LastName]
,[EmailAddress]
,[EmailPromotion]
,[Phone]
,[PasswordHash]
,[PasswordSalt]
,rowguid
,[ModifiedDate]
)
SELECT 0,N'Mr.',N'Gustavo',N'Achong',N'gustavo0@adventure-works.com',2,N'398-555-0132',
		'GylyRwiKnyNPKbC1r4FSqA5YN9shIgsNik5ADyqStZc=','TVGHbhY=',NEWID(),GETDATE()
UNION ALL
SELECT 0,N'Mr.',N'Catherine',N'Abel',N'catherine0@adventure-works.com',1,N'747-555-0171',
		'zh3goJUbYsPv92k4bVZuJtlLHwuvpQtu6uNcjkKSdF8=','rpyd5Tw=',NEWID(),GETDATE()

INSERT INTO @Contacts(
[NameStyle]
,[Title] 
,[FirstName]
,[LastName]
,[EmailAddress]
,[EmailPromotion]
,[Phone]
,[PasswordHash]
,[PasswordSalt]
,rowguid
,[ModifiedDate]
)
VALUES(1,N'Mr.',N'Gustava',N'Achong',N'gustavo0@adventure-works.com',2,N'398-555-0132',
		'GylyRwiKnyNPKbC1r4FSqA5YN9shIgsNik5ADyqStZc=','TVGHbhY=',NEWID(),GETDATE()),
     ( 1,N'Mr.',N'Catherina',N'Abel',N'catherine0@adventure-works.com',1,N'747-555-0171',
		'zh3goJUbYsPv92k4bVZuJtlLHwuvpQtu6uNcjkKSdF8=','rpyd5Tw=',NEWID(),GETDATE())

SELECT
[NameStyle]
,[Title] 
,[FirstName]
,[LastName]
,[EmailAddress]
,[EmailPromotion]
,[Phone]
,[PasswordHash]
,[PasswordSalt]
,rowguid
,[ModifiedDate]
FROM @Contacts

UPDATE TOP(1) @Contacts
SET [Phone]='13699466006'
WHERE FirstName='Gustavo' AND LastName='Achong'

DELETE TOP(1) FROM @Contacts
WHERE FirstName='Catherine' AND LastName='Abel'


SELECT * FROM @Contacts
--DROP TABLE @Contacts
GO
--http://www.cnblogs.com/zerocc/archive/2012/12/11/2812519.html

-----------------------------------------------------------View---------------------------------------------------------------------------------------------
USE AdventureWorks2008R2
GO

--DROP VIEW [dbo].[UV_Employee]
CREATE VIEW [dbo].[UV_Employee] 
AS 
SELECT 
P.BusinessEntityID,
P.FirstName,
P.MiddleName,
P.LastName,
E.JobTitle ,
E.Gender,
PP.PhoneNumber,
EA.EmailAddress,
P.ModifiedDate
FROM Person.Person AS P WITH(NOLOCK)
INNER JOIN HumanResources.Employee AS E  WITH(NOLOCK)
ON P.BusinessEntityID=E.BusinessEntityID
INNER JOIN Person.PersonPhone AS PP WITH(NOLOCK)
ON P.BusinessEntityID=PP.BusinessEntityID
INNER JOIN Person.EmailAddress AS EA WITH(NOLOCK)
ON EA.BusinessEntityID=P.BusinessEntityID
GO

SELECT COUNT(1) FROM [dbo].[UV_Employee] WITH(NOLOCK)

SELECT --TOP 10 
BusinessEntityID,
FirstName,
MiddleName,
LastName,
JobTitle ,
Gender,
PhoneNumber,
EmailAddress,
ModifiedDate
FROM [dbo].[UV_Employee] WITH(NOLOCK)
WHERE FirstName='Brian' AND LastName='LaMee'


GO

ALTER VIEW [dbo].[UV_Employee]  
AS
SELECT 
P.BusinessEntityID,
P.FirstName,
P.MiddleName,
P.LastName,
E.JobTitle ,
E.Gender,
PP.PhoneNumber,
EA.EmailAddress,
P.ModifiedDate
FROM Person.Person AS P WITH(NOLOCK)
INNER JOIN HumanResources.Employee AS E  WITH(NOLOCK)
ON P.BusinessEntityID=E.BusinessEntityID
INNER JOIN Person.PersonPhone AS PP WITH(NOLOCK)
ON P.BusinessEntityID=PP.BusinessEntityID
INNER JOIN Person.EmailAddress AS EA WITH(NOLOCK)
ON EA.BusinessEntityID=P.BusinessEntityID
WHERE Gender='F'

-----------------------------------------------------------procedure----------------------------------------------------------------------------------------
USE Test
GO


CREATE PROCEDURE dbo.[UP_UpdateEmployeePersonalInfo]
@EmployeeID INT, 
@VacationHours SMALLINT
AS
SET NOCOUNT ON;
BEGIN
BEGIN TRY
		UPDATE dbo.[Employee] 
		SET VacationHours = @VacationHours,
	        ModifiedDate=GETDATE()
		WHERE BusinessEntityID = @EmployeeID;
	END TRY
	BEGIN CATCH
		EXECUTE [dbo].[uspLogError];
	END CATCH;
END;

GO


--SELECT  TOP 10 * FROM [HumanResources].[Employee] 

EXEC dbo.[UP_UpdateEmployeePersonalInfo] 9,4



--S7OVSDB04,ItemMaintainABS,UP_IM_CheckItemCanSetActive_Panda_V4


-----------------------------------------------------------function----------------------------------------------------------------------------------------

USE Test
GO

CREATE FUNCTION [dbo].[UF_ufnGetSalesOrderStatusText](@Status [tinyint])
RETURNS [nvarchar](15) 
AS 
BEGIN
	DECLARE @ret [nvarchar](15);
	SET @ret = 
	CASE @Status
	WHEN 1 THEN 'In process'
	WHEN 2 THEN 'Approved'
	WHEN 3 THEN 'Backordered'
	WHEN 4 THEN 'Rejected'
	WHEN 5 THEN 'Shipped'
	WHEN 6 THEN 'Cancelled'
	ELSE '** Invalid **'
    END;
	RETURN @ret
END;
GO


DECLARE @ret nvarchar(15)= NULL; 
EXEC @ret = dbo.ufnGetSalesOrderStatusText @Status= 5; 
PRINT @ret;

--S7OVSDB04,CodeCenter,[UF_EC_GetNetCharge_ShippingCharge_V12]


USE [AdventureWorks2008R2]
GO

CREATE FUNCTION [dbo].[UP_TEST](@EmployeeID INT,@VacationHours SMALLINT)
RETURNS INT
AS 
BEGIN
		UPDATE [HumanResources].[Employee] 
		SET VacationHours = @VacationHours,
	        ModifiedDate=GETDATE()
		WHERE BusinessEntityID = @EmployeeID;
	RETURN 1
END;
GO


-----------------------------------------------------------Index----------------------------------------------------------------------------------------
USE TEST
GO
--DBCC freeproccache

EXEC sp_spaceused 'arinvt01' --228409                   
/*
SET STATISTICS TIME ON
SET STATISTICS IO ON
SET STATISTICS PROFILE ON
*/
SELECT item,manufactory,ItemCatalog FROM dbo.arinvt01 WITH(NOLOCK) 
WHERE manufactory=1213 AND ItemCatalog='349'

SELECT item,manufactory,ItemCatalog,CurrentPrice FROM dbo.arinvt01 WITH(NOLOCK) WHERE manufactory=1213 AND ItemCatalog='349'

/*
SET STATISTICS TIME OFF
SET STATISTICS IO OFF
SET STATISTICS PROFILE OFF
*/

CREATE INDEX IX_arinvt01_manufactory_ItemCatalog ON dbo.arinvt01
(
 manufactory ASC,
 ItemCatalog ASC
)WITH(FILLFACTOR=90)

--DROP INDEX  IX_arinvt01_manufactory_ItemCatalog ON dbo.arinvt01

--\\10.16.83.45\Dept_Folder\MIS\Sharing&Training\技术\SQL Server and Big Data\Performance Tuning\2015.09.25

-----------------------------------------------------------common select-------------------------------------------------------------------
/*
SELECT [ALL|DISTINCT|TOP(n)] select_list
FROM tablename1[,...,tablenameN]
[JOIN join_condition}
[WHERE search_conditions]
[GROUP BY group_by_list]
[HAVING search_conditions]
[ORDER BY order_list[ASC|DESC]]
*/

----set statistics profile off
----set statistics io off
----set statistics time off

USE Test
GO

--count
SELECT COUNT(1) FROM  dbo.Product WITH(NOLOCK) --507

--top
SELECT TOP 10 * FROM  dbo.Product WITH(NOLOCK)
 --not recommended

--null
SELECT 
ProductID,
Name,
ProductNumber,
Color,
SafetyStockLevel,--Minimum inventory quantity
ReorderPoint,--Inventory level that triggers a purchase order or work order.
StandardCost,--Standard cost of the product
ListPrice,---Selling price.
SellStartDate,--Date the product was available for sale.
SellEndDate, --Date the product was no longer available for sale.
DiscontinuedDate,--Date the product was discontinued.
ModifiedDate--Date and time the record was last updated.
FROM dbo.Product WITH(NOLOCK)
--WHERE Color IS NULL
WHERE Color = NULL
--WHERE Color != NULL


--distinct  column:name:basketball--------
SELECT 
DISTINCT Name,--,
--ProductID,
ProductNumber
--Color,
--SafetyStockLevel,--Minimum inventory quantity
--ReorderPoint,--Inventory level that triggers a purchase order or work order.
--StandardCost,--Standard cost of the product
--ListPrice,---Selling price.
--SellStartDate,--Date the product was available for sale.
--SellEndDate, --Date the product was no longer available for sale.
--DiscontinuedDate,--Date the product was discontinued.
--ModifiedDate--Date and time the record was last updated.
FROM dbo.Product WITH(NOLOCK)
WHERE SellStartDate IS NOT NULL 
	  AND (SellEndDate IS  NULL OR SellEndDate >GETDATE()) 
	  AND Name LIKE 'b%'
	 -- AND Name LIKE '%b'
	 -- AND Name LIKE '%b%'
	  --AND Name NOT LIKE 'b%'
	 -- AND Name LIKE 'b[^a-b]%'
ORDER BY Name DESC,ProductNumber ASC

--alias,join,
SELECT 
--P.Name AS ProductName,
--P.ProductNumber,
V.Name AS VendorName,
COUNT(P.ProductID) AS TotalProduct,
SUM(PV.OnOrderQty) AS TotalOnorderQty
--V.CreditRating AS VendorCreditRating,
--PV.OnOrderQty
FROM dbo.Product AS P WITH(NOLOCK)
INNER JOIN dbo.ProductVendor AS PV WITH(NOLOCK)
ON P.ProductID=PV.ProductID
INNER JOIN dbo.Vendor AS V WITH(NOLOCK)
ON PV.BusinessEntityID=V.BusinessEntityID
WHERE P.SellStartDate IS NOT NULL 
	AND (P.SellEndDate IS  NULL OR P.SellEndDate >GETDATE()) 
	AND V.ActiveFlag=1
    AND OnOrderQty IS NOT NULL
GROUP BY V.Name 
HAVING SUM(PV.OnOrderQty)>50
ORDER BY TotalProduct DESC,TotalOnorderQty DESC


---subquery
USE TEST
GO
SELECT 
Name,
Name,
ListPrice
FROM dbo.Product  WITH(NOLOCK)
WHERE ListPrice IN 
(
   SELECT MAX(ListPrice) FROM dbo.Product WITH(NOLOCK)
)


USE AdventureWorks2008R2
GO

SELECT DISTINCT SOH.PurchaseOrderNumber
FROM Sales.SalesOrderHeader AS SOH WITH(NOLOCK)
WHERE EXISTS(
	SELECT SalesOrderID FROM Sales.SalesOrderDetail AS SOD WITH(NOLOCK)
	WHERE UnitPrice BETWEEN 1000 AND 2000 
	AND SOH.SalesOrderID=SOD.SalesOrderID
)


----not in  and not exists

IF OBJECT_ID('tempdb..#temp1') IS NOT NULL
	DROP TABLE #temp1

CREATE TABLE #temp1
(
 id INT  
)

IF OBJECT_ID('tempdb..#temp2') IS NOT NULL
	DROP TABLE #temp2
CREATE TABLE  #temp2
(
 id INT 
)

GO
INSERT INTO #temp1
SELECT 3

INSERT INTO #temp2
SELECT 1
UNION ALL
SELECT 2
UNION ALL
SELECT NULL

SELECT * FROM #temp1
SELECT * FROM #temp2

SELECT * FROM #temp1 
WHERE id NOT IN (SELECT id FROM #temp2)


SELECT * FROM #temp1 AS a
WHERE NOT EXISTS(SELECT id FROM #temp2 AS b WHERE a.id=b.id)

-----performance
USE AdventureWorks2008R2
GO
SELECT SalesOrderID,RevisionNumber, OrderDate,[Status]
FROM Sales.SalesOrderHeader WITH(NOLOCK)
WHERE SalesOrderID NOT IN (SELECT ProductID FROM Sales.SalesOrderDetail WITH(NOLOCK))


SELECT  SalesOrderID,RevisionNumber, OrderDate,[Status] 
FROM Sales.SalesOrderHeader  AS SOH WITH(NOLOCK)
WHERE NOT EXISTS (SELECT ProductID FROM Sales.SalesOrderDetail AS SOD WITH(NOLOCK) 
				 WHERE SOH.SalesOrderID=SOD.ProductID)


/*
http://www.cnblogs.com/CareySon/p/4955123.html
*/


---------------join


IF OBJECT_ID('tempdb..#temp1') IS NOT NULL
	DROP TABLE #temp1

CREATE TABLE #temp1
(
 id INT ,
 a INT 
)

IF OBJECT_ID('tempdb..#temp2') IS NOT NULL
	DROP TABLE #temp2
CREATE TABLE  #temp2
(
 id INT ,
 b INT 
)

INSERT INTO #temp1
SELECT 1,1
UNION ALL
SELECT 2,2


INSERT INTO #temp2
SELECT 1,1
UNION ALL
SELECT 3,3

SELECT * FROM  #temp1
SELECT * FROM  #temp2

SELECT a.id AS a_id,a.a,b.id AS b_id,b.b 
FROM #temp1 AS a 
INNER JOIN #temp2 AS b
ON a.id=b.id


SELECT  a.id AS a_id,a.a,b.id AS b_id,b.b 
FROM #temp1 AS a 
LEFT JOIN #temp2 AS b
ON a.id=b.id


SELECT  a.id AS a_id,a.a,b.id AS b_id,b.b 
FROM #temp1 AS a 
LEFT OUTER JOIN #temp2 AS b
on a.id=b.id


SELECT  a.id AS a_id,a.a,b.id AS b_id,b.b  
FROM #temp1 AS a 
RIGHT JOIN #temp2 AS b
on a.id=b.id


SELECT a.id AS a_id,a.a,b.id AS b_id,b.b  
FROM #temp1 AS a 
RIGHT OUTER JOIN #temp2 AS b
on a.id=b.id

SELECT a.id AS a_id,a.a,b.id AS b_id,b.b  
FROM #temp1 AS a 
FULL OUTER JOIN #temp2 AS b
on a.id=b.id

SELECT a.id AS a_id,a.a,b.id AS b_id,b.b  
FROM #temp1 AS a 
CROSS JOIN #temp2 AS b


-------------------------------------Dynamic SQL----------------------------------------------------------
/*
1)MSSQL提供了两种动态执行SQL语句的命令：EXEC和sp_executesql;
2)通常，sp_executesql更具优势，它提供了输入输出接口，能够重用执行计划，
  编写的代码更安全。除非您有令人信服的理由使用EXEC，否侧尽量使用sp_executesql
3)EXEC和sp_executesql的使用
*/
-----------Demo 1

DECLARE @sql NVARCHAR(MAX)
		,@TableName VARCHAR(30)
		,@top INT
SET @TableName=N'product'
SET @top=2
SET @sql=N'SELECT TOP '+CAST(@top AS NVARCHAR(4))+N' * 
			FROM sys.tables WITH (NOLOCK)
			WHERE name = '''+@TableName+''''
PRINT @sql


EXEC(@sql)
GO

--推荐写法
DECLARE @sql NVARCHAR(MAX)
		,@TableName VARCHAR(30)
		,@top INT
SET @TableName=N'product'
SET @top=2
SET @sql=N'SELECT TOP (@top) * 
			FROM sys.tables WITH (NOLOCK)
			WHERE name =@TableName'
PRINT @sql
EXEC sp_executesql @sql
					,N'@TableName VARCHAR(30)
						,@top INT'
					,@TableName
					,3


-----------demo 2
DECLARE @sql NVARCHAR(MAX)
       ,@type VARCHAR(5)
       ,@crdate DATETIME

SET @type=N'u'
SET @crdate='2004-10-12 17:37:17.437'
SET @sql=N'
SELECT top 5 * 
FROM sys.sysobjects WITH (NOLOCK)
WHERE 1=1'

IF @type IS NOT NULL AND @type<>''
BEGIN
  SET @sql=@sql+' AND type='''+@type+''''
END
  

IF @crdate IS NOT NULL
BEGIN
  SET @sql=@sql+' AND crdate>='''+CONVERT(CHAR(20),@crdate,120)+''''
END

EXEC(@sql)
EXEC sp_executesql @sql
GO

--推荐写法
DECLARE @sql NVARCHAR(MAX)
       ,@type VARCHAR(5)
       ,@crdate DATETIME

SET @type=N'u'
SET @crdate='2004-10-12 17:37:17.437'
SET @sql=N'
select top 5 * 
from sys.sysobjects with (Nolock)
WHERE 1=1'

IF @type IS NOT NULL AND @type<>''
BEGIN
    SET @sql=@sql+' AND type=@type'
END

IF @crdate IS NOT NULL
BEGIN
    SET @sql=@sql+' AND crdate>=@crdate'
END

PRINT @sql
EXEC sp_executesql @sql
                  ,N'@type sysname
                     ,@crdate datetime'
                  ,@type
                  ,@crdate

select top 5 * 
from sys.sysobjects with (Nolock)
where crdate>='2004-10-12 17:37:17.437' and type='U'


--compare EXEC and sp_executesql
--demo3

DECLARE @sql1 NVARCHAR(max)
DECLARE @id NVARCHAR(10)
	SELECT @id='1'
SELECT @sql1=N'SELECT top(1)  * from sys.databases with(nolock) where database_id='+@id+''
EXEC (@sql1)
	SELECT @id='2'
SELECT @sql1=N'SELECT top(1)  * from sys.databases with(nolock) where database_id='+@id+''
EXEC (@sql1)
	SELECT @id='3'
SELECT @sql1=N'SELECT top(1)  * from sys.databases with(nolock) where database_id='+@id+''
EXEC (@sql1)


DECLARE @sql2 NVARCHAR(max)
SELECT @sql2=N'SELECT top(1)  * from sys.databases with(nolock) where database_id=@id'
EXEC sp_executesql @sql2,N'@id int',@id=1
EXEC sp_executesql @sql2,N'@id int',@id=2
EXEC sp_executesql @sql2,N'@id int',@id=3


--DBCC freeproccache
--SELECT 
--cacheobjtype,objtype,usecounts ,refcounts,sql 
-- FROM sys.syscacheobjects WITH(NOLOCK)
--WHERE sql NOT LIKE '%cach%' 
--AND  sql LIKE '%SELECT top(1)  * from sys.databases with(nolock) where database_id%'

select c.plan_handle,
 c.usecounts,
c.cacheobjtype,
c.objtype,
t.text,
qp.query_plan,
c.size_in_bytes as '对象所耗费的字节'
from sys.dm_exec_cached_plans   c with(nolock)
cross apply sys.dm_exec_sql_text(c.plan_handle) t 
cross apply sys.dm_exec_query_plan(c.plan_handle) qp  
where t.text like '%SELECT top(1)  * from sys.databases with(nolock) where database_id%'   



------sp_executesql 输出参数
DECLARE @sql NVARCHAR(max)
       ,@type VARCHAR(5)
		,@countOUT INT
SET @sql='SELECT @countOUT=COUNT(1)
		FROM sys.objects WITH (NOLOCK)
		WHERE type=@type'

EXEC sp_executesql @sql
					,N'@type sysname
						,@countOUT INT OUTPUT'
					,'U'
					,@countOUT OUTPUT
SELECT  @countOUT


------sp_executesql安全
DECLARE @sql NVARCHAR(max)
       ,@type VARCHAR(5)

SET @sql=N'
select top 5 * 
from sys.sysobjects with (Nolock)
WHERE 1=1'

----set @type=N'u'
SET @type=N'u'''+' OR 1=1;EXEC master.dbo.xp_create_subdir ''C:\temp''--'----不安全的代码

EXEC(@sql+' AND type='''+@type+'''')
PRINT @sql+' AND type='''+@type+''''
SET @type=N'P'
EXEC(@sql+' AND type='''+@type+'''')

SET @sql=N'
select top 5 * 
from sys.sysobjects with (Nolock)
WHERE type=@type'

exec sp_executesql @sql
                  ,N'@type sysname'
                  ,'U'

exec sp_executesql @sql
                  ,N'@type sysname'
                  ,'P'


--Question:
/*
Demo中的变量@sql的数据类型使用VARCHAR(MAX)可以吗？
*/









