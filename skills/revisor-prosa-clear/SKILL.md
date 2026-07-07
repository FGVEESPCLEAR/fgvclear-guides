---
name: revisor-prosa-clear
description: Revisar a prosa de guias da Série "Avaliação na Prática" do FGV EESP CLEAR, eliminando marcas de texto gerado por IA enquanto preserva precisão técnica, padrão acadêmico brasileiro e identidade da série. Use sempre que o usuário pedir para revisar, suavizar, naturalizar, "humanizar" ou tirar cara de IA de qualquer trecho de guia (seja `.tex`, prosa solta, intros de seção, ancoragens empíricas, legendas, notas de rodapé). Use também para revisão geral de gramática, pontuação, formatação LaTeX e adequação ao estilo CLEAR — esta skill cobre revisão técnica E estilística em uma só passada. Ative mesmo quando o usuário disser apenas "revise isso" ou "dá uma olhada nesse texto" no contexto dos guias.
---

# Revisor de Prosa — Série Avaliação na Prática (FGV EESP CLEAR)

Esta skill é usada para revisar capítulos, seções e trechos de prosa dos guias técnicos da Série Avaliação na Prática. O objetivo central é duplo:

- **Revisão técnica padrão:** gramática, pontuação, ortografia, concordância, regência, formatação LaTeX, consistência terminológica.
- **Eliminação de marcas de IA:** deixar o texto com voz humana de pesquisador brasileiro escrevendo material didático técnico — não com voz de assistente de IA escrevendo material didático técnico.

O segundo objetivo é o que diferencia esta skill. As próximas seções detalham como fazê-lo bem.

---

## Princípio orientador

O alvo não é "menos formal" nem "menos técnico". É **menos previsível**.

Texto de IA soa como IA porque é estatisticamente médio: escolhe sempre o conector mais óbvio, a estrutura mais simétrica, o adjetivo mais reforçador, o resumo no fim do parágrafo. Cada escolha individual está correta; o conjunto é que denuncia.

A revisão precisa intervir no padrão, não em palavras isoladas. Trocar "crucial" por "essencial" não resolve nada — as duas palavras são igualmente vazias. O que resolve é cortar o adjetivo e deixar o substantivo trabalhar sozinho, ou substituir por um qualificador concreto que diga por que aquilo importa.

**Regra prática:** se você consegue prever a próxima palavra de uma frase antes de ler, essa palavra provavelmente precisa sair ou mudar.

---

## Modo de operação

O usuário definiu o nível de intervenção como **agressivo**: você reescreve livremente e entrega versão final pronta com diff. Não pergunte permissão para cada mudança — execute.

### Escopo

Revisar tudo: prosa corrida, intros de seção, ancoragens empíricas, legendas de tabelas/figuras, notas de rodapé, e — quando soarem mecânicos — trechos técnicos (explicações de fórmulas, derivações em palavras, comentários em blocos de código se estiverem em português).

### Preservações obrigatórias (NUNCA reescrever)

Estas coisas são parte da identidade da série e da precisão técnica. Mantenha exatamente como estão, mesmo que pareçam "duras":

- Equações em LaTeX (`$...$`, `\begin{equation}...\end{equation}`, `\underbrace`, etc.) — só corrija erro de sintaxe.
- Terminologia técnica fixa: ATE, ATT, ITT, CIA, CATE, LATE, SUTVA, OLS, IPW, TWFE, FD, DiD, RDD, SCM, propensity score, plug-in, doubly robust, within transformation, etc. Não traduzir, não "suavizar", não substituir por sinônimo.
- Citações e referências: `\cite{}`, `\citet{}`, `\citep{}`, nomes de autores, anos, números de página, URLs.
- Nomes institucionais: FGV EESP CLEAR, Bolsa Família, PRONATEC, PNAD Contínua, DATASUS, Inep, SAEB, ENEM, Siconfi/FINBRA, INPE, Fala.BR, etc.
- Nomes próprios e siglas em inglês quando consagradas: "first differences", "two-way fixed effects" — mantenha o original entre parênteses se o usuário já fizer isso.
- Convenções da série: paleta de cores `clearblue`, ambiente `lstlisting` com `Rstyle`, `tcolorbox`, classes do `book`, etc. Não mexer em comandos LaTeX estruturais.
- Estrutura de equações numeradas e labels (`\label{eq:...}`): nunca renumerar nem renomear.
- Convenção matemática: notação de Yi(1), Yi(0), Di, Xi, F, F̂_n, τ, β, etc. Não trocar símbolos.

### Quando hesitar, hesite a favor do autor

Se uma escolha parece deliberada (um termo incomum que aparece em vários pontos, uma expressão recorrente, uma figura de linguagem específica), preserve. O Caio tem voz autoral nos guias — sua expertise em causal inference e política pública brasileira gera escolhas idiossincráticas que você não deve nivelar.

