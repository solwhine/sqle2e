USE AdventureWorks2022DB;
GO
CREATE OR ALTER PROCEDURE dev.usp_runVendorMarginPipeline 
	@startDate DATE,
	@endDate DATE = NULL,
	@minMargin DECIMAL(5,2)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	IF @endDate IS NULL
		SET @endDate = CAST(GETDATE() AS DATE);

	BEGIN TRY 
		SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
		BEGIN TRANSACTION;

		EXEC dev.usp_stageSalesBatch 
			@startDate=@startDate,
			@endDate=@endDate;

		EXEC dev.usp_calculateVendorMargins 
			@minMargin=@minMargin;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION;
			END;

		THROW;
	END CATCH
END