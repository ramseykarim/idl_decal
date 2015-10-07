;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;find 3 most prominent centroids of spectrum;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; My final answer uses three helper functions that I wrote along the
;  way to avoid having way too much code in one function.

; My method is to find the three highest isolated peak values in the
;  array. This will have to account for high values near a higher peak
;  and ignore them. Then, for each peak, a peak region is found; this
;  is approximately the body of the entire peak. The centroid of this
;  peak region serves as the centroid of the peak.


; This function finds the highest three peaks by first finding all the
;  places where a value was larger than the values on both sides and
;  then picking out the largest three peak values. The method of 
;  finding all the peaks came from code I found on the UCB Astro
;  website, and that is the only idea I borrowed for this project.

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

;----------------------------------
;----------------------------------
;------ This is my answer! --------
;----------------------------------
; It relies on the code above, so it all must be kept together,
;  but it returns values very very close to the peaks.

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


; End of answer



; This one was my first try and I spent a long time on it and don't
;  want to delete it :'(
; The problem with it is that it assumes the peaks are rather evenly
;  distributed and are of very comparable widths. It also assumes that
;  the noise is negligible and even.
; However, this is not the case with our spectral data, so the
;  function isn't great.

; That said, the result is close.

function find_centroids_OLD, arr
  arr_weighted = []
; Create a weighted index array (multipy value by index+1)
  for i=1, n_elements(arr) do begin
     arr_weighted = [arr_weighted, float(arr[i-1]*i)]
  endfor  
; Find one third of total weight
  t1_3 = float(total(arr)/3)
  t2_3 = t1_3*2
; Set up blank index and sum
  ind1 = 0
  sum1 = float(0)
; Find out where each third of the weight is
  while sum1 LT t1_3 do begin
     sum1 = sum1 + arr[ind1]
     ind1 = ind1 + 1
  endwhile
  ind2 = ind1
  sum2 = sum1
  while sum2 LT t2_3 do begin
     sum2 = sum2 + arr[ind2]
     ind2 = ind2 + 1
  endwhile
; Find centroid of each third of the total weight
  cent1 = total(arr_weighted[0 : (ind1 - 1)])/sum1
  cent2 = total(arr_weighted[ind1 : (ind2 - 1)])/(sum2 - sum1)
  cent3 = total(arr_weighted[ind2 : *])/(total(arr) - sum2)
; Round results so they can function as indices
  cents = [round(cent1), round(cent2), round(cent3)]
  return, cents
end
