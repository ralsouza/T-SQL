USE [DB_Sicredi]
GO
/****** Object:  StoredProcedure [dbo].[pa_ArmazenaTaxaAbandonos]    Script Date: 01/04/2019 08:28:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================================
-- Author:		Rafael Lima
-- Create date: 10/03/2017
-- Description:	Grava os dados de KPIs na tabela de fatos [dbo].[FT_KPI]
-- ======================================================================
ALTER PROCEDURE [dbo].[pa_ArmazenaTaxaAbandonos] 
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

DECLARE @TA AS DECIMAL(18,10), --Armazena o Nível de Serviço
		@DataEnt AS DATE, --Recebe a data do primeiro dia do mês anterior, no formato DATE
		@Equipe AS INT, --Recebe o ID da equipe
		@DataRet AS INT, --Retorna o ID da data pesquisada pela função ufn_RetornaIDData
		@AtingiuMeta AS INT, --Armazena o resultado da verificação de NMS
		@IDIndicador AS INT;

--Configura o ID da equipe
	SET @Equipe = @IDEquipe;

--Configura a data de entrada no formato DATE
	SET @DataEnt = (SELECT CONVERT(DATE,DATEADD(m,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()), 0))));

--Aciona a função para buscar o ID da data configurada acima
	SET @DataRet = (SELECT [dbo].[ufn_RetornaIDData](@DataEnt) AS IDData);

--Seleciona o Nível de Serviço da VIEW
	SET @TA=(SELECT [TaxaAbandonos] FROM [dbo].[vw_TaxaAbandonos_Agregado]WHERE [Equipe] = (SELECT [Nome] FROM [dbo].[DIM_EQUIPES] WHERE [IDEquipe] = @Equipe) AND [DataAtendidas] = CONVERT(DATE,DATEADD(m,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()), 0))));

--Valida se atingiu o NMS
BEGIN
	IF @Equipe = 1 GOTO Equipe_1;
	IF @Equipe = 6 GOTO Equipe_6;
END
	Equipe_1:
	IF @Equipe = 1
		IF @TA <= (SELECT [NMS] FROM [dbo].[DIM_INDICADORES] WHERE IDIndicador = 4)
		BEGIN
			SET @AtingiuMeta = 1;
			SET @IDIndicador = 4;
		END
		ELSE
			SET @AtingiuMeta = 0;
			SET @IDIndicador = 4;
	GOTO Insere_Dados;

	Equipe_6:
	IF @Equipe = 6
		IF @TA <= (SELECT [NMS] FROM [dbo].[DIM_INDICADORES] WHERE IDIndicador = 8)
		BEGIN
			SET @AtingiuMeta = 1;
			SET @IDIndicador = 8;
		END
		ELSE
			SET @AtingiuMeta = 0;
			SET @IDIndicador = 8;
	GOTO Insere_Dados;

--Insere os dados na tabela de fatos
	Insere_Dados:
	INSERT INTO [dbo].[FT_KPI] VALUES(@IDIndicador,@DataRet,@Equipe,@TA,@AtingiuMeta,NULL);

--Retorna Saída de Variáveis
	PRINT '                                           '
	PRINT 'OS SEGUINTES DADOS FORAM INSERIDOS NO BANCO'
	PRINT '==========================================='
	PRINT '# Taxa de Abandonos (Necessário Arredondar, formato 00,00%'
	PRINT @TA;
	PRINT '-------------------------------------------'
	PRINT '# ID da Data de Apuração'
	PRINT @DataRet;
	PRINT '-------------------------------------------'
	PRINT '# Atingiu meta? 1-Sim 0-Não'
	PRINT @AtingiuMeta;
END
