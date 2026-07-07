#!/usr/bin/env python3
"""
Pipeline de agentes para produção do Guia Clear de Inferência Causal.
Roda três agentes em sequência: Econometria → Escrita → Revisão.
Salva o output de cada agente em arquivo .md separado.

Uso:
    python clear_pipeline.py

Requer:
    pip install anthropic
    export ANTHROPIC_API_KEY=sk-ant-...
"""

import anthropic
import os
import sys
from datetime import datetime

# ---------------------------------------------------------------------------
# Configuração
# ---------------------------------------------------------------------------

MODEL = "claude-sonnet-4-5"
MAX_TOKENS = 8000
OUTPUT_DIR = "outputs"

# ---------------------------------------------------------------------------
# Skills (knowledge bases dos agentes)
# ---------------------------------------------------------------------------

SKILL_IDENTIFICATION = """
# SKILL: IDENTIFICAÇÃO

A cadeia fundamental: Teoria Econômica → Parâmetro do modelo econômico → Identificação → Estimando → Estimação → Inferência.

DEFINIÇÕES PRECISAS:
- Parâmetro econômico: vive no espaço do modelo teórico. Não observável diretamente. Ex: ATE = E[Yi(1) - Yi(0)].
- Estimando: funcional da distribuição observável F(Y,D,X). Pode ser aprendido com dados infinitos.
- Identificação: conjunto de hipóteses sobre o PGD que estabelece equivalência entre parâmetro e estimando.
- Estimador: função dos dados amostrais que calcula o estimando na amostra finita.

DISTINÇÕES CRÍTICAS:
- Hipóteses de identificação são sobre o mundo (o PGD), não sobre os dados. Em geral não são testáveis.
- Confusão mais comum: chamar OLS de "estratégia de identificação" — OLS é estimador, não identificação.
- p-valor pequeno não implica identificação válida. Precisão amostral ≠ validade.

ORDEM OBRIGATÓRIA ao escrever:
1. Parâmetro econômico de interesse (definido pela teoria)
2. Por que não é diretamente observável (problema fundamental)
3. Estimando candidato (funcional da distribuição observável)
4. Hipótese de identificação (o que precisa ser verdade para equivalência)
5. Por que a hipótese é plausível (argumento substantivo)
6. Estimador alinhado com o estimando

HIPÓTESES POR ESTRATÉGIA:
- Seleção em observáveis / CIA: (Yi(1),Yi(0)) ⊥ Di | Xi
- RCT / exogeneidade: (Yi(1),Yi(0)) ⊥ Di
- SUTVA: Yi(d1,...,dn) = Yi(di) — sem interferência entre unidades
- DiD: tendências paralelas
- IV: exclusão + relevância
- RD: continuidade no cutoff
- Controle Sintético: pesos que replicam pré-tratamento

SUTVA (Stable Unit Treatment Value Assumption):
Duas componentes: (1) sem interferência — Yi não depende do tratamento de outros indivíduos,
(2) sem versões múltiplas do tratamento — Di=1 tem o mesmo significado para todos.
Quando SUTVA falha: Yi = Yi(d1,...,dn) — resultado de i depende do vetor completo de tratamentos.
"""

