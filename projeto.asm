	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; * IST - UL
	; * IAC
	; * Grupo: 76
	; * Constituição do Grupo: 
	; * 	Alice Mota 			102500 
	; * 	Mafalda Matias 		103756 
	; * 	Ana Almeida			102618
	; * Descrição: Fase intermédia de um jogo de simulação de um rover a 
	; * defender o planeta X, que deve obter energia de meteoros bons e 
	; * destruir meteoros maus.
	; * Funções das teclas:
	; *		Tecla 0 -> Move o Rover de forma contínua para a esquerda
	; * 	Tecla 2 -> Move o Rover de forma contínua para a direita
	; * 	Tecla 3 -> Move o meteoro mau uma linha para baixo, produzindo um som
	; * 	Tecla 5 -> Aumenta o valor do display
	; * 	Tecla 9 -> Diminui o valor do display
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; * Constantes
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	DISPLAYS EQU 0A000H					; endereço do display
	TEC_LIN EQU 0C000H					; endereço das linhas do teclado (periférico POUT - 2)
	TEC_COL EQU 0E000H					; endereço das colunas do teclado (periférico PIN)
	LINHA_TECLADO EQU 16        		; linha inicial a ser testada (a dividir por 2)
	MASCARA EQU 0FH             		; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	
	
	DEFINE_LINHA EQU 600AH				; endereço do comando para definir a linha
	DEFINE_COLUNA EQU 600CH				; endereço do comando para definir a coluna
	DEFINE_PIXEL EQU 6012H				; endereço do comando para escrever um pixel
	APAGA_AVISO EQU 6040H				; endereço do comando para apagar o aviso de nenhum cenário selecionado
	APAGA_ECRA EQU 6002H				; endereço do comando para apagar todos os pixels já desenhados
	SELECIONA_CENARIO_FUNDO EQU 6042H	; endereço do comando para selecionar uma imagem de fundo
	SELECIONA_SOM EQU 605AH				; endereço do comando para selecionar um som de fundo
	
	LINHA_INICIAL_ROVER EQU 27			; linha do rover
	COLUNA_INICIAL_ROVER EQU 30			; coluna do rover
	
	LINHA_INICIAL_METEORO EQU 10		; linha do meteoro
	COLUNA_INICIAL_METEORO EQU 30 		; coluna do meteoro
	
	INICIO_DISPLAY EQU 020H				; valor inicial do display
	
	MIN_COLUNA EQU 0             		; coluna mais à esquerda
	MAX_COLUNA EQU 63           		; coluna mais à direita
	MAX_LINHA EQU 31             		; linha inferior
	MIN_LINHA EQU 0             		; linha superior
	ATRASO EQU 200H              		; atraso para limitar a velocidade de movimento do objeto
	
	LARGURA_ROVER EQU 5          		; largura do rover
	ALTURA_ROVER EQU 4           		; altura do rover
	LARGURA_METEORO_MAU EQU 5    		; largura do meteoro mau
	ALTURA_METEORO_MAU EQU 5     		; altura do meteoro mau
	
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; * Cores
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	COR_AMARELA EQU 0FFF0H       		; amarelo em ARGB (opaco, vermelho no máximo, verde no máximo e azul a 0)
	COR_VERMELHA EQU 0FF00H      		; vermelho em ARGB (opaco, vermelho no máximo, verde e azul a 0)
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; * Teclas com Funções
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	TECLA_00 EQU 00H             		; tecla 0 
	TECLA_02 EQU 02H             		; tecla 2
	TECLA_03 EQU 03H             		; tecla 3
	TECLA_05 EQU 05H             		; tecla 5
	TECLA_09 EQU 09H             		; tecla 9
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; * Dados
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	PLACE 1000H
pilha:
	STACK 100H                   		; espaço reservado para a pilha

SP_inicial:                   			; endereço (1200H) com que o SP deve ser inicializado
	
