DROP TABLE IF EXISTS pagamento;
DROP TABLE IF EXISTS internacao;
DROP TABLE IF EXISTS exame;
DROP TABLE IF EXISTS receita;
DROP TABLE IF EXISTS diagnostico;
DROP TABLE IF EXISTS consulta;
DROP TABLE IF EXISTS leito;
DROP TABLE IF EXISTS quarto;
DROP TABLE IF EXISTS medicamento;
DROP TABLE IF EXISTS convenio;
DROP TABLE IF EXISTS unidade;
DROP TABLE IF EXISTS especialidade;
DROP TABLE IF EXISTS medico;
DROP TABLE IF EXISTS paciente;

CREATE TABLE paciente (
    cpf VARCHAR(11) PRIMARY KEY CHECK (length(cpf) = 11),
    nome VARCHAR(100) NOT NULL,
    data_nascimento DATE NOT NULL,
    telefone VARCHAR(15),
    endereco VARCHAR(255),
    usuario VARCHAR(50) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    sexo CHAR(1) NOT NULL CHECK (sexo IN ('M','F','O')),
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE medico (
    crm VARCHAR(20) PRIMARY KEY CHECK (length(crm) BETWEEN 9 AND 20),
    nome VARCHAR(100) NOT NULL,
    especialidade VARCHAR(100) NOT NULL,
    telefone VARCHAR(15),
    usuario VARCHAR(50) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    preco_consulta DECIMAL(10,2) NOT NULL CHECK (preco_consulta > 0),
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE especialidade (
    id_especialidade INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao VARCHAR(255),
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE convenio (
    id_convenio INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    telefone VARCHAR(15),
    percentual_desconto DECIMAL(5,2) NOT NULL DEFAULT 0 CHECK (percentual_desconto BETWEEN 0 AND 100),
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE unidade (
    id_unidade INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    endereco VARCHAR(255) NOT NULL,
    telefone VARCHAR(15),
    capacidade INT NOT NULL CHECK (capacidade > 0),
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE quarto (
    id_quarto INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_unidade INT NOT NULL,
    numero VARCHAR(10) NOT NULL,
    tipo VARCHAR(30) NOT NULL DEFAULT 'Enfermaria' CHECK (tipo IN ('Enfermaria','UTI','Privativo')),
    capacidade INT NOT NULL DEFAULT 2 CHECK (capacidade > 0),
    UNIQUE (id_unidade, numero),
    FOREIGN KEY (id_unidade) REFERENCES unidade(id_unidade)
);

CREATE TABLE leito (
    id_leito INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_quarto INT NOT NULL,
    numero VARCHAR(10) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Livre' CHECK (status IN ('Livre','Ocupado','Manutencao')),
    UNIQUE (id_quarto, numero),
    FOREIGN KEY (id_quarto) REFERENCES quarto(id_quarto)
);

CREATE TABLE medicamento (
    id_medicamento INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    principio_ativo VARCHAR(100) NOT NULL,
    fabricante VARCHAR(100) NOT NULL,
    preco DECIMAL(10,2) NOT NULL CHECK (preco > 0),
    estoque INT NOT NULL DEFAULT 0 CHECK (estoque >= 0)
);

CREATE TABLE consulta (
    id_consulta INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cpf_paciente VARCHAR(11) NOT NULL,
    crm_medico VARCHAR(20) NOT NULL,
    id_convenio INT,
    data_consulta TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diagnostico TEXT,
    observacoes TEXT,
    preco DECIMAL(10,2) NOT NULL CHECK (preco > 0),
    imposto DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (imposto >= 0),
    total DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (total >= preco),
    status VARCHAR(20) NOT NULL DEFAULT 'Agendada' CHECK (status IN ('Agendada','Realizada','Cancelada')),
    FOREIGN KEY (cpf_paciente) REFERENCES paciente(cpf),
    FOREIGN KEY (crm_medico) REFERENCES medico(crm),
    FOREIGN KEY (id_convenio) REFERENCES convenio(id_convenio)
);

CREATE TABLE diagnostico (
    id_diagnostico INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_consulta INT NOT NULL,
    descricao TEXT NOT NULL,
    data_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gravidade VARCHAR(20) NOT NULL DEFAULT 'Leve' CHECK (gravidade IN ('Leve','Moderada','Grave')),
    FOREIGN KEY (id_consulta) REFERENCES consulta(id_consulta)
);

CREATE TABLE receita (
    id_receita INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_consulta INT NOT NULL,
    id_medicamento INT NOT NULL,
    medicamento VARCHAR(100) NOT NULL,
    dosagem VARCHAR(50),
    instrucoes TEXT,
    descricao TEXT NOT NULL,
    data_emissao DATE NOT NULL DEFAULT CURRENT_DATE,
    quantidade INT NOT NULL DEFAULT 1 CHECK (quantidade > 0),
    FOREIGN KEY (id_consulta) REFERENCES consulta(id_consulta),
    FOREIGN KEY (id_medicamento) REFERENCES medicamento(id_medicamento)
);

CREATE TABLE exame (
    id_exame INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cpf_paciente VARCHAR(11) NOT NULL,
    id_consulta INT,
    tipo VARCHAR(50) NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    arquivo_url VARCHAR(500) NOT NULL,
    data_envio TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'Enviado' CHECK (status IN ('Enviado','Analisado','Arquivado')),
    UNIQUE (cpf_paciente, arquivo_url),
    FOREIGN KEY (cpf_paciente) REFERENCES paciente(cpf),
    FOREIGN KEY (id_consulta) REFERENCES consulta(id_consulta)
);

CREATE TABLE internacao (
    id_internacao INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cpf_paciente VARCHAR(11) NOT NULL,
    id_leito INT NOT NULL,
    crm_medico_responsavel VARCHAR(20) NOT NULL,
    data_entrada DATE NOT NULL DEFAULT CURRENT_DATE,
    data_saida DATE,
    motivo VARCHAR(255) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Ativa' CHECK (status IN ('Ativa','Encerrada')),
    CHECK (data_saida IS NULL OR data_saida >= data_entrada),
    FOREIGN KEY (cpf_paciente) REFERENCES paciente(cpf),
    FOREIGN KEY (id_leito) REFERENCES leito(id_leito),
    FOREIGN KEY (crm_medico_responsavel) REFERENCES medico(crm)
);

CREATE TABLE pagamento (
    id_pagamento INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_consulta INT NOT NULL UNIQUE,
    valor DECIMAL(10,2) NOT NULL CHECK (valor > 0),
    data_pagamento DATE NOT NULL DEFAULT CURRENT_DATE,
    forma_pagamento VARCHAR(20) NOT NULL CHECK (forma_pagamento IN ('Pix','Cartao','Dinheiro','Convenio')),
    status VARCHAR(20) NOT NULL DEFAULT 'Pago' CHECK (status IN ('Pago','Pendente','Estornado')),
    FOREIGN KEY (id_consulta) REFERENCES consulta(id_consulta)
);
