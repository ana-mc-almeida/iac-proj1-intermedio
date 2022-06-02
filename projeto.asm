	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; * IST - UL
	; * Modulo: lab5 - move - boneco - teclado.asm
	; * Descrição: Este programa ilustra o movimento de um boneco do ecrã, sob controlo
	; * do teclado.
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; * Constantes
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	DISPLAYS EQU 0A000H          ; endereço do display
	TEC_LIN EQU 0C000H           ; endereço das linhas do teclado (periférico POUT - 2)
	TEC_COL EQU 0E000H           ; endereço das colunas do teclado (periférico PIN)
	LINHA_TECLADO EQU 16         ; linha a testar (4ª linha, 1000b)
	MASCARA EQU 0FH              ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	
	
	DEFINE_LINHA EQU 600AH       ; endereço do comando para definir a linha
	DEFINE_COLUNA EQU 600CH      ; endereço do comando para definir a coluna
	DEFINE_PIXEL EQU 6012H       ; endereço do comando para escrever um pixel
	APAGA_AVISO EQU 6040H        ; endereço do comando para apagar o aviso de nenhum cenário selecionado
	APAGA_ECRA EQU 6002H         ; endereço do comando para apagar todos os pixels já desenhados
	SELECIONA_CENARIO_FUNDO EQU 6042H ; endereço do comando para selecionar uma imagem de fundo
	SELECIONA_SOM EQU 605AH      ; endereço do comando para selecionar um som de fundo
	
	LINHA_INICIAL_ROVER EQU 27   ; linha do rover (a meio do ecrã)
	COLUNA_INICIAL_ROVER EQU 30  ; coluna do rover (a meio do ecrã)
	
	LINHA_INICIAL_METEORO EQU 10 ; linha do meteoro (a meio do ecrã)
	COLUNA_INICIAL_METEORO EQU 30 ; coluna do meteoro (a meio do ecrã)
	
	INICIO_DISPLAY EQU 020H
	
	MIN_COLUNA EQU 0             ; número da coluna mais à esquerda que o objeto pode ocupar
	MAX_COLUNA EQU 63            ; número da coluna mais à direita que o objeto pode ocupar
	MAX_LINHA EQU 31             ; número da linha
	MIN_LINHA EQU 0              ; número da linha
	ATRASO EQU 200H              ; atraso para limitar a velocidade de movimento do boneco
	
	LARGURA_ROVER EQU 5          ; largura do rover
	ALTURA_ROVER EQU 4           ; altura do rover
	LARGURA_METEORO_MAU EQU 5    ; largura do meteoro mau
	ALTURA_METEORO_MAU EQU 5     ; altura meteoro mau
	
	
	; cores
	COR_AMARELA EQU 0FFF0H       ; cor do pixel: amarelo em ARGB (opaco, vermelho no máximo, verde no máximo e azul a 0)
	COR_VERMELHA EQU 0FF00H      ; cor do pixel: vermelho em ARGB (opaco, vermelho no máximo, verde e azul a 0)
	
	; teclas com funções
	TECLA_00 EQU 00H             ; tecla 0
	TECLA_02 EQU 02H             ; tecla 2
	TECLA_03 EQU 03H             ; tecla 3
	TECLA_05 EQU 05H             ; tecla 5
	TECLA_09 EQU 09H             ; tecla 9
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; * Dados
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	PLACE 1000H
pilha:
	STACK 100H                   ; espaço reservado para a pilha
	; (200H bytes, pois são 100H words)
SP_inicial:                   ; este é o endereço (1200H) com que o SP deve ser
	; inicializado. O 1.º end. de retorno será
	; armazenado em 11FEH (1200H - 2)
	
