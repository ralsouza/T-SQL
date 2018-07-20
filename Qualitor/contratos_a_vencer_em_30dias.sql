--CONTRATOS A VENCER EM 30 DIAS

WITH cte
AS
(
	SELECT nmcontrato
		  ,dtassinatura
		  ,dtvencimento
		  ,CASE 
				WHEN (iv_contrato.dtvencimento < GETDATE()) 
					THEN 'Y' 
					ELSE 'N' 
		   END AS idvencido 
	FROM iv_contrato 
		LEFT OUTER JOIN ad_fornecedor 
			ON ad_fornecedor.cdfornecedor = iv_contrato.cdfornecedor 
		LEFT OUTER JOIN ad_usuario 
			ON ad_usuario.cdusuario = iv_contrato.cdusuario
)
SELECT 
	nmcontrato	 AS [Contrato]
   ,CONVERT(VARCHAR(10), dtvencimento,103) AS [Vencerá em]
   ,DATEDIFF(day,GETDATE(),dtvencimento) AS [Qtd. dias até o vencimento]
FROM 
	cte 
WHERE
		dtvencimento <= DATEADD(DAY,30, GETDATE())
	AND idvencido = 'N'
