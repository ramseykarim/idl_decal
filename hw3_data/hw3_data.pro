;------------------
;------ HW 3 ------
;------------------

;----------------------------------------------
; This is the centroid code from Tutorial 4
; It, for some reason, needs to be placed before the new code

function find_highest_three, arr

; This compares every value to the values next to it
  diff0 = arr - shift(arr, 1)
  diff1 = arr - shift(arr, -1)
  peak = where(diff0 GT 0 and diff1 GT 0)
  peakvals = []

; Make an array of values to go with the array of indices
  for i=0,n_elements(peak)-1 do begin
     peakvals = [peakvals, arr[peak[i]]]
  endfor
  highest3 = []

; Pick out the three highest peak values and return their indices in
;  an array
  while n_elements(highest3) LT 3 do begin
     maxpeak = max(peakvals)
     highest3 = [highest3, where(arr EQ maxpeak)]
     peakvals = peakvals[where(peakvals NE maxpeak)]
  endwhile
  return, highest3
end

; This function takes an array of values and a single peak index and
;  finds the peak region, or the entire body of the peak. It returns
;  the indices corresponding to the beginning and end of the peak
;  region in a 2-element array.
function peak_group, arr, peak

; Find average of array and set both return indices to the peak index.
  avg_arr = total(arr)/float(n_elements(arr))
  startind = peak
  endind = peak

; Go both forwards and backwards through the array starting at the
;  peak and save the indices at which the values finally hit the
;  average again.
  while arr[startind] GT avg_arr do begin
     startind = startind - 1
  endwhile
  while arr[endind] GT avg_arr do begin
     endind = endind + 1
  endwhile
  return, [startind, endind]
end

; This function finds a single centroid of a peak region given
;  an entire array and a peak. It utilizes the peak_group 
;  function from above.
function find_centroid, arr, peak
  st_end = peak_group(arr, peak)

; Split up peak_group return indices
  startind = st_end[0]
  endind = st_end[1]
  arr_weighted =[]

; Create a weighed array of (values x indices)
  for i=startind, endind do begin
     arr_weighted = [arr_weighted, float(arr[i-1]*i)]
  endfor

; Total it, divide by the value total in the same range, chillin'
  centroid = total(arr_weighted)/total(arr[startind : endind])
  return, centroid
end

function find_three_centroids, arr

; Use my highest3 function to find the highest three peaks in the
;  array.
  highest3 = find_highest_three(arr)

; For each peak, find the centroid of the peak region using find_centroid
  centroids = []
  for i=0,2 do begin
     centroids = [centroids, find_centroid(arr, highest3[i])]
  endfor

; Sort and round the results for readability and functionality as
;  indices
  centroids = round(centroids[sort(centroids)])

; Returns a 3-element array of the indices of the centroids
  return, centroids
end

;-------------------
;-------------------
;--- HW 3 CODE -----
;-------------------
;-------------------

; Loads spectra.txt and skips to the data, returning a 2D array
function load_spec
  readcol, 'spectra.txt', skipline=17, x, y
  return, [[x], [y]]
end

; Procedure to graph the spectral data and overlay the centroids
pro graphit
  spectra = load_spec()
  specy = spectra[*, 1]
  centroids = find_three_centroids(specy)
  plot, spectra[*, 0], spectra[*, 1], TITLE='Spectra', $
        XTITLE='Pixel Number', YTITLE='Signal (ADU)', $
        XRANGE=[0, 2048], YRANGE=[0, 4000], BACKGROUND=255, COLOR=0
  loadct, 2
  for i=0,2 do begin
     oplot, [centroids[i], centroids[i]], [0, 4000], $
            COLOR=35, LINESTYLE=2
  endfor
end


; Creates Gaussian distribution y values given an array of x values,
;  a standard deviation, and a mean.

function gaussian, xrange, sigma, mu

; Stops IDL from throwing the completely harmless 'floating underflow'
;  error, since the normalized gaussian deals with some numbers
;  very close to zero.

  !EXCEPT = 0
  constant = 1.0/(sigma * sqrt(2.0 * !pi))
  exponent_top = (xrange - mu)^2.0
  exponent_bottom = 2.0 * (sigma^2.0)

; System variables under '!CONST' are *not* defined by default...

  euler = 2.7182818284590452
  exponent = -(exponent_top/exponent_bottom)
  return, constant * (euler ^ exponent)
end

pro gaussplot
  
; Set up x values and characteristics of the three Gaussian distributions
  x = (findgen(120)-60)/10
  sigma1 = 0.5
  sigma2 = 0.45
  sigma3 = 0.7
  mu1 = -3.6
  mu2 = 0
  mu3 = 3

; Set up 3 distributions
  y1 = gaussian(x, sigma1, mu1)
  y2 = gaussian(x, sigma2, mu2)
  y3 = gaussian(x, sigma3, mu3)

; Add the three distributions and find the centroid of that data
  ytot = y1 + y2 + y3
  centroids = find_three_centroids(ytot)

; Plot everything
  plot, [x[0], x[n_elements(x)-1]], [0, 0], $
        TITLE='GAUSSIAN DISTRIBUTIONS', CHARSIZE=1.5, $
        XTITLE='VALUE', YTITLE='PROBABILITY'
  loadct, 2
  oplot, x, y1, COLOR=150, PSYM=10
  oplot, x, y2, COLOR=70, PSYM=10
  oplot, x, y3, COLOR=220, PSYM=10
  for i=0,2 do begin
     oplot, [x[centroids[i]], x[centroids[i]]], [0, 1], $
            COLOR=35, LINESTYLE=2
  endfor
end

