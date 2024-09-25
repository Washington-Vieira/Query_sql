# Quantidad de Vendas, receita, tributos, periódo, preço médio, estoque, valor de estoque, cliente (tudo relacionado) ... 

SELECT
    m.data_movimento,
    c.nome AS cliente,
    lf.cod_pessoa,
    pr.nome AS produto,
    SUM(CASE WHEN lp.tipo_lancamento = 'X' THEN (-1) * lp.quantidade ELSE lp.quantidade END) AS total_qtde, 
    SUM(CASE WHEN lp.tipo_lancamento = 'X' THEN (-1) * lp.valor ELSE lp.valor END) AS total_valor,
    pe.nome AS empresa,
    g.nome AS grupo,
    SUM(m.valor) AS valor,
    SUM(m.quantidade) AS quantidade,
    SUM(m.tributos_sobre_vendas) AS tributos_sobre_vendas,
    m.preco_medio,
    COALESCE(saldo.quantidade, 0) AS qtd_saldo,
    COALESCE(saldo.valor, 0) AS custo_medio

FROM
    public.lancamentos_produtos lp
JOIN relatorios.movimentacao_produtos_com_lucro_bruto_medio(
        0, 
        0, 
        0, 
        0, 
        '24/09/2024',  -- Data inicial
        current_date   -- Data final como data atual
    ) m ON (lp.cod_produto = m.cod_produto)  -- Assumindo que cod_produto conecta as duas tabelas
LEFT JOIN public.produtos pr ON (lp.cod_produto = pr.cod_produto)
LEFT JOIN public.lancamentos_financeiros lf ON (lp.cod_lanc_financeiro = lf.cod_lanc_financeiro)
LEFT JOIN public.pessoas c ON (lf.cod_pessoa = c.cod_pessoa)
INNER JOIN grupos g ON (pr.cod_grupo = g.cod_grupo)
INNER JOIN pessoas pe ON (m.cod_empresa = pe.cod_pessoa)
LEFT JOIN relatorios.saldos_produtos_com_preco_medio(
        0,
        0,
        0,
        0,  -- saldo para todos os depósitos
        current_date  -- Data de referência para o saldo
    ) AS saldo ON (m.cod_produto = saldo.cod_produto AND m.cod_empresa = saldo.cod_empresa)
WHERE
    lp.tipo_lancamento IN ('V', 'X') AND
    m.tipo_lancamento IN ('V') AND
    pr.tipo IN ('U','C','M','D','P') AND
    m.data_movimento BETWEEN '24/09/2024' AND current_date

GROUP BY
    m.data_movimento,
    pe.nome,
    pr.nome,  -- Use apenas um alias para a tabela de produtos
    g.nome,
    m.preco_medio,
    saldo.quantidade,
    saldo.valor,
    c.nome, 
    lf.cod_pessoa;
