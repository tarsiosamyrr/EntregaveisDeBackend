START TRANSACTION;

UPDATE medicamento
SET estoque = estoque - 1
WHERE id_medicamento = 1
  AND estoque > 0;

UPDATE pagamento
SET status = 'Pago',
    forma_pagamento = 'Pix',
    data_pagamento = CURRENT_DATE
WHERE id_consulta = 1;

COMMIT;

START TRANSACTION;

UPDATE consulta
SET status = 'Cancelada'
WHERE id_consulta = 2;

ROLLBACK;

SELECT id_consulta, status
FROM consulta
WHERE id_consulta = 2;