DEF_ROVER:                    ; tabela que define o boneco (cor, largura, pixels)
	WORD LARGURA_ROVER
	WORD ALTURA_ROVER
	WORD 0, 0, COR_AMARELA, 0, 0 ; # # # as cores podem ser diferentes
	WORD COR_AMARELA, 0, COR_AMARELA, 0, COR_AMARELA ; # # # as cores podem ser diferentes
	WORD COR_AMARELA, COR_AMARELA, COR_AMARELA, COR_AMARELA, COR_AMARELA ; # # # as cores podem ser diferentes
	WORD 0, COR_AMARELA, 0, COR_AMARELA, 0 ; # # # as cores podem ser diferentes
	
DEF_METEORO_MAU:              ; tabela que define o meteoro mau (cor, largura, pixels)
	WORD LARGURA_METEORO_MAU
	WORD ALTURA_METEORO_MAU
	WORD COR_VERMELHA, 0, 0, 0, COR_VERMELHA ; # # # as cores podem ser diferentes
	WORD COR_VERMELHA, 0, COR_VERMELHA, 0, COR_VERMELHA ; # # # as cores podem ser diferentes
	WORD 0, COR_VERMELHA, COR_VERMELHA, COR_VERMELHA, 0 ; # # # as cores podem ser diferentes
	WORD COR_VERMELHA, 0, COR_VERMELHA, 0, COR_VERMELHA ; # # # as cores podem ser diferentes
	WORD COR_VERMELHA, 0, 0, 0, COR_VERMELHA ; # # # as cores podem ser diferentes
	
COLUNA_ROVER: WORD COLUNA_INICIAL_ROVER
LINHA_ROVER: WORD LINHA_INICIAL_ROVER
	
COLUNA_METEORO: WORD COLUNA_INICIAL_METEORO
LINHA_METEORO: WORD LINHA_INICIAL_METEORO
	
DISPLAY: WORD INICIO_DISPLAY
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; * Código
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	PLACE 0                      ; o código tem de começar em 0000H
inicio:
	MOV SP, SP_inicial           ; inicializa SP para a palavra a seguir
	; à última da pilha
	
	MOV [APAGA_AVISO], R1        ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
	MOV [APAGA_ECRA], R1         ; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV R1, 0                    ; cenário de fundo número 0
	MOV [SELECIONA_CENARIO_FUNDO], R1 ; seleciona o cenário de fundo
	MOV R11, [DISPLAY]
	MOV [DISPLAYS], R11
	MOV R7, 1                    ; valor a somar à coluna do boneco, para o movimentar
	MOV R10, 0                   ; flag para desenhar meteoro pela primeira vez
	
mostra_meteoro:
	CALL posicao_meteoro         ; obtem a posicao do rover
	CALL desenha_boneco          ; desenha o boneco a partir da tabela
	CMP R10, 0                   ; caso não seja a primeira vez que se está a desenhar o meteoro
	JNZ espera_nao_tecla         ; é preciso esperar que a tecla não esteja a ser pressionada
	
mostra_rover:
	CALL posicao_rover           ; obtem a posicao do rover
	CALL desenha_boneco          ; desenha o boneco a partir da tabela
	
inicia_linhas:
	MOV R6, LINHA_TECLADO        ; linha a testar no teclado
espera_tecla:                 ; neste ciclo espera - se até uma tecla ser premida
	SHR R6, 1                    ; dividir por 2
	JZ inicia_linhas             ; se for 0 volta ao "inicio" das linhas
	MOV R10, R6                  ; memoriza a linha pressionada
	CALL teclado                 ; leitura às teclas
	CMP R0, 0                    ; se diferente de 0 vai dizer a coluna ( entre 1 e 8)
	JZ espera_tecla              ; espera, enquanto não houver tecla
	
	MOV R5, R6
	CALL converte_1248_to_0123
	MOV R6, R8
	
	MOV R5, R0
	CALL converte_1248_to_0123
	MOV R0, R8
	
	ADD R6, R6                   ; R6 = 2 * R6
	ADD R6, R6                   ; R6 = 2 * R6 <=> R6 = 4 * R6
	ADD R0, R6                   ; R0 = 4 * R6 + R0 - > exata tecla pressionada
	
	MOV R6, TECLA_00
	CMP R0, R6
	JZ testa_esquerda
	
	MOV R6, TECLA_02
	CMP R0, R6
	JZ testa_direita
	
	MOV R6, TECLA_03
	CMP R0, R6
	JZ move_meteoro
	
	
	MOV R6, TECLA_05
	CMP R0, R6
	JZ testa_cima
	
	MOV R6, TECLA_09
	CMP R0, R6
	JZ testa_baixo
	
	JMP espera_tecla
	
