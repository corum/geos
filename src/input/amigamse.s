; GEOS Amiga style mouse input driver
; reassembled by Maciej 'YTM/Elysium' Witkowiak

.include "const.inc"
.include "geossym.inc"
.include "geosmac.inc"
.include "jumptab.inc"

.segment "amigamse"

MouseJMP:
	jmp _MouseInit
SlowMouse:
	jmp _SlowMouse
UpdateMouse:
	jmp _UpdateMouse

acceleration:
	.byte 3

fireLast:
	.byte 0

lastO:
	.byte 1
lastY:
	.byte 1
lastX:
	.byte 1

goingUp:
	.byte $01,$03,$02
goingDown:
	.byte $00,$02,$03,$01


_MouseInit:
	lda #8
	sta mouseXPos
	sta mouseYPos
	lda #0
	sta mouseXPos+1
	sta menuNumber
_SlowMouse:
	rts

_UpdateMouse:
	bbrf MOUSEON_BIT, mouseOn, _SlowMouse
	PushB CPU_DATA
	LoadB CPU_DATA, IO_IN
	PushB cia1base+3
	PushB cia1base+1
	lda mouseAccel
	lsr
	lsr
	lsr
	lsr
	sta acceleration
	LoadB cia1base+3, $ff
	lda cia1base+1
	and #%00010000
	cmp fireLast
	beq cont
	sta fireLast
	lda cia1base+1
	and #%00010000
	bne cont
	smbf MOUSE_BIT, pressFlag
	asl
	asl
	asl
	sta mouseData

cont:
	lda cia1base+1
	tay
	and #%00000001
	sta lastO
	tya
	and #%00000100
	lsr
	ora lastO
	tax
	pha
	cmp lastY
	beq hop1
	lda lastY
	cmp goingDown,X
	beq goDown
	cmp goingUp,X
	bne hop1

goUp:
	txa
	pha
	lda mouseYPos
	sub acceleration
	cmp #200
	bcc hophop1
	lda #0
	jmp hophop1

goDown:
	txa
	pha
	lda mouseYPos
	add acceleration
	cmp #200
	bcc hophop1
	lda #199

hophop1:
	sta mouseYPos
	pla
	tax

hop1:
	PopB lastY

;OUSE_LR
	tya
	and #%00000010
	lsr
	sta lastO
	tya
	and #%00001000
	lsr
	lsr
	ora lastO
	tax
	pha
	cmp lastX
	beq hop2
	lda lastX
	cmp goingUp,X
	beq goUp2
	cmp goingDown,X
	bne hop2

goDown2:
	lda mouseXPos
	add acceleration
	sta mouseXPos
	lda mouseXPos+1
	adc #0
	sta mouseXPos+1
	beq hop2
	lda mouseXPos
	cmp #$40
	bcc hop2
	lda #$3F
	sta mouseXPos
	jmp hop2

goUp2:
	lda mouseXPos
	sub acceleration
	sta mouseXPos
	lda mouseXPos+1
	sbc #0
	sta mouseXPos+1
	bpl hop2
	LoadW mouseXPos, 0

hop2:
	PopB lastX
	PopB cia1base+1
	PopB cia1base+3
	PopB CPU_DATA
	rts
