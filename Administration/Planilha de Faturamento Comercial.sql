select cnpj, ds_pes,ds_gru,
	cast((select sum(pr_totalitem) from analise_nfs_itens where EMPRESA in (1,2,4) and ANO = 2018 and mes = 1  and cnpj = i.cnpj and ds_gru = i.ds_gru) as decimal(10,2)) as Jan,
	cast((select sum(pr_totalitem) from analise_nfs_itens where EMPRESA in (1,2,4) and ANO = 2018 and mes = 2  and cnpj = i.cnpj and ds_gru = i.ds_gru) as decimal(10,2)) as Fev,
	cast((select sum(pr_totalitem) from analise_nfs_itens where EMPRESA in (1,2,4) and ANO = 2018 and mes = 3 and cnpj = i.cnpj and ds_gru = i.ds_gru) as decimal(10,2)) as Mar,
	cast((select sum(pr_totalitem) from analise_nfs_itens where EMPRESA in (1,2,4) and ANO = 2018 and mes = 4 and cnpj = i.cnpj and ds_gru = i.ds_gru) as decimal(10,2)) as Abr,
	cast((select sum(pr_totalitem) from analise_nfs_itens where EMPRESA in (1,2,4) and ANO = 2018 and mes = 5 and cnpj = i.cnpj and ds_gru = i.ds_gru) as decimal(10,2)) as Mai,
	cast((select sum(pr_totalitem) from analise_nfs_itens where EMPRESA in (1,2,4) and ANO = 2018 and mes = 6  and cnpj = i.cnpj and ds_gru = i.ds_gru) as decimal(10,2)) as Jun,
	cast((select sum(pr_totalitem) from analise_nfs_itens where EMPRESA in (1,2,4) and ANO = 2018 and mes = 7  and cnpj = i.cnpj and ds_gru = i.ds_gru) as decimal(10,2)) as Jul,
	cast((select sum(pr_totalitem) from analise_nfs_itens where EMPRESA in (1,2,4) and ANO = 2018 and mes = 8  and cnpj = i.cnpj and ds_gru = i.ds_gru) as decimal(10,2)) as Ago,
	cast((select sum(pr_totalitem) from analise_nfs_itens where EMPRESA in (1,2,4) and ANO = 2018 and mes = 9  and cnpj = i.cnpj and ds_gru = i.ds_gru) as decimal(10,2)) as [Set],
	cast((select sum(pr_totalitem) from analise_nfs_itens where EMPRESA in (1,2,4) and ANO = 2018 and mes = 10  and cnpj = i.cnpj and ds_gru = i.ds_gru) as decimal(10,2)) as [Out],
	cast((select sum(pr_totalitem) from analise_nfs_itens where EMPRESA in (1,2,4) and ANO = 2018 and mes = 11 and cnpj = i.cnpj and ds_gru = i.ds_gru) as decimal(10,2)) as Nov,
	cast((select sum(pr_totalitem) from analise_nfs_itens where EMPRESA in (1,2,4) and ANO = 2018 and mes = 12 and cnpj = i.cnpj and ds_gru = i.ds_gru) as decimal(10,2)) as Dez,
	cast(SUM(PR_TOTALITEM) as decimal(10,2)) as total
from analise_nfs_itens i
WHERE EMPRESA in (1,2,4)
and ano = 2018
group by cnpj, ds_pes,ds_gru
