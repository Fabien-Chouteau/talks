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
