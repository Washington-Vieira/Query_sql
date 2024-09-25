WITH primeira_query AS (
    SELECT
        m.data_movimento,
        pe.nome AS empresa,
        g.nome AS grupo,
        p.nome AS produto,
        SUM(m.valor) AS valor,
        SUM(m.quantidade) AS quantidade,
        SUM(m.tributos_sobre_vendas) AS tributos_sobre_vendas,
        m.preco_medio,
        COALESCE(saldo.quantidade, 0) AS qtd_saldo,
        COALESCE(saldo.valor, 0) AS custo_medio,
        m.cod_empresa,
        p.cod_classe,
    FROM
        relatorios.movimentacao_produtos_com_lucro_bruto_medio(
            0, 
            0, 
            0, 
            0, 
            '25/09/2024',  -- Data inicial
            current_date   -- Data final como data atual
        ) m
    INNER JOIN produtos p ON (m.cod_produto = p.cod_produto)
    INNER JOIN grupos g ON (p.cod_grupo = g.cod_grupo)
    INNER JOIN pessoas pe ON (m.cod_empresa = pe.cod_pessoa)
    LEFT JOIN relatorios.saldos_produtos_com_preco_medio(
            0,
            0,
            0,
            0,  -- saldo para todos os depósitos
            current_date  -- Data de referência para o saldo
        ) AS saldo
        ON (m.cod_produto = saldo.cod_produto AND m.cod_empresa = saldo.cod_empresa)
    WHERE
        m.tipo_lancamento IN ('V')
        AND p.cod_classe = 0 OR 0 = 0
        AND p.tipo IN ('U','C','M','D','P')
        AND m.data_movimento BETWEEN '25/09/2024' AND current_date
    GROUP BY
        m.data_movimento,
        pe.nome,
        p.nome,
        g.nome,
        m.preco_medio,
        saldo.quantidade,
        saldo.valor,
        m.cod_empresa,
        p.cod_classe
),
segunda_query AS (
    SELECT 
        distinct cod_pessoa,
        p.nome,
        p.cod_classe,
        p.telefone_comercial,
        MAX(data_movimento) OVER(PARTITION BY cod_pessoa) AS data_venda,
        REPLACE(CAST((NOW() - MAX(data_movimento) OVER(PARTITION BY cod_pessoa)) AS text), 'days', 'dias') AS diferenca
    FROM
        lancamentos_financeiros lf
    LEFT JOIN lancamentos_padrao lpr USING (cod_lancamento_padrao)
    LEFT JOIN pessoas p USING (cod_pessoa)
    WHERE
        tipo_lancamento = 'V'
        AND (p.cod_classe = 0 OR 0 = 0)
        AND cod_pessoa IS NOT NULL
        AND lf.cod_empresa = 0
)
SELECT 
    pq.data_movimento,
    pq.empresa,
    pq.grupo,
    pq.produto,
    pq.valor,
    pq.quantidade,
    pq.tributos_sobre_vendas,
    pq.preco_medio,
    pq.qtd_saldo,
    pq.custo_medio,
    sq.nome AS cliente,
    sq.cod_classe,
    sq.telefone_comercial,
    sq.data_venda,
    sq.diferenca
FROM 
    primeira_query pq
LEFT JOIN 
    segunda_query sq
    ON pq.cod_empresa = sq.cod_pessoa
ORDER BY 
    pq.data_movimento, sq.nome;