DEF_ROVER:                   			; tabela que define o Rover (cor, largura, pixels)
	WORD LARGURA_ROVER					; largura do Rover
	WORD ALTURA_ROVER					; altura do Rover
	WORD 0, 0, COR_AMARELA, 0, 0 		
	WORD COR_AMARELA, 0, COR_AMARELA, 0, COR_AMARELA
	WORD COR_AMARELA, COR_AMARELA, COR_AMARELA, COR_AMARELA, COR_AMARELA
	WORD 0, COR_AMARELA, 0, COR_AMARELA, 0
	
DEF_METEORO_MAU:              			; tabela que define o meteoro mau (cor, largura, pixels)
	WORD LARGURA_METEORO_MAU			; largura do Meteoro Mau
	WORD ALTURA_METEORO_MAU				; altura do Meteoro Mau
	WORD COR_VERMELHA, 0, 0, 0, COR_VERMELHA 
	WORD COR_VERMELHA, 0, COR_VERMELHA, 0, COR_VERMELHA 
	WORD 0, COR_VERMELHA, COR_VERMELHA, COR_VERMELHA, 0 
	WORD COR_VERMELHA, 0, COR_VERMELHA, 0, COR_VERMELHA 
	WORD COR_VERMELHA, 0, 0, 0, COR_VERMELHA 
	
COLUNA_ROVER: WORD COLUNA_INICIAL_ROVER			; variável que indica a coluna do Rover
LINHA_ROVER: WORD LINHA_INICIAL_ROVER			; variável que indica a linha do Rover
	
COLUNA_METEORO: WORD COLUNA_INICIAL_METEORO		; variável que indica a coluna do Meteoro		
LINHA_METEORO: WORD LINHA_INICIAL_METEORO		; variável que indica a linha do Meteoro
	
DISPLAY: WORD INICIO_DISPLAY					; variável que indica o valor do display
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; * Código
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	PLACE 0                      		; o código começa em 0000H
inicio:
	MOV SP, SP_inicial           		; inicializa SP para a palavra a seguir à última da pilha
	
	MOV [APAGA_AVISO], R1        		; apaga o aviso de nenhum cenário selecionado
	MOV [APAGA_ECRA], R1         		; apaga todos os pixels já desenhados
	MOV R1, 0                    		; cenário de fundo número 0
	MOV [SELECIONA_CENARIO_FUNDO], R1 	; seleciona o cenário de fundo
	MOV R11, [DISPLAY]					; armazena o valor inicial do display num registo
	MOV [DISPLAYS], R11					; apresenta no display o valor anterior
	MOV R7, 1                    		; valor a somar à coluna do objeto, para o movimentar
	MOV R10, 0                   		; flag para desenhar meteoro pela primeira vez
	
mostra_meteoro:
	CALL posicao_meteoro         		; obtém a posição do rover
	CALL desenha_objeto         		; desenha o objeto a partir da tabela
	CMP R10, 0                  		; caso não seja a primeira vez que se está a desenhar o meteoro
	JNZ espera_nao_tecla         		; é preciso esperar que a tecla não esteja a ser pressionada
	
mostra_rover:
	CALL posicao_rover           		; obtém a posição do rover
	CALL desenha_objeto          		; desenha o objeto a partir da tabela
	
inicia_linhas:
	MOV R6, LINHA_TECLADO        		; linha a testar no teclado
