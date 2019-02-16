globals [ grass
   gini-index-reserve
  lorenz-points ]

breed [ apersons aperson ]
breed [ bpersons bperson ]

patches-own [ grass-amount ]

turtles-own [
  resource ;; the amount of resource this person has
  age ;; the current age of this person (in ticks)
  max-age ;; the age at which this person will die of natural causes

]

to setup
  clear-all
  create-apersons apersons-initial-population [ setup-apersons ]
  create-bpersons bpersons-initial-population [ setup-bpersons ]
  ask patches [
    set grass-amount random-float 10.0 ;; each patch starts with a random amount of grass
    recolor-grass ] ;; color it shades of green
  set grass count patches with [ grass-amount > 0 ]
  update-lorenz-and-gini

  reset-ticks
end

to go
  if not any? turtles [ stop ]
  ask turtles [
   move
   harvest
   if resource >= 5
     [ share ] ;; share with a number of neighbors
   reproduce
   set age age + 1
   if resource < 0 or age > max-age
    [die]
    ]
 regrow-grass
 set grass count patches with [ grass-amount > 0 ]
 update-lorenz-and-gini
 tick
end


;;-----------------
;; TURTLE UPDATES
;;-----------------


to setup-apersons ;; apersons procedure
  set color magenta  ;; how to color? Shades of a color?
  set shape "person"
  set size 1.25;; easier to see
  setxy random-xcor random-ycor ;;population- what other ways to do this?? where do I want my persons to be?
  set age 0
  set max-age random-float 100
  set resource 10
 end

to setup-bpersons ;; bpersons procedure
  set color orange
  set shape "person"
  set size 1.25;; easier to see
  setxy random-xcor random-ycor ;;population- what other ways to do this?? where do I want my persons to be?
  set age 0
  set max-age random-float 100
  set resource 10
 end

;;---------------
;; GO PROCEDURES
;;---------------

to move ;; how to model migration with vision (high vision for migrators/lower for non?);; make quadrants with different growback rates for seasons?
  ifelse breed = apersons
  [ move-apersons ][
  if breed = bpersons
  [ move-bpersons ] ]
end

 to move-apersons
    let target max-one-of patches [ grass-amount ]
    face target
    move-to target
    set resource resource - 1
end

 to move-bpersons
   let target max-one-of neighbors4 [ grass-amount ]
    face target
    move-to target
    set resource resource - 1
end
;;set vision (patches with [ grass-amount > .25
  ;;     ] in-radius bperson-vision)

to harvest
  ifelse breed = apersons
   [ harvest-apersons
] [
   if breed = bpersons
   [ harvest-bpersons
] ]
end

to harvest-apersons  ;; eat-cooperative from cooperation model and GL
  if grass-amount > 5
  [ let harvest-amount grass-amount * 0.50
    set grass-amount grass-amount - harvest-amount
    set resource resource + harvest-amount ]
   recolor-grass
   end

to harvest-bpersons  ;; eat-greedy from cooperation model and GL
  if grass-amount > 0 [
    let harvest-amount grass-amount * 1
    set grass-amount grass-amount - harvest-amount
    set resource resource + harvest-amount ]
   recolor-grass
 end

to share
 ifelse breed = apersons [ share-apersons ]
[ if breed = bpersons [ share-bpersons ]
]
end

to share-apersons ;;modified from diffusion on a directed network model
   let recipients apersons in-radius 3 ;; larger radius to suggest more egalitarian, but what if no one from breed in radius? directed link network a better guarantee
   if any? recipients [ ask recipients [ set resource resource + ( apersons-share-amount / count recipients ) ] ]
   set resource resource - apersons-share-amount
 end

to share-bpersons ;; modified from diffusion on a directed network model
   let recipients bpersons in-radius 1
   if any? recipients [ ask recipients [ set resource resource + ( bpersons-share-amount / count recipients ) ] ]
   set resource resource - bpersons-share-amount
 end

to reproduce;;certain age and amount of resource range needed for reproduction; also add sex and neighbor component?
  ifelse breed = apersons [ reproduce-apersons ]
  [ if breed = bpersons [ reproduce-bpersons ]
  ]
  end

to reproduce-apersons ;; must modify reproduction - look at % reproduction in wolf sheep predation model
   if age >= 15 and age <= 40 ;; and last_reproduced < current_tick - 4
     [ hatch random (apersons-number-offspring) [
      setup-apersons ] set resource resource / apersons-number-offspring]

 end

