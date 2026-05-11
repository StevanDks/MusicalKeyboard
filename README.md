# Musical Keyboard in ARM Assembly

An ARM Assembly project that implements a musical keyboard on an STM32 microcontroller, using GPIO buttons, a buzzer via PWM (Timer 3), an LCD display, and LEDs.

---

## Features

- 13 playable musical notes across 2 octaves
- PWM-based sound generation using Timer 3 (TIM3)
- Adjustable timbre (duty cycle control)
- LCD display showing current octave and timbre percentage
- LED indicators reflecting timbre intensity
- Octave selection via dedicated buttons

---

## Hardware

- **Microcontroller:** STM32F103 (ARM Cortex-M3)
- **GPIOs used:** GPIOA, GPIOB, GPIOC
- **Timer:** TIM3 — PWM output on channel 3
- **Display:** 16x2 LCD in 4-bit mode
- **Input:** 17 push buttons (SW1–SW17)
- **Output:** 8 LEDs + buzzer via PWM

---

## Button Mapping

| Button | Function |
|--------|----------|
| SW1 | Select Octave 1 |
| SW2 | Select Octave 2 |
| SW3 | Increase timbre |
| SW4 | Decrease timbre |
| SW5–SW17 | Play musical notes |

---

## Project Structure

```
MusicalKeyboard/
└── main.s       # Full ARM Assembly source code
```

---

## How It Works

1. On startup, `config_inicial` initializes TIM3, GPIO ports, and the LCD.
2. The main loop continuously reads button states via `identifica_tecla`.
3. When a note button is pressed, `toca_nota` looks up the correct PSC value from the note table and configures TIM3 to generate the corresponding frequency.
4. `som` controls which LEDs light up based on the current timbre level.
5. `atualiza_lcd` displays the current octave and timbre percentage on the LCD.

---

## Tools

- **Assembler:** Keil MDK / ARM DS-5
- **Target:** STM32F103 series

---

## License

This project is licensed under the [MIT License](LICENSE).