SKILL_ESTIMATION = """
# SKILL: ESTIMAÇÃO

Pressupõe identificação estabelecida. Como calcular o estimando na amostra finita?

AMOSTRA E DISTRIBUIÇÃO EMPÍRICA:
- Amostra: n realizações (Yi, Di, Xi) geradas por F desconhecida. Finita e aleatória.
- Distribuição empírica F̂n: coloca massa 1/n em cada observação. Converge para F com n→∞.
- Estimador plug-in: substitua F por F̂n. Unifica OLS, diferença de médias, Wald, IPW.
  Se θ = φ(F), então θ̂ = φ(F̂n).

PROPRIEDADES:
- Consistência: θ̂ →p θ quando n→∞. Propriedade mínima exigível.
- Viés: E[θ̂] - θ. Pode existir em amostras finitas mesmo com estimador consistente.
- Eficiência: menor variância assintótica na classe. Trade-off com robustez.
- Robustez: o que o estimador calcula quando hipóteses auxiliares falham?

TRADEOFF FUNDAMENTAL: eficiência vs. robustez.
- Paramétrico (ex: MLE sob normalidade): eficiente se correto, inconsistente se errado.
- Semiparamétrico (ex: OLS): robusto a algumas formas de má-especificação.
- Não-paramétrico (ex: diferença de médias): mais robusto, converge mais devagar.

ALINHAMENTO ESTIMADOR-ESTIMANDO:
- OLS com controles lineares: só calcula ATT se relação X→Y for linear. Hipótese funcional adicional à CIA.
- IPW: robusto à forma funcional de Y, sensível à especificação do propensity score.
- Doubly robust (AIPW): consistente se pelo menos um dos dois modelos (outcome ou propensity) estiver correto.

FWL (Frisch-Waugh-Lovell) POPULACIONAL:
- Versão amostral: β_X em Y = Xβ_X + Wβ_W + ε é igual ao coeficiente de ẽ_X em ẽ_Y = β_X ẽ_X + η,
  onde ẽ_Y = Y - E[Y|W] e ẽ_X = X - E[X|W] (resíduos de projetar Y e X em W).
- Versão populacional: β(w) = E[(X - E[X|W])(Y - E[Y|W])] / E[(X - E[X|W])²]
- Interpretação: FWL "partial out" o efeito de W, isolando a variação de X não explicada por W.
- Em painel: se coeficiente de W não varia com o tempo mas deveria, partial out introduz viés.
"""

SKILL_INFERENCE = """
# SKILL: INFERÊNCIA

Pressupõe identificação e estimação estabelecidas. Qual é a incerteza amostral?

DISTRIBUIÇÃO AMOSTRAL:
- Estimando θ = φ(F): número fixo. Estimador θ̂: variável aleatória.
- Distribuição amostral: como θ̂ varia entre amostras de tamanho n.
- Duas fontes: aleatoriedade de amostragem (visão modelo) vs. aleatoriedade de atribuição (design-based).

ERRO-PADRÃO:
- SE(θ̂) = √Var(θ̂). Mede dispersão típica de θ̂ em torno de θ.
- NÃO captura: viés de identificação, viés de forma funcional, incerteza sobre o modelo.
- Regra de ouro: EP pequeno com identificação fraca é pior que EP grande com identificação sólida.

ERROS-PADRÃO ROBUSTOS E CLUSTERING:
- Heteroscedasticidade: usar Huber-White / sandwich. Custo zero, sempre recomendado em corte transversal.
- Clustering: quando observações são correlacionadas dentro de grupos.
  Clusterizar pelo nível de atribuição do tratamento.
  Com <30-50 clusters: bootstrap por cluster ou inferência por permutação.
- Painel: dependência serial → clustering por unidade ou Driscoll-Kraay.

TESTES DE HIPÓTESE:
- H0 vs H1. Estatística de teste T com distribuição conhecida sob H0.
- p-valor = P(|T| ≥ |t_obs| | H0). NÃO é probabilidade de H0 ser verdadeira.
- Estatística t: t = (θ̂ - θ0) / SE(θ̂). Rejeita H0 se |t| > 1.96 (α=0.05).
- Estatística F: testa q restrições conjuntas. F < 10 no primeiro estágio de IV = instrumento fraco.
- Testes de falsificação: placebo de resultado, placebo de tratamento, pré-tendências, balanceamento.
  Evidência circunstancial — nunca provam hipótese de identificação.
- Múltiplos testes: reportar todos. Bonferroni (conservador) ou FDR (Benjamini-Hochberg).

INTERVALOS DE CONFIANÇA:
- IC de nível 1-α: P(θ ∈ [θ̂_L, θ̂_U]) = 1-α. θ é fixo; o IC é aleatório.
- IC = [θ̂ ± z_{α/2} · SE(θ̂)] para estimadores assintoticamente normais.
- Dualidade: rejeitar H0: θ=θ0 ao nível α ⟺ θ0 ∉ IC de nível 1-α.
"""

