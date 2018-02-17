pcd8544 (NOKIA 5110 display) interfacing on TIVA board in full asm
==================================================================

warning
-------
This code doesn't concern portability and was made to run on my EK-TM4C123GXL
board.
I hold no responsabilty if these projects brick your board, burn your house down
or kill your cat.

The Pinout
----------
- CE  <-> PA3
- RST <-> PF2
- D/C <-> PF3
- D   <-> PA5
- CLK <-> PA2
- LED <-> PF4

The Files
---------
- pcd8544.asm - several, hopefuly useful, asm routines to setup and comunicate with the LCD and printing images
- main.asm - a little test with bitmaps (may not be currently in a working state)
- assets/bmp2c.py - python script to convert a bitmap file to assembler or "C array" style
- assets/judy.bmp - 1bit bitmap
- assets/judy_m.bmp - 1bit mask bitmap for transparencies

The Things
----------
