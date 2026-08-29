O cenário que eu escolhi foi de IA com o usuário

1. Cenário

O cenário escolhido para este trabalho é um **sistema de Inteligência Artificial**, responsável por organizar o desenvolvimento, treinamento e utilização de modelos de IA.

O sistema permite que usuários criem modelos, utilizem conjuntos de dados para treinamento, acompanhem métricas de desempenho, realizem predições e disponibilizem os modelos para utilização.

2. Entidades

As principais entidades identificadas no cenário são:

- Usuário
- Modelo de IA
- Dataset
- Treinamento
- Métrica
- Predição
- Deploy
- Feedback
- Permissão

3. Atributos

Usuário
- **id_usuario (PK)**
- nome
- email
- tipo_usuario
- data_cadastro

Modelo de IA
- **id_modelo (PK)**
- nome
- descricao
- tipo_modelo
- algoritmo
- data_criacao
- status
- id_usuario (FK)

Dataset
- **id_dataset (PK)**
- nome
- descricao
- origem
- tamanho
- data_criacao

Treinamento
- **id_treinamento (PK)**
- data_inicio
- data_fim
- status
- parametros
- id_modelo (FK)
- id_dataset (FK)

Métrica
- **id_metrica (PK)**
- nome
- valor
- tipo_avaliacao
- id_treinamento (FK)

Predição
- **id_predicao (PK)**
- data_hora
- entrada
- resultado
- confianca
- id_modelo (FK)

Deploy
- **id_deploy (PK)**
- ambiente
- versao
- data_deploy
- status
- id_modelo (FK)

Feedback
- **id_feedback (PK)**
- descricao
- nota
- data_feedback
- id_predicao (FK)
- id_usuario (FK)

Permissão
- **id_permissao (PK)**
- tipo_permissao
- data_concessao
- id_usuario (FK)
- id_modelo (FK)

4. Relacionamentos

- Um **Usuário** pode criar vários **Modelos de IA**.
- Um **Modelo de IA** pertence a um **Usuário**.
- Um **Modelo de IA** pode possuir vários **Treinamentos**.
- Um **Dataset** pode ser utilizado em vários **Treinamentos**.
- Um **Treinamento** utiliza um **Dataset** para treinar um **Modelo de IA**.
- Um **Treinamento** pode gerar várias **Métricas**.
- Um **Modelo de IA** pode realizar várias **Predições**.
- Um **Modelo de IA** pode possuir vários **Deploys**.
- Uma **Predição** pode receber vários **Feedbacks**.
- Um **Usuário** pode fornecer vários **Feedbacks**.
- Um **Usuário** pode possuir diferentes **Permissões** sobre os **Modelos de IA**.
- Um **Modelo de IA** pode estar associado a vários **Usuários** por meio das **Permissões**.

5. Resumo do Modelo

O modelo representa o ciclo básico de utilização de Inteligência Artificial: o usuário cria um modelo, seleciona um dataset, realiza treinamentos, acompanha métricas, gera predições e pode disponibilizar o modelo por meio de um deploy. Após a utilização, os usuários podem fornecer feedback sobre as predições, permitindo acompanhar a qualidade e o desempenho do sistema.