---

## Catálogo de tells de IA — com substituições

As seis marcas que o usuário identificou como mais incômodas, em ordem de prioridade de tratamento.

### 1. Listas com bullets onde caberia prosa

**Sintoma:** três a quatro itens curtos, paralelos, que poderiam ser uma frase composta ou dois períodos.

**Tratamento:** converter para prosa sempre que os itens forem ≤ 4, semanticamente conectados, e estiverem dentro de um parágrafo explicativo (não em uma seção de "Vantagens" ou "Limitações" claramente estruturada). Manter bullets quando:

- a lista tem 5+ itens
- os itens são independentes (definições, exemplos isolados)
- a lista está em uma caixa `tcolorbox` ou seção claramente enumerativa
- o paralelismo carrega informação (ex: tabela de critérios comparativos)

**❌ Antes:**
> OLS apresenta as seguintes características:
> \begin{itemize}
>   \item É consistente sob hipóteses fracas
>   \item Tem forma fechada conhecida
>   \item Permite inferência analítica
> \end{itemize}

**✅ Depois:**
> OLS é consistente sob hipóteses fracas, tem forma fechada conhecida e permite inferência analítica — combinação que explica sua centralidade na prática.

### 2. Frases-resumo no fim de parágrafo

**Sintoma:** período final que reformula o que já foi dito. Marcadores típicos: "Em suma", "Em síntese", "Portanto", "Assim", "Dessa forma", "Em outras palavras", "Vale destacar que", "Cabe ressaltar que", "É importante notar que", "Conclui-se que".

**Tratamento:** cortar a frase inteira. Em quase todos os casos, o parágrafo termina melhor sem ela. Quando o resumo carrega informação nova (uma implicação, uma consequência prática), reescrever como sentença substantiva, sem o marcador.

**❌ Antes:**
> O estimador plug-in substitui F por F̂_n e calcula o mesmo funcional. **Em suma, fazemos com a amostra exatamente o que faríamos com a população.**

**✅ Depois:**
> O estimador plug-in substitui F por F̂_n e calcula o mesmo funcional — fazemos com a amostra exatamente o que faríamos com a população.

(O conteúdo do "em suma" virou aposto da frase anterior.)

Outro tratamento, quando a redundância é total:

**❌ Antes:**
> A consistência garante que, com amostras grandes, o estimador converge para o estimando. **Portanto, é a propriedade mínima exigível de qualquer estimador útil.**

**✅ Depois:**
> A consistência garante que, com amostras grandes, o estimador converge para o estimando. Sem ela, um estimador não melhora com mais dados — é por isso que se trata da propriedade mínima exigível.

(O resumo virou conteúdo causal.)

### 3. Paralelismos excessivos e tricolons

**Sintoma:** "X, Y e Z" repetido três vezes em parágrafos próximos; frases com a mesma estrutura sintática em sequência; abertura de subseções todas com o mesmo padrão.

**Tratamento:** quebrar a simetria. Variar comprimento de frase. Subordinar em vez de coordenar. Trocar enumeração por construção apositiva ou parentética.

**❌ Antes:**
> O IPW é robusto, transparente e intuitivo. Ele modela o propensity score, repondera a amostra e estima o efeito médio. Funciona bem com amostras grandes, com covariadas discretas e com tratamentos binários.

**✅ Depois:**
> O IPW é robusto à forma funcional do desfecho — sua vantagem central. A estratégia é direta: modela-se o propensity score e repondera-se a amostra para que tratados e controles tenham distribuição comparável de X. Funciona melhor em amostras grandes, especialmente quando o tratamento é binário.

### 4. Conectores previsíveis

Lista de conectores a evitar (ou usar com parcimônia):

| Evite | Considere |
|-------|-----------|
| Além disso | (omitir; iniciar frase direto) |
| Por outro lado | Já / Em contraste / Mas |
| Vale destacar que | (omitir; afirmar diretamente) |
| Cabe ressaltar que | (omitir) |
| É importante notar que | (omitir) |
| Nesse sentido | (omitir; usar travessão) |
| Dessa forma | Por isso / Daí |
| Assim sendo | (omitir) |
| Em outras palavras | Ou seja / (omitir; reformular) |
| Diante do exposto | (omitir; nunca aceitável em texto contemporâneo) |
| Em última análise | No fundo / (omitir) |
| Não obstante | Ainda assim / Mesmo assim |
| Sob essa ótica | (omitir) |

**Regra:** a maior parte desses conectores pode simplesmente ser apagada. Frases adultas conectam por justaposição, por travessão, por dois-pontos, ou por subordinação — não precisam de muletas adverbiais.

### 5. Adjetivos vazios

**Lista negra:** crucial, fundamental, essencial, importante, central, vital, indispensável, primordial, basilar, imprescindível.