SKILL_CLEAR = """
# SKILL: ESTILO GUIA CLEAR (FGV EESP)

MISSÃO: materiais didáticos de econometria aplicada para pós-graduandos e pesquisadores de políticas públicas.
Tom: acadêmico mas acessível. Rigoroso em notação, nunca hermético.

HIERARQUIA OBRIGATÓRIA de cada seção:
1. Por que precisamos disso? (motivação)
2. Definição intuitiva (sem formalismo)
3. Formalização matemática
4. Como estimamos / procedimento
5. Resultados e interpretação

ESTRUTURA DE CADA SUBSEÇÃO:
- Frase de abertura conectando à subseção anterior
- Intuição em prosa antes de qualquer equação
- Exemplo numérico hipotético (3-5 observações, tratados = letras A/B/C, controles = números 1/2/3)
- Formalização matemática
- Ancoragem empírica de cada conceito novo
- Frase de encerramento com transição

SIGLAS: sempre na primeira ocorrência com nome inglês E tradução portuguesa.
Exemplos corretos:
  ATE (Average Treatment Effect — Efeito Médio do Tratamento)
  ATT (Average Treatment Effect on the Treated — Efeito Médio do Tratamento sobre os Tratados)
  OLS (Ordinary Least Squares — Mínimos Quadrados Ordinários)
  RCT (Randomized Controlled Trial — Experimento Controlado Aleatorizado)
  SUTVA (Stable Unit Treatment Value Assumption — Hipótese de Estabilidade do Valor do Tratamento)
  FWL (Frisch-Waugh-Lovell)
  DiD (Difference-in-Differences — Diferenças em Diferenças)
  RDD (Regression Discontinuity Design — Desenho de Regressão Descontínua)
Nas ocorrências seguintes: só a sigla.

EXEMPLOS EMPÍRICOS: todo conceito novo deve ser ancorado no exemplo empírico em uso.
Sequência: (1) defina em abstrato, (2) explique o que significa neste exemplo específico.
Use preferencialmente exemplos de políticas públicas brasileiras (Bolsa Família, PRONATEC, programas municipais).

TOM:
- "nós" implícito: "vimos que...", "iremos mostrar...", "mostramos que..."
- Perguntas retóricas: "Será que conseguimos recuperar o ATE apenas comparando médias?"
- Advertências explícitas: "É importante notar que...", "Vale ressaltar que..."
- NUNCA: "obviamente", "trivialmente", "claramente"
- NUNCA: apresentar estimador antes de motivar o problema de identificação

NOTAÇÃO PADRÃO:
- Yi(1), Yi(0): resultados potenciais
- Di ∈ {0,1}: tratamento binário
- Xi ou Wi: covariadas
- δi = Yi(1) - Yi(0): efeito individual
- ATE = E[Yi(1) - Yi(0)], ATT = E[Yi(1) - Yi(0) | Di=1]
- p(Xi) = P(Di=1 | Xi): propensity score
- Sempre definir notação antes de usar

CÓDIGO R (quando necessário):
- Comentários em português
- Etapas numeradas: # 1) Descrição...
- Usar: tidyverse, estimatr::lm_robust(se_type="stata"), modelsummary, ggplot2+theme_classic()

TABELAS:
- Numeradas por seção: Tabela 2.1, Tabela 2.2, etc.
- Notas de rodapé: + p<0.1; * p<0.05; ** p<0.01; *** p<0.001
- Estimativas com EP entre parênteses na linha abaixo
"""

# ---------------------------------------------------------------------------
# Outline completo da seção 2
# ---------------------------------------------------------------------------

