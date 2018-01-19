---
author:
- Fabien Chouteau
title: Making the Ada Drivers Library
subtitle: Embedded Programming with Ada
titlepage-note: |
 Title notes...
institute: Embedded Software Engineer at AdaCore
twitter: DesChips
github: Fabien-Chouteau
hackaday: Fabien.C
fontsize: 15pt
theme: metropolis
...

# Programming is all about communication #

## Programming is all about communication ##

With:

>- The compiler
>- The other tools (static analyzers, provers, etc.)
>- Users of your API
>- Your colleagues
>- The idiot that wrote this stupid piece of code...
>- __Oh, wait. It was me two months ago :(__

## What makes Embedded Programming different? ##

Every bug costs more:

 - More time to investigate
 - More time to try a fix
 - Potential destruction of hardware
 - Potential injuries or death

You need more control:

 - Low resources (RAM, flash, CPU)
 - Interaction with the hardware

# Embedded Programming with Ada #

## Servo motor example ##
\columnsbegin
\column{.20\textwidth}

![](images/servo_motor.png)

\column{.80\textwidth}

![](diagrams/servo_pulses-dot.pdf)

\columnsend

## Servo motor example ##
\columnsbegin
\column{.20\textwidth}

![](images/servo_motor_explosion.png)

\column{.80\textwidth}

![](diagrams/servo_pulses-dot.pdf)

\columnsend

## Types ##

```{.ada}
procedure Set_Angle (Angle : Integer);
```

## Types ##

```{.ada}

--  Set desired angle for the servo motor.
--  
--  @param Angle: Desired rotation angle in degree.
--  Please do not use a value above 90 or below -90!
procedure Set_Angle (Angle : Integer);
```

## Types ##

```{.ada}
type Servo_Angle is range -90 .. 90;
--  Servo rotation angle in degree.

procedure Set_Angle (Angle : Servo_Angle);
--  Set desired angle for the servo motor

```

## Types ##

```{.ada}
Set_Angle (100);
```

```
warning: value not in range of type "Servo_Angle"
warning: "Constraint_Error" will be raised at run time
```

## Debugging ##

Gdb catches the exception

## Types ##

```{.ada}
subtype Safe_Range is Servo_Angle range -45 .. 10;

if Angle in Safe_Range then
   [...]
end if;

```

## Contracts ##

```{.ada}
function Initialized return Boolean;
--  Return True if the driver is initialized

procedure Initialize
   with Post => Initialized;
--  Initialize the servo motor driver

procedure Set_Angle (Angle : Servo_Angle)
   with Pre => Initialized;
--  Set desired angle for the servo motor
```

## Misc. ##

```{.ada}

procedure Plop (Ptr : not null Some_Pointer);

procedure Read_Char (C : out Character);
```

## Hardware mapping ##

```{.ada}
type Servo_Angle is range -90 .. 90
  with Size      => 8,
       Alignment => 16;
```

## Hardware mapping ##

![](diagrams/register_definition-dot.pdf)

## Hardware mapping ##

``` {.ada}
   --  Configuration of GPIO pins.
   type PIN_CNF_Register is record
      DIR            : PIN_CNF_DIR_Field   := Input;
      INPUT          : PIN_CNF_INPUT_Field := Disconnect;
      PULL           : PIN_CNF_PULL_Field  := Disabled;
      Reserved_4_7   : HAL.UInt4           := 16#0#;
      DRIVE          : PIN_CNF_DRIVE_Field := S0S1;
      Reserved_11_15 : HAL.UInt5           := 16#0#;
      SENSE          : PIN_CNF_SENSE_Field := Disabled;
      Reserved_18_31 : HAL.UInt14          := 16#0#;
   end record
     with Volatile_Full_Access, Size => 32,
          Bit_Order => System.Low_Order_First;
```

## Hardware mapping ##

``` {.ada}
   for PIN_CNF_Register use record
      DIR            at 0 range 0 .. 0;
      INPUT          at 0 range 1 .. 1;
      PULL           at 0 range 2 .. 3;
      Reserved_4_7   at 0 range 4 .. 7;
      DRIVE          at 0 range 8 .. 10;
      Reserved_11_15 at 0 range 11 .. 15;
      SENSE          at 0 range 16 .. 17;
      Reserved_18_31 at 0 range 18 .. 31;
   end record;
```

## Hardware mapping ##

``` {.ada}
   --  Pin sensing mechanism.
   type PIN_CNF_SENSE_Field is
     (
      --  Disabled.
      Disabled,
      --  Wakeup on high level.
      High,
      --  Wakeup on low level.
      Low)
     with Size => 2;
   for PIN_CNF_SENSE_Field use
     (Disabled => 0,
      High => 2,
      Low => 3);
```

## Hardware mapping ##

``` {.ada}
GPIO_Periph.PIN_CNF (4).SENSE := Disabled;
```

## SVD2Ada ##

Generates Ada hardware mapping from SVD description

``` {.xml}
<field>
  <name>SENSE</name>
  <description>Pin sensing mechanism.</description>
  <lsb>16</lsb> <msb>17</msb>
  <enumeratedValues>
    <enumeratedValue>
      <name>Disabled</name>
      <description>Disabled.</description>
      <value>0x00</value>
    </enumeratedValue>
 [...]
```

## Misc. ##

``` {.ada}
48_815

16#BEAF#

2#1011_1110_1010_1111#

5#3030230#
```

# Ravenscar Tasking #

## Task ##

A.K.A There's a mini-RTOS in my languge^[blog.adacore.com/theres-a-mini-rtos-in-my-language]


``` {.ada}
--  Task declaration
task My_Task
 with Priority => 1;
```

``` {.ada}
--  Task implementation
task body My_Task is
begin
   --  Do something cool here...
end My_Task;
```

## Synchronization 1/2 ##

``` {.ada}
protected My_Protected_Object is
   procedure Send_Signal;
   entry Wait_For_Signal;
private
   We_Have_A_Signal : Boolean := False;
end My_Protected_Object;
```

## Synchronization 2/2 ##

``` {.ada}
protected body My_Protected_Object is

   procedure Send_Signal is
   begin
       We_Have_A_Signal := True;
   end Send_Signal;

   entry Wait_For_Signal when We_Have_A_Signal is
   begin
       We_Have_A_Signal := False;
   end Wait_For_Signal;
end My_Protected_Object;
```

## Interrupt handling 1/2 ##

``` {.ada}
protected My_Protected_Object
  with Interrupt_Priority => 255
is
   entry Get_Next_Character (C : out Character);

private
   procedure UART_Interrupt_Handler
           with Attach_Handler => UART_Interrupt;

   Received_Char  : Character := ASCII.NUL;
   We_Have_A_Char : Boolean := False;
end
```

## Interrupt handling 1/2 ##

``` {.ada}
protected body My_Protected_Object is

   entry Get_Next_Character (C : out Character)
     when We_Have_A_Char
   is
   begin
       C := Received_Char;
       We_Have_A_Char := False;
   end Get_Next_Character;

   procedure UART_Interrupt_Handler is
   begin
       Received_Char  := A_Character_From_UART_Device;
       We_Have_A_Char := True;
   end UART_Interrupt_Handler;
end
```

## Runtimes profiles ##

   - Zero FootPrint (ZFP)
     - The bare minimum to program in Ada
     - Static/compile time features of Ada
     - Tagged types (Object Oriented)
     - Contracts, run-time checks
   - Ravenscar Small FootPrint (SFP)
     - ZFP + tasking
     - Ravenscar tasking
   - Ravenscar Full
     - Ravenscar SFP + everything we can add
     - Exception propagation
     - Containers

# Making the Ada Drivers Library #

## Ada Drivers Library ##

 - Firmware library
 - Hardware and vendor independent
 - 100% Ada
 - Hosted on GitHub: [github.com/AdaCore/Ada_Drivers_Library](github.com/AdaCore/Ada_Drivers_Library)

## Architecture ##

![](diagrams/ADL_architecture-dot.pdf)

## Supported components ##

 - Audio DAC: SGTL5000, CS43L22, W8994
 - Camera: OV2640, OV7725
 - IO expander: MCP23XXX, STMPE1600 HT16K33
 - Motion: AK8963, BNO055, L3GD20, LIS3DSH, MMA8653, MPU9250
 - Range: VL53L0X
 - LCD: ILI9341, OTM8009a, ST7735R, SSD1306
 - Touch panel: FT5336, FT6X06, STMPE811
 - Module:
    - AdaFruit's trellis
    - AdaFruit's Thermal printer

## Middleware ##

 - Bitmap drawing
 - File System: FAT and ARM semi-hosting
 - Log utility

## Supported platforms ##

\columnsbegin
\column{.53\textwidth}

![](images/arm_logo.png)

\column{.47\textwidth}

![](images/riscv_logo.png)

\columnsend

# Supported boards #

## STM32F405 Discovery (ARM Cortex-M4F) ##

![](images/board_f4disco.png)

## STM32F429 Discovery (ARM Cortex-M4F) ##

![](images/board_f429disco.png)

## STM32F469 Discovery  (ARM Cortex-M4F) ##

![](images/board_f469disco.png)

## STM32F746 Discovery  (ARM Cortex-M7F) ##

![](images/board_f746disco.png)

## STM32F769 Discovery  (ARM Cortex-M7F) ##

![](images/board_f769disco.png)

## OpenMV 2 (ARM Cortex-M4F) ##

![](images/board_openmv2.png)

## Crazyflie 2.0 (ARM Cortex-M4F) ##

![](images/board_cf2.png)

## BBC Micro:Bit (ARM Cortex-M0) ##

![](images/board_microbit.png)

## HiFive1 (RISC-V) ##

![](images/board_hifive1.png)

## What's next? ##

TODOs:

 - New build and configuration system (based on KConfig)
 - More documentation
 - Out of the box support of all the Cortex-M devices
 
## Contribution ##

 - Linux GPIO/I2C/SPI support
 - AVR platform
 - Components drivers

# Getting started demo #
## Examples of projects from Me, AdaCore, MWAC ##

## The Make with Ada Competition ##

## Pandoc Examples##

Regular text size

\tiny Jonathan Sarna, *American Judaism* (New Haven: Yale University
Press, 2014)

\note{
NOTES: This is a note page and you ought to be able to tell.

}

## Slide with text and footnote

Surely this is true.^[Jane Doe, *Says It Here* (New York: Oxford
University Press, 2050).]

\note{I am sure about this point.}

## This is a heading

Regular text on a slide:

-   One
-   Two
-   Three

## Incremental list

Incremental list on a slide:

>-   One
>-   Two
>-   Three

\note{
More notes:

Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod
tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At
vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd
gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.

}

## Code example

``` {.ada}
procedure Test is
begin
   null;
end Test;
```

\note{
This might be easier in R or Ruby.
}
