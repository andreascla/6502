		.org $8000

; *** Wait for LCD busy bit to clear
; registers preserved
LCDBUSY:	pha
		lda #$7f	; set PB7 as input
		sta $6002
		lda #$40	; set R/W high
		sta $6001
LCDBUSY0:	eor #$80	; set E high
		sta $6001
		lda $6000	; read PBx
		tax
		lda $6001	; set E low
		eor #$80
		sta $6001
		txa
		and #$80
		bne LCDBUSY0
		lda #$00	; set R/W low
		sta $6001
		lda #$ff	; set PBx as output
		sta $6002
		pla
		rts

TOGGLE_ENABLE:	pha
		lda $6001
		eor #$80
		sta $6001
		eor #$80
		sta $6001
		pla
		rts

; *** LCD initialisation
LINIT:		ldx #$04
		lda #$00
		sta $6001
LINIT0:		lda #$38	; 8-bit operation, 2-line display, 5x8 dots
		sta $6000
		jsr TOGGLE_ENABLE
		; jsr LCDBUSY
		dex
		bne LINIT0
		lda #$0e	; turn on display and cursor, blink off
		sta $6000
		jsr TOGGLE_ENABLE
		jsr LCDBUSY
		lda #$01	; clear display
		sta $6000
		jsr TOGGLE_ENABLE
		jsr LCDBUSY
		lda #$80	; DDRAM address set: $00
		sta $6000
		jsr TOGGLE_ENABLE
		jsr LCDBUSY
		rts

; *** Print character on LCD (40 character)
; registers preserved
LCDPRINT:	pha
		sta $6000
		lda #$20
		sta $6001
		jsr TOGGLE_ENABLE
		jsr LCDBUSY
		pla
		rts

; *** Print string on LCD
; registers preserved
LCDSTRING:	pha		; save A, Y to stack
		tya
		pha
		ldy #$00
LCDSTR0:	lda ($80),y
		beq LCDSTR1
		jsr LCDPRINT
		iny
		jmp LCDSTR0
LCDSTR1:	pla		; restore A, Y
		tay
		pla
		rts

MAIN:		lda #$ff	; setup 65c22 in/out registers
		sta $6002
		lda #$e1
		sta $6003

		jsr LINIT

		lda #<MSG
		sta $80
		lda #>MSG
		sta $81
		jsr LCDSTRING

LOOP:		nop
		jmp LOOP

		.org $e000
MSG:		.string "Hello World!"

		.org $fffc
		.word MAIN
		.word $0000