Esses adjetivos não dizem por que algo é importante — só sinalizam "preste atenção aqui". Em texto técnico, o leitor já está prestando atenção; o adjetivo é redundante.

Três tratamentos:

**(a) Cortar e deixar o substantivo trabalhar:**
- ❌ "A hipótese de SUTVA é uma premissa fundamental para identificação."
- ✅ "A hipótese de SUTVA é uma premissa para identificação."

**(b) Substituir por qualificador concreto:**
- ❌ "A escolha do propensity score é crucial."
- ✅ "A escolha do propensity score determina o viés do estimador quando há observações com p̂(X) próximo de 0 ou 1."

**(c) Reescrever a frase em torno do que importa:**
- ❌ "É importante ressaltar que a CIA é uma hipótese forte."
- ✅ "A CIA é uma hipótese forte: exige que todas as variáveis de confundimento sejam observadas e incluídas em X."

### 6. Estrutura previsível: tese → exemplo → recapitulação

**Sintoma:** todo parágrafo abre com a afirmação, ilustra com um exemplo, e fecha repetindo a afirmação em outras palavras. Quando vários parágrafos em sequência seguem essa forma, o texto soa como apostila de IA.

**Tratamento:**

- Comece alguns parágrafos pelo exemplo, deixando a tese emergir.
- Comece outros por uma objeção, uma observação contraintuitiva, ou uma comparação.
- Termine alguns parágrafos no exemplo, sem voltar à tese.
- Encadeie parágrafos: faça o parágrafo N começar respondendo ao que o N-1 deixou aberto.

Em vez de:
> A consistência é uma propriedade fundamental dos estimadores. Por exemplo, a média amostral é consistente para a média populacional. Logo, qualquer estimador útil precisa ser consistente.

Tente:
> A média amostral converge para a média populacional à medida que n cresce — propriedade que estatísticos chamam de consistência, e que separa estimadores úteis dos demais.

Ou ainda:
> Imagine um estimador que produz o mesmo número independentemente do tamanho da amostra. Ele pode até estar certo por acaso, mas não há razão para confiar nele com 1000 observações mais do que com 10. É essa intuição que a consistência formaliza.

---

## Outros padrões a vigiar

Além das seis marcas principais, atenção a estes:

- **Verbos de conexão preguiçosos:** "Isso significa que", "Isso implica que", "Isso mostra que" no início de muitas frases. Trocar por sintaxe que integre a relação causal/lógica diretamente.
- **"podemos" / "vamos" excessivos:** "Podemos ver que", "Vamos analisar", "Podemos concluir". Texto técnico em português acadêmico geralmente usa terceira pessoa ou voz passiva nesse contexto: "Vê-se que", "Resta analisar", "Conclui-se".
- **Tradução literal do inglês:** "Em ordem de" (em vez de "para"), "permite nós" (em vez de "permite-nos" ou "nos permite"), "baseado em" como conector adverbial (em vez de "com base em").
- **Hedge excessivo:** "pode-se argumentar que", "em alguma medida", "de certa forma", "até certo ponto". Texto didático precisa de afirmações claras; hedge demais soa evasivo.
- **Reforço enfático mecânico:** "muito importante", "extremamente útil", "altamente relevante". Adjetivos não precisam de advérbio intensificador em texto técnico.
- **Reformulação dupla:** "ou seja", "isto é", "em outras palavras" usados quando a primeira formulação já está clara. Reformule apenas quando a segunda versão traz algo que a primeira não trazia.
- **Listas dentro de frases:** "diversos fatores como A, B, C, D e E". Se a lista é importante, vire bullet ou tabela; se não é, corte para "fatores como A e B" ou "vários fatores".

---

## Padrões específicos do português acadêmico brasileiro

A revisão deve produzir texto que pareça escrito por um pesquisador brasileiro publicando para outros pesquisadores brasileiros — não tradução de manual em inglês.

Convenções a respeitar:

- **Decimal com vírgula:** `0,05` não `0.05` (exceto em código R/Python ou saída de software, onde mantém o ponto).
- **Citação no estilo ABNT/autor-data:** "Angrist e Pischke (2009) mostram que..." ou "(Angrist e Pischke, 2009)".
- **Itálico para termos estrangeiros não consagrados** (`\textit{propensity score}` na primeira aparição; sem itálico depois). Termos já incorporados ao jargão (OLS, ATT) ficam em redondo.
- **Sigla introduzida com o nome completo na primeira ocorrência:** "Inverse Probability Weighting (IPW)".
- **Hífen e travessão:** travessão (—) para incisos, hífen (-) só em palavras compostas. Texto de IA frequentemente usa hífen onde deveria ser travessão.
- **Aspas:** aspas curvas (" ") preferidas a aspas retas, quando o LaTeX permite.

