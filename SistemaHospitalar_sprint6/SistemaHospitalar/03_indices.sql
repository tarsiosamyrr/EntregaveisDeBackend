
CREATE INDEX idx_consulta_paciente ON consulta(cpf_paciente);

CREATE INDEX idx_consulta_medico_data ON consulta(crm_medico, data_consulta);

CREATE INDEX idx_consulta_status ON consulta(status);

CREATE INDEX idx_diagnostico_consulta ON diagnostico(id_consulta);

CREATE INDEX idx_receita_consulta ON receita(id_consulta);
-
CREATE INDEX idx_internacao_paciente_status ON internacao(cpf_paciente, status);

CREATE INDEX idx_internacao_leito ON internacao(id_leito);

CREATE INDEX idx_pagamento_data_status ON pagamento(data_pagamento, status);

CREATE INDEX idx_medicamento_principio ON medicamento(principio_ativo);

CREATE INDEX idx_quarto_unidade ON quarto(id_unidade);

CREATE INDEX idx_exame_paciente_data ON exame(cpf_paciente, data_envio);

CREATE INDEX idx_exame_consulta ON exame(id_consulta);