espera_tecla:                 			; ciclo de espera até ser premida uma tecla
	SHR R6, 1                    		; divide por 2 para passar para a linha anterior
	JZ inicia_linhas             		; se for 0 volta para a linha final
	MOV R10, R6                  		; memoriza a linha pressionada
	CALL teclado                 		; leitura das teclas
	CMP R0, 0                    		; se a coluna for diferente de 0 vai indicá-la entre 1 e 8
	JZ espera_tecla             		; espera, enquanto não se pressionar uma tecla
	
	MOV R5, R6				
	CALL converte_1248_to_0123			; converter linha de 1, 2, 4 e 8 para 0, 1, 2, 3
	MOV R6, R8					

	MOV R5, R0
	CALL converte_1248_to_0123			; converter coluna de 1, 2, 4 e 8 para 0, 1, 2, 3
	MOV R0, R8
	
	ADD R6, R6                   		; R6 = 2 * R6
	ADD R6, R6                   		; R6 = 2 * R6 <=> R6 = 4 * R6
	ADD R0, R6                   		; R0 = 4 * R6 + R0 - > exata tecla pressionada

	MOV R6, TECLA_00					; verifica se a tecla pressionada foi a número 0
	CMP R0, R6							; se foi o número 0
	JZ testa_esquerda					; verifica se pode movimentar o objeto para a esquerda

	MOV R6, TECLA_02					; verifica se a tecla pressionada foi a número 2
	CMP R0, R6							; se foi a número 2
	JZ testa_direita					; verifica se pode movimentar o objeto para a direita

	MOV R6, TECLA_03					; verifica se a tecla pressionada foi a número 3
	CMP R0, R6							; se foi a número 3
	JZ move_meteoro						; move o meteoro para a linha abaixo
	
	MOV R6, TECLA_05					; verifica se a tecla pressionada foi a número 5
	CMP R0, R6							; se foi a número 5
	JZ aumenta_display					; aumenta o valor do display 
	
	MOV R6, TECLA_09					; verifica se a tecla pressionada foi a número 9
	CMP R0, R6							; se foi o número 9
	JZ diminui_display					; diminui o valor do display
	
	JMP espera_tecla					; espera que uma nova tecla seja pressionada
	
espera_nao_tecla:            		 	; neste ciclo espera-se que a tecla deixe de ser pressionada
	CMP R10, 0                   		; verifica se é a primeira vez que desenha o meteoro
	JZ espera_tecla						
	MOV R6, R10							
	CALL teclado						; testa se a última linha pressionada ainda o está a ser
	CMP R0, 0                    		; se for diferente de 0 vai dizer a coluna (entre 1 e 8)
	JZ espera_tecla						; se for 0 espera enquanto não se pressionar uma tecla
	JMP espera_nao_tecla				; espera até a tecla deixar de ser pressionada
	
testa_esquerda:							; neste ciclo vê se é possível movimentar o obejto para a esquerda
	MOV R7, - 1                  		; desloca o objeto para a esquerda
	JMP ve_limites						; testa se está dentro dos limites do ecrã
	
testa_direita:
	MOV R7, + 1                  		; desloca o objeto para a direita, se estiver dentro dos limites do ecrã
	
ve_limites:								; neste ciclo, vê se o objeto está dentro dos limites do ecrã
	CALL posicao_rover					; vê qual a posição atual do Rover
	MOV R6, [R4]                 		; obtém a largura do Rover
	CALL testa_limites           		; vê se chegou aos limites do ecrã e se sim força R7 a 0
	CMP R7, 0							; se estiver no limite não se movimenta
	JZ espera_tecla              		; se não movimentar o objeto, lê o teclado de novo
	
move_rover:								; neste ciclo o rover muda de posição
	CALL posicao_rover					; vê qual é a posição atual do Rover
	CALL apaga_objeto            		; apaga o rover na sua posição corrente
	
coluna_seguinte:						; neste ciclo o objeto é desenhado na coluna seguinte
	ADD R2, R7                   		; para desenhar objeto na coluna seguinte (direita ou esquerda)
	MOV [COLUNA_ROVER], R2				; atualiza a coluna atual do rover
	JMP mostra_rover            	 	; vai desenhar o boneco de novo
	
aumenta_display:						; neste ciclo o valor do display é aumentado
	MOV R11, [DISPLAY]					; guarda o valor atual do display
	ADD R11, 1							; aumenta o registo do valor do display
	MOV [DISPLAYS], R11					; altera o valor apresentado nos displays	
	MOV [DISPLAY], R11					; grava na memória o novo valor do display
	JMP espera_nao_tecla				; espera até a tecla deixar de ser pressionada
	
