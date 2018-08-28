-- 1 -- Indique por ordem alfabética descendente o nome de todos os produtos
--      com classificação de comércio justo igual ou superior a B – em que A
--      é a melhor classificação.

SELECT p.nome, p.comercioJusto
  FROM Produto p
WHERE (p.comercioJusto <= 'B')
ORDER BY (p.nome) DESC;






SELECT c.nome
FROM Consumidor c, Dependente d
WHERE (c.numero = d.consumidor)
AND (c.numero NOT IN d.consumidor)
GROUP BY(c.nome);

-- 2 -- Indique o sexo e a idade de cada um dos dependentes do
--      consumidor com email 'marcolina@hotmail.com'.
SELECT d.sexo, year(curdate())-year(d.nascimento) as idade
  FROM Dependente d, Consumidor c
WHERE (c.numero = d.consumidor)
  AND (c.email = 'marcolina@hotmail.com');



-- 3 -- Email dos consumidores que compraram gasolina.

SELECT c.email
  FROM Consumidor c, Produto p, compra co
WHERE (c.numero = co.consumidor)
  AND (p.codigo = co.produto and p.marca = co.prodmarca)
  AND (p.nome LIKE 'gasolina')
GROUP BY (c.email);



-- 4 -- Email do(s) consumidor(es) que comprou mais gasolina.

    SELECT c.email
  FROM Consumidor c, Produto p, compra co
WHERE (c.numero = co.consumidor)
AND (p.codigo = co.produto and p.marca = co.prodmarca)
  AND (p.nome LIKE 'gasolina')
    AND co.quantidade = (select max(quantidade) from compra co, Produto p where p.codigo = co.produto and p.marca = co.prodmarca and p.nome='Gasolina')
    group by c.email;



-- 5 -- Determine a pegada ecológica associada a cada um dos produtos
--      do tipo lar.

SELECT p.nome, sum(e.pegadaecologica * (com.percentagem/100)) as Val
  FROM Elemento e, composto com, Produto p
WHERE (e.codigo = com.elemento)
  AND (com.produto = p.codigo and com.prodMarca=p.marca)
  AND (p.tipo = "lar")
GROUP BY(p.nome)


-- 6 -- Nome do(s) produto(s) mais prejudicial para a saúde –
--      quanto maiores os valores no atributo “saúde”, mais
--      prejudiciais são para a mesma.

SELECT p.nome
  FROM Produto p, Elemento e, composto com
WHERE (p.codigo = com.produto)
AND (com.produto = p.codigo and com.prodmarca=p.marca)
  AND (e.codigo = com.elemento)
  AND e.saude = (select max(e1.saude) from Elemento e1)


-- 7 -- Liste o sexo e a idade de todas as pessoas abrangidas por
--      esta base de dados – consumidores e seus dependentes.

SELECT sexo, year(curdate())-year(nascimento) as idade
  FROM Consumidor
UNION
SELECT sexo, year(curdate())-year(nascimento) as idade
  FROM Dependente


-- 8  -- Email do(s) consumidor(es) que registou compras implicando menor
--       pegada ecológica – ter em conta o número de dependentes, dividindo
--       a mesma pelo número de pessoas no agregado (consumidor + número de dependentes).

CREATE VIEW v_PECO
AS
SELECT p.nome, sum(pegadaecologica*(percentagem/100)) as Val
  FROM Elemento e, composto com, Produto p
WHERE (e.codigo = com.elemento)
  AND (com.produto = p.codigo and com.prodmarca=p.marca)
group by p.nome;


CREATE VIEW v_AgFamiliar
AS
SELECT c.numero, count(*)+ 1 AS n_agrFam
FROM Consumidor c, Dependente d
WHERE (d.consumidor = c.numero)
UNION
SELECT c.numero, 1 AS n_agrFam
FROM Consumidor c, Dependente d
WHERE (d.consumidor != c.numero)
GROUP BY c.numero;


CREATE VIEW v_SumCompras
AS
SELECT c.email, SUM(co.quantidade*pe.val/af.n_agrFam) AS sum_comp
  FROM Consumidor c, Produto p, compra co, v_PECO pe, v_AgFamiliar af
WHERE (p.codigo = co.produto and p.marca = co.prodmarca)
  AND (p.nome = pe.nome)
  AND (c.numero = co.consumidor)
  AND (af.numero = c.numero)
GROUP BY (co.consumidor);


SELECT sc.email
  FROM v_SumCompras sc
WHERE sc.sum_comp = (SELECT MIN(sc1.sum_comp)
                     FROM v_SumCompras sc1);


-- 9 -- Email dos consumidores que realizaram compras que incluem todos os
--      elementos mencionados na tabela “Elemento”.
CREATE VIEW com_el
AS
SELECT m.count(distinct com.elemento) AS n_el
FROM Elemento e, composto com, compra co, Produto p, Consumidor c
WHERE (e.codigo = com.elemento)
AND(c.numero=co.consumidor)
AND (com.produto = co.produto)
AND(com.prodMarca = co.prodMarca)
AND (com.produto = p.codigo and com.prodmarca=p.marca)
GROUP BY (c.numero);




SELECT c.email
FROM Consumidor c, compra co, Produto p, Elemento e, composto com , com_el cel
WHERE (cel.n_el = (SELECT count(*) from Elemento e))
  AND (cel.numero = c.numero)
GROUP BY (c.email);
