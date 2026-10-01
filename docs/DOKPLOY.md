# Deploy no Dokploy

Crie o banco PostgreSQL no mesmo ambiente da aplicação e use a conexão interna fornecida pelo Dokploy. Não exponha a porta do banco à internet.

## Banco

- Nome: `thunderweb-db`
- Database Name: `thunderweb`
- Database User: `thunderweb`
- Docker Image: `postgres:17`

## Variáveis da aplicação

Configure estas variáveis no serviço Thunderweb. O valor de `DB_HOST` é o **Internal Host** copiado da tela do banco.

```dotenv
APP_DOMAIN=thunderweb.seu-dominio.com
HTTP_SECURE_PROTOCOL=true
COOKIE_SECURE=true
COOKIE_HASHKEY=substitua-por-uma-chave-aleatoria-de-32-bytes
CONFIG_AES_HASHKEY=substitua-por-uma-chave-aleatoria-de-32-bytes

DB_HOST=internal-host-do-thunderweb-db
DB_PORT=5432
DB_NAME=thunderweb
DB_USER=thunderweb
DB_PASS=substitua-pela-senha-do-banco
DB_SSLMODE=disable

SMTP_ENABLED=false

# Endereço do aceleraweb (sem barra final). O modal da história busca a descrição
# e os comentários do Acelerato em /api/tickets/{ticket}/conteudo com a sessão de
# quem está vendo. Vazio mostra só o resumo gravado no jogo.
CONFIG_ACELERAWEB_URL=https://aceleraweb.seu-dominio.com
```

Antes de liberar cadastro por e-mail, configure SMTP e mude `SMTP_ENABLED` para `true`. Gere as duas chaves com `openssl rand -hex 32` e guarde-as apenas nas variáveis protegidas do Dokploy.

## Aplicação

Crie uma **Application** no Dokploy a partir do repositório `syg-pedro/thunderweb` e selecione:

- Build Type: `Dockerfile`
- Dockerfile: `build/Dockerfile`
- Port: `8080`
- Health Check: `GET /healthz`

Adicione o domínio pelo painel do Dokploy. Não publique uma porta externa para o PostgreSQL; a aplicação usa somente o Internal Host do banco.
