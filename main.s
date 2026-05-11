;Equates para GPIO, Timer
RCC_APB2ENR     EQU 0x40021000+0x18
RCC_APB1ENR     EQU 0x40021000+0x1C
AFIO_MAPR       EQU 0x40010000+0x04
GPIOA_CRL       EQU 0x40010800
GPIOA_CRH       EQU 0x40010800+0x04
GPIOA_IDR       EQU 0x40010800+0x08
GPIOA_ODR       EQU 0x40010800+0x0C
GPIOA_BSRR      EQU 0x40010800+0x10
GPIOA_BRR       EQU 0x40010800+0x14
GPIOB_CRL       EQU 0x40010C00
GPIOB_CRH       EQU 0x40010C00+0x04
GPIOB_IDR       EQU 0x40010C00+0x08
GPIOB_ODR       EQU 0x40010C00+0x0C
GPIOB_BSRR      EQU 0x40010C00+0x10
GPIOB_BRR       EQU 0x40010C00+0x14
GPIOC_CRL       EQU 0x40011000
GPIOC_CRH       EQU 0x40011000+0x04
GPIOC_IDR       EQU 0x40011000+0x08
GPIOC_ODR       EQU 0x40011000+0x0C
GPIOC_BSRR      EQU 0x40011000+0x10
GPIOC_BRR       EQU 0x40011000+0x14
LCD_EN          EQU 0x1000
LCD_RS          EQU 0x8000
hab_gpio_afio   EQU 0x1D
JTAG_GPIO       EQU 0x02000000
SW1             EQU 0xEFFF
SW2             EQU 0xDFFF
SW3             EQU 0xBFFF
SW4             EQU 0x7FFF
SW5             EQU 0xFFDF
SW6             EQU 0xFFEF
SW7             EQU 0xFFF7
SW8             EQU 0xFFF7
SW9             EQU 0xFFEF
SW10            EQU 0xFEFF
SW11            EQU 0xFDFF
SW12            EQU 0xF7FF
SW13            EQU 0xFBFF
SW14            EQU 0xFF7F
SW15            EQU 0x7FFF
SW16            EQU 0xBFFF
SW17            EQU 0xDFFF
MASKA           EQU 0x0098
MASKB           EQU 0xFF38
MASKC           EQU 0xE000
TIM3_BASE       EQU 0x40000400
TIM3_PSC        EQU TIM3_BASE+0x28
TIM3_CCR3       EQU TIM3_BASE+0x3C
TIM3_CCER       EQU TIM3_BASE+0x20
TIM3_CCMR2      EQU TIM3_BASE+0x1C
TIM3_ARR        EQU TIM3_BASE+0x2C
TIM3_CR1        EQU TIM3_BASE+0x00
ARR             EQU 420

;Mascaras de leds
LED1            EQU 0x0001
LED2            EQU 0x0002
LED3            EQU 0x0004
LED4            EQU 0x8000
LED5            EQU 0x0100
LED6            EQU 0x0040
LED7            EQU 0x0020
LED8            EQU 0x0800
APAGA           EQU 0x0000

;Tabela para teclas, oitavas 1 e 2, e leds
                AREA l, CODE, READONLY
leds            DCD LED8, LED7, LED6, LED5, LED4, LED3, LED2, LED1

                AREA t, DATA, READONLY
teclas          DCD 5, 13, 6, 14, 7, 8, 15, 9, 16, 10, 17, 11, 12, 0

                AREA O_1, DATA, READONLY
notas_1         DCD 0, 164, 165, 145, 138, 130, 123, 116, 109, 103, 97, 92, 87, 0

                AREA O_2, DATA, READONLY
notas_2         DCD 0, 327, 310, 291, 275, 260, 245, 231, 218, 206, 194, 183, 173, 0

;Programa principal
                EXPORT __main
                AREA trabalho, CODE, READONLY
__main
                BL config_inicial
                MOV R10, #1         ; oitava
                MOV R11, #0         ; timbre
volta
                BL atualiza_lcd
                BL identifica_tecla
                CMP R8, R7
                MOV R7, R8
                BEQ volta
                CMP R8, #1
                BEQ select_o1
                CMP R8, #2
                BEQ select_o2
                CMP R8, #3
                BEQ aumenta_t
                CMP R8, #4
                BEQ diminui_t
                MOV R4, R8
                BL toca_nota
                BL som
                B volta

