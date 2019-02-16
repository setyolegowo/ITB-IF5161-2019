;Phil Klahs
;Istvan Karsai
;2012
;Game Example



globals[
  red-population
  black-population
  total 
  new-state
  ]

patches-own[
  state
  ]


to setup
  clear-all
  setup-board  
  reset-ticks
end

to go
  ifelse(red-population = 0 or black-population = 0)[
     stop                                                    ; Stop procedure if either population goes to zero
  ]                                                          ; this prevents errors in cases when the program would
  [                                                          ; be trying to find a colored patch that is not there                                                          
     patch-death
     patch-birth
     color-patches
  ] 
  
  tick
end





to patch-death
  if (death-strategy = 3)[negative-death-strategy]             ; this section directs the program to the death-strategy
  if (death-strategy = 2)[neutral-death-strategy]              ; that you choose with the slider "death-strategy"
  if (death-strategy = 1)[positive-death-strategy]

end

to negative-death-strategy
  let dice (random-float total)
  ifelse (dice < red-population)[
    ask n-of 1 patches with [state = 1][
    set black-population (black-population - 1)
    set state 0
    set pcolor white
    ]
  ]
  [
    ask n-of 1 patches with [state = 2][
    set red-population (red-population - 1)
    set state 0
    set pcolor white
    ]
  ]
  
end

to neutral-death-strategy
  let dice (random-float 1)
  
  ifelse (dice < .5)[
    ask n-of 1 patches with [state = 1][
    set black-population (black-population - 1)
    set state 0
    set pcolor white
    ]
  ]
  [
    ask n-of 1 patches with [state = 2][
    set red-population (red-population - 1) 
    set state 0
    set pcolor white  
    ]
    
  ]
  
end

to positive-death-strategy
  ask n-of 1 patches with [pcolor != grey][
    
     ifelse (state = 1)[
       set black-population (black-population - 1)
     ]
     [
       set red-population (red-population - 1)
     ]
      
       set state 0
       set pcolor white
  ]  
  
end





to patch-birth
  if (birth-strategy = 1)[negative-birth-strategy]             ; this section directs the program to the birth-strategy
  if (birth-strategy = 2)[neutral-birth-strategy]              ; that you choose with the slider "birth-strategy"
  if (birth-strategy = 3)[positive-birth-strategy]
  
end

to negative-birth-strategy
  let dice (random-float total)
   
  ifelse (dice < red-population)[
     set new-state 1
     set black-population (black-population + 1)
  ]
  [
     set new-state 2
     set red-population (red-population + 1)
  ]
  
end

to neutral-birth-strategy
  let dice (random-float 1)
  
  ifelse (dice < .5) [
     set new-state 1
     set black-population (black-population + 1)
  ]
  [
     set new-state 2
     set red-population (red-population + 1)
  ]
      
end

to positive-birth-strategy
  ask n-of 1 patches with [state > 0][set new-state state] 
  
      ifelse (new-state = 1)[
         set black-population (black-population + 1)
      ]
      [
         set red-population (red-population + 1)
      ]
  
end
  




to color-patches
  ask patches with [pcolor = white][
    if (state = 0) [set state new-state]
    if (state = 1) [set pcolor black]
    if (state = 2) [set pcolor red]
  ]
end

to setup-board
  ask patches [set state 1 set pcolor black]
 
  set total (Board-length ^ 2)
  let half-total 0
  let half-length 0
  ifelse (total mod 2 = 0)[                                                                        ; We determine if the total is even or odd                             
     set half-total (total / 2)                                                                    ; If it is even then we can easy divide in
     set half-length (Board-length / 2)                                                            ; half to get red and black populations                       
  ]                   
  [
     set half-total ((total / 2) - .5)                                                             ; If total is odd then we remove the decimal
     set half-length ((Board-length / 2) - .5)                                                     ; so that we do not deal with fractions of patches                       
  ]
  set red-population (half-total)
  set black-population (total - half-total)                                                        ; In odd cases we let black have one more than red    
  
                                                      
  ask patches [
     if ((pxcor <= (0 - half-length)) or pxcor > (0 + (Board-length - half-length)) or             ; Here we set everything but the board size chosen 
        (pycor <= (0 - half-length)) or pycor > (0 + (Board-length - half-length)))[               ; by the slider "Board-length" to grey so that
        set state -1                                                                               ; these patches do not affect the model
        set pcolor grey
     ]
  ] 
  ask n-of (half-total) patches with [pcolor = black] [set state 2 set pcolor red]
end
@#$#@#$#@
GRAPHICS-WINDOW
413
27
908
543
50
50
4.802
1
10
1
1
1
0
1
1
1
-50
50
-50
50
0
0
1
ticks
30.0

