with ChamadosEquipes(Equipe,Abertos,Encerrados,EmAtendimento,[Atrasados(Solução)],[NoPrazo(Solução)]) as
(select 
       case
			when [nmequipe] LIKE  '%Alimentação'							  then 'Alimentação'
			when [nmequipe] LIKE  '%Uniforme'								  then 'Uniforme'
			when [nmequipe] LIKE  '%Epis'									  then 'Epis'
			when [nmequipe] LIKE  '%Limpeza Conservação e Jardinagem'		  then 'Limpeza Conservação e Jardinagem'
			when [nmequipe] LIKE  '%Segurança Patrimonial'					  then 'Segurança Patrimonial'
			when [nmequipe] LIKE  '%Controle de Acesso'						  then 'Controle de Acesso'
			when [nmequipe] LIKE  '%Chaves e carimbo'						  then 'Chaves e carimbo'
			when [nmequipe] LIKE  '%Desvios de Fornecedores'				  then 'Desvios de Fornecedores'
			when [nmequipe] LIKE  '%Controle de Pragas'						  then 'Controle de Pragas'
			when [nmequipe] LIKE  '%Correios e Malotes'					      then 'Correios e Malotes'
			when [nmequipe] LIKE  '%Manutenção Civil Elétrica e Refrigeração' then 'Manutenção Civil Elétrica e Refrigeração'
			when [nmequipe] LIKE  '%Pequenas Mudanças'						  then 'Pequenas Mudanças'
			when [nmequipe] LIKE  '%Qualidade CASP'							  then 'Qualidade CASP'
			when [nmequipe] LIKE  '%Serviço de Motoboy'						  then 'Serviço de Motoboy'
			when [nmequipe] LIKE  '%Transporte%'						      then 'Transporte'
	   end as Equipe,
	   count(cdchamado) as Abertos,
	   sum(case when cdsituacao=7  then 1 else 0 end) as Encerrados,
	   sum(case when cdsituacao=2  then 1 else 0 end) as EmAtendimento,
	   sum(case when idatrasoservico='Y' then 1 else 0 end) as [Atrasados(Solução)],
	   sum(case when idatrasoservico='N' then 1 else 0 end) as [NoPrazo(Solução)]
from vw_hd_chamado13
where dtchamado >= @dtinicial and dtchamado <= @dtfinal
	 AND cdtipochamado LIKE  @nmequipe
     AND([nmequipe] LIKE  '%Alimentação' 
	  OR [nmequipe] LIKE  '%Uniforme' 
	  OR [nmequipe] LIKE  '%Epis' 
	  OR [nmequipe] LIKE  '%Limpeza Conservação e Jardinagem' 
	  OR [nmequipe] LIKE  '%Segurança Patrimonial' 
	  OR [nmequipe] LIKE  '%Controle de Acesso' 
	  OR [nmequipe] LIKE  '%Chaves e carimbo' 
	  OR [nmequipe] LIKE  '%Pequenas Reformas' 
      OR [nmequipe] LIKE  '%Desvios de Fornecedores' 
	  OR [nmequipe] LIKE  '%Controle de Pragas' 
	  OR [nmequipe] LIKE  '%Correios e Malotes' 
	  OR [nmequipe] LIKE  '%Manutenção Civil Elétrica e Refrigeração' 
      OR [nmequipe] LIKE  '%Pequenas Mudanças' 
      OR [nmequipe] LIKE  '%Qualidade CASP' 
      OR [nmequipe] LIKE  '%Serviço de Motoboy'
	  OR [nmequipe] LIKE  '%Transporte%')
group by nmequipe)
select Equipe,
	   Abertos,
	   Encerrados as Fechados,
	   EmAtendimento as [Em Atendimento],
	   [NoPrazo(Solução)] as [Encerrados no Prazo],
	   [Atrasados(Solução)] as [Encerrados Fora do Prazo],
	   CAST(ROUND((CAST(ROUND([Atrasados(Solução)],2)  AS DECIMAL(18,10))/CAST(ROUND(Abertos,2) AS DECIMAL(18,10))),2) AS DECIMAL(18,10)) AS [Percentual de Atraso] 
from ChamadosEquipes
