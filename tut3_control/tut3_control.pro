;.................
;...Tutorial 3!...
;.................

;First new script
;Takes two integers & prints sqrts of all
; the integers between them in order.
;First input must be smaller than second
; and both must be positive.
pro squares, a, b

  ;Tests for INTEGER type. Type 2 is INTEGER
  if size(a, /TYPE) EQ 2 and size(b, /TYPE) EQ 2 then begin

  ;Test bounds
     if a LT b and a GT 0 then begin

  ;Index between a and b and starting printing some squares
       for i=a, b do print, i^2

     endif else print, 'IMPROPER BOUNDS'

  ;Error if conditions not met
  endif else print, 'IMPROPER INPUT TYPE'

end


;Factorial procedure
;Input must be an ingeger between 1 and 12, inclusive
pro factorial, int

  ;Test input type for INTEGER
  if size(int, /TYPE) EQ 2 then begin

  ;Test bounds
    if int LE 12 and int GE 1 then begin

  ;Sets up factorial product
      fact = 1

  ;Does the multiplication
      for i=int, 1, -1 do fact = i*fact

  ;Prints the total product
      print, fact

    endif else begin

  ;Special cases
      if int EQ 0 then print, 1 else print, 'CANNOT COMPUTE'

    endelse

  endif else print, 'IMPROPER INPUT TYPE'

end

;Generates 1000-element array of random numbers between 1 and 100,
; inclusive
;Returns array containing all of the elements from the first array
; that are greater than 50
function long_where

  ;Generate random array
  array=randomu(seed, 1000)*100

  ;Set up return array
  array_where=[]

  ;Index matches length of generated array
  for i=0, 999 do begin

  ;Build new array
     if array[i] GE 50.0 then array_where = [array_where, array[i]]

  endfor

  return, array_where

end

;Does the same thing as the last one but takes less code
function short_where

  ;Generate random array
  array=randomu(seed, 1000)*100

  ;Just use where
  array_where = array[where(array GE 50.0)]

  ;And then return it
  return, array_where

end
