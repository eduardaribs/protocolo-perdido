# Protocolo Perdido

Jogo 2D de Engenharia de Software sobre diagramas de sequência.

1. Extraia o ZIP e importe o arquivo `project.godot` no Godot 4.
2. Pressione **F5** e clique em **Jogar**. Na primeira vez, o jogo abre o treinamento.
3. Use **WASD** ou **setas** para andar e **E** perto das estações para interagir. Use **Esc** para voltar ou pausar.
4. Na Fase 01, siga os objetivos na parte de baixo da tela. Consulte as pistas, monte a sequência no simulador e corrija a primeira mensagem que falhar e valide um horário livre e outro ocupado.

O menu **Selecionar fase** permite repetir o treinamento ou abrir a Fase 01. O melhor resultado fica salvo neste computador. As estrelas premiam a conclusão da fase, a ausência de falhas ou erros de previsão e a conclusão sem usar o botão **Pedir dica**. A consulta aos terminais é opcional para a pontuação.

## Animação do computador — v12

Depois de prever o resultado de um cenário, acompanhe as setas do diagrama.
Em seguida, a astronauta caminha até um computador e executa sua sequência.
O monitor mostra a confirmação, a recusa esperada ou uma falha específica.
Use **Ver resultado e corrigir** para revisar um erro de montagem.
Se a previsão do fragmento alt estiver incorreta, faça uma nova previsão.
O botão **Pular animação** avança diretamente ao resultado visual, sem mudar a pontuação.

## Entrada na nave — v13

O menu mostra a nave no espaço, com estrelas em movimento e um planeta.
Clique em **JOGAR · Entrar na nave** para aproximar a câmera da nave.
Após a aproximação, a tela faz uma transição para a sala de operações.
A primeira entrada leva ao treinamento. Nas seguintes, abre a Fase 01.
O botão **Pular entrada** abre o interior diretamente.
**Como funciona** mantém a prévia animada das etapas da missão disponível.

O interior agora tem estrutura metálica, janela panorâmica para o espaço,
corredor central e escotilha do laboratório. Ao aprovar os dois cenários,
as luzes mudam para verde e a escotilha se abre.
A animação da astronauta testando a sequência no computador também está incluída.

## Ponte de comando ilustrada — v14

O interior foi refeito com arte 2D em perspectiva: janela para a Terra,
consoles azuis, verdes e lilás, mesa holográfica âmbar, tubulações e iluminação.
Os equipamentos da própria ilustração são os pontos de interação.
Aproxime-se pela frente ou pelos lados e pressione E. Os nomes e marcadores
identificam os consoles, e as colisões acompanham os móveis ilustrados.
A nave do menu, o zoom de entrada, os testes e a animação do computador
também estão incluídos. A arte do cenário foi produzida com apoio de IA.

## Cabine de testes — v15

A animação do teste agora usa uma cabine ilustrada com escotilha para a Terra,
console metálico, teclado e iluminação. A gatinha caminha até o equipamento.
O monitor mostra a espera, o processamento e o resultado, com luz verde para
operações válidas e vermelha para divergências. A explicação aparece após a
animação, junto ao botão para continuar e revisar o resultado.
O cenário principal da ponte de comando e a entrada com zoom estão incluídos.

## Gatinha e terminais educativos — v16

A personagem agora usa uma arte detalhada com quatro poses: espera,
dois passos de caminhada e interação com o teclado. A mesma gatinha aparece
na nave, na cabine de testes e nas telas dos terminais.

Na Fase 01, aproxime-se dos consoles e pressione E:
- Terminal: demonstra o pedido de reserva enviado ao Serviço.
- Serviço: demonstra a consulta, a resposta e a gravação para um horário livre.
- Banco: demonstra a consulta e a resposta de horário ocupado.

Cada terminal tem tela de boas-vindas, conexão animada, cores próprias,
mensagens em movimento e explicações de UML sincronizadas com cada etapa.
Use **Rever animação** para acompanhar de novo e **Voltar à nave** para explorar.
Após consultar os três equipamentos, aparece também **Abrir simulador**.
A consulta continua sendo uma ajuda educativa, sem gastar corações.

## Organização das pistas — v17

As pistas usam um diagrama ampliado, com uma mensagem por vez.
Leia primeiro a função do equipamento, acompanhe a seta no centro e veja
a explicação de UML logo abaixo. O conteúdo permanece na mesma etapa
até você clicar em **Próxima mensagem**.

**Anterior** volta uma etapa e **Repetir esta seta** reproduz a mensagem atual.
**Concluir pista e voltar** registra a pista e retorna à nave.
**Sair da pista** fecha a explicação sem registrar uma consulta incompleta.
As pistas continuam opcionais e não gastam corações.

O cenário detalhado da nave e a cabine ilustrada dos testes permanecem no jogo.

## Menu orbital e tipografia — v18

O menu inicial foi integrado à cena espacial, com título sobre o fundo,
comandos em estilo HUD, ícones e destaque no botão Jogar.
A aproximação da nave continua ao iniciar o treinamento ou a fase.

A fonte Oxanium foi incluída nos títulos, botões e identificação da nave.
Os textos explicativos usam Open Sans para facilitar a leitura.
As duas fontes e suas licenças estão na pasta fonts do projeto.
Não é necessário instalar fontes no computador.

O visual dos painéis e botões foi harmonizado com os tons azul e ciano da nave.

## História e conclusão da missão — v19

Ao clicar em Jogar, a nave se aproxima e o jogo apresenta a missão em três
transmissões curtas. A tripulação depende da água reciclada e usa uma única
câmara para analisar cada amostra. Você é a astronauta que deve recuperar
o agendamento da câmara reconstruindo o protocolo de mensagens.

Use Continuar e Anterior para ler no seu ritmo, ou Pular história para
entrar diretamente. Na primeira partida, o treinamento vem após a história.

Depois de aprovar os testes de horário livre e ocupado, acompanhe a tarefa:
a astronauta leva a amostra à câmara no horário confirmado, a análise acontece
e o equipamento libera o lote de água da missão. A tela de estrelas aparece
ao selecionar Ver conclusão da missão.
Pular animação vai ao fim da análise, preservando a pontuação.

A narrativa e os resultados da análise fazem parte da ficção do jogo.


## Versão 20 — Aprendizado explícito de UML
- Objetivos educativos antes do início do reparo.
- Pistas com mensagens cumulativas, leitura de cima para baixo e barras de ativação.
- Destaque do caminho escolhido no fragmento alt; o outro caminho fica esmaecido.
- Pergunta de compreensão após os dois testes, com explicação e nova tentativa sem gastar corações.
- Revisão final de linhas de vida, mensagens, respostas, ativações e condições antes das estrelas.

Para abrir: extraia o ZIP, importe project.godot no Godot 4.7.2 e pressione F5.
