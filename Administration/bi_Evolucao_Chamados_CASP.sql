USE [Qualitor]
GO
/****** Object:  StoredProcedure [dbo].[bi_Evolucao_Chamados_CASP]    Script Date: 01/04/2019 08:30:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafael Lima de Souza - ConstatLM2
-- Create date: 2017-01-12
-- Description:	Consulta para retornar a quantidade de chamados, por regional e por situação.
-- =============================================

ALTER PROCEDURE [dbo].[bi_Evolucao_Chamados_CASP] 
	
	@dtinicial		nvarchar(10),
    @dtfinal		nvarchar(10),
	@nmequipe		tinyint
	
AS
BEGIN
	SET NOCOUNT ON;

	declare @sql			nvarchar(4000);
	declare @ParmDefinition nvarchar(500);

    SET @sql= N'select 
			cast(vw13.dtchamado as date) as dataabertura,
			nmsituacao as situacao, 
			count(vw13.cdchamado) as qtdchamados
			from vw_hd_chamado13 vw13
			where 
				vw13.dtchamado >= @dtinicial and vw13.dtchamado <= @dtfinal
				and vw13.cdtipochamado in (@regional) 
				and vw13.cdsituacao not in (8) 
				and vw13.cdcategoria1 in (1500,1501,1503,1504,1505,1506,1727,7002,7086,7088,7090,7108,7128,9254) ';

	if (@nmequipe = 4)
		begin
			set @sql = @sql + N'and vw13.cdcategoria1 not in (1727,7108,7128)
							   and vw13.cdcategoria2 in (1510,1511,1514,1517,1518,1519,1520,1521,1522,1523,1524,1525,1527
														,1530,1531,1532,1533,1534,1535,1536,1537,1671,1728,7003,7043,7078
														,7087,7089,7091,7092,7109,7116,7123,7134,7136,7137,7138,7139,7145
														,7146,7147,7162,8859,9045,9255,9257,9258)	
							   group by  cast(vw13.dtchamado as date), nmsituacao
							   order by  cast(vw13.dtchamado as date);';
		end
	else if (@nmequipe = 5)
		begin
			set @sql = @sql + N'and vw13.cdcategoria1 in (7108,7128)
							   and vw13.cdcategoria2 in (1510,1511,1514,1517,1518,1519,1520,1521,1522,1523,1524,1525,1527
														,1530,1531,1532,1533,1534,1535,1536,1537,1671,1728,7003,7043,7078
														,7087,7089,7091,7092,7109,7116,7123,7134,7136,7137,7138,7139,7145
														,7146,7147,7162,8859,9045,9255,9257,9258)	
							   group by  cast(vw13.dtchamado as date), nmsituacao
							   order by  cast(vw13.dtchamado as date);';
		end
	else
		begin
			set @sql = @sql + N'and vw13.cdcategoria1 not in (7108,7128)
							   and vw13.cdcategoria2 in (1510,1511,1514,1517,1518,1519,1520,1521,1522,1523,1524,1525,1527
														,1530,1531,1532,1533,1534,1535,1536,1537,1671,1728,7003,7043,7078
														,7087,7089,7091,7092,7109,7116,7123,7134,7136,7137,7138,7139,7145
														,7146,7147,7162,8859,9045,9255,9257,9258)	
							   group by  cast(vw13.dtchamado as date), nmsituacao
							   order by  cast(vw13.dtchamado as date);';
		end

	SET @ParmDefinition = N'@dtinicial nvarchar(9),@dtfinal nvarchar(9),@regional nchar(1)';

	execute sp_executesql @sql,@ParmDefinition,@dtinicial = @dtinicial,@dtfinal = @dtfinal,@regional = @nmequipe;
END
