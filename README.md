# Timer Application using LPC1768 Microcontroller

## Overview
This project implements a timer application using the LPC1768 microcontroller. The application is designed to interface with a seven-segment display to provide accurate timing functionality. It includes features such as keypad input for setting the timer duration, real-time display of the timer on the seven-segment display, and a buzzer alarm to signal when the timer reaches zero.

## Features
- Set timer duration using keypad input
- Display timer countdown on a seven-segment display
- Trigger buzzer alarm when the timer expires
- Maximum input duration: 99 minutes 59 seconds
- Implemented on LPC1768 microcontroller with C programming language

## Hardware Requirements
- LPC1768 Microcontroller: A 32-bit CortexM3 microcontroller from NXP
- Keypad: Input device for setting the timer duration
- Seven-Segment Display: Output device for displaying the timer countdown
- Buzzer: Alarm device triggered when the timer expires

## Assumptions
- Port Configuration:
  - PORT 2.10 to 2.13 as OUTPUT (rows)
  - PORT 1.23 to 1.26 as INPUT (columns)
  - PORT 0.4 to 0.11 as DATA LINES for Seven-Segment Display
  - PORT 0.23 to 0.26 as ENABLE LINES for Seven-Segment Display
  - PORT 2.0 as SWITCH
  - PORT 4.28 configured for BUZZER

## Code Structure
The code consists of the following main components:
- `main.c`: Main program file containing the timer logic and hardware interaction functions.
- `timer_config.h`: Header file containing port configurations and other constants.
- `Makefile`: Makefile for compiling and building the project.

## How to Use
1. Connect the LPC1768 microcontroller with the required hardware components.
2. Compile the code using an appropriate toolchain.
3. Flash the compiled code onto the LPC1768 microcontroller.
4. Power on the system and interact with the keypad to set the timer duration.
5. The timer countdown will be displayed on the seven-segment display.
6. When the timer expires, the buzzer alarm will be triggered.


