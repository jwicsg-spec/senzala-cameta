# Senzala Cametá — Vercel + Supabase

## IMPORTANTE
Esta versão usa uma estrutura estática simples para a Vercel. O arquivo `config.js` fica na raiz do projeto e é carregado diretamente pelo site.

## 1. Configurar o Supabase
No Supabase, execute `supabase/schema.sql` no SQL Editor. Depois crie o usuário administrador em Authentication > Users e confira o UUID dele na tabela `public.admins`.

## 2. Configurar o site
Abra `config.js` na raiz e preencha:

```js
window.SENZALA_SUPABASE_CONFIG = {
  url: 'https://SEU-PROJETO.supabase.co',
  key: 'SUA_CHAVE_PUBLICA'
};
```

Use somente a Project URL e a Publishable key (ou anon public em projetos antigos). Nunca coloque service_role ou secret key.

## 3. GitHub
Envie o conteúdo desta pasta para o repositório GitHub. A estrutura deve ficar assim:

- `index.html`
- `config.js`
- `assets/`
- `admin/`
- `supabase/`
- `vercel.json`

Não coloque esta pasta inteira dentro de outra pasta no GitHub.

## 4. Vercel
Importe o repositório no Vercel. Não defina Root Directory como `public`. O projeto já está pronto para ser servido pela raiz.

Depois do deploy, teste primeiro:

`https://SEU-DOMINIO.vercel.app/config.js`

Essa URL deve mostrar o JavaScript de configuração, não 404/410.

Depois teste:

`https://SEU-DOMINIO.vercel.app/`
`https://SEU-DOMINIO.vercel.app/admin/`
