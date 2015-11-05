;--------------------
;---- Tutorial 7 ----
;--------------------



; Set up graphing parameters and graph the given equation

pro perfect_dist
  x = findgen(30)
  y = ((10^x)/(factorial(x)))*(exp(-10))
  loadct, 0
  plot, [0], [0], XRANGE=[0,30], YRANGE=[0, 0.14], $
        XTITLE='Location', YTITLE='Count', TITLE='MCMC distributions', $
        CHARSIZE=1.2, COLOR=0, BACKGROUND=255
  loadct, 2
  oplot, x, y, PSYM=10, COLOR=100
end


; Simple if-then-else returning 3 element arrays

function prob_test, xi
  if xi LE 9 then begin
     return, [(xi/20.0), ((10.0-xi)/20.0), 0.5]
  endif else begin
     return, [0.5, ((xi-9.0)/(2.0*(xi+1))), (5.0/(xi+1))]
  endelse
end


; Picks a number between -1 and 1 (-1=left, 0=stay, 1=right)
; Uses the fact that randomu(seed) generates a number from 0 to 1,
; and the probabilities sum to 1

function step_decide, p
  sum = 0
  rand = randomu(seed)
  for i=0,2 do begin
     sum = sum + p[i]

; When the random number is less than or equal to the sum, return the
; index - 1 so that we can just add this result to xi to get x(i+1)
     if rand LE sum then begin
        return, i-1
     endif
  endfor
end


; Iterates through the steps and returns a record of where it has
; stepped

pro main, x0, s

; Check data types to make sure they are integers, stop and throw
; error if not
  if size(x0, /TYPE) NE 2 or size(s, /TYPE) NE 2 then begin
     stop, 'Error - Input integer start and step values'
  endif

; Set up iteration parameters and iterate
  xi = x0
  results = [[xi], [1]]
  i = 1
  steplog = [xi]

; Iteration creates a 2D array, the x values carrying the values being
; stepped to, and the y values carrying the number of steps to that
; value
; A steplog array also keeps track of the individual steps
  while i LT s do begin
     xi = xi + step_decide(prob_test(xi))
     existence = where(results[*, 0] EQ xi)
     if existence EQ -1 then begin
        results = [results, [[xi], [1]]]
     endif else begin
        results[existence, 1] = results[existence, 1] + 1
     endelse
     steplog = [steplog, xi]
     i = i+1
  endwhile

; Order the results  
  results_order = sort(results[*,0])
  results_sorted = [[],[]]
  for i=0,n_elements(results_order)-1 do begin
     i_x = results[results_order[i], 0]
     i_y = results[results_order[i], 1]
     results_sorted = [results_sorted, [[i_x], [i_y]]]
  endfor
  results = results_sorted

; Normalize the results
  results = float(results)
  results[*, 1] = results[*, 1]/float(s)

; Overplot the results; we are assuming the equation has already been plotted
  loadct, 1
  oplot, results[*,0], results[*,1], PSYM=10, COLOR=180

; Now plot the steps
  loadct, 0
  plot, [0], [0], XRANGE=[0, s], YRANGE=[0, 25], $
        TITLE='Steps Taken', CHARSIZE=1.2, COLOR=0, $
        XTITLE='Step number', YTITLE='Value', BACKGROUND=255
  loadct, 2
  oplot, findgen(s), steplog, COLOR=35
end


; Utilizes the fact that both procedures are graphing procedures, so
; we just need to call both with the plotting window set to carry two
; plots

pro mcmc, start, steps
  !P.MULTI = [0, 1, 2]
  perfect_dist
  main, start, steps
end