BUTTON
33
27
97
68
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
99
27
162
68
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
167
27
407
209
Populations
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"set-plot-y-range  0 total" ""
PENS
"default" 1.0 0 -2674135 true "" "plot red-population"
"pen-1" 1.0 0 -16449023 true "" "plot black-population"

MONITOR
69
112
163
157
NIL
red-population
17
1
11

MONITOR
69
163
163
208
NIL
black-population
17
1
11

SLIDER
166
295
406
328
birth-strategy
birth-strategy
1
3
2
1
1
NIL
HORIZONTAL

SLIDER
129
329
162
524
death-strategy
death-strategy
1
3
2
1
1
NIL
VERTICAL

SLIDER
32
73
163
106
Board-length
Board-length
1
100
65
1
1
NIL
HORIZONTAL

TEXTBOX
229
225
379
260
Birth Strategy
20
0.0
1

TEXTBOX
18
350
168
400
Death\nStrategy
20
0.0
1

TEXTBOX
176
232
209
281
_
40
0.0
1

TEXTBOX
276
250
325
293
=
35
0.0
1

TEXTBOX
367
251
403
294
+
33
0.0
1

TEXTBOX
99
309
127
358
_
40
0.0
1

TEXTBOX
95
403
122
446
=
35
0.0
1

TEXTBOX
97
477
126
517
+
33
0.0
1

TEXTBOX
175
341
231
369
  density\ndependant
11
0.0
1

TEXTBOX
260
346
324
364
catastrophe
11
0.0
1

TEXTBOX
343
346
403
364
catastrophe
11
0.0
1

TEXTBOX
175
412
234
430
equillibrium
11
0.0
1

TEXTBOX
271
407
313
435
random \n  walk
11
0.0
1

TEXTBOX
342
413
402
431
catastrophe
11
0.0
1

TEXTBOX
179
492
234
510
equillibrium
11
0.0
1

TEXTBOX
263
492
321
510
equillibrium
11
0.0
1

TEXTBOX
343
482
398
510
  density\ndependant
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

Please cite as:

Klahs, P. and Karsai, I (2014): Population regulation via feedback. Netlogo v. 5.01 simulation. http://ccl.northwestern.edu/netlogo/models/community/Population regulation via feedback.nlogo
 
This is a simple model to demonstrate the effect of feedback on birth and death to population growth. I use this model to teach students on understanding the effect of feedback (positive and negative) on systems.

## HOW IT WORKS

The simulation works with 2 populations (red and black); they die and propagate according to the rules. The agents are not affecting each other directly.
Death is a simple elimination of the individual (make a patch empty).
Birth is a simple occupation of an empty patch.
Feedback is simply coming from the population sizes. For example, if positive birth strategy is implemented, then the population with more individuals has a higher probability to occupy the empty patch. 

## HOW TO USE IT

You set up the size of the arena and the type of feedback for birth and death. For example if both is set to neutral (=) then you will observe random walk of the population sizes. Positive death strategy tends to stabilize the populations and tends
to lead to an equlibrium. On the other hand, positive birth strategy tends to drive the system to chatastrophy: due to the strong positive feedback effect, the population with
less individuals will die out quickly and the population with more individuals will go through an explosive increase.

## THINGS TO NOTICE

Experiment with different setups and follow the fate of the 2 populations. Understand the effect of negative and positive feedback on the populations.

## THINGS TO TRY

Try to run the simulation on different sizes of arena and study the effect of habitat size on stability of populations.

## EXTENDING THE MODEL

The model is deliberately oversimplified. The main goal of this model to teach the effect of feedback on a simple system. Our more complicated 2 populations model can be found here: http://ccl.northwestern.edu/netlogo/models/community/HabitatFragmentation


## NETLOGO FEATURES

See notes in the code for details

## RELATED MODELS

This model is inspired by the book of Eigen and Winkler: Das Spiel: Naturgesetze steuern den Zufall.

## CREDITS AND REFERENCES

This model was described and analysed in detailed in this book:
Zsíros, V. and Karsai, I. (1997). Death and Life, Randomity and Rule: Modeling some  Fundamental Biological Mechanisms. Synbiologia Hungaria 3, Scientia, Budapest. (in Hungarian).

Eigen, M. and Winkler, R. (1975). Das Spiel: Naturgesetze steuern den Zufall, ISBN-13: 978-3492021517 Piper. pp. 403. (in German).
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -7500403 true true 135 285 195 285 270 90 30 90 105 285
Polygon -7500403 true true 270 90 225 15 180 90
Polygon -7500403 true true 30 90 75 15 120 90
Circle -1 true false 183 138 24
Circle -1 true false 93 138 24

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
