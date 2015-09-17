;..........................
; some functions for y'all.
;..........................

function d_t_r, d
  r = d * 3.1415926535 /180
  return, r
end

function r_t_d, r
  d = r * 180/3.1415926535
  return, d
end

function weight_of_mars, m
  a = 3.75
  f = m*a
  n_t_p = 0.224808943
  w = f*n_t_p
  return, w
end

pro      tip_calc, check, group
  tip = check * 0.15
  bill = check * 1.15
  tip_per_person = tip/group
  print, 'Tip: ' + STRING(tip)
  print, 'Tip per person: ' + STRING(tip_per_person)
  print, 'Total: ' + STRING(bill)
end

pro      swap_em, a, b
  c = b
  b = a
  a = c
end

function nth_root, n, a
  x = a^(1.0/FLOAT(n))
  return, x
end

