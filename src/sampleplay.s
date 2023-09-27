mpChannel
.byte $00

mpPlaySample

		lda #$00
		sta mpChannel

:		lda mpChannel
		asl
		asl
		asl
		asl
		tax

		ldy #$11

		lda #<.loword(samples)
		sta $d72a,x										; CHXCURADDRL
		lda #>.loword(samples)
		sta $d72b,x										; CHXCURADDRC
		lda #<.hiword(samples)
		sta $d72c,x										; CHXCURADDRM

		lda #<(samples+$2b00)
		sta $d727,x										; CHXTADDRL
		lda #>(samples+$2b00)
		sta $d728,x										; CHXTADDRM

		lda freql,y
		sta $d724,x										; CHXFREQL    Audio DMA channel X frequency LSB
		lda freqm,y
		sta $d725,x										; CHXFREQC    Audio DMA channel X frequency middle byte
		lda freqh,y
		sta $d726,x										; CHXFREQM    Audio DMA channel X frequency MSB

		lda #$40										; set volume
		sta $d729,x										; CHXVOLUME

		lda #%10010000									; enable audio DMA
		sta $d711										; D711                      AUDEN BLKD AUDWRBLK NOMIX – AUDBLKTO

		lda #%10000010									; play DMA (CHXEN)  with loop enabled (CHXLOOP), 8 bit samples (CHXSBITS) (11=16, 10=8, 01=upper nybl, 00=lower nybl)
		sta $d720,x										; D720      CHXEN CHXLOOP CHXSGN CHXSINE CHXSTP – CHXSBITS

		inc mpChannel
		lda mpChannel
		cmp #$05
		bne :-

		rts

; ----------------------------------------------------------------------------------------------------

samplestarts

freql
.byte <($1ad1)
.byte <($1c69)
.byte <($1e1a)
.byte <($1fe4)
.byte <($21c9)
.byte <($23cc)
.byte <($25ed)
.byte <($282e)
.byte <($2a92)
.byte <($2d1a)
.byte <($2fc8)
.byte <($329f)

.byte <($1ad1)
.byte <($1c69)
.byte <($1e1a)
.byte <($1fe4)
.byte <($21c9)
.byte <($23cc)
.byte <($25ed)
.byte <($282e)
.byte <($2a92)
.byte <($2d1a)
.byte <($2fc8)
.byte <($329f)

.byte <($1ad1)
.byte <($1c69)
.byte <($1e1a)
.byte <($1fe4)
.byte <($21c9)
.byte <($23cc)
.byte <($25ed)
.byte <($282e)
.byte <($2a92)
.byte <($2d1a)
.byte <($2fc8)
.byte <($329f)

freqm
.byte >($1ad1)
.byte >($1c69)
.byte >($1e1a)
.byte >($1fe4)
.byte >($21c9)
.byte >($23cc)
.byte >($25ed)
.byte >($282e)
.byte >($2a92)
.byte >($2d1a)
.byte >($2fc8)
.byte >($329f)

.byte >($1ad1)
.byte >($1c69)
.byte >($1e1a)
.byte >($1fe4)
.byte >($21c9)
.byte >($23cc)
.byte >($25ed)
.byte >($282e)
.byte >($2a92)
.byte >($2d1a)
.byte >($2fc8)
.byte >($329f)

.byte >($1ad1)
.byte >($1c69)
.byte >($1e1a)
.byte >($1fe4)
.byte >($21c9)
.byte >($23cc)
.byte >($25ed)
.byte >($282e)
.byte >($2a92)
.byte >($2d1a)
.byte >($2fc8)
.byte >($329f)

freqh
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