select_o1
                MOV R10, #1
                B volta

select_o2
                MOV R10, #2
                B volta

aumenta_t
                PUSH {R5, R6}
                LDR R5, =TIM3_CCR3
                LDR R6, [R5]
                CMP R6, #940
                ADDLE R6, R6, #50
                STR R6, [R5]
                POP {R6, R5}
                BX LR

diminui_t
                PUSH {R5, R6}
                LDR R5, =TIM3_CCR3
                LDR R6, [R5]
                CMP R6, #90
                SUBGE R6, R6, #50
                STR R6, [R5]
                POP {R6, R5}
                BX LR

                LTORG

atualiza_lcd
                PUSH {LR, R0, R1, R2}
                MOV R4, #0x02
                BL lcd_command
                MOV R4, #'o'
                BL lcd_data
                MOV R4, #'-'
                BL lcd_data
                ADD R4, R10, #'0'
                BL lcd_data
                MOV R4, #' '
                BL lcd_data
                MOV R4, #'t'
                BL lcd_data
                MOV R4, #'-'
                BL lcd_data
                LDR R0, =TIM3_CCR3
                LDR R1, [R0]
                MOV R2, #10
                UDIV R1, R1, R2
                UDIV R4, R1, R2
                MOV R3, R4
                ADD R4, #'0'
                BL lcd_data
                MOV R4, R1
                MLS R4, R3, R2, R1
                ADD R4, #'0'
                BL lcd_data
                MOV R4, #'%'
                BL lcd_data
                POP {R2, R1, R0, LR}
                BX LR

som
                PUSH {LR, R0, R1, R2, R3, R5, R6, R7}
                LDR R0, =GPIOA_ODR
                LDR R1, =TIM3_CCR3
                LDR R2, [R1]
                LDR R5, =leds
                MOV R3, #0
                MOV R7, #0
loop
                CMP R2, R3
                ADDGT R3, R3, #130
                LDR R6, [R5]
                ADD R5, R5, #4
                ORRGT R7, R7, R6
                BGT loop
                STR R7, [R0]
                POP {R7, R6, R5, R3, R2, R1, R0, LR}
                BX LR

identifica_tecla
                PUSH {R1, R2, R3, R5, R11}
                LDR R1, =GPIOB_IDR
                LDR R2, [R1]
                MOV R5, #MASKB
                AND R2, R5, R2
                LDR R1, =GPIOA_IDR
                LDR R0, [R1]
                MOV R5, #MASKA
                AND R0, R5, R0
                LDR R1, =GPIOC_IDR
                LDR R11, [R1]
                MOV R5, #MASKC
                AND R11, R5, R11
                MOV R8, #0

                ; SW1 (B)
                MOV R3, #SW1
                MOV R5, #MASKB
                AND R3, R3, R5
                CMP R2, R3
                MOVEQ R8, #1

                ; SW2 (B)
                MOV R3, #SW2
                MOV R5, #MASKB
                AND R3, R3, R5
                CMP R2, R3
                MOVEQ R8, #2

                ; SW3 (B)
                MOV R3, #SW3
                MOV R5, #MASKB
                AND R3, R3, R5
                CMP R2, R3
                MOVEQ R8, #3

                ; SW4 (B)
                MOV R3, #SW4
                MOV R5, #MASKB
                AND R3, R3, R5
                CMP R2, R3
                MOVEQ R8, #4

                ; SW5 (B)
                MOV R3, #SW5
                MOV R5, #MASKB
                AND R3, R3, R5
                CMP R2, R3
                MOVEQ R8, #5

                ; SW6 (B)
                MOV R3, #SW6
                MOV R5, #MASKB
                AND R3, R3, R5
                CMP R2, R3
                MOVEQ R8, #6

                ; SW7 (B)
                MOV R3, #SW7
                MOV R5, #MASKB
                AND R3, R3, R5
                CMP R2, R3
                MOVEQ R8, #7

                ; SW8 (A)
                MOV R3, #SW8
                MOV R5, #MASKA
                AND R3, R3, R5
                CMP R0, R3
                MOVEQ R8, #8

                ; SW9 (A)
                MOV R3, #SW9
                MOV R5, #MASKA
                AND R3, R3, R5
                CMP R0, R3
                MOVEQ R8, #9

                ; SW10 (B)
                MOV R3, #SW10
                MOV R5, #MASKB
                AND R3, R3, R5
                CMP R2, R3
                MOVEQ R8, #10

                ; SW11 (B)
                MOV R3, #SW11
                MOV R5, #MASKB
                AND R3, R3, R5
                CMP R2, R3
                MOVEQ R8, #11

                ; SW13 (B)
                MOV R3, #SW13
                MOV R5, #MASKB
                AND R3, R3, R5
                CMP R2, R3
                MOVEQ R8, #13

                ; SW14 (A)
                MOV R3, #SW14
                MOV R5, #MASKA
                AND R3, R3, R5
                CMP R0, R3
                MOVEQ R8, #14

                ; SW15 (C)
                MOV R3, #SW15
                MOV R5, #MASKC
                AND R3, R3, R5
                CMP R11, R3
                MOVEQ R8, #15

                ; SW16 (C)
                MOV R3, #SW16
                MOV R5, #MASKC
                AND R3, R3, R5
                CMP R11, R3
                MOVEQ R8, #16

                ; SW17 (C)
                MOV R3, #SW17
                MOV R5, #MASKC
                AND R3, R3, R5
                CMP R11, R3
                MOVEQ R8, #17

                POP {R11, R5, R3, R2, R1}
                BX LR

                LTORG

