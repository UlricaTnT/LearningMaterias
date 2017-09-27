USE ECommerce2005
GO

/******************************************************************
*name        :  ECommerce2005.dbo.UP_EC_RealTime_AddItemsToExistWishList_V3
*function    :  add temporary data to one exist wish list
*input       :  WishListNumber,CustomerNumber,ItemList,QtyList,PriceList,Country,MaxQty
*output      :  ReturnValue
Table Used   :
*	------------------------------------------------------- 

*author      :  Kelvin Jiang
*server		 :  SSLQuery
*CreateDate  :  2006/03/22
*UpdateDate  :  2008/10/11
*UpdateBy	:	Neil Chen
*UpdateDate  :  2016/11/2 #13360 Sin Lin add insert SalesPrice & SaveCountry, update to V3
*UpdateDate  :  2017/5/22 #13754 Howard Wang add Priority
*UpdateDate  :  2017/5/23 #13754 Howard Wang add fix Priority error
*UpdateDate  :  2017/6/28 #13818 Howard Wang fix RealTime write logic 
*************************************************************************/



ALTER PROC  dbo.UP_EC_RealTime_AddItemsToExistWishList_V3
(
	@WishListNumber INT,
	@CustomerNumber INT,        	
	@ItemList       VARCHAR(2000),
	@QtyList        VARCHAR(1000),
	@PriceList		VARCHAR(2000),
	@Country		CHAR(3),
	@MaxQty         INT,
	@PriorityList   VARCHAR(1000),
	@ReturnValue    INT  OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE	@k9 CHAR(1),
			@Strlocate1 INT,
			@Strlocate2 INT,
			@Strlocate3 INT,
			@Strlocate4 INT
	DECLARE @Item CHAR(20),
			@Qty INT,@TTLQty INT,
			@Price DECIMAL(10,2),
			@Priority INT, 
			@TTLCountry CHAR(3), 
			@TTLCustomPriority INT, 
			@TTLPrice DECIMAL(10,2)
	
	DECLARE @Temp TABLE(
				ItemNumber  VARCHAR(20) NULL,
				Qty			INT DEFAULT 0,
				Price		DECIMAL(10,2),
				Country		CHAR(3),
				CustomPriority INT DEFAULT 0
				)
	
	SET @ReturnValue = 1;
	
	BEGIN TRY			
		--Check whether is the WishListNumber exist
		IF EXISTS(SELECT TOP 1 1 FROM dbo.V_EC_WishListMaster WITH (NOLOCK)
			WHERE CustomerNumber = @CustomerNumber AND WishListNumber = @WishListNumber)
		BEGIN			
			BEGIN TRAN;	
				IF @ItemList <> ''		
				BEGIN
					SET @Strlocate1 = 0 
					SET @Strlocate2 = 0 
					SET @Strlocate3 = 0 
				    SET @Strlocate4 = 0 
					SET @k9        = ','
					
					INSERT INTO @Temp (ItemNumber,Qty,Price,Country,CustomPriority) 
					SELECT ItemNumber,Qty,SalesPrice,SaveCountry,CustomPriority 
					FROM dbo.V_EC_WishListTransaction_V1 WITH (NOLOCK) 
						WHERE WishlistNumber = @WishListNumber
					
					WHILE LEN(@ItemList) > 0 
					BEGIN
						SET @Strlocate1 = CHARINDEX(@k9,@ItemList)
						SET @Strlocate2 = CHARINDEX(@k9,@QtyList)
						SET @Strlocate3 = CHARINDEX(@k9,@PriceList)
						SET @Strlocate4 = CHARINDEX(@k9,@PriorityList)

						IF @Strlocate1 > 0 
						BEGIN 
							SET  @Item = SUBSTRING(@ItemList,1,@Strlocate1-1) 
							SET  @ItemList = SUBSTRING(@ItemList,@Strlocate1+1 ,LEN(@ItemList)) 
							SET  @Qty = SUBSTRING(@QtyList,1,@Strlocate2-1) 
							SET  @QtyList = SUBSTRING(@QtyList,@Strlocate2+1 ,LEN(@QtyList))
							SET  @Price = SUBSTRING(@PriceList,1,@Strlocate3-1) 
							SET  @PriceList = SUBSTRING(@PriceList,@Strlocate3+1 ,LEN(@PriceList)) 
							SET  @Priority = SUBSTRING(@PriorityList,1,@Strlocate4-1) 
							SET  @PriorityList = SUBSTRING(@PriorityList,@Strlocate4+1 ,LEN(@PriorityList))
						END 
						ELSE 
						BEGIN 
							SET  @Item =  @ItemList 
							SET  @ItemList = ''  

							IF @Strlocate2 >0
								SET  @Qty = SUBSTRING(@QtyList,1,@Strlocate2-1) 
							ELSE
								SET  @Qty =  @QtyList 
							SET  @QtyList = ''  

							IF @Strlocate3 > 0
								SET  @Price = SUBSTRING(@PriceList,1,@Strlocate3-1) 
							ELSE
								SET @Price = @PriceList							
								SET @PriceList = ''	

							IF @Strlocate4 >0
								SET  @Priority = SUBSTRING(@PriorityList,1,@Strlocate4-1) 
							ELSE
								SET  @Priority =  @PriorityList 
								SET  @PriorityList = ''  
						END 
					
						INSERT INTO @Temp (ItemNumber,Qty,Price,Country,CustomPriority) VALUES (@Item,@Qty,@Price,@Country,@Priority)

						--have been in WishListTransaction_RealTime
						IF EXISTS(SELECT TOP 1 1 FROM dbo.WishListTransaction_RealTime WITH (NOLOCK) 
									WHERE WishlistNumber = @WishListNumber AND ItemNumber = @Item AND TransferStatus = 'O')
						BEGIN
						
							SELECT @TTLQty = CASE WHEN (SUM(Qty) > @MaxQty)
												THEN @MaxQty 
												ELSE SUM(Qty) 
												END FROM @Temp 
							WHERE ItemNumber = @Item 
							GROUP BY ItemNumber
								
							UPDATE dbo.WishListTransaction_RealTime
								SET Qty = @TTLQty,
									LastEditDate = GETDATE(),
									ChangeType = CASE WHEN ChangeType = N'D' 
													  THEN N'A' 
													  ELSE ChangeType END,
									CustomPriority = @Priority
								WHERE WishlistNumber = @WishListNumber AND ItemNumber = @Item AND TransferStatus = 'O'
						END
						
						ELSE IF EXISTS(SELECT TOP 1 1 FROM Imk.dbo.WhisListTransaction WITH (NOLOCK) 
										WHERE WishlistNumber = @WishListNumber AND ItemNumber = @Item)
						BEGIN
						
							SELECT TOP 1 @TTLCountry = SaveCountry, 
										 @TTLCustomPriority = CustomPriority,
										 @TTLPrice = SalesPrice								   
							FROM Imk.dbo.WhisListTransaction WITH (NOLOCK) 
							WHERE WishlistNumber = @WishListNumber AND ItemNumber = @Item
						
							INSERT INTO dbo.WishListTransaction_RealTime(WishListNumber,
																		 ItemNumber,
																		 Qty,
																		 ChangeType,
																		 TransferStatus,
																		 SalesPrice,
																		 SaveCountry,
																		 CustomPriority) 									
							SELECT @WishListNumber,
									ItemNumber,
									Qty = CASE WHEN (SUM(Qty) > @MaxQty) 
										  THEN @MaxQty 
										  ELSE SUM(Qty) END,
									'U',
									'O',
									@TTLPrice,
									@TTLCountry,
									@TTLCustomPriority
													  
							FROM @Temp 
							WHERE ItemNumber = @Item 
							GROUP BY ItemNumber
						END						

						ELSE
						--not in WishListTransaction_RealTime and WishListTransaction
						BEGIN
							INSERT INTO dbo.WishListTransaction_RealTime(WishListNumber,
																		 ItemNumber,
																		 Qty,
																		 ChangeType,
																		 TransferStatus,
																		 SalesPrice,
																		 SaveCountry,
																		 CustomPriority) 
							VALUES(@WishListNumber,@Item,@Qty,'A','O',@Price,@Country,@Priority)			
						END		
					END					   
				END								
			COMMIT TRAN;
		END
	END TRY	
	BEGIN CATCH 
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRAN;
		END; 
		SET @ReturnValue = -1 
	END CATCH
END








GO