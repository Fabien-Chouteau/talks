---
author:
- Fabien Chouteau
title: Embedded Ada with Alire
titlepage-note: |
 Title notes...
institute: Embedded Software Engineer
twitter: DesChips
github: Fabien-Chouteau
hackaday: Fabien.C
fontsize: 15pt
theme: metropolis
logo: images/adacore.png
...

## Scope: MCUs

 - Micro-controllers
   - "Simple" devices
   - A few KiB sometimes MiB of RAM and ROM
   - No virtual memory
   - A lot of inputs/outputs
 - No Operating System (bare-metal)

## The hardware

![](images/board_microbit.png)

## What do we need?

 - Toolchain
 - Board Support Package (BSP)
   - Run-time
   - Startup code
   - Linker scripts
   - Drivers
 - Libraries

## Architecture of the crates

## Create the `nrf51_hal` crate

```console
$ alr init --lib nrf51_hal
$ cd nrf51_hal
```

## Add `cortex_m` dependency

```console
$ alr with cortex_m
```
## Add `gnat_arm_elf` dependency

```console
$ alr with gnat_arm_elf
```

## Edit GPR file

## Create the `microbit_bsp` crate

```console
$ cd ..
$ alr init --lib microbit_bsp
$ cd microbit_bsp
```

## Add a pin dependency to `nrf51_hal`

```console
$ alr with nrf51_hal --use=../nrf51_hal
```

## Configure run-time in GPR file

Zero-FootPrint run-times without parts that are specific to a given MCU or
board

That means without:

 - Linker script
 - Startup code (crt0.S)

``` {.ada}
```

## Add device configuration in GPR file

``` {.ada}
```

## Get and build startup-gen

```console
$ alr get --build startup_gen
```

## Use startup-gen generator

```console
$ startup-gen -P microbit_bsb.gpr \
              -l src/link.ld \
              -s src/crt0.S
```

## Add crt0 + linker script in GPR file

```ada
```

## Create the my_application crate

```console
$ cd ..
$ alr init --bin my_application
$ cd my_application
```

## Add a pin dependency to `microbit_bsp`

```console
$ alr with microbit_bsp --use=../microbit_bsp
```

## Configure GPR file

## Write hello-world

```ada
with Ada.Text_IO;

procedure My_Application is
begin
   for X in 1 .. 10 loop
      Ada.Text_IO.Put_Line ("Hello World!");
   end loop;
end My_Application;
```

## First build

```
$ alr build
```

## Run hello-world on QEMU

```console
$  qemu-system-arm -nographic -no-reboot \
                   -semihosting -M microbit \
                   -kernel bin/my_application
```
# Peripheral Drivers

## Memory Mapped Registers

![&nbsp;](diagrams/memory_layout-dot.pdf)

## Memory Mapped Registers

![&nbsp;](diagrams/register_definition-dot.pdf)

## Hardware Mapping

``` {.c}
#define SENSE_MASK     (0x30)
#define SENSE_POS      (4)

#define SENSE_DISABLED (0)
#define SENSE_HIGH     (2)
#define SENSE_LOW      (3)

uint8_t *register = 0x80000100;

// Clear Sense field
*register &= ~SENSE_MASK;
// Set sense value
*register |= SENSE_DISABLED << SENSE_POS;
```

## Hardware Mapping

``` {.ada}
--  High level view of the Sense field
type Pin_Sense is
  (Disabled,
   High,
   Low)
  with Size => 2;

--  Hardware representation of the Sense field
for Pin_Sense use
  (Disabled => 0,
   High     => 2,
   Low      => 3);
```

## Hardware Mapping

``` {.ada}
--  High level view of the register
type IO_Register is record
   Reserved_A : UInt4;
   SENSE      : Pin_Sense;
   Reserved_B : UInt2;
end record;

--  Hardware representation of the register
for IO_Register use record
   Reserved_A at 0 range 0 .. 3;
   SENSE      at 0 range 4 .. 5;
   Reserved_B at 0 range 6 .. 7;
end record;
```

## Hardware Mapping

``` {.ada}
Register : IO_Register
  with Address => 16#8000_0100#;
```

``` {.ada}
Register.SENSE := Disabled;
```
## Mapping for the nRF51

 - nRF51
  - 28 peripherals
  - 414 memory mapped registers
  - 903 fields in the registers

Who wants to write all the representation clauses?

## System View Description (SVD)

``` {.xml}
<field>
  <name>SENSE</name>
  <description>Pin sensing mechanism.</description>
  <lsb>4</lsb> <msb>5</msb>
  <enumeratedValues>
    <enumeratedValue>
      <name>Disabled</name>
      <description>Disabled.</description>
      <value>0x00</value>
    </enumeratedValue>
 [...]
```

## Get and build svd2ada

```console
$ alr get --build svd2ada
```
