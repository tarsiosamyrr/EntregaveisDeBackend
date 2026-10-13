const dbHospital = db.getSiblingDB("sistema_hospitalar_nosql");

print("\n=== 1) FILTRO + PROJEÇÃO: pacientes cujo nome começa com 'J' ===");
printjson(dbHospital.pacientes.find(
  { nome: { $regex: "^J", $options: "i" } },
  { nome: 1, nascimento: 1, "contato.telefone": 1, _id: 0 }
).toArray());

print("\n=== 2) FILTRO + ORDENAÇÃO + PROJEÇÃO: consultas realizadas, mais recentes primeiro ===");
printjson(dbHospital.consultas.find(
  { status: "realizada" },
  { pacienteId: 1, data: 1, status: 1, "medico.nome": 1, _id: 0 }
).sort({ data: -1 }).toArray());

print("\n=== 3) FILTRO EM DOCUMENTO EMBUTIDO: consultas de Cardiologia, ordenadas por data ===");
printjson(dbHospital.consultas.find(
  { "medico.especialidade": "Cardiologia" },
  { data: 1, status: 1, "medico.nome": 1, "triagem.pressao": 1, _id: 0 }
).sort({ data: 1 }).toArray());

print("\n=== 4) FILTRO COM OPERADOR: pacientes com alergias registradas ===");
printjson(dbHospital.pacientes.find(
  { alergias: { $exists: true, $not: { $size: 0 } } },
  { nome: 1, alergias: 1, _id: 0 }
).sort({ nome: 1 }).toArray());

function estagios(plano) {
  const raiz = plano.queryPlan || plano; // MongoDB 8 pode aninhar o plano em queryPlan
  let lista = [raiz.stage];
  if (raiz.inputStage) lista = lista.concat(estagios(raiz.inputStage));
  if (raiz.inputStages) raiz.inputStages.forEach(s => { lista = lista.concat(estagios(s)); });
  return lista;
}

function resumo(titulo, cursor) {
  const e = cursor.explain("executionStats");
  const s = e.executionStats;
  print("\n--- " + titulo);
  print("estágios:            " + estagios(e.queryPlanner.winningPlan).join(" > "));
  print("nReturned:           " + s.nReturned);
  print("totalKeysExamined:   " + s.totalKeysExamined);
  print("totalDocsExamined:   " + s.totalDocsExamined);
}

const consultaPorPaciente = () => dbHospital.consultas.find({ pacienteId: ObjectId("650000000000000000000001") });
const consultaPorStatusOrdenada = () => dbHospital.consultas.find({ status: "realizada" }).sort({ data: -1 });

print("\n=== 5) EXPLAIN ANTES DOS ÍNDICES (esperado: COLLSCAN) ===");
resumo("busca por pacienteId", consultaPorPaciente());
resumo("status = 'realizada' ordenado por data desc", consultaPorStatusOrdenada());

print("\n=== 6) CRIAÇÃO DOS ÍNDICES ===");

print(dbHospital.consultas.createIndex({ pacienteId: 1 }, { name: "idx_consultas_paciente" }));

print(dbHospital.consultas.createIndex({ status: 1, data: -1 }, { name: "idx_consultas_status_data" }));
printjson(dbHospital.consultas.getIndexes().map(i => ({ nome: i.name, chave: i.key })));

print("\n=== 7) EXPLAIN DEPOIS DOS ÍNDICES (esperado: IXSCAN, sem estágio SORT na consulta 2) ===");
resumo("busca por pacienteId", consultaPorPaciente());
resumo("status = 'realizada' ordenado por data desc", consultaPorStatusOrdenada());

print("\nObservação: com poucos documentos o tempo é irrelevante; compare estágios e totalDocsExamined.");