diminui_display:						; neste ciclo o valor do display é diminuido
	MOV R11, [DISPLAY]					; guarda o valor atual do display
	SUB R11, 1							; diminui o registo do valor do display
	MOV [DISPLAYS], R11					; altera o valor apresentado nos displays
	MOV [DISPLAY], R11					; grava na memória o novo valor do display
	JMP espera_nao_tecla				; espera até a tecla deixar de ser pressionada
	
	
move_meteoro:							; neste ciclo o meteoro muda de posição
	CALL posicao_meteoro				; vê qual é a posição atual do rover
	CALL apaga_objeto            		; apaga o meteoro na sua posição corrente
	MOV R5, 0                    		; seleção do som a ser utilizado
	MOV [SELECIONA_SOM], R5				; utilização do som
	
linha_seguinte:							; neste ciclo o objeto é desenhado na linha seguinte
	ADD R1, 1                    		; aumenta o valor da linha em que o objeto se encontra
	MOV R6, MAX_LINHA					
	CMP R1, R6							; verifica se o objeto está na última linha do ecrã
	JZ reinicia_meteoro					; se estiver reinicia o meteoro na sua posição original
	MOV [LINHA_METEORO], R1				; altera a variável da linha atual do meteoro
	JMP mostra_meteoro          		; desenha novamente o meteoro
	
reinicia_meteoro:
	MOV R1, MIN_LINHA            		; coloca o meteoro no início do ecrã
	MOV [LINHA_METEORO], R1		
	JMP mostra_meteoro           		; desenha o meteoro de novo
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; desenha_objeto -> desenha um objeto na linha e coluna indicadas com a 
	; forma e cor definidas na tabela indicada.
	; Argumentos: 
	; 		R1 - linha
	; 		R2 - coluna
	; 		R4 - tabela que define o objeto
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
desenha_objeto:					 ; neste ciclo é desenhado um objeto na linha e coluna indicados 
	PUSH R1
	PUSH R2                      ; indicador da coluna em que está a desenhar
	PUSH R3                      ; indicador da cor que está a desenhar
	PUSH R4                      ; endereço da tabela
	PUSH R5                      ; largura do objeto
	PUSH R6                      ; altura do objeto
	PUSH R7                      ; guarda a coluna inicial
	PUSH R8                      ; guarda a largura do objeto
obtem_altura_desenha:			 ; neste ciclo é obtida a altura do objeto
	MOV R8, [R4]                 ; obtém a largura do objeto
	ADD R4, 2                    ; endereço da altura do objeto
	MOV R6, [R4]                 ; obtém a altura do objeto
	ADD R4, 2                    ; endereço da cor do próximo pixel
	MOV R7, R2					 ; guarda a coluna em que o objeto esta 
obtem_largura_desenha:			 ; neste ciclo é obtida a largura do objeto
	MOV R2, R7
	MOV R5, R8                   ; obtém a largura do objeto
desenha_pixels:               	 ; desenha os pixels do objeto a partir da tabela
	MOV R3, [R4]                 ; obtém a cor do próximo pixel do objeto
	CALL escreve_pixel           ; escreve cada pixel do objeto
	ADD R4, 2                    ; endereço da cor do próximo pixel
	ADD R2, 1                    ; próxima coluna
	SUB R5, 1                    ; menos uma coluna para tratar
	JNZ desenha_pixels           ; continua até percorrer toda a largura do objeto
	ADD R1, 1					 
	SUB R6, 1					 ; menos uma linha para percorrer
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
	; apaga_objeto -> Apaga um boneco na linha e coluna indicadas com a forma 
	; definida na tabela indicada.
	; Argumentos: 
	; 		R1 - linha
	; 		R2 - coluna
	; 		R4 - tabela que define o boneco
	;
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
apaga_objeto:					 ; neste ciclo o objeto na posição indicada é apagado
	PUSH R1
	PUSH R2                      ; indicador da coluna em que está a desenhar
	PUSH R3                      ; indicador da cor com que está a desenhar
	PUSH R4                      ; enderaço da tabela
	PUSH R5                      ; largura do objeto
	PUSH R6                      ; altura do objeto
	PUSH R7                      ; guarda a coluna inicial
	PUSH R8                      ; guarda a largura do objeto