OUTLINE_SECAO2 = """
OUTLINE DA SEÇÃO 2: IDENTIFICAÇÃO

Estrutura completa a ser desenvolvida:

2. Identificação
   Introdução calma e gradual. Começa com Y como função abstrata de X (modelo teórico genérico).
   Constrói intuição sobre o parâmetro de interesse do modelo teórico vs. modelo populacional.
   O ponto central: no modelo populacional, não observamos o contrafactual — explique isso
   de forma muito intuitiva. Introduza SUTVA aqui como hipótese necessária.
   Prepara o terreno para 2.1: para fazer equivalência entre parâmetro e estimando, precisamos
   hipóteses sobre a função Y(X), exogeneidade, e não interferência.

2.1 Modelo Linear com Tratamento Binário
   Assuma que o modelo verdadeiro é Y linear em X. Ressalte que isso já é uma hipótese — talvez Y
   não seja linear, talvez existam efeitos heterogêneos. Foque no caso X binário sem covariadas
   (função linear por construção nesse caso).

2.1.1 Hipótese de Exogeneidade
   Assuma X exógeno. Resolva o problema de identificação algebricamente, passo a passo.
   Explique intuitivamente o que exogeneidade significa. Conecte a uma aplicação empírica concreta.
   Introduza o conceito de RCT (Randomized Controlled Trial — Experimento Controlado Aleatorizado)
   como o design que garante exogeneidade por construção.

2.1.2 Viés de Seleção
   O que acontece sem exogeneidade? Abra o estimando e mostre o termo de viés de seleção
   algebricamente. Dê intuição com exemplo empírico concreto (por que a seleção ocorre,
   o que o viés captura, qual a direção esperada).

2.1.3 Interferência (Relaxando SUTVA)
   Reescreva o modelo permitindo spillover: Yi(d1,...,dn) — resultado de i depende do vetor
   completo de tratamentos. Mostre as hipóteses necessárias para identificar o efeito nesse
   contexto. Resolva o problema de identificação. Dê exemplo empírico de interferência
   (ex: vacinação, programas de emprego com efeitos de rede).

2.1.4 Covariadas
   Adicione covariadas W: Y(x,w) = Y(0,w) + β(w)·x.
   Adapte a hipótese de exogeneidade: E[ε | X, W] = 0.
   Resolva o problema de identificação — o estimando será uma média ponderada dos β(w).
   Hipótese mais forte: β(w) = β constante. Explique intuitivamente por que efeitos
   heterogêneos podem ser um problema com exemplo empírico.
   Introduza a versão populacional do teorema FWL:
   β = E[(X - E[X|W])(Y - E[Y|W])] / E[(X - E[X|W])²]

2.2 Mais de um Período
   Introduza o modelo com múltiplos períodos, sem efeitos dinâmicos inicialmente.
   X binário, β_t varia com t. Sem covariadas primeiro.

2.2.1 Identificação em Painel
   Adapte a hipótese de exogeneidade para painel. O estimando captura média ponderada dos β_t.
   Faça isso para:
   (A) Modelo pooled: regride Y em X e dummies de tempo. Mostre algebricamente os pesos.
   (B) Modelo de efeitos fixos: within transformation. Mostre algebricamente os pesos.
   Compare os dois — os pesos diferem. Explique intuitivamente.

2.2.2 Covariadas em Painel
   Adicione covariadas W no modelo em painel.
   (A) Pooled sem interação W×D: use FWL para mostrar que há um termo de viés. Mostre
       algebricamente qual é esse viés e de onde vem (coeficiente de W não varia com t).
   (B) Pooled com interação W×D: mostre que o viés desaparece. Demonstração algébrica.
   Explique intuitivamente com exemplo empírico por que o viés existe e como a interação resolve.

2.3 Modelo com Tratamento Não-Binário
   Como assumir linearidade quando X não é binário pode ser problemático.
   Primeiro: assuma que o modelo realmente é linear mas com efeitos heterogêneos.
   O que conseguimos identificar? Uma média ponderada dos efeitos.

2.3.1 Modelo Estrutural Não-Linear
   Defina Y = h(X, ε) — modelo estrutural geral.
   Parâmetro de interesse: se X contínuo, derivada ∂h/∂X. Se X discreto, h(x+1,ε) - h(x,ε).
   Ao assumir especificação linear, identificamos uma média ponderada dessas variáveis.
   Podemos ir além: identificar efeitos heterogêneos condicionando em valores de X.
   Mencione as hipóteses para isso (Chesher 2003) sem entrar em detalhes exotéricos.
   Mostre a diferença entre o estimando de OLS e o estimando da Average Derivative
   (referência: Imbens e Newey 2009, Garzon e Possebom 2025).
   Contexto: mundo em que X é exógeno.

2.4 Além do RCT
   Comente a diferença entre RCT e métodos quasi-experimentais.
   Como mudanças na hipótese de exogeneidade levam a diferentes estratégias de identificação.
   
   Subseções curtas (intuição apenas, com menção ao guia Clear correspondente):
   
   2.4.1 Matching
   Quando a exogeneidade só vale condicional a observáveis: CIA.
   Intuição do matching como reconstrução do contrafactual via comparação de similares.
   Referência ao Guia Clear de Matching.
   
   2.4.2 Regressão Descontínua (RDD)
   Exogeneidade local: ao redor do cutoff, atribuição é como se aleatória.
   Intuição do design. Referência ao Guia Clear de RDD.
   
   2.4.3 Diferenças em Diferenças (DiD)
   Exogeneidade substituída por tendências paralelas.
   Intuição do design. Referência ao Guia Clear de DiD.
   
   2.4.4 Controle Sintético
   Quando não há grupo de controle natural comparável.
   Intuição de construir um controle sintético via pesos.
   Referência ao Guia Clear de Controle Sintético.
"""

