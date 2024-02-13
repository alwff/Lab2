;******************************************************************
;
; Universidad del Valle de Guatemala 
; IE2023:: Programación de Microcontroladores
; Laboratorio2.asm
; Autor: Alejandra Cardona 
; Proyecto: Laboratorio 2
; Hardware: ATMEGA328P
; Creado: 06/02/2024
; Última modificación: 06/02/2024
;
;******************************************************************
; ENCABEZADO
;******************************************************************


.INCLUDE "M328PDEF.INC"
.CSEG

.ORG 0x00

;******************************************************************
; STACK POINTER
;******************************************************************

	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R17, HIGH(RAMEND)
	OUT SPH, R17

;******************************************************************
; 
;		TABLA DE VALORES
; A	  B	  C	  D	  E	  F	  G 
; PB0 PB1 PB2 PB3 PB4 PB5 PD7
; 
;******************************************************************

7SEG: 
	.DB 0x3F, 0x06, 0x5B, 0x4F, 0X66, 0X6D, 0X7D, 0X07, 0X7F, 0X6F, 0X77, 0X7C, 0X39, 0X5E, 0X79, 0X71

;******************************************************************
; 7SEGMENTOS 
;******************************************************************
/*
SET7SEG: 
	LDI R17, R19
	LDI ZH, HIGH(7SEG << 1)
	LDI ZL, LOW(7SEG << 1)
	ADD ZL, R17
	LPM R17, Z
*/
;******************************************************************
; CONFIGURACIÓN 
;******************************************************************

Setup:

	LDI R24, (1 << CLKPCE)
	STS CLKPR, R24		
	LDI R24, 0b0000_0111		
	STS CLKPR, R24
			
	;Setting
	LDI R18, 0xFC	; PD como salidas -- PD2aPD6 LEDS -- PD7 7seg sobrante
	OUT DDRD, R18

	LDI R22, 0xFF	; PB como salidas
	OUT DDRB, R22

	LDI R24, 0x60 ; Pullups
	OUT PORTC, R24	; Fin de pullups

	CALL Init_T0
			
	LDI R20, 0	// Contador de mS
	LDI R19, 0	// LEDs -- Binario
	LDI R21, 0	//	LeftShift bits


;******************************************************************
; LOOP 
;******************************************************************

LOOP:

	IN R16, TIFR0	; Timer interruption
	CPI R16, (1 << TOV0)
	BRNE LOOP
	
	CPI R19, 16
	BREQ RESETEAR	; Salta a función si R19 llego a 15 

	LDI R16, 100
	OUT TCNT0, R16
	SBI TIFR0, TOV0
	INC R20
	CPI R20, 10	; Se repite 10 veces el contador de 10 mS para alcanzar los 100 mS de las instrucciones
	BRNE LOOP
	CLR R20	; Se borra el contador			
	
	INC R19
	MOV R21, R19
	LSL R21
	LSL R21

	OUT PORTD, R21

	RJMP LOOP	; Bluce infinito

;******************************************************************
; VACIAR EL CONTADOR 
;******************************************************************

RESETEAR:
 
	LDI R19, 0

;******************************************************************
; TIMER 
;******************************************************************

Init_T0: 

	LDI R16, (1 << CS02)|(1 << CS00)
	OUT TCCR0B, R16

	LDI R16, 100
	OUT TCNT0, R16
	
	RET

;******************************************************************
; BOTONES 
;******************************************************************
/*
BUT1:  ; Incremento
CALL Delay
INC R19	; Incrementar el contador
RJMP LOOP

BUT2:	; Decremento
CALL Delay
DEC R19
RJMP LOOP
*/
;******************************************************************
; DELAY 
;******************************************************************
/*
Delay: 
	
	LDI R25, 0xFF ; El valor máximo para el ATmega328p
	DelayyA: 
		LDI R26, 0xFF
		DelayyB: 
			DEC R25
			BRNE DelayyB ; Branch if not equal, siempre que no sea 0 se cicla
			DEC R26
			BRNE DelayyA
	RET ; Regresa al punto donde fue llamada la etiqueta
 */