obtem_altura_apaga:
	MOV R8, [R4]                 ; obtém a largura do objeto
	ADD R4, 2                    ; endereço da altura do objeto 
	MOV R6, [R4]                 ; obtém a altura do objeto
	ADD R4, 2                    ; endereço da altura do objeto 
	MOV R7, R2
obtem_largura_apaga:
	MOV R2, R7
	MOV R5, R8                   ; obtém a largura do objeto
apaga_pixels:                 ; desenha os pixels do objeto a partir da tabela
	MOV R3, 0                    ; obtém a cor do próximo pixel do objeto
	CALL escreve_pixel           ; escreve cada pixel do objeto
	ADD R4, 2                    ; endereço da cor do próximo pixel 
	ADD R2, 1                    ; próxima coluna
	SUB R5, 1                    ; menos uma coluna para tratar
	JNZ apaga_pixels             ; continua até percorrer toda a largura do objeto
	ADD R1, 1					 
	SUB R6, 1					 ; menos uma linha para tratar
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
	; escreve_pixel -> Escreve um pixel na linha e coluna indicadas.
	; Argumentos: 
	; 		R1 - linha
	; 		R2 - coluna
	;		R3 - cor do pixel (em formato ARGB de 16 bits)
	;
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
escreve_pixel:					 ; neste ciclo é escrito um pixel na linha e coluna indicada
	MOV [DEFINE_LINHA], R1       ; seleciona a linha
	MOV [DEFINE_COLUNA], R2      ; seleciona a coluna
	MOV [DEFINE_PIXEL], R3       ; altera a cor do pixel na linha e coluna já selecionadas
	RET
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; atraso -> Executa um ciclo para implementar um atraso.
	; Argumentos: 
	;		R11 - valor que define o atraso
	;
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
atraso:							 ; neste ciclo é implementado um atraso
	PUSH R11					 ; valor que define o atraso
ciclo_atraso:					 ; neste ciclo é repetido o atraso as vezes indicadas
	SUB R11, 1
	JNZ ciclo_atraso			 ; enquanto for diferente de 0, é repetido o ciclo
	POP R11
	RET
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; testa_limites - Testa se o objeto chegou aos limites do ecrã e nesse caso
	; impede o movimento (força R7 a 0)
	; Argumentos: 
	; 		R2 - coluna em que o objeto está
	; 		R6 - largura do objeto
	; 		R7 - sentido de movimento do objeto (valor a somar à coluna em cada
	; movimento: + 1 para a direita, - 1 para a esquerda)
	;
	; Retorna: R7 - 0 se já tiver chegado ao limite, inalterado caso contrário
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
testa_limites:				
	PUSH R5
	PUSH R6
testa_limite_esquerdo:        	 ; neste ciclo vê-se se o objeto chegou ao limite esquerdo
	MOV R5, MIN_COLUNA			 
	CMP R2, R5					 ; verifica se chegou ao lado esquerdo
	JGT testa_limite_direito	 ; se não tiver chegado ao lado esquerdo, testa o direito
	CMP R7, 0                    ; passa a deslocar - se para a direita
	JGE sai_testa_limites		 ; já verificou todos os limites, e por isso sai
	JMP impede_movimento         ; entre limites. Mantém o valor do R7
