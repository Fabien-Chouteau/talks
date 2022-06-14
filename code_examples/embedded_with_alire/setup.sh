#!/bin/sh

alr -n init --lib nrf51_hal
cd nrf51_hal
# alr -n with cortex_m
alr -n with hal
alr -n with gnat_arm_elf
cd ..

alr init --lib microbit_bsp
cd microbit_bsp

alr -n with nrf51_hal --use=../nrf51_hal

sed -i '4 i for Target use "arm-elf";' microbit_bsp.gpr
sed -i '4 i for Runtime ("Ada") use "zfp-cortex-m0";' microbit_bsp.gpr

cd ..

alr -n get --build startup_gen

sed -i '31 i \
   package Device_Configuration is\
      for CPU_Name use "ARM Cortex-M0";\
      for Number_Of_Interrupts use "32";\
\
      for Memories use ("flash", "ram");\
\
      for Mem_Kind ("flash") use "rom";\
      for Address  ("flash") use "0x00000000";\
      for Size     ("flash") use "256K";\
\
      for Mem_Kind ("ram") use "ram";\
      for Address  ("ram") use "0x20000000";\
      for Size     ("ram") use "16K";\
\
      for Boot_Memory use "flash";\
   end Device_Configuration;\
' microbit_bsp/microbit_bsp.gpr

cat microbit_bsp/microbit_bsp.gpr

cd microbit_bsp
alr exec -- ../startup_gen_22.0.0_85f5a122/startup-gen -P microbit_bsp.gpr -l src/link.ld -s src/crt0.S
sed -i '4 i for Languages use ("Ada", "Asm_CPP");' microbit_bsp.gpr
sed -i '4 i Linker_Switches := ("-T", Project'"'"'Project_dir & "/src/link.ld");' microbit_bsp.gpr


cd ..

alr init --bin my_application
cd my_application
alr -n with microbit_bsp --use=../microbit_bsp

sed -i '2 i with "microbit_bsp.gpr";' my_application.gpr
sed -i '4 i for Runtime ("Ada") use MicroBit_BSP'"'"'Runtime ("Ada");' my_application.gpr
sed -i '4 i for Target use MicroBit_BSP'"'"'Target;' my_application.gpr
sed -i '24 i \
   package Linker is\
      for Default_Switches ("Ada") use\
        MicroBit_BSP.Linker_Switches &\
        ("-Wl,--print-memory-usage",\
         "-Wl,--gc-sections");\
   end Linker;\
' my_application.gpr

cat <<EOF > src/my_application.adb
with Ada.Text_IO;

procedure My_Application is
begin
   for X in 1 .. 10 loop
      Ada.Text_IO.Put_Line ("Hello World!");
   end loop;
end My_Application;
EOF

alr build
qemu-system-arm -nographic -no-reboot \
                -semihosting -M microbit \
                -kernel bin/my_application
cd ..

alr get --build svd2ada

cd nrf51_hal
../svd2ada_0.1.0_6eb0b591/bin/svd2ada \
    ../svd2ada_0.1.0_6eb0b591/CMSIS-SVD/Nordic/nrf51.svd \
    --boolean \
    -o src/ \
    -p nRF51_SVD \
    --base-types-package HAL \
    --gen-uint-always

cat <<EOF > src/nrf51_hal-rng.ads
with HAL;
package Nrf51_Hal.RNG is
   function Read return HAL.UInt8;
end Nrf51_Hal.RNG;
EOF

cat <<EOF > src/nrf51_hal-rng.adb
with nRF51_SVD.RNG;

package body Nrf51_Hal.RNG  is

   function Read return HAL.UInt8 is
      use HAL;
      use nRF51_SVD.RNG;
   begin
      --  Clear event
      RNG_Periph.EVENTS_VALRDY := 0;

      --  Start random numnber generator
      RNG_Periph.TASKS_START := 1;

      while RNG_Periph.EVENTS_VALRDY = 0 loop
         null;
      end loop;

      return RNG_Periph.VALUE.VALUE;
   end Read;
end Nrf51_Hal.RNG;
EOF

cd ..

cd my_application
cat <<EOF > src/my_application.adb
with Ada.Text_IO;
with Nrf51_Hal.RNG;

procedure My_Application is
begin

   for X in 1 .. 10 loop
      Ada.Text_IO.Put_Line ("Hello World!" &
                              Nrf51_Hal.RNG.Read'Img);
   end loop;
end My_Application;
EOF
alr build
qemu-system-arm -nographic -no-reboot \
                -semihosting -M microbit \
                -kernel bin/my_application
