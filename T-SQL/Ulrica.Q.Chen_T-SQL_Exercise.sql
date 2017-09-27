
--===================================ϰ��һ=========================================

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

--��Ŀһ������SCHEMA
CREATE SCHEMA bank_uc07

--BYDBA 5��

--��Ŀ���������ͻ�����ǿ������׼�¼�� 

--����Customer��
CREATE TABLE bank_uc07.UlricaCustomer_uc07
(
	[ID]					INT IDENTITY(1,1) NOT NULL ,
	[CustomerID]			CHAR(18) UNIQUE  NOT NULL,  --���Ψһ��ʶ --BYDBA ΨһԼ���������淶
	[Name]					NVARCHAR(50) NOT NULL,
	[Phone]					VARCHAR(11) NOT NULL,
	[Address]				NVARCHAR(128) NOT NULL,
	[CreateTime]			DATETIME NOT NULL CONSTRAINT DF_UlricaCustomer_uc07_CreateTime DEFAULT GETDATE(),  --Ĭ�ϻ�ȡ��ǰʱ��
	[LastEditDate]			DATETIME NOT NULL CONSTRAINT DF_UlricaCustomer_uc07_LastEditDate DEFAULT GETDATE(), 
	[Remarks]				NVARCHAR(128),
CONSTRAINT [PK_UlricaCustomer_uc07] PRIMARY KEY CLUSTERED  --��������ID
(
    [ID] ASC
)WITH (FILLFACTOR=90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UlricaCustomer_uc07_ID] ON bank_uc07.UlricaCustomer_uc07  --��������  --BYDBA һ���Ѿ��������о�û�б�Ҫ���Ǿۼ�������,������Ĭ�Ͼ��Ǿۼ�����.
( 
        [ID] 
)WITH (FILLFACTOR = 90) 
Go

--����Debit_Card��
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
CREATE NONCLUSTERED INDEX [IX_UlricaDebit_Card_uc07_ID] ON bank_uc07.UlricaDebit_Card_uc07    --BYDBA һ���Ѿ��������о�û�б�Ҫ���Ǿۼ�������,������Ĭ�Ͼ��Ǿۼ�����.
( 
        [ID] 
)WITH (FILLFACTOR = 90) 
Go

--����Transactions��
CREATE TABLE bank_uc07.UlricaTransactions_uc07
(
	[TransactionNumber]		INT IDENTITY(1,1) NOT NULL ,
	[Card_ID]				INT FOREIGN KEY REFERENCES bank_uc07.UlricaDebit_Card_uc07(ID) NOT NULL,  --�����п�����Ϊ���  --BYDBA һ�����ǲ�����ʹ�����,����һ���Խ����������������.
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
CREATE NONCLUSTERED INDEX [IX_UlricaTransactions_uc07_TransactionNumber] ON bank_uc07.UlricaTransactions_uc07   --BYDBA һ���Ѿ��������о�û�б�Ҫ���Ǿۼ�������,������Ĭ�Ͼ��Ǿۼ�����.
( 
        [TransactionNumber] 
)WITH (FILLFACTOR = 90) 
Go

--BYDBA 16�� ��ṹ���ɹ�����(7)+��������(3)+IDENTITY����(2)+Ĭ��ֵԼ��(3)+CHECKԼ��(1)+����(0)

--��Ŀ������ʼ�����ݵ���Customer
INSERT INTO bank_uc07.UlricaCustomer_uc07 
(
	[CustomerID],
	[Name],
	[Phone],
	[Address])
VALUES 
('610524198807330846',N'����','13438995253',N'�Ĵ�ʡ�ɶ��и������츮���1888��'),
('610524198807340846',N'����','13438995253',N'�Ĵ�ʡ�ɶ��и������츮���1888��'),
('610524198807340842',N'����','13438995253',N'�Ĵ�ʡ�ɶ��и������츮���1888��'),

('610524198807330811',N'����','13438995253',N'�Ĵ�ʡ�ɶ��и������츮���1888��'),
('610524198807340812',N'����','13434995253',N'�Ĵ�ʡ�ɶ��и������츮���1880��'),
('610524198807340813',N'·�˼�','13424995253',N'�Ĵ�ʡ�ɶ��и������츮���') 

--BYDBA 5�� INSERT�﷨��ȷ(2)+���ĵĴ���(3)

--��Ŀ�ģ���ѯ�ͻ���Ϣ
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

--BYDBA 17�� ��ȷ��ʾҪ�����Ϣ(12)+���б���(5)



--��Ŀ�壺ʵ��ת�˹��ܵĴ洢����

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
SET NOCOUNT ON;--�������� Transact-SQL ���Ӱ�������

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

	IF	@__$tran_count = 0 --���û��Ƕ�����������µ����� --BYDBA ����һ�����Ǽ����С��������Բ�ѯ��û�����õģ���������һ���ڸ���/ɾ��/�޸ı�����֮ǰ�������� 
		BEGIN TRAN; 

	ELSE

	BEGIN;
		SAVE TRAN @__$tran_name_save;--���Ƕ�������������û�ԭ��
		SET @__$tran_count_save = @__$tran_count_save + 1;--��ԭ������+1
	END;

	IF @SourceIDStatus=1 --ת����״̬����   --BYDBA û����������ֵ��ֵ��
		BEGIN 
			SELECT @Balance=Balance
			FROM bank_uc07.UlricaDebit_Card_uc07			AS A WITH(NOLOCK)
			WHERE ID=@SourceID
			
			IF @Balance>=@Money	--�����ڻ����ת����Ŀ
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

					IF (@TargetIDStatus=1 AND @TargetName=@Name)  --�Է��˺ź���������������
						BEGIN 
							UPDATE bank_uc07.UlricaDebit_Card_uc07
							SET Balance=(Balance-@Money),LastEditDate=GETDATE()
							WHERE ID=@SourceID

							UPDATE bank_uc07.UlricaDebit_Card_uc07
							SET Balance=(Balance+@Money),LastEditDate=GETDATE()
							WHERE ID=@TargetID
					
							INSERT INTO bank_uc07.UlricaTransactions_uc07([Card_ID],[Type],[Amount],[Indate],[Status],[Remarks])
							VALUES(@SourceID,N'֧��',@Money,GETDATE(),1,N'ת���ɹ�')

							INSERT INTO bank_uc07.UlricaTransactions_uc07([Card_ID],[Type],[Amount],[Indate],[Status],[Remarks])
							VALUES(@TargetID,N'����',@Money,GETDATE(),1,N'ת��ɹ�')

						END

					ELSE --�տ��˲����ڻ��տ����˺��쳣
						BEGIN

						SET @Remark=N'�տ��˲����ڻ��տ����˺��쳣'

						INSERT INTO bank_uc07.UlricaTransactions_uc07([Card_ID],[Type],[Amount],[Indate],[Status],[Remarks])
						VALUES (@SourceID,N'֧��',0,GETDATE(),0,@Remark)

						END
				END
			ELSE --����ת����Ŀ
				BEGIN

				SET	@Remark=N'�˻�����'

				INSERT INTO bank_uc07.UlricaTransactions_uc07([Card_ID],[Type],[Amount],[Indate],[Status],[Remarks])
					VALUES (@SourceID,N'֧��',0,GETDATE(),0,@Remark)

				END
		END
	ELSE --ת����״̬�쳣
		BEGIN
			
			SET	@Remark=N'���˻�״̬�쳣'

			INSERT INTO bank_uc07.UlricaTransactions_uc07([Card_ID],[Type],[Amount],[Indate],[Status],[Remarks])	
			VALUES (@SourceID,N'֧��',0,GETDATE(),0,@Remark)	
	
			END	

	COMMIT TRAN

END TRY

BEGIN CATCH

	ROLLBACK TRAN @__$tran_name_save  --�ع�����ԭ��
	SET @__$tran_count_save = @__$tran_count_save - 1;  --��ԭ������-1

/*
IF XACT_STATE() <> 0                      --BYDBA ��������쳣����Ҫ��������������Ĵ���ֻ����������sp��������������ĳ������ʱ���ǶԵģ���û�����ֵ��þͻ�����⡣
	BEGIN;
		IF @__$tran_count = 0
			ROLLBACK TRAN;
		-- XACT_STATE Ϊ -1 ʱ, ���ܻع������񱣴��, ���������������������ͳһ������ع�
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
--BYDBA ����Ӧ�ð��쳣��ϢҲ��¼�����ױ��У�ֻ�ǽ�����ʧ�ܵ�

END CATCH;
GO

--BYDBA 22�� �洢�����﷨��ȷ(5)+ʵ��ת�˹���(4)+�����ǡ������(4)+�쳣����ǡ��(4)+�洢���̲�����������ж�Ӧ�ֶβ������ͱ���һ��(5)


--��Ŀ����ʵ��ת��
DECLARE
	@SourceID		INT,
	@Money			DECIMAL(12,2),
	@TargetID		INT,
	@Name			NVARCHAR(50)
 
SET @SourceID=6214921603447611
SET	@Money=666
SET @TargetID=6214921603447622
SET	@Name=N'����'

EXEC bank_uc07.[Up_Test_InnerBankTransfer] @SourceID,@Money,@TargetID,@Name

--BYDBA 3�� �ɹ�ʵ��ת��(3)+��ȡ����ֵ(0)

--��Ŀ�ߣ��ַ����Ĳ��
USE Test
GO
--����һ�������洢�ַ����ı�
CREATE TABLE bank_uc07.UlricaSplitSrting_uc07
(
	[ID]				INT IDENTITY(1,1) NOT NULL,
	[Items]				VARCHAR(32) NOT NULL, 
	[SplitTime]			DATETIME NOT NULL CONSTRAINT DF_UlricaSplitSrting_uc07_SplitTime DEFAULT GETDATE(),  --Ĭ�ϻ�ȡ��ǰʱ��
CONSTRAINT [PK_UlricaSplitSrting_uc07] PRIMARY KEY CLUSTERED  --��������ΪID
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

	IF @Str <> '/'  --���������ֲ������
	INSERT INTO #TEMP([Items]) VALUES(@Str)  

END

INSERT INTO bank_uc07.UlricaSplitSrting_uc07([Items])
SELECT		DISTINCT [Items]		
FROM		#TEMP	AS A WITH(NOLOCK)
WHERE		[Items]<>''   --BYDBA ��Ŀ�в�û��Ҫ�����п�ֵ��

DROP TABLE #TEMP


SELECT * FROM bank_uc07.UlricaSplitSrting_uc07

--BYDBA 19�� ʵ���ַ�����ֹ���(14)+ȥ���ظ�ֵ(5)



--===================================ϰ���=========================================

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

--��Ŀһ���淶��T-SQLд��
SELECT  A.[Name],
		ISNULL(A.[SizeUnitMeasureCode],'CM') AS SizeUnitMeasureCode 
FROM	
		AdventureWorks.Production.product AS A
INNER JOIN
		AdventureWorks.Sales.SalesOrderDetail AS B 
ON	
		A.[Productid]=B.[Productid] 
		AND A.[ModifiedDate]>'2012-06-25 00:00:00'

--BYDBA 16�� ���ִ�дС(2)+��ʽ������(2)+��ʽ������(2)+���뿪ʼUSE DB(0)+���ѯ�������WITH(NOLOCK)(0)+CASE WHEN ��ISNULL��(4)+WHERE����д����ȷ��INNER JOIN (6)

--��Ŀ����ͬ����

--���ڴ���ͬ�����ı����ɾ�ĺͽṹ���ģ��������ڷ����ˣ�Դͷ�����в��������ԣ���Ҫ��ServerA�����С�

ALTER TABLE dbo.tb_item
ADD [state] INT  NULL  CONSTRAINT DF_tb_item_state DEFAULT (0)

UPDATE	dbo.tb_item
SET		[state]= 0
WHERE	[state] IS NULL

ALTER TABLE dbo.tb_item
ALTER COLUMN [state] INT  NOT NULL

--BYDBA 20�� ʵ������еĽű�(5)+���÷�������(0)+��ȷ���Ĭ��ֵԼ��(5)+Լ�������Ƿ�淶(5)+ѡ����ȷ��Serverִ��(5)


--��Ŀ�������ŵĲ�ѯ��ʽ

DECLARE @ItemNumber NCHAR(25)
SET		@ItemNumber='00-000-006R'

SELECT	A.ItemNumber,A.ProductTitle,A.ProductName,A.ManualProductName 
FROM	dbo.ItemDescription AS A WITH (NOLOCK)
WHERE	A.ItemNumber=CONVERT(CHAR,@ItemNumber)  --BYDBA ���������ȷָ��CHAR�ĳ���

--BYDBA	15�� ������ʽת����10��+�������Ǽ�WITH(NOLOCK)(5)


--��Ŀ�ģ��Ż��ű�
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

--BYDBA 15�� ������in�е������Ȼ����ڱ����������ʱ�����������β�ѯ��ʽ���(15)


--��Ŀ�壺���ݹ鵵

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

	@CurrentYear=		DATEPART(YEAR,DATEADD(YEAR,-1,GETDATE())),  --2016��--������ʽ
	@StartYear=			2000,  --��2000�꿪ʼ--������ʽ
	@ThisYear=			DATEPART(YEAR,GETDATE()) --2017��,������ʽ

BEGIN TRY

	IF	@__$tran_count = 0 --���û��Ƕ�����������µ�����
		BEGIN TRAN;
	ELSE
	BEGIN;
		SAVE TRAN @__$tran_name_save;--���Ƕ�������������û�ԭ��
		SET @__$tran_count_save = @__$tran_count_save + 1;--��ԭ������+1
	END;	

	WHILE ( @StartYear <= @CurrentYear )
	BEGIN 

		SET			@CurrentYearStr=CONVERT(VARCHAR(4),@CurrentYear)  --2016��--�ַ���ʽ
		SET			@CurrentYearFirstDay=CONVERT(VARCHAR(4),@CurrentYear) --2016�꣬�ַ���ʽ
		SET			@CurrentYearLastDay=DATEADD(DAY,-1,(DATEADD(YEAR,1,(CONVERT(VARCHAR(4),@CurrentYear))))) --2016�����һ�죬������ʽ
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

	DELETE FROM		bank_uc07.UlricaTransactions_uc07	--ɾ��ԭ���е�����
	WHERE			Indate < @ThisYear
	
	COMMIT

END TRY

BEGIN CATCH

	ROLLBACK TRAN	@__$tran_name_save  --�ع�����ԭ��
	SET				@__$tran_count_save = @__$tran_count_save - 1;  --��ԭ������-1

END CATCH;
GO

--BYDBA 10�� ����ʵ��(8)+�����ʵ�,�����Ͻ�(2)+��������(0)