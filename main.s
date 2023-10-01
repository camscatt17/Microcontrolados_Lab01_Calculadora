; main.s
; Desenvolvido para a placa EK-TM4C1294XL
; Programa referente ao Lab 01 da turma de microcontroladores 2023.2
; Programa incrementado a partir do projeto GPIO2 da aula de GPIO do professor Peron.

; -------------------------------------------------------------------------------
        THUMB                        ; Instru��es do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declara��es EQU - Defines
;<NOME>         EQU <VALOR>
; ========================
TRUE 	EQU 0x1
FALSE 	EQU 0x0

MULTIPLICADOR EQU 0x0x20000000
TABUADA EQU 0x2000000f
MULTIPLICACAO EQU 0x2000001e

; -------------------------------------------------------------------------------
; �rea de Dados - Declara��es de vari�veis
		AREA  DATA, ALIGN=2
		; Se alguma vari�vel for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a vari�vel <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma vari�vel de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posi��o da RAM		

; -------------------------------------------------------------------------------
; �rea de C�digo - Tudo abaixo da diretiva a seguir ser� armazenado na mem�ria de 
;                  c�digo
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma fun��o do arquivo for chamada em outro arquivo	
        EXPORT Start                ; Permite chamar a fun��o Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma fun��o externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; fun��o <func>
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
; Fun��o main()
Start  		
	BL PLL_Init                  ;Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL SysTick_Init
	BL GPIO_Init                 ;Chama a subrotina que inicializa os GPIO
	
	; inicializacao das tabuada em 1x1
	LDR R0, =MULTIPLICACAO       ;Carrega em R0 a variavel Multiplica��o
	MOV R1, =MULTIPLICADOR                   ;Carrega em R1 o valor 1
	MOV R2, =TABUADA                   ;Carrega em R2 o valor 1
	MUL R1, R1, R2               ;Faz a multiplica��o de R1 com R2 e armazena em R1
	BL PrintaTabuada
	BL AcendeLED

MainLoop
	BL PortJ_Input				 ;Chama a subrotina que l� o estado das chaves e coloca o resultado em R0
Verifica_SW2	
	CMP R0, #2_00000001			 ;Verifica se somente a chave SW2 est� pressionada
	BEQ SW2_pressionada
Verifica_SW1                     ;Verifica se somente a chave SW1 est� pressionada
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
; Fun��o PrintaTabuada
; Par�metro de entrada: MULTIPLICACAO
; Par�metro de sa�da: nenhum
PrintaTabuada
	
	BX LR

; -------------------------------------------------------------------------------
; Fun��o AcendeLED
; Par�metro de entrada: MULTIPLICACAO
; Par�metro de sa�da: nenhum
AcendeLED

	BX LR

; -------------------------------------------------------------------------------------------------------------------------
; Fun��o IncrementaMultiplicador
; Par�metro de entrada: -
; Par�metro de sa�da: -
IncrementaMultiplicador
	LDR R0, =MULTIPLICADOR       ;Carrega em R0 o valor atual do MULTIPLICADOR
	CMP R0, #9                   ;Compara o valor de R0 com 9
	ITE EQ
		MOVEQ R0, #1             ;Se for igual, MULTIPLICADOR = 1
		ADDNE R0, #1             ;Se for diferente, MULTIPLICADOR++
	STR R0, [MULTIPLICADOR]      ;Carrega o valor que est� em R0 no endere�o de mem�ria de MULTIPLICADOR
	BX LR 

; -----------------------------------------------------------------------------------------------------------------------
; Fun��o IncrementaTabuada
; Par�metro de entrada: -
; Par�metro de sa�da: -
IncrementaTabuada
	LDR R0, =TABUADA;            ;Carrega em R0 o valor atual do TABUADA
	CMP R0, #8                   ;Compara o valor de R0 com 8
	ITE EQ
		MOVEQ R0, #1             ;Se for igual, TABUADA = 1
		ADDNE R0, #1             ;Se for diferente, TABUADA++
		
	STR R0, [TABUADA]            ;Carrega o valor que est� em R0 no endere�o de mem�ria de TABUADA
	BX LR

; -----------------------------------------------------------------------------------------------------------------------
; Fun��o Multiplicacao
; Par�metro de entrada: MULTIPLICADOR, TABUADA, MULTIPLICACAO
; Par�metro de sa�da: MULTIPLICACAO
Multiplicacao
	LDR R0, =MULTIPLICADOR      ;Carrega em R0 o valor atual do MULTIPLICADOR
	LDR R1, =TABUADA            ;Carrega em R1 o valor atual do TABUADA
	LDR R2, =MULTIPLICACAO
	MUL R2, R0, R1              ;Multiplica R1, por R0 e armazena em R2
	STR R2, [MULTIPLICACAO]     ;Carrega o valor que est� em R2 no endere�o de mem�ria de MULTIPLICACAO
	BL PrintaTabuada
	BX MainLoop


; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                        ;Garante que o fim da se��o est� alinhada 
    END                          ;Fim do arquivo


