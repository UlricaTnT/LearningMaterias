
--===================================习题一=========================================

/*================================================================================  
Server:    10.16.75.20  
DataBase:  Test  
Author:    Ulrica.Q.Chen
Object:    Exercise
Version:   1.0  
Date:      26/07/2017
Content:   Exercise
----------------------------------------------------------------------------------  
Modified history:      
      
Date        Modified by    VER    Description      
------------------------------------------------------------  
28/07/2017  Ulrica.Q.Chen  1.0     Create.  
================================================================================*/ 
USE Test
GO

--题目一：创建SCHEMA
CREATE SCHEMA bank_uc07

--BYDBA 5分

--题目二：创建客户表，借记卡表，交易记录表 

--创建Customer表
CREATE TABLE bank_uc07.UlricaCustomer_uc07
(
	[ID]					INT IDENTITY(1,1) NOT NULL ,
	[CustomerID]			CHAR(18) UNIQUE  NOT NULL,  --添加唯一标识 --BYDBA 唯一约束命名不规范
	[Name]					NVARCHAR(50) NOT NULL,
	[Phone]					VARCHAR(11) NOT NULL,
	[Address]				NVARCHAR(128) NOT NULL,
	[CreateTime]			DATETIME NOT NULL CONSTRAINT DF_UlricaCustomer_uc07_CreateTime DEFAULT GETDATE(),  --默认获取当前时间
	[LastEditDate]			DATETIME NOT NULL CONSTRAINT DF_UlricaCustomer_uc07_LastEditDate DEFAULT GETDATE(), 
	[Remarks]				NVARCHAR(128),
CONSTRAINT [PK_UlricaCustomer_uc07] PRIMARY KEY CLUSTERED  --设置主键ID
(
    [ID] ASC
)WITH (FILLFACTOR=90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UlricaCustomer_uc07_ID] ON bank_uc07.UlricaCustomer_uc07  --创建索引  --BYDBA 一般已经是主键列就没有必要建非聚集索引了,主键列默认就是聚集索引.
( 
        [ID] 
)WITH (FILLFACTOR = 90) 
Go

--创建Debit_Card表
CREATE TABLE bank_uc07.UlricaDebit_Card_uc07
(
	[ID]					INT IDENTITY(1,1) NOT NULL,
	[CustomerID]			CHAR(18) NOT NULL,  
	[Password]				VARCHAR(32) NOT NULL,
	[Balance]				DECIMAL(12,2) NOT NULL,
	[IsVIP]					BIT NOT NULL,
	[Status]				BIT NOT NULL,
	[CreateTime]			DATETIME NOT NULL CONSTRAINT DF_UlricaDebit_Card_uc07_CreateTime DEFAULT GETDATE(),  
	[LastEditDate]			DATETIME NOT NULL CONSTRAINT DF_UlricaDebit_Card_uc07_LastEditDate DEFAULT GETDATE(),  
	[Remarks]				NVARCHAR(128),
CONSTRAINT [PK_UlricaDebit_Card_uc07] PRIMARY KEY CLUSTERED   
(
    [ID] ASC
)WITH (FILLFACTOR=90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UlricaDebit_Card_uc07_ID] ON bank_uc07.UlricaDebit_Card_uc07    --BYDBA 一般已经是主键列就没有必要建非聚集索引了,主键列默认就是聚集索引.
( 
        [ID] 
)WITH (FILLFACTOR = 90) 
Go

--创建Transactions表
CREATE TABLE bank_uc07.UlricaTransactions_uc07
(
	[TransactionNumber]		INT IDENTITY(1,1) NOT NULL ,
	[Card_ID]				INT FOREIGN KEY REFERENCES bank_uc07.UlricaDebit_Card_uc07(ID) NOT NULL,  --将银行卡号作为外键  --BYDBA 一般我们不建议使用外键,数据一致性交给程序设计者来做.
	[Type]					NVARCHAR(16) NOT NULL,
	[Amount]				DECIMAL(12,2) NOT NULL,
	[Indate]				DATETIME NOT NULL CONSTRAINT DF_UlricaTransactions_uc07_Indate DEFAULT GETDATE(),  
	[Status]				BIT NOT NULL,
	[Remarks]				NVARCHAR(128),
CONSTRAINT [PK_UlricaTransactions_uc07] PRIMARY KEY CLUSTERED  
(
    [TransactionNumber] ASC
)WITH (FILLFACTOR=90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UlricaTransactions_uc07_TransactionNumber] ON bank_uc07.UlricaTransactions_uc07   --BYDBA 一般已经是主键列就没有必要建非聚集索引了,主键列默认就是聚集索引.
( 
        [TransactionNumber] 
)WITH (FILLFACTOR = 90) 
Go

--BYDBA 16分 表结构都成功创建(7)+主键设置(3)+IDENTITY属性(2)+默认值约束(3)+CHECK约束(1)+索引(0)

--题目三：初始化数据到表Customer
INSERT INTO bank_uc07.UlricaCustomer_uc07 
(
	[CustomerID],
	[Name],
	[Phone],
	[Address])
VALUES 
('610524198807330846',N'张三','13438995253',N'四川省成都市高新区天府五街1888号'),
('610524198807340846',N'李四','13438995253',N'四川省成都市高新区天府五街1888号'),
('610524198807340842',N'王五','13438995253',N'四川省成都市高新区天府五街1888号'),

('610524198807330811',N'赵六','13438995253',N'四川省成都市高新区天府五街1888号'),
('610524198807340812',N'田七','13434995253',N'四川省成都市高新区天府五街1880号'),
('610524198807340813',N'路人甲','13424995253',N'四川省成都市高新区天府五街') 

--BYDBA 5分 INSERT语法正确(2)+中文的处理(3)

--题目四：查询客户信息
SELECT TOP 100 
		A.[Name],A.[CustomerID],A.[Phone],A.[Address],
		SUM(B.[Balance])				AS TotalBanlance,
		SUM(C.[Amount])					AS TotalTransactionAmount,
		COUNT(C.[TransactionNumber])	AS TransactionCount
FROM 
		bank_uc07.UlricaCustomer_uc07		AS A WITH (NOLOCK)
INNER JOIN 
		bank_uc07.UlricaDebit_Card_uc07		AS B WITH (NOLOCK)
ON 
		A.[CustomerID]=B.[CustomerID]
INNER JOIN  
		bank_uc07.UlricaTransactions_uc07	AS C WITH (NOLOCK)
ON 
		B.[ID]=C.[Card_ID]
		AND C.[Status]=1
		AND GETDATE() < DATEADD(DAY, 6*30, C.[Indate])
GROUP BY
		A.[Name],
		A.[CustomerID],
		A.[Phone],
		A.[Address]
ORDER BY 
		SUM(C.[Amount])	DESC,
		COUNT(C.TransactionNumber) DESC

--BYDBA 17分 正确显示要求的信息(12)+有列别名(5)



--题目五：实现转账功能的存储过程

/*===========================Create SP=================================
**DB:Test
**Type:Procedure
**ObjectName:bank_uc07.Up_Test_InnerBankTransfer
**team:MIS
**Creater:Ulrica.Q.Chen
**Create date:26/07/2017
**Modify by:Ulrica.Q.Chen
**Modify date:28/07/2017
**Function: Inner bank transfering
**Variable:N/A
=====================================================================*/
USE Test
GO

CREATE PROC bank_uc07.Up_Test_InnerBankTransfer

@SourceID		INT,
@Money			DECIMAL(12,2),
@TargetID		INT,
@Name			NVARCHAR(50)

AS
SET NOCOUNT ON;--不返回受 Transact-SQL 语句影响的行数

DECLARE
	@__$tran_count			int,
	@__$tran_name_save		varchar(32),
	@__$tran_count_save		int,
	
	@SourceIDStatus			BIT,
	@Balance				DECIMAL(12,2),
	@TargetIDStatus			BIT,
	@TargetName				NVARCHAR(50),
	@Remark					NVARCHAR(128)

SELECT
	@__$tran_count = @@TRANCOUNT,
	@__$tran_name_save = '__$save_'
						+ CONVERT(varchar(11), ISNULL(@@PROCID, -1))
						+ '.'
						+ CONVERT(varchar(11), ISNULL(@@NESTLEVEL, -1)),
	@__$tran_count_save = 0
;
BEGIN TRY;

	IF	@__$tran_count = 0 --如果没有嵌套事务，则开启新的事务 --BYDBA 事务一般我们坚持最小化，事务对查询是没有作用的，所以我们一般在更新/删除/修改表数据之前开启事务。 
		BEGIN TRAN; 

	ELSE

	BEGIN;
		SAVE TRAN @__$tran_name_save;--如果嵌套了事务，则设置还原点
		SET @__$tran_count_save = @__$tran_count_save + 1;--还原点数量+1
	END;

	IF @SourceIDStatus=1 --转出卡状态正常   --BYDBA 没看到你对这个值赋值？
		BEGIN 
			SELECT @Balance=Balance
			FROM bank_uc07.UlricaDebit_Card_uc07			AS A WITH(NOLOCK)
			WHERE ID=@SourceID
			
			IF @Balance>=@Money	--余额大于或等于转款数目
				BEGIN
					SELECT 
							@TargetName=B.[Name],
							@TargetIDStatus=C.[Status]
					FROM	
							bank_uc07.UlricaCustomer_uc07	AS B
					INNER JOIN	
							bank_uc07.UlricaDebit_Card_uc07 AS C
					ON
							B.[CustomerID]=C.[CustomerID]
							AND C.[ID]=@TargetID

					IF (@TargetIDStatus=1 AND @TargetName=@Name)  --对方账号和姓名存在且正常
						BEGIN 
							UPDATE bank_uc07.UlricaDebit_Card_uc07
							SET Balance=(Balance-@Money),LastEditDate=GETDATE()
							WHERE ID=@SourceID

							UPDATE bank_uc07.UlricaDebit_Card_uc07
							SET Balance=(Balance+@Money),LastEditDate=GETDATE()
							WHERE ID=@TargetID
					
							INSERT INTO bank_uc07.UlricaTransactions_uc07([Card_ID],[Type],[Amount],[Indate],[Status],[Remarks])
							VALUES(@SourceID,N'支出',@Money,GETDATE(),1,N'转出成功')

							INSERT INTO bank_uc07.UlricaTransactions_uc07([Card_ID],[Type],[Amount],[Indate],[Status],[Remarks])
							VALUES(@TargetID,N'存入',@Money,GETDATE(),1,N'转入成功')

						END

					ELSE --收款人不存在或收款人账号异常
						BEGIN

						SET @Remark=N'收款人不存在或收款人账号异常'

						INSERT INTO bank_uc07.UlricaTransactions_uc07([Card_ID],[Type],[Amount],[Indate],[Status],[Remarks])
						VALUES (@SourceID,N'支出',0,GETDATE(),0,@Remark)

						END
				END
			ELSE --余额不足转款数目
				BEGIN

				SET	@Remark=N'账户余额不足'

				INSERT INTO bank_uc07.UlricaTransactions_uc07([Card_ID],[Type],[Amount],[Indate],[Status],[Remarks])
					VALUES (@SourceID,N'支出',0,GETDATE(),0,@Remark)

				END
		END
	ELSE --转出卡状态异常
		BEGIN
			
			SET	@Remark=N'此账户状态异常'

			INSERT INTO bank_uc07.UlricaTransactions_uc07([Card_ID],[Type],[Amount],[Indate],[Status],[Remarks])	
			VALUES (@SourceID,N'支出',0,GETDATE(),0,@Remark)	
	
			END	

	COMMIT TRAN

END TRY

BEGIN CATCH

	ROLLBACK TRAN @__$tran_name_save  --回滚到还原点
	SET @__$tran_count_save = @__$tran_count_save - 1;  --还原点数量-1

/*
IF XACT_STATE() <> 0                      --BYDBA 对事务的异常处理要这样处理。你上面的处理只会在你的这个sp被其他带有事务的程序调用时才是对的，但没有这种调用就会出问题。
	BEGIN;
		IF @__$tran_count = 0
			ROLLBACK TRAN;
		-- XACT_STATE 为 -1 时, 不能回滚到事务保存点, 这种情况留给外层调用者做统一的事务回滚
		ELSE IF XACT_STATE() = 1
		BEGIN;
			WHILE @__$tran_count_save > 0
			BEGIN;
				ROLLBACK TRAN @__$tran_name_save;
				SET @__$tran_count_save = @__$tran_count_save - 1;
			END;
		END;
	END;
*/
--BYDBA 这里应该把异常信息也记录到交易表中，只是交易是失败的

END CATCH;
GO

--BYDBA 22分 存储过程语法正确(5)+实现转账功能(4)+事务的恰当处理(4)+异常处理恰当(4)+存储过程参数类型与表中对应字段参数类型保持一致(5)


--题目六：实现转账
DECLARE
	@SourceID		INT,
	@Money			DECIMAL(12,2),
	@TargetID		INT,
	@Name			NVARCHAR(50)
 
SET @SourceID=6214921603447611
SET	@Money=666
SET @TargetID=6214921603447622
SET	@Name=N'田七'

EXEC bank_uc07.[Up_Test_InnerBankTransfer] @SourceID,@Money,@TargetID,@Name

--BYDBA 3分 成功实现转账(3)+获取返回值(0)

--题目七：字符串的拆分
USE Test
GO
--建立一张用来存储字符串的表
CREATE TABLE bank_uc07.UlricaSplitSrting_uc07
(
	[ID]				INT IDENTITY(1,1) NOT NULL,
	[Items]				VARCHAR(32) NOT NULL, 
	[SplitTime]			DATETIME NOT NULL CONSTRAINT DF_UlricaSplitSrting_uc07_SplitTime DEFAULT GETDATE(),  --默认获取当前时间
CONSTRAINT [PK_UlricaSplitSrting_uc07] PRIMARY KEY CLUSTERED  --设置主键为ID
(
	[ID] ASC
)WITH (FILLFACTOR=90) ON [PRIMARY]
) ON [PRIMARY]
GO

DECLARE	@Str  NVARCHAR(1000) 
DECLARE @Spliter VARCHAR(2)
SET	@Str = '01;03;02;06;08;04;01;03;09;;20;12;1;24;25;87'
SET @Spliter=';'


IF OBJECT_ID('tempdb..#TEMP_00') IS NOT NULL
	DROP TABLE #TEMP

CREATE TABLE #TEMP(
	[Items] VARCHAR(32) NOT NULL)

BEGIN
	DECLARE	@i INT
	SET		@Str=RTRIM(LTRIM(@Str))
	SET		@i=CHARINDEX(@Spliter,@Str)

	WHILE @i>=1
	BEGIN 
		INSERT INTO #TEMP([Items]) VALUES(LEFT(@Str,@i-1))
		SET @Str =SUBSTRING(@Str,@i+1,LEN(@Str)-@i)
		SET @i=CHARINDEX(@Spliter,@Str)
	END

	IF @Str <> '/'  --将最后的数字插入表中
	INSERT INTO #TEMP([Items]) VALUES(@Str)  

END

INSERT INTO bank_uc07.UlricaSplitSrting_uc07([Items])
SELECT		DISTINCT [Items]		
FROM		#TEMP	AS A WITH(NOLOCK)
WHERE		[Items]<>''   --BYDBA 题目中并没有要求不能有空值。

DROP TABLE #TEMP


SELECT * FROM bank_uc07.UlricaSplitSrting_uc07

--BYDBA 19分 实现字符串拆分功能(14)+去掉重复值(5)



--===================================习题二=========================================

/*================================================================================  
Server:    10.16.75.20  
DataBase:  Test  
Author:    Ulrica.Q.Chen
Object:    Exercise
Version:   1.0  
Date:      27/07/2017
Content:   Exercise
----------------------------------------------------------------------------------  
Modified history:      
      
Date        Modified by    VER    Description      
------------------------------------------------------------  
29/07/2017  Ulrica.Q.Chen  1.0     Create.  
================================================================================*/ 

--题目一：规范的T-SQL写法
SELECT  A.[Name],
		ISNULL(A.[SizeUnitMeasureCode],'CM') AS SizeUnitMeasureCode 
FROM	
		AdventureWorks.Production.product AS A
INNER JOIN
		AdventureWorks.Sales.SalesOrderDetail AS B 
ON	
		A.[Productid]=B.[Productid] 
		AND A.[ModifiedDate]>'2012-06-25 00:00:00'

--BYDBA 16分 区分大写小(2)+格式化对齐(2)+格式化换行(2)+代码开始USE DB(0)+表查询允许脏读WITH(NOLOCK)(0)+CASE WHEN 用ISNULL简化(4)+WHERE联接写法改确切INNER JOIN (6)

--题目二：同步链

--对于存在同步练的表的增删改和结构更改，都必须在发布端（源头）进行操作。所以，需要在ServerA上运行。

ALTER TABLE dbo.tb_item
ADD [state] INT  NULL  CONSTRAINT DF_tb_item_state DEFAULT (0)

UPDATE	dbo.tb_item
SET		[state]= 0
WHERE	[state] IS NULL

ALTER TABLE dbo.tb_item
ALTER COLUMN [state] INT  NOT NULL

--BYDBA 20分 实现添加列的脚本(5)+采用分批处理(0)+正确添加默认值约束(5)+约束命名是否规范(5)+选择正确的Server执行(5)


--题目三：最优的查询方式

DECLARE @ItemNumber NCHAR(25)
SET		@ItemNumber='00-000-006R'

SELECT	A.ItemNumber,A.ProductTitle,A.ProductName,A.ManualProductName 
FROM	dbo.ItemDescription AS A WITH (NOLOCK)
WHERE	A.ItemNumber=CONVERT(CHAR,@ItemNumber)  --BYDBA 这里最好明确指定CHAR的长度

--BYDBA	15分 避免隐式转换（10）+并发考虑加WITH(NOLOCK)(5)


--题目四：优化脚本
USE ItemMaintainNewegg
GO

IF EXISTS (SELECT TOP 1 1 FROM dbo.Priceinfo WITH (NOLOCK))     
BEGIN
	SELECT	item
	INTO	#TEMP_Item
	FROM	ItemSKU.[dbo].arinvt01 WITH (NOLOCK)
	WHERE	descrip LIKE 'Memor xxxx|JACKTEST0723002001 R%'

	SELECT	itemNo,productName,unitPrice,rebate
	FROM	dbo.Priceinfo WITH (NOLOCK)
	WHERE	itemNo IN(
					SELECT  item
					FROM	#TEMP_Item)

	SELECT	Item,Model,CatKeywords,ManuKeywords
	FROM	dbo.advsItems WITH (NOLOCK)
	WHERE	Item IN(
					SELECT  item
					FROM	#TEMP_Item)

	SELECT	ItemNumber,[Priority],ItemType,ImageSize,Memo
	FROM	dbo.EC_NFHomepage WITH (NOLOCK)
	WHERE	ItemNumber IN(
					SELECT  item
					FROM	#TEMP_Item)
END 

--BYDBA 15分 将条件in中的数据先缓存在表变量或者临时表中来避免多次查询正式大表(15)


--题目五：数据归档

DECLARE
	@__$tran_count			INT,
	@__$tran_name_save		VARCHAR(32),
	@__$tran_count_save		INT,

	@CurrentYear			INT,
	@StartYear				INT,
	@ThisYear				DATE,

	@CurrentYearStr			VARCHAR(4),  
	@CurrentYearFirstDay	DATE,
	@CurrentYearLastDay		DATE,
	@CreateTable			NVARCHAR(MAX),
	@TableName				VARCHAR(200)

SELECT
	@__$tran_count =	@@TRANCOUNT,
	@__$tran_name_save = '__$save_'
						+ CONVERT(varchar(11), ISNULL(@@PROCID, -1))
						+ '.'
						+ CONVERT(varchar(11), ISNULL(@@NESTLEVEL, -1)),
	@__$tran_count_save = 0,

	@CurrentYear=		DATEPART(YEAR,DATEADD(YEAR,-1,GETDATE())),  --2016年--数字形式
	@StartYear=			2000,  --从2000年开始--数字形式
	@ThisYear=			DATEPART(YEAR,GETDATE()) --2017年,数字型式

BEGIN TRY

	IF	@__$tran_count = 0 --如果没有嵌套事务，则开启新的事务
		BEGIN TRAN;
	ELSE
	BEGIN;
		SAVE TRAN @__$tran_name_save;--如果嵌套了事务，则设置还原点
		SET @__$tran_count_save = @__$tran_count_save + 1;--还原点数量+1
	END;	

	WHILE ( @StartYear <= @CurrentYear )
	BEGIN 

		SET			@CurrentYearStr=CONVERT(VARCHAR(4),@CurrentYear)  --2016年--字符型式
		SET			@CurrentYearFirstDay=CONVERT(VARCHAR(4),@CurrentYear) --2016年，字符型式
		SET			@CurrentYearLastDay=DATEADD(DAY,-1,(DATEADD(YEAR,1,(CONVERT(VARCHAR(4),@CurrentYear))))) --2016年最后一天，数字形式
		SET			@TableName ='bank_uc07.Transactions_'+CONVERT(varchar(4),@CurrentYear)

		SET			@CreateTable=
		'IF  (OBJECT_ID('''+@TableName+''') IS NULL )
			CREATE TABLE '+@TableName+'(
					[TransactionNumber]		INT IDENTITY(1,1) NOT NULL ,
					[Card_ID]				INT FOREIGN KEY REFERENCES bank_uc07.UlricaDebit_Card_uc07(ID) NOT NULL,  
					[Type]					NVARCHAR(16) NOT NULL,
					[Amount]				DECIMAL(12,2) NOT NULL,
					[Indate]				DATETIME NOT NULL CONSTRAINT DF_@TableName_Indate DEFAULT GETDATE(),  
					[Status]				BIT NOT NULL,
					[Remarks]				NVARCHAR(128),
					[LastEditDate]			DATETIME NOT NULL CONSTRAINT DF_@TableName_LastEditDate DEFAULT GETDATE(),
			CONSTRAINT [PK_UlricaTransactions_uc07] PRIMARY KEY CLUSTERED  
			(
				[TransactionNumber] ASC
			)WITH (FILLFACTOR=90) ON [PRIMARY]
			) ON [PRIMARY] 
			
			DECLARE		@CurrentYearFirstDay	DATE
			DECLARE		@CurrentYearLastDay		DATE 
			SET			@CurrentYearFirstDay=CONVERT(VARCHAR(4),'+@CurrentYearStr+')
			SET			@CurrentYearLastDay=DATEADD(DAY,-1,(DATEADD(YEAR,1,(CONVERT(VARCHAR(4),'+@CurrentYearStr+')))))
			
			INSERT INTO '+@TableName+'([TransactionNumber],[Card_ID],[Type],[Amount],[Indate],[Status],[Remarks])
			SELECT		TransactionNumber,Card_ID,Type,Amount,Indate,Status,Remarks
			FROM		bank_uc07.UlricaTransactions_uc07 AS A WITH(NOLOCK)
			WHERE		Indate BETWEEN @CurrentYearFirstDay AND @CurrentYearLastDay'

			EXEC	sp_executesql @CreateTable
			SET		@CurrentYear=@CurrentYear-1   --2016->2015
	END	

	DELETE FROM		bank_uc07.UlricaTransactions_uc07	--删除原表中的数据
	WHERE			Indate < @ThisYear
	
	COMMIT

END TRY

BEGIN CATCH

	ROLLBACK TRAN	@__$tran_name_save  --回滚到还原点
	SET				@__$tran_count_save = @__$tran_count_save - 1;  --还原点数量-1

END CATCH;
GO

--BYDBA 10分 功能实现(8)+方法适当,考虑严谨(2)+分批处理(0)