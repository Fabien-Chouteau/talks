---
author:
- Fabien Chouteau
title: Get Started with Open Source Formal Verification
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

## What is Formal Verification?

the act of proving or disproving the correctness of intended algorithms [...]
using formal methods of mathematics [^1]

[^1]: [https://en.wikipedia.org/wiki/formal_verification](https://en.wikipedia.org/wiki/formal_verification)

## An example

```c
y = 10 / (x - 10);
```

## An example

```c
y = 10 / (x - 10);
```

```c
x - 10 != 0
```

## An example

```c
y = 10 / (x - 10);
```
```c
x - 10 != 0
```
```c
x != 10
```

## An example

```c
if (x != 10) {
  y = 10 / (x - 10);
} else {
  y = 42;
};
```

## Spot the bugs

```c
float * compute (int * tab, int size) {

   float tab2 [size];
   float * result;

   for (int j = 0; j <= size; ++j) {
	   tab [j] = tab2 [j] / 10;
   }

   result = tab2;
   return result;
}
```

##

![](images/SPARK.svg)

## SPARK - The Automatic Proof Toolkit

![](images/gnatprove_flow.png)

## SPARK - The language

![](images/wait_its_ada.jpg)

## Why a subset of Ada?

```Ada
type Percentage is new Float range 0.0 .. 1.0;
```

## Why a subset of Ada?

```Ada
type Stack is private;

function Is_Empty (S : Stack) return Boolean;
function Is_Full (S : Stack) return Boolean;

procedure Push (S : in out Stack; Value : Natural)
  with Pre  => not Is_Full (S),
       Post => not Is_Empty (S);

```

## Why should I care about SPARK?

 - No vulnerabilities for __any__ possible inputs
 - Proof of functional correctness
 - Avoid some of the testing efforts

NVIDIA Security Team [^2]:

 - "Testing security is pretty much impossible"
 - "provability over testing as a preferred verification method"
 - "let's focus on other areas of security"

[^2]: https://www.adacore.com/papers/nvidia-adoption-of-spark-new-era-in-security-critical-software-development

# Let's prove!

## Download and install Alire

\columnsbegin
\column{.53\textwidth}

![](images/alire_logo.png)

\column{.47\textwidth}

Download the Alire package manager from:
[https://alire.ada.dev](https://alire.ada.dev)

\columnsend


## Start a new crate
```console
$ alr init --bin lets_prove
lets_prove initialized successfully.
```
```console
$ cd lets_prove
```

## Add gnatprove dependency
```console
$ alr with gnatprove
```

## Add some code

In `src/lets_prove.adb`:
```ada
with Ada.Text_IO;

procedure Lets_Prove
with SPARK_Mode
is
   X : constant Integer := Integer (Ada.Text_IO.Col);
   Y : Integer;
begin
   Y := 10 / (X - 10);

   Ada.Text_IO.Put_Line (Y'Img);
end Lets_Prove;
```

## Run gnatprove

```console
$ alr gnatprove
Phase 1 of 2: generation of Global contracts ...
Phase 2 of 2: flow analysis and proof ...

lets_prove.adb:9:12: medium: divide by zero might fail
    9 |   Y := 10 / (X - 10);
      |        ~~~^~~~~~~~~~
Summary logged in gnatprove.out
```

## With counter examples
```console
$ alr gnatprove --counterexamples=on
Phase 1 of 2: generation of Global contracts ...
Phase 2 of 2: flow analysis and proof ...

lets_prove.adb:9:12: medium: divide by zero might fail
    9 |   Y := 10 / (X - 10);
      |        ~~~^~~~~~~~~~
  e.g. when X = 10
Summary logged in gnatprove.out
```

## Fix the code

```ada
with Ada.Text_IO;

procedure Lets_Prove
with SPARK_Mode
is
   X : constant Integer := Integer (Ada.Text_IO.Col);
   Y : Integer;
begin
   if X /= 10 then
      Y := 10 / (X - 10);
   else
      Y := 42;
   end if;

   Ada.Text_IO.Put_Line (Y'Img);
end Lets_Prove;
```

## Run gnatprove again

```console
$ alr gnatprove
Phase 1 of 2: generation of Global contracts ...
Phase 2 of 2: flow analysis and proof ...
Summary logged in gnatprove.out
```

That's it you just proved your first program!

## Resources

![](images/learn_spark_screenshot.png)

## The answer

![](images/7_potential_bugs.png)
