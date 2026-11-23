# 🚀 Protocolo Perdido

Uma missão espacial para praticar diagramas de sequência UML.

O sistema de agendamento do laboratório falhou. A tripulação depende da análise da água reciclada para liberar seu uso, e sua missão é recuperar a comunicação entre os componentes do sistema.

Investigue os consoles, reconstrua a sequência de mensagens e teste o protocolo para reativar o laboratório.

## 🎯 Objetivo educativo

O jogo foi desenvolvido para apoiar o contato inicial com diagramas de sequência UML, conteúdo de Engenharia de Software.

Durante a missão, o jogador pratica:

- Identificação dos participantes e de suas linhas de vida.
- Ordem e direção das mensagens.
- Interpretação de respostas e barras de ativação.
- Condições e caminhos alternativos do fragmento `alt`.

## 🎮 Como funciona

O jogo apresenta uma fase com três momentos:

1. **Investigar:** explorar os consoles de Terminal, Serviço e Banco de Dados para conhecer suas responsabilidades.
2. **Construir:** responder às perguntas e montar a sequência de mensagens no simulador.
3. **Testar:** verificar o comportamento do protocolo em horários livres e ocupados.

As escolhas recebem feedback explicativo. O jogador pode revisar a sequência, solicitar dicas e tentar novamente.

Após os testes, uma pergunta de compreensão e uma revisão visual retomam os conceitos trabalhados.

## 🕹️ Controles

| Comando | Ação |
|---|---|
| WASD ou setas | Mover o personagem |
| E | Interagir com os consoles |
| Mouse | Selecionar alternativas e navegar pelas telas |

## 🛠️ Tecnologias

- **Godot Engine 4.7.2**
- **GDScript**
- Interface e diagramas desenhados por componentes do jogo.
- Recursos visuais e animações para contextualizar a missão.

Ferramentas de inteligência artificial generativa apoiaram a elaboração de código, textos e recursos visuais durante o desenvolvimento.

## ▶️ Como executar

1. Baixe o repositório em **Code → Download ZIP** ou clone-o.
2. Extraia os arquivos, se necessário.
3. Abra o Godot Engine 4.7.2.
4. Clique em **Importar** e selecione `project.godot`.
5. Aguarde a importação dos recursos.
6. Pressione **F5** para executar o jogo.

Mantenha as pastas `art` e `fonts` nas posições originais, pois o projeto utiliza esses caminhos.

A pasta `.godot` é gerada automaticamente pelo editor e não precisa ser incluída no repositório.

## 📚 Contexto acadêmico

Projeto desenvolvido para a disciplina de **Engenharia de Software**, na **Universidade Federal do Maranhão — UFMA**.

A proposta contempla uma fase com início, desenvolvimento e encerramento, além de indicação de erros e acertos do jogador.

O protótipo passou por verificações funcionais. Sua eficácia na aprendizagem ainda não foi avaliada por meio de estudo com participantes.

## 👩‍💻 Autoras

**Isabel Conceição Sousa**  
isabel.cs@discente.ufma.br

**Maria Eduarda Ribeiro da Silva**  
maria.ribeiro1@discente.ufma.br

## 🔭 Possibilidades de evolução

- Novos desafios e contextos de interação.
- Introdução gradual dos fragmentos `loop` e `opt`.
- Ampliação das explicações e dos recursos de acessibilidade.
- Avaliação da experiência e da aprendizagem com estudantes.

Essas possibilidades não fazem parte, necessariamente, da versão atual.
