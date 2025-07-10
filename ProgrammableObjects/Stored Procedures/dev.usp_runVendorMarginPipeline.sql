SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dev].[usp_runVendorMarginPipeline] 
	@startDate DATE,
	@endDate DATE = NULL,
	@minMargin DECIMAL(5,2)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	IF @endDate IS NULL
		SET @endDate = CAST(GETDATE() AS DATE);

	DECLARE @stagedcount INT = 0;
	DECLARE @insertedcount INT = 0;

	BEGIN TRY 
		SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
		BEGIN TRANSACTION;

		---1.stage the sales data
		EXEC dev.usp_stageSalesBatch 
			@startDate=@startDate,
			@endDate=@endDate,
			@rowsStaged = @stagedcount OUTPUT;

		EXEC dev.usp_calculateVendorMargins 
			@minMargin=@minMargin,
			@insertedcount = @insertedcount OUTPUT;

		COMMIT TRANSACTION;

		PRINT ('Pipeline complete');
		PRINT CONCAT('sales staged: ',@stagedcount);
		PRINT CONCAT('margin rows inserted: ',@insertedcount);
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION;
			END;

		THROW;
	END CATCH
END
GO
