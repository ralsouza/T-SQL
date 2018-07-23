SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Name of Author
-- Create date: Date goes here
-- Description:	Procedure to retrieve error information.
-- =============================================
CREATE PROCEDURE usp_GetErrorInfo
AS
BEGIN

	SET NOCOUNT ON;
    SELECT   
         ERROR_NUMBER() AS ErrorNumber  
        ,ERROR_SEVERITY() AS ErrorSeverity  
        ,ERROR_STATE() AS ErrorState  
        ,ERROR_LINE () AS ErrorLine  
        ,ERROR_PROCEDURE() AS ErrorProcedure  
        ,ERROR_MESSAGE() AS ErrorMessage;  
END
GO
