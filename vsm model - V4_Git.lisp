;;Siyu Wu May 24th 2024, Bosch PA
;revised using Dan's feedback, cancel deterministric, add noise to the utility, change the reward to the result production rules rather than the same ones with utility, delete unneccessary parameter setting, while still keep the weight and blank the same (need further work on this though)

;;This is an ACT-R model to optimize time reduction within assembly sectors. This model has two levels of expertise in decision making, one is novice and one is expert.
;;Here's how expert level will work:
;;Calculate Predicted Defect Rate Increase: The model will first calculate the predicted increase in defect rate for both the pre-assembly and assembly ;;phases after a time reduction using variables of OEE  CT and time.
;;Compare Defect Rate Increases: The model will then compare the predicted defect rate increases for both sections.
;;Choose Optimal Sector: The section with the lower predicted defect rate increase will be identified as the optimal choice for time reduction.


;;ACT-R

(clear-all)

(define-model vsm
;; parameters
;(sgp :seed (10000 100))
(sgp :v t :esc t  :trace-detail low  :MODEL-WARNINGS NIL :ul t :ult t :egs 3)

;chunk-type
(chunk-type decision strategy state time OEE1 OEE2 CT1 CT2)
(chunk-type decision-metrics preweight weight defect-rate1 defect-rate2 dif)

;goal-chunk
 (define-chunks
    (goer isa decision state choose-strategy time blank OEE1 blank OEE2 blank CT1 blank CT2 blank)
   (choose-strategy)(decide-strategy)(brute-strategy)(brute-decision)(naive-decision) (perceive)(weight)(next-weight) (preassemble)(assemble)(assemble-perceive)(compare)(decide)(next-decide)(result)(stop)(blank))
  
;start goal buffer
(goal-focus goer)

  ;prodcution rules
  ;; expert production sets
  ;;choose -strategy
(p choose-strategy
   =goal>
   isa decision
   state choose-strategy
==>
   =goal>
   isa decision
   state decide-strategy
   )
  
 
 ;; choose expert strategy
 ( p expert-strategy
   =goal>
     isa decision
     state  decide-strategy
 ==>
     =goal>
     isa decision
     state perceive
  )

;;  start retrival chunks for task target and decision metrics   
(p perceive
   =goal>
   isa     decision
   state   perceive

 ==>
   =goal>
   isa     decision
   state   weight
   time   X
   OEE1   X
   CT1 X
   OEE2  X
   CT2  X
   )
  
;;Consider the weights of preassemble in decision making
(p preassemble-weight
   =goal>
   isa    decision
   state  weight
   time  =time
   OEE1  =OEE1
   CT1   =CT1
   OEE2  =OEE2
   CT2   =CT2
   ?imaginal>
     buffer empty
    state  free
==>
   =goal>
    !bind! =aval (/ (* =CT1 =OEE2) (+ (* =CT1 =OEE2) (* =CT2 =OEE1)))
   ; !bind! =bval (/ (* =CT2 =OEE1) (+ (* =CT1 =OEE2) (* =CT2 =OEE1)))
    !output! (=aval)
    !output! ("caculate the preassemble defect decision weight")
   ; !output! (=bval)
   ; !output! ("calculate the assemble defect decision weight")
    +Imaginal>
    preweight   =aval
    weight      nil
 =goal>
   isa     decision
   state   next-weight
   )

;; consider weights of assemble in decision making
(p assemble-weight
   =goal>
    isa  decision
    state  next-weight
    time   =time
    OEE1  =OEE1
    CT1   =CT1
    OEE2  =OEE2
    CT2   =CT2
    =imaginal>
    preweight   =aval
    weight      nil
==>
     !bind!   =bval (/ (* =CT2 =OEE1) (+ (* =CT1 =OEE2) (* =CT2 =OEE1)))
     !output!  (=bval)
     !output!  ("calculate the assemble defect decision weight")
   =goal>
     isa  decision
     state  preassemble
    +Imaginal>
    preweight   =aval
    weight      =bval
   )
  
;; calculate preassemble defect rate1 increase and put into imaginal

(p preassemble
  =goal>
   isa   decision
   state   preassemble
   time    =time
   OEE1    =OEE1
   CT1      =CT1
   OEE2    =OEE2
   CT2    =CT2
 =imaginal>
   preweight   =aval
   weight      =bval
   defect-rate1  nil
 ==>
  !bind!    =cval(* (*  =time (- 1 =OEE1) ) =aval)
   !output! (=cval)
   !output! ("calculate the final preassemble defect rate")
  ;!bind!    =dval(* (*  =time (- 1 =OEE2) ) =bval)
   +Imaginal>
  ; preweight   =aval
   weight      =bval
   defect-rate1   =cval
   defect-rate2   nil
 =goal>
   isa     decision
  state   assemble-perceive
   )
  
;;calculate assemble defectrate2 increase and put into imaginal buffer
(p assemble
  =Imaginal>
  ; preweight   =aval
   weight      =bval
   defect-rate1   =cval
   defect-rate2   nil
  =goal>
   isa    decision
   state  assemble-perceive
   time    =time
   OEE2    =OEE2
   CT2    =CT2
 ==>
    !bind!    =dval(* (*  =time (- 1 =OEE2) ) =bval)
   !output! (=dval)
   !output!  ("calclate the assemble defect rate") 
  +imaginal>
    defect-rate1   =cval
    defect-rate2   =dval
 =goal>
   isa     decision
   state  compare
   )

;; compare the defect rate increase
(p compare
 =goal>
   isa    decision
   state  compare
   =imaginal>
   defect-rate1   =cval
   defect-rate2   =dval
==>
 =goal>
   isa decision
   state  decide
   !bind!  =val(- =cval =dval)
   !output! (=val)
  =imaginal>
   dif    =val
   )
  
;;Decide which sector to reduce
(p decide
 =goal>
   isa    decision
   state   decide
 =imaginal>
   < dif  0
==>
 =goal>
   isa      decision
   state    result
   !output!  ("choose preassemble has better stable output!")
   )
  
(p redecide
 =goal>
   isa    decision
   state  decide
 =imaginal>
   > dif    0
==>
  =goal>
   isa      decision
   state    result
   !output!  ("choose assemble has better stable output!")
 )

;; finish task and loop back to start another trail
(p stop
  =goal>
  isa decision
  state result
==>
   =goal>
   isa decision
   state choose-strategy
   !output!  ("this is the end of one decision making")
   )


  ;; production sets for intermediate strategy
  ; choose intermediate strategy
 (P decide-brute
   =goal>
   isa decision
   state decide-strategy
==>
   =goal>
   isa decision
   state brute-strategy
    time  4
    OEE1   0.88
    CT1 44
    OEE2  0.8
    CT2  40
     
   )
; retrival chunks and compare the OEE of preassemble and assemble
(p brute-strategy
   =goal>
    isa  decision
    state brute-strategy
    time   =time
    OEE1  =OEE1
    CT1   =CT1
    OEE2  =OEE2
    CT2   =CT2
     ?imaginal>
     buffer  empty
     state   free
 ==>
     !bind!  =val(- =OEE1 =OEE2)
     !output! (=val)
    =goal>
     isa decision
     state brute-decision
     +imaginal>
     dif  =val
   )

;; compare the dif and make decison using intuition "It's not wise to cutting off the good part from a fruit", then loop back to next trail

  (p brute-choice
     =goal>
   isa    decision
   state  brute-decision
 =imaginal>
   > dif    0
==>
  =goal>
   isa      decision
   state    choose-strategy
   !output!  ("choose assemble has better stable output!")
     )
 
(p brute-next-choice
     =goal>
    isa  decision
    state  brute-decision
    =imaginal>
     <  dif  0
 ==>
     =goal>
     isa  decision
    state  choose-strategy
    !output!  ("choose preassemble has better stable output!")  
   )

 ;; novice production sets
 ;; make the decision using intuition " defect happen in the preassemble will amplified during the later phases"  and only goal chunk, then loop back to next trail.
  (p naive-choice
     =goal>
     isa decision
     state decide-strategy
==>
     =goal>
     isa decision
     state naive-decision
     )

  (p naive-decision
     =goal>
     isa decision
     state naive-decision
 ==>
     =goal>
     isa decision
     state choose-strategy
     !output!  ("assebly is always the right place to reduce time!")
)     

(spp naive-choice :u 10) ;higher than other to emulate the situation of all the tasks start with beginer decision making
(spp decide-brute :u 0)
(spp expert-strategy :u 0) 

;reward or penalty each decision's result
(spp naive-decision :reward 0)
(spp brute-strategy :reward 5)
(spp compare :reward 20)  ; Increased to make it more attractive


)
