# Agenda de Contatos (Ruby CLI)

Uma agenda de contatos simples em **Ruby**, com **POO**, persistência em **JSON**, busca por nome/telefone/e-mail, aniversariantes do mês e **exportação para CSV**. Perfeita para portfólio: código limpo, testes (a implementar com RSpec) e espaço para evolução (Sinatra/Rails).

## ✨ Features

- CRUD de contatos (nome, telefone, e-mail, aniversário opcional)
- Persistência em `data/contatos.json`
- Busca por nome/telefone/e-mail
- Aniversariantes por mês
- Exportação para CSV em `exports/`
- CLI simples e organizada

## 📂 Estrutura

```
agenda-ruby/
├─ app.rb
├─ agenda.rb
├─ contact.rb
├─ data/
│  └─ contatos.json
├─ exports/
│  └─ .gitkeep
└─ README.md
```

## 🧰 Requisitos

- **Ruby** 3.x (recomendado 3.2+)
- Sem gems externas obrigatórias (usa bibliotecas padrão: `json`, `csv`, `securerandom`, `fileutils`)

## 🚀 Como rodar

1) Clone o repo e entre na pasta:
```bash
git clone https://github.com/seu-usuario/agenda-ruby.git
cd agenda-ruby
```

2) Garanta que o Ruby está ok:
```bash
ruby -v
```

3) Rode a aplicação:
```bash
ruby app.rb
```

> O arquivo `data/contatos.json` será criado se não existir.

## 🖱️ Uso (menu)

- **1) Listar contatos** – mostra todos os contatos ordenados por nome  
- **2) Buscar contatos** – busca por nome/telefone/e-mail  
- **3) Adicionar contato** – cria um novo contato  
- **4) Editar contato** – atualiza campos pelo **ID**  
- **5) Remover contato** – remove pelo **ID**  
- **6) Aniversariantes do mês** – informe 1–12  
- **7) Exportar CSV** – gera um arquivo em `exports/`  
- **0) Sair**

### Formato da data de nascimento
Use `YYYY-MM-DD` (ex.: `1990-04-15`). Pode deixar em branco.

## 🧪 Testes (planejado com RSpec)

Em breve:
- `spec/contact_spec.rb`: validações de e-mail/telefone e serialização JSON  
- `spec/agenda_spec.rb`: CRUD, busca, aniversários e export CSV  

Instalação (quando adicionarmos os testes):
```bash
bundle add rspec --group "development,test"
bundle exec rspec --init
```

Rodar:
```bash
bundle exec rspec
```

## ✅ Validações (próximos commits)

- **E-mail**: formato básico (`algo@dominio.tld`)
- **Telefone**: apenas dígitos, com tamanho mínimo (ex.: 8–11)
- **Nome**: obrigatório

> Hoje o projeto valida presença de nome/telefone/e-mail no `Agenda#add`. As validações de formato entrarão em commits futuros.

## 📥 Importar CSV (roadmap)

Adicionar comando de **importação** (CSV → JSON):
- Ler `id,name,phone,email,birthday`
- Gerar `id` (UUID) quando ausente
- Ignorar linhas inválidas com relatório

## 🧯 Seeds (modo “seed”)

Adicionar um script simples para popular alguns contatos:
```bash
ruby scripts/seed.rb
```
> Este script criará entradas de exemplo em `data/contatos.json`.

## 🌐 Versão Web (roadmap)

- **Sinatra** (rápido): endpoints REST + página simples  
- **Rails (API)**: evoluir para API + front separado (React/Next) ou Rails views  
- Reaproveitar `Agenda`/`Contact` como camada de domínio

## 🧾 Exemplo de `contatos.json`

```json
[
  {
    "id": "e7f6d2f1-1234-4a5b-9c1b-111111111111",
    "name": "Ana Silva",
    "phone": "27999990000",
    "email": "ana@exemplo.com",
    "birthday": "1995-03-10"
  }
]
```

## 🗂️ Exportação CSV

Ao exportar, será criado um arquivo como:
```
exports/contatos-20250101-103000.csv
```

Colunas: `id,name,phone,email,birthday`

## 🧭 Convenção de commits

Usamos **Conventional Commits**:
- `feat:` nova funcionalidade
- `fix:` correção
- `chore:` tarefas auxiliares (ex.: `.gitignore`, `.gitkeep`)
- `docs:` documentação (README, etc.)
- `refactor:` refatorações sem mudar comportamento
- `test:` testes automatizados

Exemplos iniciais sugeridos:
```bash
git add contact.rb
git commit -m "feat: add Contact class with basic attributes and JSON serialization"

git add agenda.rb
git commit -m "feat: add Agenda class with CRUD operations and JSON persistence"

git add app.rb
git commit -m "feat: add CLI interface for Agenda with contact management menu"

mkdir -p data && echo "[]" > data/contatos.json
git add data/contatos.json
git commit -m "chore: add initial empty contacts JSON file"

mkdir -p exports && touch exports/.gitkeep
git add exports/.gitkeep
git commit -m "chore: add exports directory with .gitkeep"

echo "exports/*.csv" >> .gitignore
git add .gitignore
git commit -m "chore: ignore generated CSV files in exports/"
```

## 🛠️ Troubleshooting

- **Erro de JSON ao carregar**: apague/ajuste `data/contatos.json` (deixe como `[]`).  
- **ID não encontrado ao editar/remover**: liste contatos (opção 1) e copie o **ID** correto.  
- **Caracteres estranhos no Windows**: use `chcp 65001` antes de rodar para forçar UTF-8.

## 📜 Licença

MIT. Use à vontade para estudos/portfólio.
