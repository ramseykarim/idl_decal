;---------------
; Cats fits file
;---------------

;;;LATE -20

;Basic distance formula for later use

function dist, a, b
  x1 = a[0]
  x2 = b[0]
  y1 = a[1]
  y2 = b[1]
  dx = x2 - x1
  dy = y2 - y1
  d = sqrt(dx^2 + dy^2)
  return, d
end




; This will return the LOCATION of the nearest cat



function min_dist, x, y, catlcts
  click = [x, y]
  distances = []
  for i=0,3 do distances = [distances, dist(catlcts[*, i], click)]
  cat_loc = catlcts[*, where(distances EQ min(distances))]
  return, cat_loc
end


;I just want this defined for my own use. The next function inclues it too.
function which_cat, lct, catlcts, catnames
  cat = where(catlcts[0, *] EQ lct[0])
  return, cat
end



function whats_my_name, lct, catlcts, catnames
  cat = where(catlcts[0, *] EQ lct[0])
  return, catnames[cat]
end

function colorzoom, catnumber, catboxes
  return, catboxes[*, *, catnumber]
end

function better_half, box_array
  x_extent = n_elements(box_array[*, 0])
  left_half = box_array[0:(x_extent/2)-1, *]
  right_half = box_array[(x_extent/2):*, *]
  bright_half = right_half * 1.33
  whole_thing = [left_half, bright_half]
  return, whole_thing
end



;This procedure is unfortunately necessary to define variables,
;start up the fits image, and run the functions because apparently
;we can't do ANYTHING in a .pro file without putting it INTO a procedure

pro do_the_thing
  KIT1LOC = [150, 400]
  KIT2LOC = [700, 700]
  KIT3LOC = [600, 300]
  KIT4LOC = [1000, 600]
  KIT1NAME = 'Molly'
  KIT2NAME = 'Mary'
  KIT3NAME = 'Mike'
  KIT4NAME = 'Malakai' ;;;Why are these hard coded????? Use the deader. -5

  LOCS = [[KIT1LOC], [KIT2LOC], [KIT3LOC], [KIT4LOC]]
  NAMES = [KIT1NAME, KIT2NAME, KIT3NAME, KIT4NAME]

  loadct, 0
  img=mrdfits('idl_image.fits', 0, hdr) ;;;This file path isnt right. -5
  display, img, TITLE='Cats', charsize=1.5

  KIT1BOX = img[0:300, 280:550]
  KIT2BOX = img[470:770, 410:680]
  KIT3BOX = img[520:820, 210:480]
  KIT4BOX = img[700:1000, 360:630]
  BOXES = [[[KIT1BOX]], [[KIT2BOX]], [[KIT3BOX]], [[KIT4BOX]]]

  
  cursor, Xc, Yc, /WAIT
;  print, 'Our location is: ', Xc, Yc
  distance_to_cat = min_dist(Xc, Yc, LOCS)
;  print, distance_to_cat
  our_cat_number = which_cat(distance_to_cat, LOCS, NAMES)
  our_cat = whats_my_name(distance_to_cat, LOCS, NAMES)
;  print, 'THIS IS ', our_cat
  loadct, 1
  our_cat_zoom = colorzoom(our_cat_number, BOXES)
  print, our_cat_number
  our_better_cat = better_half(our_cat_zoom)
  display, our_better_cat, $
           TITLE='THIS IS YOUR CATt NOW', charsize=2
  sxaddpar, hdr, 'REASON', 'This cat is way chill'
  sxaddpar, hdr, 'KITNAME', our_cat
  mwrfits, our_better_cat, 'pretty_kitty.fits', hdr, /create
end

