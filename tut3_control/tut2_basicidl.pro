;..........................
; some functions for y'all.
;..........................

;Converts degrees to radians
function d_t_r, d
  ;Conversion factor is pi/180
  r = d * 3.1415926535 /180
  return, r
end

;Converts radians to degrees
function r_t_d, r
  ;Converson factor is 180/pi
  d = r * 180/3.1415926535
  return, d
end

;Calculates your weight on Mars given your mass
function weight_of_mars, m
  a = 3.75
  f = m*a
  n_t_p = 0.224808943
  w = f*n_t_p
  return, w
end

;Calculates tip, tip per person, and total bill
pro tip_calc, check, group
  tip = check * 0.15
  bill = check * 1.15
  tip_per_person = tip/group
  print, 'Tip: ' + STRING(tip)
  print, 'Tip per person: ' + STRING(tip_per_person)
  print, 'Total: ' + STRING(bill)
end

;Reassigns variables
pro swap_em, a, b
  c = b
  b = a
  a = c
end

;Finds nth root of a and accounts for some errors
function nth_root, n, a
  if size(n, /TYPE) EQ 7 or size(a, /TYPE) EQ 7 then begin
     print, 'Wrong data type'
  endif else begin
    if n LT 0 then begin
       print, 'Input is negative. Dont do that'
    endif else begin
       if n EQ 0 then begin
          print, 'Zeroth root does not exist'
       endif else begin
          x = a^(1.0/FLOAT(n))
          return, x
       endelse
    endelse
  endelse
end
