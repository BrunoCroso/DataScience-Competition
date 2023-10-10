-- Pergunta 1. Quantas compras foram feitas no total?

select count(order_id) as 'Total de compras' from tb_orders;

-- Resposta: 99441

-- Pergunta 2. Quantos vendedores temos? E quantos compradores?

select count(distinct seller_id) as 'Número de vendedores' from tb_sellers;
select count(distinct customer_unique_id) as 'Número de compradores' from tb_customers;

-- Resposta: 3095 vendedores e 96096 compradores 

-- Pergunta 3. Qual o produto vendido mais pesado?

select max(product_weight_g) as 'Maior peso (em gramas)' from tb_products;
select product_category_name as 'Categoria', product_id as 'ID do produto' from tb_products where product_weight_g = 40425;

-- Resposta: O produto mais vendido é o de categoria cama_mesa_banho e id 26644690fde745fc4654719c3904e1db, pesando 40425g

-- Pergunta 4. Quantas compras foram entregues?

select count(order_status) as 'Número de compras entregues' from tb_orders where order_status = 'delivered';

-- Resposta: 96478 compras foram entregues

-- Pergunta 5. Qual o ticket médio de cada método de pagamento?

select distinct payment_type as 'Tipos de pagamento' from tb_order_payments;
select avg(payment_value) as 'Ticket Médio para cartões de crédito' from tb_order_payments where payment_type = ('credit_card');
select avg(payment_value) as 'Ticket Médio para boletos' from tb_order_payments where payment_type = ('boleto');
select avg(payment_value) as 'Ticket Médio para vouchers' from tb_order_payments where payment_type = ('voucher');
select avg(payment_value) as 'Ticket Médio para cartões de débito' from tb_order_payments where payment_type = ('debit_card');
select avg(payment_value) as 'Ticket Médio para pagamentos não definidos' from tb_order_payments where payment_type = ('not_defined');

-- Resposta: 163,32 reais para cartão de crédito, 145,03 reais para boletos, 65,70 reais para voucher e 142,57 reais para cartão de débito

-- Pergunta 6. Qual a média de itens por compra?

select avg(order_item_id) as 'Média de itens por compra' from tb_order_items;

-- Resposta: Aproximadamente 1,2 itens por compra

-- Pergunta 7. Qual estado possui mais compras? E qual possui menos?

select distinct customer_state as 'Estado', count(customer_state) as 'Compras no estado' from tb_customers
group by (customer_state)
order by count(customer_state);

-- Resposta: O estado com mais compras é São Paulo e o com menos compras é Roraima

-- Pergunta 8. Qual estado possui mais vendas? E qual possui menos?

select distinct  tb_sellers.seller_state as 'Estado', count(tb_sellers.seller_state) as 'Vendas no estado'
from tb_order_items join tb_sellers
on tb_order_items.seller_id = tb_sellers.seller_id
group by tb_sellers.seller_state
order by count(tb_sellers.seller_state);

-- Resposta: O estado com mais vendas é São paulo e o com menos vendas é o Acre

-- Pergunta 9. Qual foi o valor total das compras realizadas no primeiro semestre de 2018?

select sum(tb_order_payments.payment_value) as 'Valor total das compras realizadas no primeiro semestre de 2018'
from tb_order_payments join tb_orders
on tb_orders.order_id = tb_order_payments.order_id
where tb_orders.order_purchase_timestamp between '2018-01-01' and '2018-07-01';

-- Resposta: Aproximadamente 6.605.767,76 reais

-- Pergunta 10. Há pedidos reembolsados? Se sim, quantos?

select count(*) from tb_orders
where order_status = 'canceled';

-- Resposta: Assumindo que os pedidos cancelados foram reembolsados, tem-se 625 pedidos reembolsados

-- Pergunta 11. Ordene os estados pelo tempo de demora da chegada do pedido do maior pro menor

