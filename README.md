# picocalc-r2p2
PicoRuby shell for PicoCalc.
This project is currently experimental.

## About

This project combines:
- **R2P2** (Ruby Rapid Portable Platform) by HASUMI Hitoshi - PicoRuby shell system
- **PicoCalc** hardware components by ClockworkPI - LCD SPI driver and I2C keyboard driver
- Integration and modifications by KAGEYAMA Katsuhiko

The goal is to provide a Ruby-based shell environment that runs on PicoCalc hardware, offering an interactive programming environment with LCD display and keyboard input capabilities.

## Components

- **Base System**: R2P2 PicoRuby shell
- **Display**: LCD SPI driver (from PicoCalc project)
- **Input**: I2C keyboard driver (from PicoCalc project)
- **Hardware Target**: Raspberry Pi Pico 2 / PicoCalc hardware

## Prerequisites

- pico-sdk 2.2.0
- CMake
- Ruby (for rake build system)

## build

./build.sh

## flash

./build.sh flash

## Credits

- **HASUMI Hitoshi** - Original R2P2 project
- **ClockworkPI** - PicoCalc hardware design and drivers
- **PicoRuby Team** - Ruby runtime for microcontrollers

## License

MIT License - See LICENSE file for details.
