;-----------------------
;--Tutorial 8: Math 54--
;-----------------------

function x_vector
  readcol, 'data.dat', x, y
  xprime = []
  for i=0,n_elements(x)-1 do xprime = [[xprime], [x[i], 1]]
  return, xprime
end

function y_vector
  readcol, 'data.dat', x, y
  return, y
end

function find_coeffs, x_p, y
  x_t = transpose(x_p)
  interior_of_inv = x_t ## x_p
  inv = invert(interior_of_inv)
  final = inv ## x_t ## y
  return, final
end

function regress, x_p, A
  final = x_p ## A
  return, final
end

pro main
  readcol, 'data.dat', x, y
  x_prime = x_vector()
  A = find_coeffs(x_prime, y)
  y_prime = regress(x_prime, A)
  
  psopen, 'best_fit_rkarim.ps', /encapsulated, /color
  plot, [0, 399], [0, y_prime[399]], /nodata, $
        TITLE='y=mx+b', xtitle='X Values', ytitle='Y Values'
  oplot, x, y, color=!green, psym=4
  oplot, x, y_prime, color=!blue
  
  psclose
end


pro debug
  x_p = x_vector()
  a = find_coeffs(x_p, y_vector())
;  print, a
;  print, '--------------------------------------------------'
;  print, n_elements(a)
;  print, '--------------------------------------------------'
  b = regress(x_p, a)
  print, [x_p, b]
  print, '--------------------------------------------------'
end
