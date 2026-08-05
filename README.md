# Thunderweb

Ferramenta de colaboração ágil para planning poker, retrospectivas, story mapping e check-ins assíncronos.

## Rodar localmente

```bash
docker compose up --build
```

Abra [http://localhost:8080](http://localhost:8080). O compose também inicia PostgreSQL e MailDev para desenvolvimento.

## Origem e licença

Thunderweb é derivado do [Thunderdome Planning Poker](https://github.com/StevenWeathers/thunderdome-planning-poker), no commit `c16141a179765b897e9c0027d849797de774bbbc`.

O código permanece sob a licença [Apache-2.0](LICENSE). O remoto `upstream` aponta para o projeto de origem; configure o remoto `origin` do repositório Thunderweb antes de publicar alterações.

## Documentação técnica do upstream

- [Instalação](docs/INSTALLATION.md)
- [Configuração](docs/CONFIGURATION.md)
- [Desenvolvimento](docs/DEVELOPING.md)
- [Deploy no Dokploy](docs/DOKPLOY.md)
- [API Swagger](docs/swagger/swagger.json)
