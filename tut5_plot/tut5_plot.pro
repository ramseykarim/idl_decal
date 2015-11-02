; My plot! :)

;;;Nice job. Looks creepy in the window without any title or circle.

pro smiley
; Initial x values
  circx = findgen(200.0)/100 - 1

psopen, 'tut5_plot_ps.eps', /encapsulated, /color

; Face! Circle split into positive and negative halves,
;   all plot/axis settings dealt with here
  circy1 = sqrt(1 - (circx)^2)
  circy2 = -sqrt(1 - (circx)^2)
  plot, circx, circy1, $
        TITLE='Hell yeah', CHARSIZE=2, XRANGE=[-1.0, 1.0], $
        YRANGE=[-1.0, 1.0], /ISOTROPIC
  oplot, circx, circy2

; Loading a 'spectrum' color scheme
  loadct, 6

; Mouth! Semicircle, so negative half of a smaller circle
  semicirc = -sqrt(0.75^2 - (circx[25:175])^2)
  oplot, circx[25:175], semicirc, COLOR=70

; Eyes! Four graphs, two ellipses split into positive and negative halves
  lefteye1 = 0.2*sqrt(1 - (round(100*(circx[90:110]^2)/0.01)*0.01)) + 0.1
  lefteye2 = -0.2*sqrt(1 - (round(100*(circx[90:110]^2)/0.01)*0.01)) + 0.1
  righteye1 = 0.2*sqrt(1 - (round(100*(circx[90:110]^2)/0.01)*0.01)) + 0.1
  righteye2 = -0.2*sqrt(1 - (round(100*(circx[90:110]^2)/0.01)*0.01)) + 0.1
  oplot, circx[65:85], lefteye1, COLOR=150
  oplot, circx[65:85], lefteye2, COLOR=150
  oplot, circx[115:135], righteye1, COLOR=150
  oplot, circx[115:135], righteye2, COLOR=150

; Nose! Parabola
  nose = 20.0*circx[90:110]^2 - 0.35
  oplot, circx[90:110], nose, COLOR=180

  psclose
end
