SELECT 
    c.nome as cliente, 
    lf.cod_pessoa,
    pr.nome as produto, 
    SUM(CASE WHEN lp.tipo_lancamento = 'X' THEN (-1)*lp.quantidade ELSE lp.quantidade END) AS total_qtde, 
    SUM(CASE WHEN lp.tipo_lancamento = 'X' THEN (-1)*lp.valor ELSE lp.valor END) AS total_valor
FROM 
    public.lancamentos_produtos lp
LEFT JOIN 
    public.produtos pr ON (lp.cod_produto = pr.cod_produto)
LEFT JOIN 
    public.grupos gr ON (pr.cod_grupo = gr.cod_grupo)
LEFT JOIN 
    public.depositos d ON (lp.cod_deposito = d.cod_deposito and lp.cod_empresa = d.cod_empresa)
LEFT JOIN 
    public.lancamentos_financeiros lf ON (lp.cod_lanc_financeiro = lf.cod_lanc_financeiro)
LEFT JOIN 
    public.pessoas c ON (lf.cod_pessoa = c.cod_pessoa)    
WHERE
    lp.tipo_lancamento in ('V', 'X') and
    lp.cancelado = False and 
    lp.situacao = 2 and
    lp.data_movimento = '20/09/2024' and lp.data_movimento = CURRENT_DATE and
    (lp.cod_empresa = 0 or 0 = 0) and
    (lp.cod_deposito = 0 or 0 = 0) and
    (0 = '0' OR gr.id like 0 || '%') and
    (lp.cod_produto = 0 or 0 = 0) and      
    (lf.cod_pessoa = 0 or 0 = 0)  
group by 
    c.nome, 
    lf.cod_pessoa, 
    pr.nome                                                 
order by 
    lf.cod_pessoa, 
    pr.nome