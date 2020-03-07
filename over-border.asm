*   = $2000 ; sys 8192



interrupt
    sei         ; ignore interrupts

    ; disable all interrupts and clear pending interrupts
    lda #%0111111    
    sta $dc0d ; interrupt control register CIA #1
    sta $dd0d ; interrupt control register CIA#2

   lda $dc0d   ;clear any pending interrupts CIA#1 by reading
   lda $dd0d    ; clear any pending interrupts CIA#2 by reading

    ; enable raster interrupt
   lda #%00000001   ;turn on the raster interrupt
   sta $d01a  ; irq mask register

    ; setting the interrupt line
   ldy #$33   ;generate interrupt on first line on main screen area
   sty $d012  ; write: line to compare for raster interrupt
   lda #$1b  ;clear high order bit of the raster interrupt compare. very naive
   sta $d011

    ; set the interrupt vector
   lda #<25rows  ;set the correct address for the interrupt
   sta $0314
   lda #>25rows
   sta $0315

   cli      ; enable interrupts 
    rts

25rows
   asl $d019 ; Acknowledge interrupt by clearing VICs interrupt flag

    ; set to 25 column mode
    ldx #$1b
    stx $d011
    ;lda $d011
    ;ora #%00001000
    ;sta $d011

    ; set interrupt for 24rows
   ldy #$f9     ; interrupt rasterline
   sty $d012
   lda #<24rows ; interrupt vector
   sta $0314
   lda #>24rows
   sta $0315

   jmp $ea31 ; Kernel routine but skip scanning the keyboard

24rows
   asl $d019 ; Acknowledge interrupt by clearing VICs interrupt flag

    ; set to 24 column mode
    ldx #$13
    stx $d011
    ;lda $d011
    ;and #%11110111
    ;sta $d011

    ; set interrupt for 24rows
   ldy #$33     ; interrupt rasterline
   sty $d012
   lda #<25rows ; interrupt vector
   sta $0314
   lda #>25rows
   sta $0315

   jmp $ea31 ; Kernel routine but skip scanning the keyboard

















