/**********************************************************
                创建人:Lave_lei
                创建日期:2017-07-25 02:15
                功能描述 :DBA第一次作业
**********************************************************/

-----------------------------------------------First------------------------------------------------------
/*
1.创建三张表的Schema
*/

USE Test;
GO

CREATE SCHEMA [bank_ll7i] AUTHORIZATION [intern_test]   --新建一个SCHEMA并制定其owner
GO

-----------------------------------------------Second-----------------------------------------------------
/*
请从数据库设计者的角度创建以上三张表。
1.先将三张表建好
2.为Customer_ll7i(CustomerID),Debit_Card_ll7i(ID),Transactions_ll7i(Card_ID)建立索引
*/

USE Test;
GO

    --创建用户表
    CREATE TABLE [bank_ll7i].[Customer_ll7i] (
    	ID INT NOT NULL IDENTITY(1,1)
    	,CustomerID char(18) NOT NULL
    	,Name nvarchar(10) NOT NULL
    	,Phone char(11) NOT NULL
    	,Address nvarchar(30) NOT NULL
    	,CreateTime datetime DEFAULT GETDATE()
    	,LastEditDate datetime
    	,Remarks nvarchar(50)
        ,CONSTRAINT PK_Customer_ll7i PRIMARY KEY
        (
            ID ASC
        ));

    --创建身份证号的的唯一索引
    CREATE UNIQUE INDEX IX_Customer_ll7i_CustomerID ON [bank_ll7i].[Customer_ll7i](CustomerID);

    --创建卡表
    CREATE TABLE [bank_ll7i].[Debit_Card_ll7i](
    	ID char(20) NOT NULL
    	,CustomerID char(18) NOT NULL 
    	,Password nvarchar(20) NOT NULL
    	,Balance DECIMAL(12,2)DEFAULT 0 NOT NULL
    	,IsVIP BIT DEFAULT 0 NOT NULL
    	,Status BIT DEFAULT 0 NOT NULL
    	,CreateTime DATETIME DEFAULT GETDATE()
    	,LastEditDate DATETIME DEFAULT GETDATE()
    	,Remarks nvarchar(50)
        ,CONSTRAINT PK_Debit_Card_ll7i PRIMARY KEY(
            ID ASC
        ));

    --创建卡号的索引 主键已经唯一了 因此就不建唯一值索引了
    CREATE INDEX IX_Debit_Card_ll7i_ID ON [bank_ll7i].[Debit_Card_ll7i](ID);

    --创建交易记录表
    CREATE TABLE [bank_ll7i].[Transactions_ll7i](
    	TransactionNumber INT IDENTITY(1,1)
    	,Card_ID CHAR(20) NOT NULL
    	,Type BIT NOT NULL
    	,Amount DECIMAL(12,2) NOT NULL
    	,Indate DATETIME DEFAULT GETDATE()
    	,Status BIT DEFAULT 0
    	,Remarks nvarchar(50)
        ,CONSTRAINT PK_Transactions_ll7i PRIMARY KEY
        (
            TransactionNumber ASC
        ));

    --创建交易表的卡号索引，此处不用唯一
    CREATE INDEX IX_Transactions_ll7i_Card_ID ON [bank_ll7i].[Transactions_ll7i](Card_ID);

GO

------------------------------------------------Thrid----------------------------------------
/*
初始化以下内容到表Customer中。
*/

USE Test
GO

    INSERT INTO [bank_ll7i].[Customer_ll7i]
        (
            CustomerID
            ,Name
            ,Phone
            ,Address
        ) 
    VALUES (
            '610524198807330846'
            ,N'张三'
            ,'13438995253'
            ,N'四川省成都市高新区天府五街1888号'
            );
    
    INSERT INTO [bank_ll7i].[Customer_ll7i]
        (
            CustomerID
            ,Name
            ,Phone
            ,Address
        ) 
    VALUES (
        '610524198807340846'
        ,N'李四'
        ,'13434995253'
        ,N'四川省成都市高新区天府五街1880号'
        );
    
    INSERT INTO [bank_ll7i].[Customer_ll7i]
        (
            CustomerID
            ,Name
            ,Phone
            ,Address
        ) 
    VALUES (
            '610524198807340842'
            ,N'王五'
            ,'13424995253'
            ,N'四川省成都市高新区天府五街'
            );

GO

-------------------------------------Fourth--------------------------------------
/*
查询该银行最近6个月总交易额最大,交易次数最多的前100名没有备注信息的客户信息，
最终需要显示的信息：客户名称,客户身份证号，联系电话，住址，当前总余额，总交易额，交易次数。
注意：以上交易额是指交易成功的有效交易额。
1.使用内连接
*/

