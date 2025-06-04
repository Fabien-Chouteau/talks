---
author:
- Fabien Chouteau
title: Making the Mars Rover Demo
titlepage-note: |
 Title notes...
institute: Embedded Software Engineer at AdaCore
mastodon: '@DesChips@mamot.fr'
mastodon_link: 'https://mamot.fr/@DesChips'
github: Fabien-Chouteau
hackaday: Fabien.C
fontsize: 15pt
theme: metropolis
logo: images/adacore.png
---

## Context

::: columns

:::: column

![](images/2025_ew_T_1819.jpg)

::::

:::: column

![](images/2025_ew_T_0761.jpg)

::::

:::

# Why do we make demos for trade shows?


## Why do we make demos for trade shows?

 - \only<1->{Software is not easy to show}

 - \only<2->{Especially software dev tools}

 - \only<3->{We have to quickly grab attention}

## Constraints?

 - \only<1->{Eye catching}

 - \only<2->{Easy to deploy/use}

 - \only<3->{As much as possible relevant}

 - \only<4->{Reliable...}

# The Process

## Finding the good idea

 - \only<1->{First idea, a remote controlled thingy}

 - \only<2->{Looking for robots that would look nice}

 - \only<3->{Looking for robots that would be relevant}

## 4Tronix M.A.R.S Rover

![[https://shop.4tronix.co.uk/products/marsrover](https://shop.4tronix.co.uk/products/marsrover)](images/4tronix_mars_rover.png)

## Investigate feasibility

 - \only<1->{How to control?}\only<2->{ → RPi Pico}

 - \only<3->{How to add remote?}\only<4->{ → Wireless PS2 controller}

 - \only<5->{Autonomous mode?}\only<6->{ → Onboard sensor}

## Implementation: A Custom PCB

::: columns

:::: column

![](images/mars-rover-pcb-1.png)

::::

:::: column

![](images/mars-rover-pcb-2.png)

::::

:::

- RPi Pico
- PS2 remote
- Screen and buttons

## Implementation: Software

 - Using Alire of course
 - rp2040-hal
 - New drivers needed (Servos, and PS2 remote)
 
## Implementation: Autonomous Mode

::: columns

:::: column

- Very simple (KISS)
- Never hit a wall
- Never get stuck

::::

:::: column

![](diagrams/mars-rover-autonmous-mode-dot.pdf)

::::

:::


## Implementation: 
 
## SPARKify

```ada
function Cannot_Crash return Boolean is
  (if Rover_HAL.Get_Sonar_Distance < Safety_Distance and then
      Rover_HAL.Get_Turn = Rover_HAL.Straight
   then
     Rover_HAL.Get_Power (Rover_HAL.Left)  <= 0 and then
     Rover_HAL.Get_Power (Rover_HAL.Right) <= 0);
```

## SPARKify

```ada
      [...]

      Delay_Milliseconds (30);

      pragma Loop_Invariant (Rover.Cannot_Crash);
   end loop;
end Run;
```

## SPARKify

```ada
Dist := Sonar_Distance;

if Dist < Rover.Safety_Distance then
  --  Ignore forward commands when close to an obstacle
  Buttons (Up) := False;
end if;
```

[blog.adacore.com/lets-write-a-safety-monitor-for-a-mars-rover](https://blog.adacore.com/lets-write-a-safety-monitor-for-a-mars-rover)

## Deploy

![&nbsp;](images/2025_ew_adacore_booth.jpg)

## Add a little flag!

![&#8203;](images/2025_ew_F_3381.jpg)

# Other Demos

## SPARK Railway

![&#8203;](images/spark-railway-demo.jpg)

## RISC-V Drawing

![&#8203;](images/rriscv-whiteboard-demo.png)

## Crazyflie

![&#8203;](images/board_cf2.png)

## Drawing Sudoku

![&#8203;](images/sudoku-drawing-demo.jpeg)

## Misc demos

![&#8203;](images/ada-in-action-demo.jpeg)
