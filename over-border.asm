*   = $2000 ; sys 8192



interrupt
    sei         ; ignore interrupts

    lda #%0111111    
    sta $dc0d ; interrupt control register CIA #1
    sta $dd0d ; interrupt control register CIA#2

   lda $dc0d   ;clear any pending interrupts CIA#1
   lda $dd0d    ; clear any pending interrupts CIA#2

   lda #$01   ;turn on the raster interrupt
   sta $d01a  ; irq mask register

   ldy #$aa   ;generate interrupt on first line on main screen area
   sty $d012  ; write: line to compare for raster interrupt

   lda #$1b  ;clear high order bit of the raster interrupt compare. very naive
   sta $d011

   lda #<irq  ;set the correct address for the interrupt
   sta $0314
   lda #>irq
   sta $0315

   cli      ; enable interrupts 

    rts

irq
   asl $d019 ; Acknowledge interrupt by clearing VICs interrupt flag
   inc $d020 ; Change border colour
   jmp $ea81 ; Kernel routine