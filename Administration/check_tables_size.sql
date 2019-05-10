-- ==============================================================================
-- Consulta para retornar o tamanho das tabelas do banco de dados, unidade em mb
-- A ordenação definida é used_mb de maior para menor
-- 
-- DESCRIÇÃO DAS COLUNAS:
--		* schemaname: Nome do esquema onde encontra-se a tabela
--		* tablename:  Nome da tabela medida
--		* rowcounts:  Contagem da quantidade de linhas contidas na tabela
--		* used_MB:	Quantidade em megabytes em uso na tabela
--		* unused_MB:  Quantidade em megabytes disponíveis na tabela
--		* total_MB:   Tamanho total da tabela
-- ==============================================================================

with cte1
as
(
	select
		 s.name as schemaname
		,t.name as tablename
		,p.rows as rowcounts
		,cast(round((sum(a.used_pages) / 128.00), 2) as numeric(36, 2)) as used_MB
		,cast(round((sum(a.total_pages) - sum(a.used_pages)) / 128.00, 2) as numeric(36, 2)) as unused_MB
		,cast(round((sum(a.total_pages) / 128.00), 2) as numeric(36, 2)) as total_MB
	from 
		sys.tables t
	inner join 
		sys.indexes i 
			on t.object_id = i.object_id
	inner join 
		sys.partitions p 
			on i.object_id = p.object_id and i.index_id = p.index_id
	inner join 
		sys.allocation_units a 
			on p.partition_id = a.container_id
	inner join 
		sys.schemas s 
			on t.schema_id = s.schema_id
	group by 
		 t.name
		,s.name
		,p.rows
)
select 
	* 
from 
	cte1 
order by 
	used_mb desc
