SELECT table_name, column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema='public'
AND table_name IN ('usuario','modelo_ia','dataset','treinamento','metrica','deploy','predicao','feedback','permissao')
ORDER BY table_name, ordinal_position;
