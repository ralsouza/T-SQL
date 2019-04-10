USE [SgtcDb_Extratos]
GO
/****** Object:  StoredProcedure [dbo].[usp_creates_customer_consolidation_job]    Script Date: 09/04/2019 19:56:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafael Lima
-- Create date: 08/04/2019
-- Description:	Procedure that automates the creation of data consolidation jobs for the generation of extracts.
--				This procedure is designed to create schedules that perform weekly jobs.
--
-- ENTRADAS DO PROCEDIMENTO:
--
--		# client_id................int...................Id do cliente 
--		# consolidation_initial....nvarchar(10)..........Data inicial da consolidação, formato esperado 'yyyy-mm-dd'
--		# consolidation_end_date...nvarchar(10)..........Data final da consolidação, formato esperado 'yyyy-mm-dd'
--		# type_process.............nvarchar(3)...........Tipo de consolidação a ser gerada, por 1 para Gestor, 2 para individuais ou 3 para ambos.
--													   No caso da opção 3, serão adicinadas uma tarefa para cada tipo de consolidação
--		# schedule_name............nvarchar(50)..........Nome do job
--		# description..............nvarchar(1000)........Inserir informacoes uteis sobre o job de consolidacao
--		# freq_interval............int...................Define os dias da semana que determinada agenda rodará
--					 Indice dos dias da semana de freq_interval - Para selecionar mais de um dia de cada vez, adicione os números. Ex: 1 + 2 = 3 é domingo e segunda
--						1 = Sunday
--						2 = Monday
--						4 = Tuesday
--						8 = Wednesday
--						16 = Thursday
--						32 = Friday
--						64 = Saturday
--		# active_start_date........int...................Data em que a execução do job iniciará
--      # execution_time...........nvarchar(10)..........Horário em que o job executará
--
-- EXEMPLO:
--
--		declare
--			 @client_id int = 41
--			,@consolidation_initial nvarchar(10)  = '2019-01-16'
--			,@consolidation_end_date nvarchar(10) = '2019-02-15'
--			,@type_process int = 1
--			,@schedule_name nvarchar(50) = 'Agenda_15-05-2019'
--			,@description nvarchar(1000) = 'Job para consolidar os dados YARA'
--			,@freq_interval int = 112
--			,@active_start_date nvarchar(10) = '2019-04-09'
--			,@execution_time nvarchar(10) = '05:15:00'

--		exec sgtcdb_extratos.dbo.usp_creates_customer_consolidation_job 
--			 @client_id
--			,@consolidation_initial
--			,@consolidation_end_date
--			,@type_process
--			,@schedule_name
--			,@description
--			,@freq_interval
--			,@active_start_date
--			,@execution_time
--		go
-- =============================================
ALTER PROCEDURE [dbo].[usp_creates_customer_consolidation_job] 
	@client_id int,
	@consolidation_initial nvarchar(10),
	@consolidation_end_date nvarchar(10),
	@type_process int,
	@schedule_name nvarchar(50),
	@description nvarchar(1000),
	@freq_interval int,
	@active_start_date nvarchar(10),
	@execution_time nvarchar(10)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE
		@customer_acronym nvarchar(5),
		@job_name nvarchar(100),
		@proc nvarchar(500),
		@proc2 nvarchar(500),
		@proc3 nvarchar(500),
		@stepName nvarchar(100),
		@stepName2 nvarchar(100),
		@stepName3 nvarchar(100)

	-- Set customer acronym
	SET @customer_acronym = (select Code from SgtcDb.customer.Client where id = @client_id);
	
	-- Set date on which job execution can begin
	SET @active_start_date = (select replace(@active_start_date, '-',''));

	-- Set time to execution job
	set @execution_time = (select cast(replace(@execution_time, ':','') as int));

	-- Set job name to Individual
	SET @job_name = (select N'SGTC_CONSOLIDATION_' + @customer_acronym)

	-- Check which type of consolidation
	if @type_process = 1

		begin

			-- Set referente month into step name with referente month to Gestores
			SET @stepName = (select 'consolidation_GES_ref_'+ replace(@consolidation_initial, '-',''))

			set @proc = (select 'SgtcDb.dbo.usp_extracao_extratos_gestores ' + cast(@client_id as nvarchar(3)) + ', ''' + @consolidation_initial + ''', ''' + @consolidation_end_date + '''')
			
		end

	else if @type_process = 2

		begin

			-- Set referente month into step name with referente month to Individual
			SET @stepName = (select 'consolidation_IND_ref_'+ replace(@consolidation_initial, '-',''))
			
			set @proc = (select 'SgtcDb.dbo.usp_extracao_extratos_individuais ' + '''' + @consolidation_initial + '''' + ', ' + cast(@client_id as nvarchar(3)))

		end

	else if @type_process = 3

		begin
			
			SET @stepName2 = (select 'consolidation_IND_ref_'+ replace(@consolidation_initial, '-',''))

			set @proc2 = (select 'SgtcDb.dbo.usp_extracao_extratos_individuais ' + '''' + @consolidation_initial + '''' + ', ' + cast(@client_id as nvarchar(3)))
			

			SET @stepName3 = (select 'consolidation_GER_ref_'+ replace(@consolidation_initial, '-',''))

			set @proc3 = (select 'SgtcDb.dbo.usp_extracao_extratos_gestores ' + cast(@client_id as nvarchar(3)) + ', ''' + @consolidation_initial + ''', ''' + @consolidation_end_date + '''')

		end
		else
			RAISERROR('@Type parameter not recognized, try 1 to Gestores or 2 to Individual consolidation.',16,1)

	-- Adds a new job executed by the SQLServerAgent service
	DECLARE @jobId BINARY(16)

	EXEC  msdb.dbo.sp_add_job @job_name = @job_name, 
			@enabled=1, 
			@notify_level_eventlog=0, 
			@notify_level_email=2, 
			@notify_level_netsend=2, 
			@notify_level_page=2, 
			@delete_level=0,
			@description=@description,
			@category_name=N'Data Collector', 
			@owner_login_name=N'TGWEB001\rafael.lima',
		    @job_id = @jobId OUTPUT

	-- Targets the specified job at the specified server
	EXEC msdb.dbo.sp_add_jobserver @job_name=@job_name, @server_name = N'TGWEB001\SGTC'

	-- Adds a step (operation) to a job
	if @type_process = 3
		begin
			EXEC msdb.dbo.sp_add_jobstep @job_name=@job_name, @step_name=@stepName2, 
					@step_id=1, 
					@cmdexec_success_code=0, 
					@on_success_action=3, 
					@on_fail_action=2, 
					@retry_attempts=0, 
					@retry_interval=0, 
					@os_run_priority=0,
					@subsystem=N'TSQL', 
					@command = @proc2, 
					@database_name=N'SgtcDb', 
					@flags=0
			
			EXEC msdb.dbo.sp_add_jobstep @job_name=@job_name, @step_name=@stepName3, 
					@step_id=2, 
					@cmdexec_success_code=0, 
					@on_success_action=1, 
					@on_fail_action=2, 
					@retry_attempts=0, 
					@retry_interval=0, 
					@os_run_priority=0,
					@subsystem=N'TSQL', 
					@command = @proc3, 
					@database_name=N'SgtcDb', 
					@flags=0	
		end
		else
			EXEC msdb.dbo.sp_add_jobstep @job_name=@job_name, @step_name=@stepName, 
					@step_id=1, 
					@cmdexec_success_code=0, 
					@on_success_action=1, 
					@on_fail_action=2, 
					@retry_attempts=0, 
					@retry_interval=0, 
					@os_run_priority=0,
					@subsystem=N'TSQL', 
					@command = @proc, 
					@database_name=N'SgtcDb', 
					@flags=0

	-- Creates a schedule for a job
	-- In the SGTC, it's mandatory to write the schedule below before creating others. In this case, use the specific procedure of creating schedules for existing jobs
	
	-- Dayweek Index at @freq_interval - To select more than one day at a time, add the numbers. Ex: 1+2=3 is Sunday and Monday
	-- 1 = Sunday
	-- 2 = Monday
	-- 4 = Tuesday
	-- 8 = Wednesday
	-- 16 = Thursday
	-- 32 = Friday
	-- 64 = Saturday	

	DECLARE @schedule_id int

	EXEC msdb.dbo.sp_add_jobschedule @job_name=@job_name, @name=@schedule_name, 
			@enabled=1, 
			@freq_type=8, -- Weekly
			@freq_interval = @freq_interval, 
			@freq_subday_type=1, 
			@freq_subday_interval=0, 
			@freq_relative_interval=0, 
			@freq_recurrence_factor=1, -- every week
			@active_start_date = @active_start_date, -- Date on which job execution can begin
			@active_start_time = @execution_time, 
			@schedule_id = @schedule_id OUTPUT

END