USE Test 
GO

    SELECT TOP 100 C.Name AS [姓名]
             ,C.CustomerID AS [身份证号]
             ,C.Phone AS [电话号码]
             ,C.Address AS [地址]
             ,F.Balance AS [余额]
             ,SUM(T.Amount) AS [交易金额]
             ,COUNT(T.Status) AS [交易次数]
    FROM [bank_ll7i].[Customer_ll7i] AS C with(NOLOCK)
    INNER JOIN [bank_ll7i].[Debit_Card_ll7i] AS D with(NOLOCK)
        ON C.CustomerID = D.CustomerID
    INNER JOIN [bank_ll7i].[Transactions_ll7i] T with(NOLOCK)
        ON D.ID = T.Card_ID,
        [bank_ll7i].[Debit_Card_ll7i] AS F
    WHERE T.Status=1
            AND T.InDate>=DATEADD(MONTH,-6,GETDATE())
    GROUP BY  C.Name,C.CustomerID, C.Phone,C.Address,D.Balance
    ORDER BY  SUM(T.Amount) DESC, COUNT(T.Status) DESC; 
GO

----------------------------------------------Fifth------------------------------------

/*
编写一个实现转账功能的存储过程。
输入参数：转出卡号，金额，转入卡号，卡号户主姓名
转账流程如下，其中转帐操作是一个原子操作，要么都成功要么都失败,并返回操作结果。
*/

USE Test
GO 

CREATE PROCEDURE [bank_ll7i].[UP_TransferMoney]
	   @OUTCard_ID char(20) 
	  ,@Number decimal(12,2) 
	  ,@InCard_ID char(20) 
	  ,@InName nvarchar(10) 
AS
	DECLARE @Balance decimal(12,2); --当前余额
	DECLARE @Status bit; --卡的状态
	DECLARE @CustomerName nvarchar(10); --入账账户姓名

	SET XACT_ABORT OFF;
	SET NOCOUNT ON;

	--获取转出账号余额和状态
	SELECT TOP 1
		@Balance=[Balance] 
	   ,@Status =[Status] 
	FROM [bank_ll7i].[Debit_Card_ll7i] WITH(NOLOCK) 
	WHERE 
		ID = @OUTCard_ID ;
	
	--判断是否符合转出条件
	IF @Status=1 AND @Balance>=@Number
		BEGIN

			--获得符合条件的转出账户的拥有者姓名
			SELECT TOP 1
				@CustomerName=[Name] 
			FROM [bank_ll7i].[Customer_ll7i] WITH(NOLOCK) 
			WHERE 
				[Name]=@InName 
				AND [CustomerID] IN 
					( 
						SELECT TOP 1 
							CustomerID 
						FROM [bank_ll7i].[Debit_Card_ll7i] WITH(NOLOCK) 
						WHERE 
							[ID]=@InCard_ID 
					)
			--判断是否有符合条件的转出账号
			IF @CustomerName IS NOT NULL AND @CustomerName<>''
				BEGIN
					BEGIN TRY
						BEGIN TRAN --开始事务
							--扣除转出账号金额
							UPDATE TOP(1) [bank_ll7i].[Debit_Card_ll7i] 
							SET [Balance]=[Balance]-@Number 
							WHERE ID = @OUTCard_ID;
							--增加转入账号金额
							UPDATE TOP(1) [bank_ll7i].[Debit_Card_ll7i] 
							SET [Balance]=[Balance]+@Number 
							WHERE ID = @InCard_ID;
							--增加转出记录	
							INSERT INTO [bank_ll7i].[Transactions_ll7i] 
							( 
								[Card_ID] 
								,[Type] 
								,[Amount] 
								,[Status] 
								,[Remarks] 
							)
							VALUES
							( 
								@OUTCard_ID 
								,0 
								,@Number 
								,1 
								,N'转给'+RTRIM(@InCard_ID) 
							);
							--增加转入记录
							INSERT INTO [bank_ll7i].[Transactions_ll7i] 
							( 
								[Card_ID] 
								,[Type] 
								,[Amount] 
								,[Status] 
								,[Remarks] 
							)
							VALUES
							( 
								@InCard_ID 
								,1 
								,@Number 
								,1 
								,N'收到来自'+RTRIM( @OUTCard_ID)+N'转账'
							);
						--提交事务	
						COMMIT TRAN;
						RETURN 1;
						END TRY
						BEGIN CATCH
							--回滚事务
							ROLLBACK TRAN;
							--添加转出失败记录
							INSERT INTO [bank_ll7i].[Transactions_ll7i] 
							( 
				  				[Card_ID] 
								,[Type] 
								,[Amount] 
								,[Status] 
								,[Remarks] 
							) 
							VALUES
							( 
				  				@OUTCard_ID 
								,0 
								,@Number 
								,0 
								,N'转给'+RTRIM(@OUTCard_ID) 
							)
							--添加转入失败记录
							INSERT INTO [bank_ll7i].[Transactions_ll7i] 
							( 
				  				[Card_ID] 
								,[Type] 
								,[Amount] 
								,[Status] 
								,[Remarks] 
							)
							VALUES
							( 
				  				@InCard_ID 
								,1 
								,@Number 
								,0 
								,N'收到来自'+RTRIM(@OUTCard_ID)+N'转账'
							);
							RETURN -1;
						END CATCH
				END
				--表示无符合条件的转入账号
				ELSE RETURN 2
		END;
		--表示无符合条件的转出账号
		ELSE RETURN 3;