toca_nota
                PUSH {LR, R0, R1, R2, R3, R4, R5, R6}
                CMP R10, #2
                BEQ usa_notas2
                LDR R1, =notas_1+4
                B seleciona_nota
usa_notas2
                LDR R1, =notas_2+4
seleciona_nota
                LDR R0, =TIM3_PSC
                LDR R2, =teclas
                MOV R3, #0
                MOV R5, #0
loop_tecla
                LDR R5, [R2, R3, LSL #2]
                CMP R5, R4
                ADDNE R3, R3, #1
                BNE loop_tecla
                LDR R6, [R1, R3, LSL #2]
                STR R6, [R0]
                POP {R6, R5, R3, R2, R1, R0, LR}
                B volta
                BX LR

config_inicial
                PUSH {LR}
                LDR R0, =RCC_APB1ENR
                LDR R1, [R0]
                ORR R1, R1, #0x03
                STR R1, [R0]
                LDR R0, =TIM3_ARR
                LDR R1, =ARR
                STR R1, [R0]
                LDR R0, =TIM3_CCMR2
                LDR R1, =0x0068
                STR R1, [R0]
                LDR R0, =TIM3_CCER
                LDR R1, =0x0100
                STR R1, [R0]
                LDR R0, =TIM3_CCR3
                MOV R1, #50
                STR R1, [R0]
                LDR R0, =TIM3_CR1
                MOV R1, #0x01
                STR R1, [R0]
                LDR R1, =RCC_APB2ENR
                LDR R0, [R1]
                ORR R0, R0, #hab_gpio_afio
                STR R0, [R1]
                LDR R1, =AFIO_MAPR
                LDR R0, =JTAG_GPIO
                STR R0, [R1]
                LDR R1, =GPIOA_CRL
                LDR R0, =0x43344333
                STR R0, [R1]
                LDR R1, =GPIOA_CRH
                LDR R0, =0x34433443
                STR R0, [R1]
                LDR R1, =GPIOB_CRL
                LDR R0, =0x4444444B
                STR R0, [R1]
                LDR R1, =GPIOB_CRH
                LDR R0, =0x44444444
                STR R0, [R1]
                LDR R1, =GPIOC_CRL
                LDR R0, =0x44444444
                STR R0, [R1]
                LDR R1, =GPIOC_CRH
                LDR R0, =0x44444444
                STR R0, [R1]
                MOV R4, #0x01
                BL lcd_command
                BL lcd_init
                POP {LR}
                BX LR

lcd_command
                PUSH {LR, R4, R5, R7, R8, R10, R11}
                AND R5, R4, #0xF0
                LSR R5, R5, #4
                AND R7, R5, #0x08
                LSL R10, R7, #8
                AND R7, R5, #0x04
                LSL R7, R7, #3
                ORR R10, R10, R7
                AND R7, R5, #0x02
                LSL R7, R7, #5
                ORR R10, R10, R7
                AND R7, R5, #0x01
                LSL R7, R7, #8
                ORR R10, R10, R7
                LDR R11, =LCD_RS
                BIC R10, R10, R11
                BIC R10, R10, #LCD_EN
                LDR R8, =GPIOA_ODR
                STR R10, [R8]
                BL delay
                ORR R10, R10, #LCD_EN
                STR R10, [R8]
                BL delay
                BIC R10, R10, #LCD_EN
                STR R10, [R8]
                BL delay
                AND R5, R4, #0x0F
                AND R7, R5, #0x08
                LSL R10, R7, #8
                AND R7, R5, #0x04
                LSL R7, R7, #3
                ORR R10, R10, R7
                AND R7, R5, #0x02
                LSL R7, R7, #5
                ORR R10, R10, R7
                AND R7, R5, #0x01
                LSL R7, R7, #8
                ORR R10, R10, R7
                LDR R11, =LCD_RS
                BIC R6, R6, R11
                BIC R10, R10, #LCD_EN
                LDR R9, =GPIOA_ODR
                STR R10, [R8]
                BL delay
                BIC R10, R10, R11
                STR R10, [R8]
                BL delay
                ORR R10, R10, #LCD_EN
                STR R10, [R8]
                BL delay
                BIC R10, R10, #LCD_EN
                STR R10, [R8]
                BL delay
                POP {R11, R10, R8, R7, R5, R4, LR}
                BX LR

lcd_data
                PUSH {LR, R4, R5, R7, R8, R10, R11}
                AND R5, R4, #0xF0
                LSR R5, R5, #4
                AND R7, R5, #0x08
                LSL R10, R7, #8
                AND R7, R5, #0x04
                LSL R7, R7, #3
                ORR R10, R10, R7
                AND R7, R5, #0x02
                LSL R7, R7, #5
                ORR R10, R10, R7
                AND R7, R5, #0x01
                LSL R7, R7, #8
                ORR R10, R10, R7
                LDR R11, =LCD_RS
                ORR R10, R10, R11
                BIC R10, R10, #LCD_EN
                LDR R8, =GPIOA_ODR
                STR R10, [R8]
                BL delay
                ORR R10, R10, #LCD_EN
                STR R10, [R8]
                BL delay
                BIC R10, R10, #LCD_EN
                STR R10, [R8]
                BL delay
                AND R5, R4, #0x0F
                AND R7, R5, #0x08
                LSL R10, R7, #8
                AND R7, R5, #0x04
                LSL R7, R7, #3
                ORR R10, R10, R7
                AND R7, R5, #0x02
                LSL R7, R7, #5
                ORR R10, R10, R7
                AND R7, R5, #0x01
                LSL R7, R7, #8
                ORR R10, R10, R7
                ORR R10, R10, R11
                BIC R6, R6, #LCD_EN
                LDR R8, =GPIOA_ODR
                STR R10, [R8]
                BL delay
                ORR R10, R10, #LCD_EN
                STR R10, [R8]
                BL delay
                BIC R10, R10, #LCD_EN
                STR R10, [R8]
                BL delay
                POP {R11, R10, R8, R7, R5, R4, LR}
                BX LR

lcd_init
                PUSH {LR, R4}
                MOV R4, #0x33
                BL lcd_command
                MOV R4, #0x32
                BL lcd_command
                MOV R4, #0x20
                BL lcd_command
                MOV R4, #0x0E
                BL lcd_command
                MOV R4, #0x01
                BL lcd_command
                BL delay
                MOV R4, #0x06
                BL lcd_command
                POP {R4, LR}
                BX LR

delay
                PUSH {LR, R0, R1}
                LDR R0, =1
d_L1            LDR R1, =10000
d_L2            SUBS R1, R1, #1
                BNE d_L2
                SUBS R0, R0, #1
                BNE d_L1
                POP {R1, R0, LR}
                BX LR

                END