testa_limite_direito:            ; neste ciclo vê-se se o objeto chegou ao limite direito
	ADD R6, R2                   ; posição a seguir ao extremo direito do objeto
	MOV R5, MAX_COLUNA			
	CMP R6, R5					 ; vê se chegou ao limite direito do ecrã
	JLE sai_testa_limites        ; entre limites. Mantém o valor do R7
	CMP R7, 0                    ; passa a deslocar - se para a direita
	JGT impede_movimento		 ; se tiver chegado ao limite, impede o movimento
	JMP sai_testa_limites		 ; já verificou todos os limites, e por isso sai
impede_movimento:				 ; neste ciclo,o movimento do rover é impedido
	MOV R7, 0                    ; impede o movimento, forçando R7 a 0
sai_testa_limites:				 ; neste ciclo, para-se de testar se o rover chegou aos limites laterais do ecrã
	POP R6
	POP R5
	RET
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; teclado -> Faz uma leitura às teclas de uma linha do teclado e retorna o valor lido
	; Argumentos: 
	; 		R6 - linha a testar (em formato 1, 2, 4 ou 8)
	;
	; Retorna: R0 - valor lido das colunas do teclado (0, 1, 2, 4, ou 8)
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
teclado:						 ; neste ciclo são lidas as teclas de uma linha do teclado
	PUSH R2
	PUSH R3
	PUSH R5
	MOV R2, TEC_LIN              ; endereço do periférico das linhas
	MOV R3, TEC_COL              ; endereço do periférico das colunas
	MOV R5, MASCARA              ; isola os 4 bits de menor peso, ao ler as colunas do teclado
	MOVB [R2], R6                ; escreve no periférico de saída (linhas)
	MOVB R0, [R3]                ; lê do periférico de entrada (colunas)
	AND R0, R5                   ; elimina os bits para além dos bits 0 - 3
	POP R5
	POP R3
	POP R2
	RET
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; converte_1248_to_0123 -> Converte o valor entre (1, 2, 4 ou 8) para um valor entre (0, 1, 2, 3)
	; Argumentos: 
	; 		R5 - valor (em formato 1, 2, 4 ou 8)
	;
	; Retorna: R8 - valor (em formato 0, 1, 2, 3)
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
converte_1248_to_0123:			 ; neste ciclo os valores (1, 2, 4 e 8) são convertidos em (0, 1, 2, 3)
	PUSH R5
	MOV R8, - 1					 ; inicializa o counter
	CMP R5, 0					 ; verifica que o counter não é zero
	JZ fim_1248_to_0123			 ; vai para o fim do ciclo
ciclo_1248_to_0123:				 ; ciclo que converte os números
	SHR R5, 1					 ; dividir por dois
	ADD R8, 1                    ; incrementa o contador
	CMP R5, 0					 ; verifica se o valor é zero
	JNZ ciclo_1248_to_0123       ; repete o ciclo enquanto R5 = / = 0
fim_1248_to_0123:				 ; ciclo que termina os ciclos anteriores
	POP R5
	RET
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; posicao_rover -> Retorna as informações do rover
	; Argumentos: nenhum
	;
	; Retorna:
	; 		R1 - linha do rover
	; 		R2 - coluna do rover
	; 		R4 - endereço da tabela que define o rover
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	
posicao_rover:
	MOV R1, [LINHA_ROVER]        ; linha do rover
	MOV R2, [COLUNA_ROVER]       ; coluna do rover
	MOV R4, DEF_ROVER            ; endereço da tabela que define o rover
	RET
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; posicao_meteoro -> Retorna as informações do meteoro
	; Argumentos: nenhum
	;
	; Retorna:
	; 		R1 - linha do meteoro
	; 		R2 - coluna do meteoro
	; 		R4 - endereço da tabela que define o meteoro
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
posicao_meteoro:
	MOV R1, [LINHA_METEORO]      ; linha do meteoro
	MOV R2, [COLUNA_METEORO]     ; coluna do meteoro
	MOV R4, DEF_METEORO_MAU      ; endereço da tabela que define o meteoro
	RET
