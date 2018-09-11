;
begin
;
x = fspan(0.27,0.96,203)
;
do i = 0,dimsizes(x)-1
  print("(/"+x(i)+","+x(i)+","+x(i)+"/), \")
end do
;
end
