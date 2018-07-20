SELECT 
	   nmusuarioacompanhamento AS Consultor
	  ,nmcliente AS Cliente
	  ,CAST(CAST(SUM(nrduracao) AS int) AS varchar(MAX)) + ':' + RIGHT(CAST(CAST(ROUND(100 + (SUM(nrduracao) - CAST(SUM(nrduracao) AS int)) * 60, 2) AS int) AS varchar(MAX)),2) AS TotalHoras
	  ,SUM(nrduracao) AS nrduracao
FROM
	vw_hd_acompanhamento03
WHERE
	    CAST(dtacompanhamento AS date) >= @dtinicio and CAST(dtacompanhamento AS date) <= @dtfinal 
   AND cdequipe IN (1, 24, 26, 21,26,27)
   AND cdcliente NOT IN (1)
   AND  cdsituacao != 8
   AND cdtipoacompanhamento IN(2,3,4,5,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40) 
GROUP BY nmusuarioacompanhamento,nmcliente
ORDER BY nmusuarioacompanhamento