espera_nao_tecla:             ; neste ciclo espera - se até uma tecla ser premida
	CMP R10, 0                   ;verifica se é o inicial
	JZ espera_tecla
	MOV R6, R10
	CALL teclado
	CMP R0, 0                    ; se diferente de 0 vai dizer a coluna ( entre 1 e 8)
	JZ espera_tecla
	JMP espera_nao_tecla
	
testa_esquerda:
	MOV R7, - 1                  ; vai deslocar para a esquerda
	JMP ve_limites
	
testa_direita:
	MOV R7, + 1                  ; vai deslocar para a direita
	;JMP ve_limites ;linha desnecessária porque a rotina vem mesmo a seguir
	
ve_limites:
	CALL posicao_rover
	MOV R6, [R4]                 ; obtém a largura do boneco
	CALL testa_limites           ; vê se chegou aos limites do ecrã e se sim força R7 a 0
	CMP R7, 0
	JZ espera_tecla              ; se não é para movimentar o objeto, vai ler o teclado de novo
	
move_rover:
	CALL posicao_rover
	CALL apaga_boneco            ; apaga o boneco na sua posição corrente
	
coluna_seguinte:
	;CALL posicao_rover desnecessario porque já faz isto no move boneco
	ADD R2, R7                   ; para desenhar objeto na coluna seguinte (direita ou esquerda)
	MOV [COLUNA_ROVER], R2
	JMP mostra_rover             ; vai desenhar o boneco de novo
	
testa_cima:
	MOV R11, [DISPLAY]
	ADD R11, 1
	MOV [DISPLAYS], R11
	MOV [DISPLAY], R11
	JMP espera_nao_tecla
	
testa_baixo:
	MOV R11, [DISPLAY]
	SUB R11, 1
	MOV [DISPLAYS], R11
	MOV [DISPLAY], R11
	JMP espera_nao_tecla
	
	
move_meteoro:
	CALL posicao_meteoro
	CALL apaga_boneco            ; apaga o boneco na sua posição corrente
	MOV R5, 0                    ;som
	MOV [SELECIONA_SOM], R5
	
linha_seguinte:
	;CALL posicao_rover desnecessario porque já faz isto no move boneco
	ADD R1, 1                    ; para desenhar objeto na coluna seguinte (direita ou esquerda)
	MOV R6, MAX_LINHA
	CMP R1, R6
	JZ reinicia_meteoro
	MOV [LINHA_METEORO], R1
	JMP mostra_meteoro           ; vai desenhar o boneco de novo
	
reinicia_meteoro:
	MOV R1, MIN_LINHA            ; coloca o meteoro no início do ecrã
	MOV [LINHA_METEORO], R1
	JMP mostra_meteoro           ; vai desenhar o boneco de novo
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; DESENHA_BONECO - Desenha um boneco na linha e coluna indicadas
	; com a forma e cor definidas na tabela indicada.
	; Argumentos: R1 - linha
	; R2 - coluna
	; R4 - tabela que define o boneco
	;
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
desenha_boneco:
	PUSH R1
	PUSH R2                      ; indicador da coluna em que está a desenhar
	PUSH R3                      ; indicador da cor que está a desenhar
	PUSH R4                      ;enderaço da tabela
	PUSH R5                      ;largura do boneco
	PUSH R6                      ; altura do boneco
	PUSH R7                      ; guarda a coluna inicial
	PUSH R8                      ; guarda a largura do boneco
