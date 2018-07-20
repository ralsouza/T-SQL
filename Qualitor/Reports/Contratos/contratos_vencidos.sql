--CONTATOS VENCIDOS COM 30 DIAS OU MAIS

WITH cte
AS
(
	SELECT nmcontrato
		  ,CAST(dtassinatura AS date) dtassinatura
		  ,CAST(dtvencimento AS date) dtvencimento
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
   ,CONVERT(VARCHAR(10), dtvencimento,103) AS [Vencido em]
   ,ABS(DATEDIFF(day,GETDATE(),dtvencimento)) AS [Qtd. dias vencido]
FROM 
	cte 
WHERE 
	idvencido = 'Y'
