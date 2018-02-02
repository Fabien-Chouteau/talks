with Ada.Text_IO; use Ada.Text_IO;

procedure Servo_Driver 
  with SPARK_Mode
is

   type Servo_Angle is range -90 .. 90
     with Size      => 8,
          Alignment => 16;

   subtype Safe_Range is Servo_Angle range -45 .. 10;
   
   procedure Set_Angle (Angle : Servo_Angle) is
   begin
      Put_Line ("Angle set to:" & Angle'Img);
      if Angle in Safe_Range then
         Put_Line ("Is in safe range");
      end if;
   end Set_Angle;

   procedure Set_Angle_Double (X : Servo_Angle) is
   begin
      Set_Angle (X * 2);
   end Set_Angle_Double;

   procedure Set_Angle_Catch (X : Servo_Angle) is
   begin
      Set_Angle (X * 2);
   exception
      when Constraint_Error =>
         Put_Line ("Well, that was close");
   end Set_Angle_Catch;

begin

   Set_Angle (-5);

   --  Set_Angle (100);
   
   Set_Angle_Catch (80);

   Set_Angle_Double (80);
end Servo_Driver;
