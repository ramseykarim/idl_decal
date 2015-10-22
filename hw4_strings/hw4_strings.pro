; !!!!!!!!!!!!!!!!!!!!!!!!!
; !!!!!!!!!!!!!!!!!!!!!!!!!
; !!!String manipulation!!!
; !!!!!!!!!!!!!!!!!!!!!!!!!
; !!!!!!!!!!!!!!!!!!!!!!1!!

pro getaclue
  readcol, 'clues.txt', skipline=0, a, FORMAT='A'
  mystring = [strlowcase(strmid(a[0], 0, 1))]
  for i=0,n_elements(a)-1 do begin
     if strmatch(a[i], '*og*') EQ 1 then begin
        og_pos = strpos(a[i], 'og')
        mystring = [mystring, strmid(a[i], og_pos, 2)]
     endif
  endfor
  mystring = [mystring, '_']
  for i=0,n_elements(a)-1 do begin
     if strmatch(a[i], '*ate*') EQ 1 then begin
        p_pos = strpos(a[i], 'p')
        mystring = [mystring, strmid(a[i], p_pos, 3)]
     endif
  endfor
  i=0
  while n_elements(mystring) LT 5 do begin
     if strmatch(a[i], '*x*') EQ 1 then begin 
        mystring = [mystring, strmid(a[i], 0, 2)]
     endif
     i = i + 1
  endwhile
  mystring = strjoin(mystring)
  o_pos = strpos(mystring, 'o', /REVERSE_SEARCH)
  mystring = strmid(mystring, 0, o_pos) + repstr(strmid(mystring, o_pos), 'o')
  print, mystring
end