select avg(julianday(tb_orders.order_delivered_customer_date) - julianday(tb_orders.order_purchase_timestamp)) as 'Média de tempo de entrega (em dias)', tb_customers.customer_state as 'Estado do cliente'
from tb_orders join tb_customers
on tb_orders.customer_id = tb_customers.customer_id
group by tb_customers.customer_state
order by avg(julianday(tb_orders.order_delivered_customer_date) - julianday(tb_orders.order_purchase_timestamp)) desc;

-- Resposta: No código

-- Pergunta 12. Ordene as categorias com mais vendas da mais vendida pra menos vendida

select tb_products.product_category_name as 'Categoria', count(tb_order_items.product_id) as 'Número de vendas'
from tb_order_items join tb_products
on tb_order_items.product_id = tb_products.product_id
group by tb_products.product_category_name
order by count(tb_order_items.product_id) desc;

-- Resposta: No código

-- Pergunta 13. Quais os 10 compradores que compraram mais itens?

select tb_customers.customer_unique_id as 'ID do cliente', count(product_id) as 'Número de compras'
from tb_customers join tb_orders on tb_customers.customer_id = tb_orders.customer_id
join tb_order_items on tb_orders.order_id = tb_order_items.order_id
group by tb_customers.customer_unique_id
order by count(product_id) desc limit 10;

-- Resposta: No código

-- Pergunta 14. Quais são os 5 vendedores com maior review score?

select tb_sellers.seller_id as 'ID do vendedor', avg(tb_order_reviews.review_score) as 'Review Score medio', count(tb_sellers.seller_id) as 'Número de vendas'
from tb_order_reviews join tb_order_items on tb_order_reviews.order_id = tb_order_items.order_id
join tb_sellers on tb_order_items.seller_id = tb_sellers.seller_id
group by tb_sellers.seller_id
order by avg(tb_order_reviews.review_score) desc, count(tb_sellers.seller_id) desc limit 5;
-- Como há mais de 5 vendedores com média máxima, foi selecionado os 5 com nota máxima e maior número de vendas.

-- Resposta: No código

-- Pergunta 15. Qual a taxa de conversão de cada método de pagamento?

with total as
 (
    select count(*) as 'Total', tb_order_payments.payment_type
    from tb_orders join tb_order_payments
    on tb_orders.order_id = tb_order_payments.order_id
    group by tb_order_payments.payment_type
 ), entregados as
 (
    select count(*) as "Entregados", tb_order_payments.payment_type
    from tb_orders join tb_order_payments
    on tb_orders.order_id = tb_order_payments.order_id
    where tb_orders.order_status = 'delivered'
    group by tb_order_payments.payment_type
 )


select total.payment_type as 'Método de pagamento',
    total.Total as 'Total de compras realizadas',
    entregados.Entregados as 'Total de compras entregues',
    ((100*entregados.Entregados)/total.Total) as 'Taxa de conversão (%)'


from total join entregados on total.payment_type = entregados.payment_type
;

-- Resposta: No código

-- Pergunta 16. Qual é o mês do ano com maior média de vendas?

select strftime('%m', order_purchase_timestamp) as 'Mês', count(order_id)/count(distinct strftime('%Y', order_purchase_timestamp)) as 'Média de vendas no mês' from tb_orders
group by strftime('%m', order_purchase_timestamp)
order by count(order_id) desc
;

-- Resposta: O mês com maior média de vendas é Agosto

-- Pergunta 17. Qual é o método de pagamento mais usado em cada estado? Qual é o share
-- (porcentagem do total) desse método de pagamento?

