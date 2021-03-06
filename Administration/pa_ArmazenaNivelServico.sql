USE [DB_Sicredi]
GO
/****** Object:  StoredProcedure [dbo].[pa_ArmazenaNivelServico]    Script Date: 31/03/2019 12:12:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================================
-- Author:		Rafael Lima
-- Create date: 10/03/2017
-- Description:	Grava os dados de KPIs na tabela de fatos [dbo].[FT_KPI]
-- ======================================================================
ALTER PROCEDURE [dbo].[pa_ArmazenaNivelServico] 
	-- Recebe o IDEquipe

		--IDs das Equipes:
			--1 Service Desk 8022
			--5 Apoio de Campo 8011
			--6 Service Desk 8000
	@IDEquipe INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @NS AS DECIMAL(18,10), --Armazena o Nível de Serviço
		@DataEnt AS DATE, --Recebe a data do primeiro dia do mês anterior, no formato DATE
		@Equipe AS INT, --Recebe o ID da equipe
		@DataRet AS INT, --Retorna o ID da data pesquisada pela função ufn_RetornaIDData
		@AtingiuNMS AS INT, --Armazena o resultado da verificação de NMS
		@IDIndicador AS INT;

--Configura o ID da equipe
	SET @Equipe = @IDEquipe;
--Configura a data de entrada no formato DATE
	SET @DataEnt = (SELECT CONVERT(DATE,DATEADD(m,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()), 0))));
--Aciona a função para buscar o ID da data configurada acima
	SET @DataRet = (SELECT [dbo].[ufn_RetornaIDData](@DataEnt) AS IDData);
--Seleciona o Nível de Serviço da VIEW
BEGIN
	IF @Equipe = 5
		BEGIN
			SET @NS=(SELECT [NivelServico90seg] FROM [dbo].[vw_NivelServico_Agredado] WHERE [Equipe] = (SELECT [Nome] FROM [dbo].[DIM_EQUIPES] WHERE [IDEquipe] = @Equipe) AND [DataAtendidas] = CONVERT(DATE,DATEADD(m,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()), 0))));
		END
	ELSE
		BEGIN
			SET @NS=(SELECT [NivelServico] FROM [dbo].[vw_NivelServico_Agredado] WHERE [Equipe] = (SELECT [Nome] FROM [dbo].[DIM_EQUIPES] WHERE [IDEquipe] = @Equipe) AND [DataAtendidas] = CONVERT(DATE,DATEADD(m,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()), 0))));
		END
END
--Valida se atingiu o NMS
BEGIN
	IF @Equipe = 1 GOTO Equipe_1;
	IF @Equipe = 5 GOTO Equipe_5;
	IF @Equipe = 6 GOTO Equipe_6;
END

	Equipe_1:
	IF @Equipe = 1
		IF @NS >= (SELECT [NMS] FROM [dbo].[DIM_INDICADORES] WHERE IDIndicador = 2)
		BEGIN
			SET @AtingiuNMS = 1;
			SET @IDIndicador = 2;
		END
		ELSE
			SET @AtingiuNMS = 0;
			SET @IDIndicador = 2;
	GOTO Insere_Dados;

	Equipe_5:
	IF @Equipe = 5
		IF @NS >= (SELECT [NMS] FROM [dbo].[DIM_INDICADORES] WHERE IDIndicador = 14)
		BEGIN
			SET @AtingiuNMS = 1;
			SET @IDIndicador = 14;
		END
		ELSE
			SET @AtingiuNMS = 0;
			SET @IDIndicador = 14;
	GOTO Insere_Dados;

	Equipe_6:
	IF @Equipe = 6
		IF @NS >= (SELECT [NMS] FROM [dbo].[DIM_INDICADORES] WHERE IDIndicador = 6)
		BEGIN
			SET @AtingiuNMS = 1;
			SET @IDIndicador = 6;
		END
		ELSE
			SET @AtingiuNMS = 0;
			SET @IDIndicador = 6;
	GOTO Insere_Dados;

--Insere os dados na tabela de fatos
	Insere_Dados:
	INSERT INTO [dbo].[FT_KPI] VALUES(@IDIndicador,@DataRet,@Equipe,@NS,@AtingiuNMS,NULL);

--Retorna Saída de Variáveis
	PRINT '                                           '
	PRINT '==========================================='
	PRINT 'OS SEGUINTES DADOS FORAM INSERIDOS NO BANCO'
	PRINT '==========================================='
	PRINT '# Nível de Serviço (Necessário Arredondar, formato 00,00%'
	PRINT @NS;
	PRINT '-------------------------------------------'
	PRINT '# ID da Data de Apuração'
	PRINT @DataRet;
	PRINT '-------------------------------------------'
	PRINT '# Atingiu NMS? 1-Sim 0-Não'
	PRINT @AtingiuNMS;
END
