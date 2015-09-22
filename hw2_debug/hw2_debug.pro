;Debugging Homework


;Fixed 'endfr' typo and added '-1' to the index term
pro error1
   x=findgen(10)
   for i=0,n_elements(x)-1 do begin
       print, x[i]
   endfor
end


;Reintroduced several vowels into the code and made 'hello' into a string.
pro error2
   print, 'hello'
end


;Changed function into procedure since it doesn't take an
;argument and fixed variable assignment.
pro error3
   a = 'ed '
   b = 'is '
   c = 'a girl?'
   result = a + b + c
   print, result
end

;Made x's contents into strings so z is all one type and doesn't error.
pro error4
   x = ['1', '2', '3']
   y = ['a', 'b', 'c']
   z = [x, y]
end



;Changed '=' to 'EQ', changed incorrect end statements, and fixed typos.
pro error5
   x = findgen(100, 100)
   s = size(x)
   for i = 0, s[1] do begin
      for j = 0, s[2] do begin
         if (i + j EQ 90) then begin
            x[i,j] = 0
         endif
      endfor
   endfor
   for i = 0, s[1] - 1 do begin
      for j = 0, s[2] - 1 do begin
         if i + j > 45 then begin
            x[i,j] = i + j
         endif
      endfor
   endfor
   print,x
end
































































































;There are no easter eggs down here, go away.










































;The solution to Homework 2 can be found at...




































































;Haha, got ya
