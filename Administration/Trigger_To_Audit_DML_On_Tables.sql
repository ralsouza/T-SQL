--Trigger to audit rows inserted,deleted or updated

CREATE TRIGGER YourTrigger ON YourTable
   AFTER INSERT,UPDATE,DELETE
AS

DECLARE @HistoryType    char(1) --"I"=insert, "U"=update, "D"=delete

SET @HistoryType=NULL

IF EXISTS (SELECT * FROM INSERTED)
BEGIN
    IF EXISTS (SELECT * FROM DELETED)
    BEGIN
        --UPDATE
        SET @HistoryType='U'
    END
    ELSE
    BEGIN
        --INSERT
        SET @HistoryType='I'
    END
    --handle insert or update data
    INSERT INTO YourLog
            (ActionType,ActionDate,.....)
        SELECT
            @HistoryType,GETDATE(),.....
            FROM INSERTED

END
ELSE IF EXISTS(SELECT * FROM DELETED)
BEGIN
    --DELETE
    SET @HistoryType='D'

    --handle delete data, insert into both the history and the log tables
    INSERT INTO YourLog
            (ActionType,ActionDate,.....)
        SELECT
            @HistoryType,GETDATE(),.....
            FROM DELETED

END
--ELSE
--BEGIN
--    both INSERTED and DELETED are empty, no rows affected
--END