# ---------------------------------------------------------------------------
# System prompts dos agentes
# ---------------------------------------------------------------------------

SYSTEM_ECONOMETRIA = f"""Você é o Agente de Econometria de um pipeline editorial para o Guia Clear de Inferência Causal (FGV EESP).

{SKILL_IDENTIFICATION}

{SKILL_ESTIMATION}

{SKILL_INFERENCE}

Sua tarefa: produzir o CONTEÚDO TÉCNICO COMPLETO da Seção 2 (Identificação) do guia.

REGRAS:
- Siga o outline fornecido rigorosamente, subseção por subseção, sem pular nada.
- Para cada subseção: (1) apresente a intuição, (2) formalize matematicamente, (3) derive o resultado principal passo a passo.
- Inclua todas as derivações algébricas pedidas no outline. Seja explícito e detalhado.
- Use notação consistente ao longo de toda a seção.
- Inclua exemplos numéricos hipotéticos (3-5 observações) antes das formalizações.
- Não se preocupe com estilo editorial — foque em rigor técnico e completude.
- Escreva em português.
- Para referências: Chesher (2003), Imbens e Newey (2009), Garzon e Possebom (2025).
- Para os guias Clear mencionados em 2.4: referencie como "Guia Clear de [Método]" — os guias ainda serão publicados.
"""

SYSTEM_ESCRITA = f"""Você é o Agente de Escrita de um pipeline editorial para o Guia Clear de Inferência Causal (FGV EESP).

{SKILL_CLEAR}

Sua tarefa: receber o conteúdo técnico do Agente de Econometria e transformá-lo em prosa no estilo Clear.

REGRAS:
- Mantenha TODO o rigor técnico e TODAS as derivações — não simplifique nem omita matemática.
- Aplique TODAS as regras de estilo: siglas com tradução, ancoragem empírica, hierarquia pedagógica.
- Use exemplos de políticas públicas brasileiras quando possível (Bolsa Família, PRONATEC, etc.).
- Tom com "nós" implícito, perguntas retóricas, advertências explícitas.
- Cada subseção deve começar conectando à anterior e terminar preparando a próxima.
- Numeração de subseções exatamente como no outline: 2, 2.1, 2.1.1, 2.1.2, etc.
- Escreva em português.
"""

SYSTEM_REVISAO = f"""Você é o Agente de Revisão de um pipeline editorial para o Guia Clear de Inferência Causal (FGV EESP).

{SKILL_IDENTIFICATION}

{SKILL_ESTIMATION}

{SKILL_INFERENCE}

{SKILL_CLEAR}

Sua tarefa: revisar o texto do Agente de Escrita. Verifique e corrija:

CHECKLIST TÉCNICO:
- [ ] Confusão entre parâmetro econômico / estimando / estimador?
- [ ] Ordem invertida (estimador antes da identificação)?
- [ ] Hipóteses de identificação apresentadas como testáveis quando não são?
- [ ] Derivações algébricas com erros?
- [ ] Notação inconsistente entre subseções?
- [ ] SUTVA introduzido antes de 2.1.3?
- [ ] FWL na versão de esperanças condicionais (não matricial)?
- [ ] Viés em painel com covariadas mostrado como termo explícito?
- [ ] Average Derivative vs. OLS distinguidos corretamente?

CHECKLIST EDITORIAL:
- [ ] Siglas sem tradução em português?
- [ ] Conceitos sem ancoragem no exemplo empírico?
- [ ] Seções sem transição para a próxima?
- [ ] Uso de "obviamente", "trivialmente", "claramente"?
- [ ] Exemplos numéricos ausentes antes de formalizações?

Produza o TEXTO FINAL revisado, incorporando todas as correções necessárias.
Se uma seção estiver correta, reproduza-a com eventuais melhorias de fluência.
Escreva em português.
"""

