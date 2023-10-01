; main.s
; Desenvolvido para a placa EK-TM4C1294XL
; Programa referente ao Lab 01 da turma de microcontroladores 2023.2
; Programa incrementado a partir do projeto GPIO2 da aula de GPIO do professor Peron.

; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declarações EQU - Defines
;<NOME>         EQU <VALOR>
; ========================
TRUE 	EQU 0x1
FALSE 	EQU 0x0

MULTIPLICADOR EQU 0x0x20000000
TABUADA EQU 0x2000000f
MULTIPLICACAO EQU 0x2000001e

; -------------------------------------------------------------------------------
; Área de Dados - Declarações de variáveis
		AREA  DATA, ALIGN=2
		; Se alguma variável for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a variável <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma variável de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posição da RAM		

; -------------------------------------------------------------------------------
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma função do arquivo for chamada em outro arquivo	
        EXPORT Start                ; Permite chamar a função Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma função externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; função <func>
		IMPORT  PLL_Init
		IMPORT  SysTick_Init
		IMPORT  SysTick_Wait1ms			
		IMPORT  GPIO_Init
        IMPORT  PortF_Output
        IMPORT  PortJ_Input
		IMPORT 	select_leds
		IMPORT 	set_leds
		IMPORT 	set_DS1_ON
		IMPORT 	set_DS2_ON
		IMPORT	select_dig_DS


; -------------------------------------------------------------------------------
; Função main()
Start  		
	BL PLL_Init                  ;Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL SysTick_Init
	BL GPIO_Init                 ;Chama a subrotina que inicializa os GPIO
	
	; inicializacao das tabuada em 1x1
	LDR R0, =MULTIPLICACAO       ;Carrega em R0 a variavel Multiplicação
	MOV R1, =MULTIPLICADOR                   ;Carrega em R1 o valor 1
	MOV R2, =TABUADA                   ;Carrega em R2 o valor 1
	MUL R1, R1, R2               ;Faz a multiplicação de R1 com R2 e armazena em R1
	BL PrintaTabuada
	BL AcendeLED

MainLoop
	BL PortJ_Input				 ;Chama a subrotina que lê o estado das chaves e coloca o resultado em R0
Verifica_SW2	
	CMP R0, #2_00000001			 ;Verifica se somente a chave SW2 está pressionada
	BEQ SW2_pressionada
Verifica_SW1                     ;Verifica se somente a chave SW1 está pressionada
	CMP R0, #2_00000010
	BEQ SW1_pressionada
	B end_loop
SW2_pressionada
	BL IncrementaMultiplicador
	B MainLoop
SW1_pressionada
	BL IncrementaTabuada
end_loop
	BL Multiplicacao
	B MainLoop

; -------------------------------------------------------------------------------
; Função PrintaTabuada
; Parâmetro de entrada: MULTIPLICACAO
; Parâmetro de saída: nenhum
PrintaTabuada
	
	BX LR

; -------------------------------------------------------------------------------
; Função AcendeLED
; Parâmetro de entrada: MULTIPLICACAO
; Parâmetro de saída: nenhum
AcendeLED

	BX LR

; -------------------------------------------------------------------------------------------------------------------------
; Função IncrementaMultiplicador
; Parâmetro de entrada: -
; Parâmetro de saída: -
IncrementaMultiplicador
	LDR R0, =MULTIPLICADOR       ;Carrega em R0 o valor atual do MULTIPLICADOR
	CMP R0, #9                   ;Compara o valor de R0 com 9
	ITE EQ
		MOVEQ R0, #1             ;Se for igual, MULTIPLICADOR = 1
		ADDNE R0, #1             ;Se for diferente, MULTIPLICADOR++
	STR R0, [MULTIPLICADOR]      ;Carrega o valor que está em R0 no endereço de memória de MULTIPLICADOR
	BX LR 

; -----------------------------------------------------------------------------------------------------------------------
; Função IncrementaTabuada
; Parâmetro de entrada: -
; Parâmetro de saída: -
IncrementaTabuada
	LDR R0, =TABUADA;            ;Carrega em R0 o valor atual do TABUADA
	CMP R0, #8                   ;Compara o valor de R0 com 8
	ITE EQ
		MOVEQ R0, #1             ;Se for igual, TABUADA = 1
		ADDNE R0, #1             ;Se for diferente, TABUADA++
		
	STR R0, [TABUADA]            ;Carrega o valor que está em R0 no endereço de memória de TABUADA
	BX LR

; -----------------------------------------------------------------------------------------------------------------------
; Função Multiplicacao
; Parâmetro de entrada: MULTIPLICADOR, TABUADA, MULTIPLICACAO
; Parâmetro de saída: MULTIPLICACAO
Multiplicacao
	LDR R0, =MULTIPLICADOR      ;Carrega em R0 o valor atual do MULTIPLICADOR
	LDR R1, =TABUADA            ;Carrega em R1 o valor atual do TABUADA
	LDR R2, =MULTIPLICACAO
	MUL R2, R0, R1              ;Multiplica R1, por R0 e armazena em R2
	STR R2, [MULTIPLICACAO]     ;Carrega o valor que está em R2 no endereço de memória de MULTIPLICACAO
	BL PrintaTabuada
	BX MainLoop


; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                        ;Garante que o fim da seção está alinhada 
    END                          ;Fim do arquivo


