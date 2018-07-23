SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Name Author
-- Create date: Date goes here
-- Description:	Procedure with TRY/CATCH 
-- =============================================
CREATE PROCEDURE usp_proc_with_trycatch -- Change this name
AS
	SET NOCOUNT ON;
	--If a run-time error is generated, the entire transaction will be terminated and rolled back.
	SET XACT_ABORT ON; 
BEGIN
	BEGIN TRY

		BEGIN TRANSACTION
			--Statement 1
		COMMIT TRANSACTION

		BEGIN TRANSACTION
			--Statement 2
		COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
		
		-- Execute error retrieval routine
		DECLARE @ErrLine nvarchar(10) = ERROR_LINE();
		DECLARE @ErrMess nvarchar(300) = ERROR_MESSAGE();
		EXECUTE usp_GetErrorInfo;

		-- Test whether the transaction is uncommittable
		IF (XACT_STATE()) = -1  
		BEGIN  
			PRINT  N'The transaction is in an uncommittable state.' +  'Rolling back transaction. Error Line: ' +  @ErrLine + ' Error Message: ' + @ErrMess
			ROLLBACK TRANSACTION;  
		END; 

		-- Test whether the transaction is committable  
		IF (XACT_STATE()) = 1  
		BEGIN  
			PRINT  
				N'The transaction is committable.' +  'Committing transaction.'  
			COMMIT TRANSACTION;     
		END;  
	END CATCH
END