obtem_altura_desenha:
	MOV R8, [R4]                 ; obtém a largura do boneco
	ADD R4, 2                    ; endereço da altura do boneco (2 porque a largura é uma word)
	MOV R6, [R4]                 ; obtém a altura do boneco
	ADD R4, 2                    ; endereço da altura do boneco (2 porque a largura é uma word)
	MOV R7, R2
obtem_largura_desenha:
	MOV R2, R7
	MOV R5, R8                   ; obtém a largura do boneco
desenha_pixels:               ; desenha os pixels do boneco a partir da tabela
	MOV R3, [R4]                 ; obtém a cor do próximo pixel do boneco
	CALL escreve_pixel           ; escreve cada pixel do boneco
	ADD R4, 2                    ; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
	ADD R2, 1                    ; próxima coluna
	SUB R5, 1                    ; menos uma coluna para tratar
	JNZ desenha_pixels           ; continua até percorrer toda a largura do objeto
	ADD R1, 1
	SUB R6, 1
	JNZ obtem_largura_desenha    ; continua até percorrer toda a altura do objeto
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; APAGA_BONECO - Apaga um boneco na linha e coluna indicadas
	; com a forma definida na tabela indicada.
	; Argumentos: R1 - linha
	; R2 - coluna
	; R4 - tabela que define o boneco
	;
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
apaga_boneco:
	PUSH R1
	PUSH R2                      ; indicador da coluna em que está a desenhar
	PUSH R3                      ; indicador da cor que está a desenhar
	PUSH R4                      ;enderaço da tabela
	PUSH R5                      ;largura do boneco
	PUSH R6                      ; altura do boneco
	PUSH R7                      ; guarda a coluna inicial
	PUSH R8                      ; guarda a largura do boneco
obtem_altura_apaga:
	MOV R8, [R4]                 ; obtém a largura do boneco
	ADD R4, 2                    ; endereço da altura do boneco (2 porque a largura é uma word)
	MOV R6, [R4]                 ; obtém a altura do boneco
	ADD R4, 2                    ; endereço da altura do boneco (2 porque a largura é uma word)
	MOV R7, R2
obtem_largura_apaga:
	MOV R2, R7
	MOV R5, R8                   ; obtém a largura do boneco
apaga_pixels:                 ; desenha os pixels do boneco a partir da tabela
	MOV R3, 0                    ; obtém a cor do próximo pixel do boneco
	CALL escreve_pixel           ; escreve cada pixel do boneco
	ADD R4, 2                    ; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
	ADD R2, 1                    ; próxima coluna
	SUB R5, 1                    ; menos uma coluna para tratar
	JNZ apaga_pixels             ; continua até percorrer toda a largura do objeto
	ADD R1, 1
	SUB R6, 1
	JNZ obtem_largura_apaga      ; continua até percorrer toda a altura do objeto
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET
	
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; ESCREVE_PIXEL - Escreve um pixel na linha e coluna indicadas.
	; Argumentos: R1 - linha
	; R2 - coluna
	; R3 - cor do pixel (em formato ARGB de 16 bits)
	;
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
escreve_pixel:
	MOV [DEFINE_LINHA], R1       ; seleciona a linha
	MOV [DEFINE_COLUNA], R2      ; seleciona a coluna
	MOV [DEFINE_PIXEL], R3       ; altera a cor do pixel na linha e coluna já selecionadas
	RET
	
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; ATRASO - Executa um ciclo para implementar um atraso.
	; Argumentos: R11 - valor que define o atraso
	;
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
atraso:
	PUSH R11
ciclo_atraso:
	SUB R11, 1
	JNZ ciclo_atraso
	POP R11
	RET
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; TESTA_LIMITES - Testa se o boneco chegou aos limites do ecrã e nesse caso
	; impede o movimento (força R7 a 0)
	; Argumentos: R2 - coluna em que o objeto está
	; R6 - largura do boneco
	; R7 - sentido de movimento do boneco (valor a somar à coluna
	; em cada movimento: + 1 para a direita, - 1 para a esquerda)
	;
	; Retorna: R7 - 0 se já tiver chegado ao limite, inalterado caso contrário
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
testa_limites:
	PUSH R5
	PUSH R6