**Voz e pessoa:** a série usa primeira pessoa do plural ("estimamos", "consideramos") com moderação — predominam construções impessoais ("estima-se", "considera-se") e referências ao leitor em segunda pessoa do plural são raras. Não introduza "você" se o texto original não usa.

---

## Protocolo de revisão — duas passadas

### Passada 1: técnica

Antes de tocar no estilo, varra os erros mecânicos:

- **Gramática e ortografia:** concordância nominal e verbal, regência, crase, pontuação, ortografia.
- **LaTeX:** comandos com sintaxe correta, ambientes fechados, `\label{}` e `\ref{}` consistentes, `\cite{}` apontando para chaves que existem no `.bib`, parênteses e chaves balanceados em equações.
- **Numeração e referências cruzadas:** equações, tabelas, figuras numeradas em ordem; `\eqref{}` aponta para label existente.
- **Consistência terminológica:** se o texto usa "estimando" e "alvo de estimação" intercambiavelmente, padronize para o termo da Seção 2; se usa "propensity score" e "escore de propensão", padronize para a forma que o resto do guia usa.
- **Notação matemática:** símbolos consistentes ao longo do trecho (Y vs. y, Xi vs. X_i, n vs. N).
- **Citações:** ano confere, nome do autor grafado corretamente, vírgula entre nome e ano conforme estilo.

Reporte erros desta passada de forma resumida, mas sempre conserte no diff.

### Passada 2: estilística (anti-IA)

Agora aplique o catálogo de tells. Trabalhe por parágrafo, na seguinte ordem:

1. Identifique a estrutura do parágrafo (tese-exemplo-resumo? lista disfarçada? sucessão de tricolons?).
2. Decida se a estrutura precisa quebrar.
3. Caçar adjetivos vazios e conectores previsíveis — corte primeiro, reformule depois.
4. Verificar abertura e fechamento — o parágrafo abre de forma previsível? fecha com resumo redundante?
5. Ler em voz alta mentalmente: onde o ritmo é monótono, varie comprimento de frase.

---

## Formato de entrega

Entregue três blocos, nesta ordem:

### Bloco 1 — Resumo executivo

Três a seis linhas, em prosa, descrevendo o que estava bem e foi preservado, as intervenções mais pesadas (que parágrafos foram reescritos por inteiro, se algum), e decisões editoriais que o usuário deveria revisar (ex: "cortei o parágrafo de transição entre 3.3 e 3.4 porque era redundante; se quiser manter a transição explícita, posso reescrever").

Não use bullet points neste bloco. Não comece com "Em suma" (regra que vale para você também).

### Bloco 2 — Diff anotado

Para cada trecho alterado, mostre:

```
[§ identificador: começo do parágrafo ou subseção]

ANTES:
<trecho original literal>

DEPOIS:
<trecho revisado literal>

POR QUÊ:
<uma linha, no máximo duas, explicando a intervenção>
```

Agrupe alterações pequenas (vírgulas, hífen → travessão, ajustes ortográficos) em um único bloco no final do diff, em formato de lista compacta, sem explicação individual.

### Bloco 3 — Versão final limpa

O texto inteiro revisado, pronto para colar no `.tex`. Sem marcações de diff, sem comentários, sem `% TODO`. Se o trecho era um arquivo completo, devolva o arquivo completo.

Se o texto for muito longo (> ~500 linhas de LaTeX), pergunte ao usuário se quer a versão final em arquivo separado salvo no Dropbox/Overleaf ou inline na resposta.

---

## Calibração de agressividade

O usuário pediu nível agressivo. Isso significa:

- Reescreva frases inteiras quando o problema é estrutural, não cosmético.
- Funda parágrafos quando há redundância entre eles; quebre parágrafos longos demais.
- Corte frases inteiras quando são puramente resumitivas ou meta-textuais ("Nesta seção, veremos...").
- Substitua exemplos didáticos por exemplos mais específicos quando os originais soarem genéricos — desde que o exemplo novo seja factualmente correto e coerente com a expertise do autor (causal inference, política pública brasileira).
- Não introduza informação técnica nova que o texto original não autoriza. Sua reescrita pode mudar a forma de qualquer afirmação, mas não pode alterar seu conteúdo factual.

**Limite da agressividade:** se você está prestes a alterar uma definição técnica, uma fórmula, ou uma afirmação sobre uma fonte de dados brasileira, pare e sinalize no Bloco 1 em vez de reescrever silenciosamente.

---

## Critério final de qualidade

Antes de entregar a revisão, faça uma última pergunta a si mesmo, parágrafo por parágrafo:

> "Se eu lesse esse parágrafo em um livro publicado por uma editora universitária brasileira, sem saber sua origem, suspeitaria que foi escrito por IA?"

Se a resposta for "sim" para qualquer parágrafo, volte a ele. Se a resposta for "não" para todos, a revisão está pronta.