# ---------------------------------------------------------------------------
# Funções auxiliares
# ---------------------------------------------------------------------------

def ensure_output_dir():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

def save_output(filename: str, content: str):
    path = os.path.join(OUTPUT_DIR, filename)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"\n✓ Salvo em: {path}")

def run_agent(client: anthropic.Anthropic, name: str, system: str, user_message: str, output_file: str) -> str:
    print(f"\n{'='*60}")
    print(f"  AGENTE: {name}")
    print(f"{'='*60}\n")

    full_text = ""

    with client.messages.stream(
        model=MODEL,
        max_tokens=MAX_TOKENS,
        system=system,
        messages=[{"role": "user", "content": user_message}]
    ) as stream:
        for text in stream.text_stream:
            print(text, end="", flush=True)
            full_text += text

    print(f"\n\n[{name}: {len(full_text)} caracteres gerados]")
    save_output(output_file, full_text)
    return full_text

# ---------------------------------------------------------------------------
# Pipeline principal
# ---------------------------------------------------------------------------

def main():
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        print("Erro: variável de ambiente ANTHROPIC_API_KEY não encontrada.")
        print("Execute: export ANTHROPIC_API_KEY=sk-ant-...")
        sys.exit(1)

    client = anthropic.Anthropic(api_key=api_key)
    ensure_output_dir()

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    print("\n" + "="*60)
    print("  PIPELINE CLEAR — GUIA DE INFERÊNCIA CAUSAL")
    print("  Seção 2: Identificação")
    print(f"  Modelo: {MODEL} | Max tokens: {MAX_TOKENS}")
    print("="*60)

    # ------------------------------------------------------------------
    # Agente 1: Econometria
    # ------------------------------------------------------------------
    user_econ = f"""Produza o conteúdo técnico completo da Seção 2 (Identificação) do Guia Clear de Inferência Causal.

Siga este outline rigorosamente, desenvolvendo CADA subseção por completo:

{OUTLINE_SECAO2}

Seja completo e não pule subseções. Inclua todas as derivações algébricas pedidas."""

    output_econ = run_agent(
        client=client,
        name="Econometria",
        system=SYSTEM_ECONOMETRIA,
        user_message=user_econ,
        output_file=f"01_econometria_{timestamp}.md"
    )

    # ------------------------------------------------------------------
    # Agente 2: Escrita
    # ------------------------------------------------------------------
    user_escrita = f"""Transforme o seguinte conteúdo técnico em prosa no estilo Clear, aplicando TODAS as regras editoriais.

Mantenha toda a matemática e todas as derivações. Sua função é organizar, fluidificar e ancorar pedagogicamente.

CONTEÚDO TÉCNICO:
{output_econ}"""

    output_escrita = run_agent(
        client=client,
        name="Escrita",
        system=SYSTEM_ESCRITA,
        user_message=user_escrita,
        output_file=f"02_escrita_{timestamp}.md"
    )

    # ------------------------------------------------------------------
    # Agente 3: Revisão
    # ------------------------------------------------------------------
    user_revisao = f"""Revise o texto abaixo verificando rigor técnico e conformidade com o estilo Clear.
Produza a versão final corrigida, pronta para publicação.

TEXTO A REVISAR:
{output_escrita}"""

    output_final = run_agent(
        client=client,
        name="Revisão",
        system=SYSTEM_REVISAO,
        user_message=user_revisao,
        output_file=f"03_final_{timestamp}.md"
    )

    print("\n" + "="*60)
    print("  PIPELINE CONCLUÍDO")
    print(f"  Outputs salvos em: {OUTPUT_DIR}/")
    print(f"  Arquivo final: 03_final_{timestamp}.md")
    print("="*60 + "\n")

if __name__ == "__main__":
    main()