to reproduce-bpersons
  if age >= 15 and age <= 40;; and (last_reproduced < current_tick - 4
       [ hatch random (bpersons-number-offspring) [
      setup-bpersons ] set resource resource / bpersons-number-offspring]

 end
;;-------------------
;; PATCH UPDATES
;;-------------------

to regrow-grass
  ask patches [
    set grass-amount grass-amount + 0.01
    if grass-amount > 10 [
      set grass-amount 10
    ]
recolor-grass
  ]
end

to recolor-grass
  set pcolor scale-color green grass-amount 0 20
end


;;-------------------------------------
;; MONITORING AND REPORTING PROCEDURES
;;-------------------------------------


to-report resource-fraction ;; GL, feeding example. the math
  let possible-resource (count patches) * 10
  let total-resource sum [ grass-amount ] of patches
  report total-resource / possible-resource
end

to update-lorenz-and-gini
  let num-people count turtles
  let sorted-wealths sort [resource] of turtles
  let total-wealth sum sorted-wealths
  let wealth-sum-so-far 0
  let index 0
  set gini-index-reserve 0
  set lorenz-points []
  repeat num-people [
    set wealth-sum-so-far (wealth-sum-so-far + item index sorted-wealths)
    set lorenz-points lput ((wealth-sum-so-far / total-wealth) * 100) lorenz-points
    set index (index + 1)
    set gini-index-reserve
      gini-index-reserve +
      (index / num-people) -
      (wealth-sum-so-far / total-wealth)
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
649
470
16
16
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

SLIDER
7
131
205
164
apersons-initial-population
apersons-initial-population
0
1000
383
1
1
NIL
HORIZONTAL

SLIDER
7
175
206
208
bpersons-initial-population
bpersons-initial-population
0
1000
0
1
1
NIL
HORIZONTAL

BUTTON
11
63
75
96
NIL
Setup\n
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
94
64
157
97
NIL
Go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
2
218
206
251
apersons-share-amount
apersons-share-amount
0
10
5
1
1
NIL
HORIZONTAL

SLIDER
2
260
208
293
bpersons-share-amount
bpersons-share-amount
0
10
0
1
1
NIL
HORIZONTAL

SLIDER
2
303
206
336
apersons-number-offspring
apersons-number-offspring
0
4
3
1
1
NIL
HORIZONTAL

SLIDER
4
347
205
380
bpersons-number-offspring
bpersons-number-offspring
0
10
0
1
1
NIL
HORIZONTAL

PLOT
657
202
930
424
Population
Time
Population
0.0
100.0
0.0
1000.0
true
true
"" ""
PENS
"Apersons" 1.0 0 -5825686 true "" "plot count apersons"
"Bpersons" 1.0 0 -955883 true "" "plot count bpersons"

MONITOR
658
429
743
474
NIL
count apersons
3
1
11

MONITOR
752
429
836
474
NIL
count bpersons
3
1
11

MONITOR
936
430
1172
475
NIL
count patches with [ grass-amount < 1 ]
3
1
11

PLOT
935
204
1183
422
Resource Amount
Time
% of max
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
" Resource" 1.0 0 -10899396 true "" "plot resource-fraction * 100"

MONITOR
1107
31
1330
76
NIL
count apersons with [ resource > 10\n\n\n ]
17
1
11

MONITOR
1108
94
1331
139
NIL
count bpersons with [ resource > 10\n\n\n ]
17
1
11

PLOT
888
27
1088
177
Lorenz Curve
Pop. %
Wealth %
0.0
100.0
0.0
100.0
false
true
"" ""
PENS
"Equal" 100.0 0 -16777216 true ";; draw a straight line from lower left to upper right\nset-current-plot-pen \"equal\"\nplot 0\nplot 100" ""
"Lorenz" 1.0 0 -2674135 true "" "plot-pen-reset \nset-plot-pen-interval 100 / count turtles\nplot 0\nforeach lorenz-points plot"

PLOT
679
28
879
178
Gini Index vs. Time
Time
Gini
0.0
100.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -13345367 false "" "plot (gini-index-reserve ) / count turtles * 2"

@#$#@#$#@
## WHAT IS IT?

The purpose of the Socio-Natural model is to test which social behaviors
contribute to the resiliency of both culture and environment utilizing comparison between two differing social systems.


## HOW IT WORKS

The Socio-Natural model is made up of two breeds of agents who interact
with the environment and other agents. The environment is a wrapping world made up of patches with a generic resource that have a determined carrying capacity and growth rate assigned at the start of the simulation. For this model one tick or iteration represents one year. Every model should run for at least one-thousand iterations or until population collapse. Population collapse is defined as no more individuals.

The individuals of different breeds possess different land-use, common benefit, and
movement rules. For the A-person breed these rules include: (1) equitable distribution of wealth and resources to provide for common benefit (2) demographic regulation with possible seasonal migration to prevent resource depression (3) utilization of diverse resources to prevent resource depression.

The differing elements of the B-person breed include: (1) unequitable distribution of wealth and resources altering levels of benefit (2) sedentariness and sharp shifts in population (3) skewed resource dependence that effects biodiversity.

At every iteration all individuals (1) move, (2) harvest, (3) share, (4) randomly reproduce based on number of possible offspring, (5) age, and (6) randomly die. The world (7) regrows grass at a fixed amount every iteration.


## HOW TO USE IT

On the left, adjust the sliders to change initial population levels of each breed, to determne how much resource each inidividual of a breed can share, and to decide reproduction rates.

On the right, monitor the population levels of each breed, resource levels in the world, and the distribution of resources. 


## THINGS TO NOTICE

The socio-natural model is interested in certain response variables. These include: (1) How long a population sustains before collapse, if collapse occurs, (2) how stable
population levels are, (3) how much resource is maintained in the world, and (4) how equitably resources are shared.


## THINGS TO TRY

Move sliders to alter how much breeds share, reproduce or to see how initial population effects outcomes.

How long do populations last when they are not competeing against one another?
What does the resource level look like?
How equitable is their society?


## EXTENDING THE MODEL

Advance any of these these settings by altering the code with simple or complex changes.
For example, resource regrowth could be altered to seasonal cycles or change the code to reflect agricultural and technological control over resource cycles.

This socio-natural model is currently a closed system which if opened to simulate immigration, has potential to reveal more interesting resilient behavior relational patterns. Additionally, more diverse resources along with diverse use of those resources would enhance the program. Moreover, introducing a level of diversity and modifying to an open system would produce dynamic resource growth rates, advanced migratory and movement patterns and allow for more socio-natural perturbations to be tested.
 
Another avenue to achieve higher variance in social complexity use of NetLogo’s Hubnet. Hubnet is participatory simulation offering that allows models to run by its programmed rules as well as by human participation. 

The socio-natural model can also be advanced with innovation coding. This can be achieved by either equipping agents with coping mechanisms in the programming stage or including a genetic algorithm in which agents learn.

Future simulations with this modification have the potential to illuminate much about resilient behavior adoption and sustainable development education.


## RELATED MODELS

This model incorporates features from other netlogo models: diffusion on a directed network, cooperation, feeding, and wolf/sheep predation. 

## CREDITS AND REFERENCES

George Lescia

Axtell, Robert L., Joshua M. Epstein, Jeffrey S. Dean, George J. Gumerman, Alan C. Swedlund, Jason Harburger, Shubha Chakravarty, Ross Hammond, Jon Parker, and Miles Parker
2002  Population growth and collapse in a multiagent model of the Kayenta Anasazi in Long House Valley. Proceedings of the National Academy of Sciences 99(suppl 3): 7275–7279.

Dean, Jeffrey S., George J. Gumerman, Joshua M. Epstein, Robert L. Axtell, Alan C. Swedlund, Miles T. Parker, and Stephen McCarroll
  2000  Understanding Anasazi culture change through agent-based modeling. Dynamics in 
  human and primate societies: Agent-based modeling of social and spatial processes: 179–205.

Epstein, Joshua M.
  1996  Growing artificial societies: social science from the bottom up. Brookings Institution 
  Press.

  1997  Artificial societies and generative social science. Artificial Life and Robotics 1(1): 33–34.

  1999  Agent-based computational models and generative social science. Generative Social 
  Science: Studies in Agent-Based Computational Modeling 4(5): 4–46.

  2006  Generative social science: Studies in agent-based computational modeling. Princeton 
  University Press.

  2008  Why model? Journal of Artificial Societies and Social Simulation 11(4): 12.
  Epstein, Joshua M., and Robert Axtell

Gilbert, Nigel, and Klaus G. Troitzsch
  2005  Simulation for the Social Scientist (2nd Edition). McGraw-Hill Professional Publishing,  Berkshire, GBR.

Kohler, Timothy & Sander Van der Leeuw. (Eds.)
  2007 The Model Based Archaeology of Socio-Natural Systems. School for Advanced Research, 
  Santa Fe, NM.

Wilensky, Uri, and William Rand
  2015  An Introduction to Agent-Based Modeling: Modeling Natural, Social, and Engineered  
  Complex Systems with NetLogo. MIT Press, April 10.

Wilensky, U. (1997). NetLogo Cooperation model. http://ccl.northwestern.edu/netlogo/models/Cooperation. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL

Stonedahl, F. and Wilensky, U. (2008). NetLogo Diffusion on a Directed Network model. http://ccl.northwestern.edu/netlogo/models/DiffusiononaDirectedNetwork. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Wilensky, U. (1998). NetLogo Wealth Distribution model. http://ccl.northwestern.edu/netlogo/models/WealthDistribution. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Li, J. and Wilensky, U. (2009). NetLogo Sugarscape 3 Wealth Distribution model. http://ccl.northwestern.edu/netlogo/models/Sugarscape3WealthDistribution. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL

Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Wilensky, U. (2005). NetLogo Wolf Sheep Predation (System Dynamics) model. http://ccl.northwestern.edu/netlogo/models/WolfSheepPredation(SystemDynamics). Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
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
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="OnlyA_Sustainability check at certain population" repetitions="3" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count grass-amount</metric>
    <metric>count apersons</metric>
    <metric>count bpersons</metric>
    <enumeratedValueSet variable="apersons-share-amount">
      <value value="1"/>
      <value value="1"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bpersons-number-offspring">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="apersons-initial-population">
      <value value="322"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="apersons-number-offspring">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bpersons-initial-population">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bpersons-share-amount">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
