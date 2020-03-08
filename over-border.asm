*=49152

        jsr initialize_sprites
        jsr initialize_raster_interrupts
        rts

initialize_raster_interrupts

        sei           ; ignore all interrupts

        ; disable all interrupts and clear pending interrupts
        lda #%0111111 
        sta 56333     ; interrupt control register CIA #1
        sta 56589     ; interrupt control register CIA#2

        lda 56333     ;clear any pending interrupts CIA#1 by reading
        lda 56589     ; clear any pending interrupts CIA#2 by reading

        ; enable raster interrupt
        lda #%00000001;turn on the raster interrupt
        sta 53274     ; irq mask register

        ; setting the interrupt line
        ldy #00      ; generate interrupt on first line on main screen area
        sty 53266     ; write: line to compare for raster interrupt
        lda #27      ; clear high order bit of the raster interrupt compare. very naive
        sta 53265     

        ; set the interrupt vector
        lda #<rasterline_000  ; set the correct address for the interrupt
        sta 788     
        lda #>rasterline_000  
        sta 789     

        cli           ; enable interrupts
        rts

initialize_sprites

        ; set sprite location to 832
        lda #13       ; 13 x 64 = 832      
        sta 2040     ; sprite 0
        sta 2041     ; sprite 1
        sta 2042     ; sprite 2
        sta 2043     ; sprite 3
        sta 2044     ; sprite 4
        sta 2045     ; sprite 5
        sta 2046     ; sprite 6
        sta 2047     ; sprite 7

        ; set x
        lda #153      
        sta 53248     ; sprite 0
        lda #24      
        sta 53250     ; sprite 1
        lda #72      
        sta 53252     ; sprite 2
        lda #120      
        sta 53254     ; sprite 3
        lda #168      
        sta 53256     ; sprite 4
        lda #216      
        sta 53258     ; sprite 5

        ; set most significant bit for last two sprites
        lda #192
        sta 53264     

        lda #8      
        sta 53260     ; sprite 6
        lda #56      
        sta 53262     ; sprite 7

        ; set y
        lda #153      
        sta 53249     ; sprite 0
        ; raster interrupts will set y of the border sprites

        ; set color
        lda #1      
        sta 53287     ; sprite 0
        lda #14      
        sta 53288     ; sprite 1
        sta 53289     ; sprite 2
        sta 53290     ; sprite 3
        sta 53291     ; sprite 4
        sta 53292     ; sprite 5
        sta 53293     ; sprite 5
        sta 53294     ; sprite 5

        ; double size
        lda #255      
        sta 53271     
        sta 53277     

        ; fill sprite data
        lda #255      
        ldx #63      
loop_sprite_data
        DEX
        STA 832,X   
        bne loop_sprite_data      

        ; enable all sprites
        lda #255      
        sta 53269  

        rts

rasterline_000

        ; put all sprites in the top border
        lda #8      
        sta 53251     ; sprite 1
        sta 53253     ; sprite 2
        sta 53255     ; sprite 3
        sta 53257     ; sprite 4
        sta 53259     ; sprite 5
        sta 53261     ; sprite 6
        sta 53263     ; sprite 7

        ; set to 25 column mode
        lda 53265     
        ora #%00001000
        sta 53265

        ; move sprite 0 vertically
        dec 53249     

        ; register next raster
        ldy #249      ; rasterline
        sty 53266   
        lda #<rasterline_249  ; vector
        sta 788     
        lda #>rasterline_249  
        sta 789     
        asl 53273     ; Acknowledge interrupt by clearing VICs interrupt flag
        jmp 59953     ; Kernel routine including scanning the keyboard

rasterline_249

        ; put all sprites in the bottom border
        lda #250
        sta 53251     ; sprite 1
        sta 53253     ; sprite 2
        sta 53255     ; sprite 3
        sta 53257     ; sprite 4
        sta 53259     ; sprite 5
        sta 53261     ; sprite 6
        sta 53263     ; sprite 7

        ; set to 24 column mode
        lda 53265     
        and #%11110111
        sta 53265     

        ; register next raster
        ldy #00      ; rasterline
        sty 53266     
        lda #<rasterline_000  ; vector
        sta 788     
        lda #>rasterline_000 
        sta 789     
        asl 53273     ; Acknowledge interrupt by clearing VICs interrupt flag
        jmp 59953     ; Kernel routine including scanning the keyboard