testa_limite_esquerdo:        ; vê se o boneco chegou ao limite esquerdo
	MOV R5, MIN_COLUNA
	CMP R2, R5
	JGT testa_limite_direito
	CMP R7, 0                    ; passa a deslocar - se para a direita
	JGE sai_testa_limites
	JMP impede_movimento         ; entre limites. Mantém o valor do R7
testa_limite_direito:         ; vê se o boneco chegou ao limite direito
	ADD R6, R2                   ; posição a seguir ao extremo direito do boneco
	MOV R5, MAX_COLUNA
	CMP R6, R5
	JLE sai_testa_limites        ; entre limites. Mantém o valor do R7
	CMP R7, 0                    ; passa a deslocar - se para a direita
	JGT impede_movimento
	JMP sai_testa_limites
impede_movimento:
	MOV R7, 0                    ; impede o movimento, forçando R7 a 0
sai_testa_limites:
	POP R6
	POP R5
	RET
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; TECLADO - Faz uma leitura às teclas de uma linha do teclado e retorna o valor lido
	; Argumentos: R6 - linha a testar (em formato 1, 2, 4 ou 8)
	;
	; Retorna: R0 - valor lido das colunas do teclado (0, 1, 2, 4, ou 8)
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
teclado:
	PUSH R2
	PUSH R3
	PUSH R5
	MOV R2, TEC_LIN              ; endereço do periférico das linhas
	MOV R3, TEC_COL              ; endereço do periférico das colunas
	MOV R5, MASCARA              ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOVB [R2], R6                ; escrever no periférico de saída (linhas)
	MOVB R0, [R3]                ; ler do periférico de entrada (colunas)
	AND R0, R5                   ; elimina bits para além dos bits 0 - 3
	POP R5
	POP R3
	POP R2
	RET
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; converte_1248_to_0123 - Converte o valor entre (1, 2, 4 ou 8) para um valor entre (0, 1, 2, 3)
	; Argumentos: R5 - valor (em formato 1, 2, 4 ou 8)
	;
	; Retorna: R8 - valor (em formato 0, 1, 2, 3)
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
converte_1248_to_0123:
	PUSH R5
	MOV R8, - 1
	CMP R5, 0
	JZ fim_1248_to_0123
ciclo_1248_to_0123:
	SHR R5, 1
	ADD R8, 1                    ; incrementa o contador
	CMP R5, 0
	JNZ ciclo_1248_to_0123       ; repete o ciclo enquanto R5 = / = 0
fim_1248_to_0123:
	POP R5
	RET
	
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; posicao_rover - Converte o valor entre (1, 2, 4 ou 8) para um valor entre (0, 1, 2, 3)
	; Argumentos: nenhuma
	;
	; Retorna:
	; R1 - linha do rover
	; R2 - coluna do rover
	; R4 - endereço da tabela que define o rover
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	
posicao_rover:
	MOV R1, [LINHA_ROVER]        ; linha do rover
	MOV R2, [COLUNA_ROVER]       ; coluna do rover
	MOV R4, DEF_ROVER            ; endereço da tabela que define o rover
	RET
	
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; posicao_rover - Retorna as informações do
	; Argumentos: nenhuma
	;
	; Retorna:
	; R1 - linha do meteoro
	; R2 - coluna do meteoro
	; R4 - endereço da tabela que define o meteoro
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
posicao_meteoro:
	MOV R1, [LINHA_METEORO]      ; linha do meteoro
	MOV R2, [COLUNA_METEORO]     ; coluna do meteoro
	MOV R4, DEF_METEORO_MAU      ; endereço da tabela que define o meteoro
	RET