GO

-----------------------------------------------Sixth------------------------------------------
/*
通过以上编写的存储过程来实现一笔转账，并获取返回值。
写出你需要实现的转账及实现脚本。

*/
USE Test;
GO

DECLARE @RE INT;
EXECUTE @RE = [bank_ll7i].[TransferMoney] 5120144588, 20, 5120144589, N'李四';
SELECT @RE AS [结果] ;
GO

----------------------------------------------Seventh-----------------------------------------

/*
我们经常会遇到字符串拆分的需求，比如有字符串01;03;02;06;08;04;01;03;09;;20;12;1;24;25;87，题目如下：
在Test数据下创建一个表，用来存放拆分后的字符串，至少包含三个字段：主键，字符串值，拆分时间(请为拆分时间设置当前时间的默认约束)
请拆分上面字符串，放到上面创建的表(拆分后的字符串需要去掉重复值)

1.首先创建表格，包含一个主键ID，一个值，一个时间的记录；
2.创建一个SP，将结果存进一个临时表格，再将其OUTPUT出来；
3.将临时表格里面的数据插进表中；
*/

----先创建一个表格，用来存储正式的数据
USE Test
GO

CREATE TABLE [bank_ll7i].[split_string_test_ll7i]
(
ID INT IDENTITY(1,1)
,VALUE CHAR(5) UNIQUE NOT NULL
,InTime DATETIME DEFAULT GETDATE()
,CONSTRAINT PK_split_string_test_ll7i PRIMARY KEY
(ID ASC)
)

--创建一个SP，用来计算拆分字符串
USE Test
GO

CREATE PROCEDURE [bank_ll7i].[UP_Split_String]
	@splitString NVARCHAR(80),
	@separator char(1)
AS
    --减少务必要输出 节约资源
	SET NOCOUNT ON;

	DECLARE @Index SMALLINT,  
			@DELIndex SMALLINT,  
			@Start SMALLINT,    
			@InsertValue VARCHAR(5);  --每次插进表格中的值

    --创建临时表
    CREATE TABLE #temp(
        item CHAR(4) NOT NULL
    )

    --记录分隔符的长度
	SET @DELIndex = LEN(@separator);
    
    --循环开始给临时表中插值
	WHILE LEN(@splitString)>0
	BEGIN
        --记录每次分隔符所在的位置
		SET @Index=CHARINDEX(@separator,@splitString);

		IF @Index = 0    --表示已经无该分隔符了，将尝试剩下的值全部插入
			BEGIN
				SET @InsertValue =LTRIM(RTRIM(@splitString));
				IF @InsertValue IS NOT NULL 
                        AND @InsertValue<>''
                        AND (SELECT item FROM #temp WHERE item=@InsertValue) IS NULL
                    INSERT INTO #temp VALUES(@InsertValue);
				BREAK;   --跳出循环
			END
		ELSE
			BEGIN
				SET @InsertValue = LTRIM(RTRIM(SUBSTRING(@splitString,1,@Index-1)));
                --如果该值不为NULL，不为空，在#temp中没有出现过，则插入
				IF @InsertValue IS NOT NULL 
                        AND @InsertValue<>''
                        AND (SELECT item FROM #temp WHERE item=@InsertValue) IS NULL
                INSERT INTO #temp VALUES(@InsertValue);

                --记录开始分割的地方
				SET @Start=@Index+@DELIndex;
				SET @splitString = SUBSTRING(@splitString,@Start,LEN(@splitString)-@Start+1);
			END
	END
    --输出#temp中的所有值
    SELECT item FROM #temp
GO


---调用这个SP向目标表里面插值
INSERT INTO 
    [bank_ll7i].[split_string_test_ll7i](VALUE) 
EXEC [bank_ll7i].[UP_Split_String] '01;03;02;06;08;04;01;03;09;;20;12;1;24;25;87', ';';