with Credito as 
    (select tb_customers.customer_state, count(tb_order_payments.payment_type) as 'cartao_credito'
    from tb_order_payments join tb_orders on tb_order_payments.order_id = tb_orders.order_id
    join tb_customers on tb_orders.customer_id = tb_customers.customer_id
    where tb_order_payments.payment_type = 'credit_card'
    group by tb_customers.customer_state
), Debito as 
    (select tb_customers.customer_state, count(tb_order_payments.payment_type) as 'cartao_debito'
    from tb_order_payments join tb_orders on tb_order_payments.order_id = tb_orders.order_id
    join tb_customers on tb_orders.customer_id = tb_customers.customer_id
    where tb_order_payments.payment_type = 'debit_card'
    group by tb_customers.customer_state
), Boletos as 
    (select tb_customers.customer_state, count(tb_order_payments.payment_type) as 'boletos'
    from tb_order_payments join tb_orders on tb_order_payments.order_id = tb_orders.order_id
    join tb_customers on tb_orders.customer_id = tb_customers.customer_id
    where tb_order_payments.payment_type = 'boleto'
    group by tb_customers.customer_state
), Voucher as 
    (select tb_customers.customer_state, count(tb_order_payments.payment_type) as 'voucher'
    from tb_order_payments join tb_orders on tb_order_payments.order_id = tb_orders.order_id
    join tb_customers on tb_orders.customer_id = tb_customers.customer_id
    where tb_order_payments.payment_type = 'voucher'
    group by tb_customers.customer_state
)

select Credito.customer_state as 'Estado', Credito.cartao_credito, Debito.cartao_debito, Boletos.boletos, Voucher.voucher
from Credito join Debito on Credito.customer_state = Debito.customer_state
join Boletos on Credito.customer_state = Boletos.customer_state
join Voucher on Credito.customer_state = Voucher.customer_state;

with Credito as 
    (select tb_customers.customer_state, count(tb_order_payments.payment_type) as 'cartao_credito'
    from tb_order_payments join tb_orders on tb_order_payments.order_id = tb_orders.order_id
    join tb_customers on tb_orders.customer_id = tb_customers.customer_id
    where tb_order_payments.payment_type = 'credit_card'
    group by tb_customers.customer_state
), Totais as 
    (select tb_customers.customer_state, count(tb_order_payments.payment_type) as 'totais'
    from tb_order_payments join tb_orders on tb_order_payments.order_id = tb_orders.order_id
    join tb_customers on tb_orders.customer_id = tb_customers.customer_id
    group by tb_customers.customer_state)

select Credito.customer_state as 'Estado', 100*Credito.cartao_credito/Totais.totais as 'share do cartao de credito (%)'
from Credito join Totais on Credito.customer_state = Totais.customer_state;

-- Resposta: Em todos os estados o método de pagamento mais utilizado é o cartão de crédito.
-- O share deste método de pagamento está descrito no cógigo

-- Pergunta 18. Qual a porcentagem de clientes que já usou mais de um método de 
-- pagamento diferente?

with clientes_dif as
    (select tb_customers.customer_unique_id
    from tb_order_payments join tb_orders on tb_order_payments.order_id = tb_orders.order_id
    join tb_customers on tb_orders.customer_id = tb_customers.customer_id
    group by tb_customers.customer_unique_id
    having count(distinct tb_order_payments.payment_type) > 1
)

select 1000*(count(clientes_dif.customer_unique_id))/96096 as 'Partes por mil de clientes que ja usaram mais de um metodo de pagamento'
from clientes_dif
;

-- Resposta: Aproximadamente 2,6%

-- Pergunta 19. Liste os 10 melhores vendedores e seus respectivos estados

select tb_sellers.seller_id as 'ID do vendedor', tb_sellers.seller_state as "Estado do vendedor", count(*) as 'Número de vendas'
from tb_order_items join tb_sellers on tb_order_items.seller_id = tb_sellers.seller_id
group by tb_sellers.seller_id
order by count(*) desc limit 10;

-- Resposta: 

-- Pergunta 20. Escolha o output de alguma pergunta ou crie uma tabela própria e construa um
-- dashboard no Google Data Studio a partir dela - o dash pode ter mais de uma tabela



-- Resposta: 
