
;Helper functions ==============================================================

  ;-----------------------------------------------------------------------------
  ;Pexilization function
  ; Args:
  ;   name := name of the pixel
  ;   xmin := x minimum of the pixle, starting point.
  ;   xmax := x maximum of the pixle, ending point.
  (define pixelization
   (lambda (name xmin xmax ymin)
     (begin
       ( cond ( < ymin -0.5) (define ymin 0) (else (define ymin ymin))  )
       (define y_offset 0)
       (define inner.metal
         (sdegeo:create-rectangle
           (position (+ xmin 0) -1 0)
           (position (- xmax 0) ymin 0)
           "Aluminum"
           (string-append name "_Al_layer1")
         )
       )
       ;(define outer.metal (sdegeo:create-rectangle (position xmin -1 0) (position xmax -0.5 0) "Aluminum" (string-append name "_Al_layer2") ) )

       (define contact_y (- ymin 0.0) ) ; 1.0
       (define Top_Contact_Point (/ (+ xmin xmax ) 2 ) )
       ;(define Top_Contact_Edge (find-edge-id (position Top_Contact_Point contact_y 0 ) ) ) ;return edge list

       ;(sdegeo:define-contact-set name 4.0 (color:rgb 1.0 0.0 0.0) "##")
       ;(sdegeo:insert-vertex (position xmin contact_y 0 ) )
       ;(sdegeo:insert-vertex (position xmax contact_y 0 ) )
       ;(sdegeo:set-current-contact-set name )
       ;(sdegeo:set-contact-edges Top_Contact_Edge name)
       ;(sdegeo:set-contact-boundary-edges outer.metal)

       ;(define delete.edge.1 (find-edge-id (position Top_Contact_Point (- ymin 0.5) 0 ) ) )
       ;(sdegeo:delete-contact-edges delete.edge.1)
       ;(define delete.edge.2 (find-edge-id (position xmin (- ymin 0.5) 0 ) ) )
       ;(sdegeo:delete-contact-edges delete.edge.2)
       ;(define delete.edge.3 (find-edge-id (position xmax (- ymin 0.5) 0 ) ) )
       ;(sdegeo:delete-contact-edges delete.edge.3)

       ;(sdegeo:define-contact-set (string-append "inner_" name) 4.0 (color:rgb 1.0 0.0 0.0) "##")
       (sdegeo:define-contact-set name 4.0 (color:rgb 1.0 0.0 0.0) "##")
       (sdegeo:insert-vertex (position xmin 0 0 ) )
       (sdegeo:insert-vertex (position xmax 0 0 ) )
       ;(sdegeo:set-current-contact-set (string-append "inner_" name) )
       ;(sdegeo:set-current-contact-set name)
       ;(sdegeo:set-contact-boundary-edges inner.metal)
       (sdegeo:define-2d-contact (find-edge-id (position Top_Contact_Point y_offset 0) ) name)
       ;(define Inner.Top_Contact_Edge  (find-edge-id (position Top_Contact_Point y_offset 0) ) )
       ;(sdegeo:set-contact-edges Inner.Top_Contact_Edge (string-append "inner_" name))

       ;(define v1 (car (find-vertex-id (position xmin (- ymin 1.0) 0 ) ) ) )
       ;(define v2 (car (find-vertex-id (position xmax (- ymin 1.0) 0 ) ) ) )
       ;(sdegeo:fillet-2d (list v1 v2) 0.2 )
     )
   )
  )
  ;-----------------------------------------------------------------------------
  ;Pexilization function with more realistic structure
  ; Args:
  ;   name := name of the pixel
  ;   xmin := x minimum of the pixle, starting point.
  ;   xmax := x maximum of the pixle, ending point.
  (define pixelization_real
   (lambda (name xmin xmax ymin over_hand oxide_thickness)
     (begin
       ; ( cond ( < ymin -0.5) (define ymin 0) (else (define ymin ymin))  )
       (define y_offset 0)
       (define over_hang over_hand)
       (define thickmin (- ymin oxide_thickness))
       (define thickmax (* 2 thickmin))

       (define metal_cont
         (sdegeo:create-polygon
           (list
            (position xmin ymin 0)
            (position xmax ymin 0)
            (position xmax thickmin 0)
            (position (+ xmax over_hang) thickmin 0)
            (position (+ xmax over_hang) thickmax 0)
            (position (- xmin over_hang) thickmax 0)
            (position (- xmin over_hang) thickmin 0)
            (position xmin thickmin 0)
            (position xmin ymin 0)
           )
           "Aluminum"
           (string-append name "_Al_layer1")
          )
        )

       (sdegeo:define-contact-set name 4.0 (color:rgb 1.0 0.0 0.0) "##")

       ; (sdegeo:set-current-contact-set name)
       ; (sdegeo:set-contact-boundary-edges metal_cont)

       (define contact_y (- ymin 0.0) ) ; 1.0
       (define Top_Contact_Point (/ (+ xmin xmax ) 2 ) )
       (sdegeo:insert-vertex (position xmin 0 0 ) )
       (sdegeo:insert-vertex (position xmax 0 0 ) )
       (sdegeo:define-2d-contact (find-edge-id (position Top_Contact_Point y_offset 0) ) name)
     )
   )
  )
  ;-----------------------------------------------------------------------------
  ;Gaussian dopoing function
  ; Args:
  ;   name : name for reference
  ;   dopant_name : dopant type
  ;   xmin : x minimum of re/eval window (rfwin)
  ;   xmax : x maximum of rfwin
  ;   y_loc : y starting point for the doping
  ;   peak_loc : peak dopoing location in y
  ;   peak_val : peak dopoing value at peak_loc
  ;   val_at_depth : dopoing value at depth
  ;   depth : depth of the doping in y
  ;   symm : (as)symmetric dopoing.
  ;   lateral_factor: lateral diffusion factor
  (define GaussProf
   (lambda (name dopant_type xmin xmax y_loc peak_loc peak_val val_at_depth depth symm lateral_factor)
     (begin
       (define ref_win (string-append name "_ref_win" ))
       (define doping_fun (string-append name "_doping_fun" ))
       (define place (string-append name "_place" ))

       (sdedr:define-refeval-window
         ref_win ; name of ref/eval window
         "Line" ;ref window type, could be {"Point" | "Line" | "Rectangle" | "Polygon" |"Cuboid"}
         (position xmin y_loc 0)
         (position xmax y_loc 0)
       )

       ;implant definition
       (sdedr:define-gaussian-profile
         doping_fun
         dopant_type
         "PeakPos" peak_loc
         "PeakVal" peak_val
         "ValueAtDepth" val_at_depth
         "Depth" depth
         "Gauss"
         "Factor" lateral_factor
       )

       ;implant placement
       (sdedr:define-analytical-profile-placement
         place
         doping_fun
         ref_win
         symm ; {"Both" | "Positive" | "Negative"}
         "NoReplace" ;{"Replace" | "NoReplace"}
         "Eval" ;{"Eval" | "NoEval"}
       ) ;NoSymm
     )
   )
  )

  ;-----------------------------------------------------------------------------
  ;Gaussian dopoing function alternaive with STD
  ; Args:
  ;   name : name for reference
  ;   dopant : dopant type
  ;   xmin : x minimum of re/eval window (rfwin)
  ;   xmax : x maximum of rfwin
  ;   y_loc : y starting point for the doping
  ;   peak_loc : peak dopoing location in y
  ;   peak_val : peak dopoing value at peak_loc
  ;   val_at_depth : dopoing value at depth
  ;   depth : depth of the doping in y
  ;   symm : (as)symmetric dopoing.
  ;   lateral_factor: lateral diffusion factor
  (define STDGaussProf
   (lambda (name dopant y_loc xmin xmax peak_loc peak_val std direction factor lateral)
     (begin
       (define ref_win (string-append name "_ref_win" ))
       (define doping_fun (string-append name "_doping_fun" ))
       (define place (string-append name "_place" ))

       (sdedr:define-refeval-window
         ref_win ; name of ref/eval window
         "Line" ;ref window type, could be {"Point" | "Line" | "Rectangle" | "Polygon" |"Cuboid"}
         (position (- xmin lateral) y_loc 0)
         (position (+ xmax lateral) y_loc 0)
       )

       ;implant definition
       (sdedr:define-gaussian-profile
         doping_fun
         dopant
         "PeakPos" peak_loc
         "PeakVal" peak_val
         "StdDev" std
         "Gauss"
         "Factor" factor
       )

       ;implant placement
       (sdedr:define-analytical-profile-placement
         place
         doping_fun
         ref_win
         direction ; {"Both" | "Positive" | "Negative"}
         "NoReplace" ;{"Replace" | "NoReplace"}
         "Eval" ;{"Eval" | "NoEval"}
       ) ;NoSymm
     )
   )
  )

  ;-----------------------------------------------------------------------------
  ;(Cell_Mesh "top_surface_mesh" x_min x_max ymin (+ ymin 1) 0 0 0 0.04 "DopingConcentration" "Rectangle" 10 10 5 5)

  ;defining meshing function
  ; Args:
  ;   Name : name for reference
  ;   Xmin : x min
  ;   Xmax : x max
  ;   Ymin : y min
  ;   Ymax : y max
  ;   Zmin : z min, let it 0
  ;   Zmax : z max, let it 0
  ;   edge_width : width of extension at xmin and xmax
  ;   ref_win_type :  refen window type, eg. "Rectangle", "Point", "Line", "Polygon"
  ;   func_name : function name to be used for refinement, e.g "DopingConcentration"
  ;   ref_type : reference type e.g. "MaxGradient" or "MaxTransDiff"
  ;   ref_value : reference value for meshing. simply, if the size is greater than value, it refine.
  ;   XMaxSize : max refine width in x
  ;   XMinSize : min refine width in x
  ;   YMaxSize : max refine width in y
  ;   YMinSize : min refine width in y
  (define Cell_Mesh
   (lambda (Name Xmin Xmax Ymin Ymax Zmin Zmax edge_width ref_win_type func_name ref_type ref_value XMaxSize XMinSize YMaxSize YMinSize)
     (begin
       (define RWin (string-append Name "_RefWindow" ))
       (define RSize (string-append Name "_RefSize" ))
       (define RPlace (string-append Name "_RefPlacement" ))
       (define RFunc (string-append Name "_RefFunc" ))

       (sdedr:define-refeval-window
         RWin
         ref_win_type
         (position (- Xmin edge_width) Ymin Zmin)
         (position  (+ Xmax edge_width) Ymax Zmax)
       )

       (define Xrange (- Xmax Xmin))
       (define Yrange (- Ymax Ymin))
       (define Zrange 0);(- Zmax Zmin))

       ;(sdedr:define-refinement-size RSize (/ Xrange XMaxSize) (/ Yrange YMaxSize) (/ Xrange XMinSize) (/ Yrange YMinSize) )
       (sdedr:define-refinement-size RSize XMaxSize YMaxSize XMinSize YMinSize)
       (sdedr:define-refinement-function RSize func_name ref_type ref_value) ;0.4 "DopingConcentration"
       (sdedr:define-refinement-placement RPlace RSize RWin)
     )
   )
  )

  (define ConstantMesh
    (lambda (Name ref_win_type Xmin Xmax Ymin Ymax lateral XMinSize XMaxSize YMinSize YMaxSize)
      (begin
        (define RWin (string-append Name "_RefWindow" ))
         (define RSize (string-append Name "_RefSize" ))
         (define RPlace (string-append Name "_RefPlacement" ))

        (sdedr:define-refeval-window
          RWin
          ref_win_type
          (position (- Xmin lateral) Ymin 0)
          (position (+ Xmax lateral) Ymax 0)
        )

        (sdedr:define-refinement-size RSize XMaxSize YMaxSize XMinSize YMinSize)
        (sdedr:define-refinement-placement RPlace RSize RWin)
      )
    )
  )

  (define ConstantPolyMesh
    (lambda (Name position_list XMinSize XMaxSize YMinSize YMaxSize)
      (begin
        (define RWin (string-append Name "_RefWindow" ))
         (define RSize (string-append Name "_RefSize" ))
         (define RPlace (string-append Name "_RefPlacement" ))

        (sdedr:define-refeval-window
          RWin
          "Polygon"
          position_list
        )

        (sdedr:define-refinement-size RSize XMaxSize YMaxSize XMinSize YMinSize)
        (sdedr:define-refinement-placement RPlace RSize RWin)
      )
    )
  )

  (define ConstDopeMesh
    (lambda (Name ref_win_type Xmin Xmax Ymin Ymax lateral XMinSize XMaxSize YMinSize YMaxSize)
      (begin
        (define RWin (string-append Name "_RefWindow" ))
         (define RSize (string-append Name "_RefSize" ))
         (define RPlace (string-append Name "_RefPlacement" ))
         (define RFunc (string-append Name "_RefFunc" ))

        (sdedr:define-refeval-window
          RWin
          ref_win_type
          (position (- Xmin lateral) Ymin 0)
          (position (+ Xmax lateral) Ymax 0)
        )

        (sdedr:define-refinement-size RSize XMaxSize YMaxSize XMinSize YMinSize)
        (sdedr:define-refinement-function RSize "DopingConcentration" "MaxTransDiff" 1)
        (sdedr:define-refinement-placement RPlace RSize RWin)
      )
    )
  )

  ; PadMeshing include interface between two reigons. e.g. Silicon and Oxide
  (define PadMeshing
    (lambda (Name ref_win_type Xmin Xmax Ymin Ymax lateral XMinSize XMaxSize YMinSize YMaxSize mat1 mat2)
      (begin
        (define RWin (string-append Name "_RefWindow" ))
         (define RSize (string-append Name "_RefSize" ))
         (define RPlace (string-append Name "_RefPlacement" ))

        (sdedr:define-refeval-window
          RWin ref_win_type
          (position (- Xmin lateral) Ymin 0)
          (position (+ Xmax lateral) Ymax 0)
        )

        (sdedr:define-refinement-size RSize XMaxSize YMaxSize XMinSize YMinSize)

        (sdedr:define-refinement-function RSize "MaxLenInt" mat1 mat2 0.1 1.0 "DoubleSide")
        (sdedr:define-refinement-function RSize "DopingConcentration" "MaxTransDiff" 1)

        (sdedr:define-refinement-placement RPlace RSize RWin)
      )
    )
  )

  ;-----------------------------------------------------------------------------
  (define EdgeMesh
   (lambda (Name X Y Z Width Thick)
     (begin
       (define RWin (string-append Name "_Window" ))
       (define RSize (string-append Name "_Size" ))
       (define RPlace (string-append Name "_Placement" ))
       (sdedr:define-refeval-window RWin "Rectangle" (position (- X Width) (- Y Thick) Z) (position (+ X Width) (+ Y Thick) Z))
       (sdedr:define-refinement-size RSize (/ Width 50) (/ Thick 100) (/ Width 10) (/ Width 100) )
       (sdedr:define-refinement-function RSize "DopingConcentration" "MaxTransDiff" 0.4)
       (sdedr:define-refinement-placement RPlace RSize RWin)
     )
   )
  )

; ==============================================================================
; ==============================================================================
; ==============================================================================
; ==============================================================================

(sde:clear)
(sdegeo:set-default-boolean "ABA")

(define xmin 0)
(define xmax @width@)
(define ymin 0)
(define ymax @thickness@)

(define edge_dist 20)
(define jte_width 2.5)

(define jte_L_xmin edge_dist)
(define jte_L_xmax (+ jte_L_xmin jte_width))
(define jte_R_xmax (- xmax edge_dist))
(define jte_R_xmin (- jte_R_xmax jte_width))
(define jte_peak_loc 0)
(define jte_peak_dope 1e19)
(define jte_depth 1.5)

(define nplus_xmin jte_L_xmax)
(define nplus_xmax jte_R_xmin)
(define nplus_peak_loc 0.1)
(define nplus_peak_dope 1e19)
(define nplus_depth 0.15)

(define pplus_offset 8)
(define pplus_xmin (+ nplus_xmin pplus_offset))
(define pplus_xmax (- nplus_xmax pplus_offset))
(define pplus_peak_loc 1.5)
(define pplus_peak_dope @pplus_dope@)
(define pplus_depth 0.35)

(define backplate_peak_loc 0)
(define backplate_peak_dope 1e19)
(define backplate_depth 0.1)

(define oxide_thickness 0.1)
(define oxide_L_xmin xmin)
(define oxide_L_xmax jte_L_xmax)
(define oxide_R_xmin jte_R_xmin)
(define oxide_R_xmax xmax)

; =======================================================================================
; Creating float-zone wafer
(sdegeo:create-rectangle
(position xmin ymin 0) (position xmax ymax 0)
"Silicon"
"wafer"
)

(define wafer_dope 3e12)
(sdedr:define-refinement-window
"wafer.win"
"Rectangle"
(position xmin ymin 0)
(position xmax ymax 0)
)
(sdedr:define-constant-profile "wafer.dope" "BoronActiveConcentration" wafer_dope)
(sdedr:define-constant-profile-placement "wafer.place" "wafer.dope" "wafer.win")

; =======================================================================================
; Creating implanted regions: N+ & P+ layers, JTE, backside.
(STDGaussProf
  "nplus.profile"
  "PhosphorusActiveConcentration"
  ymin nplus_xmin nplus_xmax
  nplus_peak_loc nplus_peak_dope nplus_depth
  "Positive" 1 0
)

(STDGaussProf
  "jte_L.profile"
  "PhosphorusActiveConcentration"
  ymin jte_L_xmin jte_L_xmax
  jte_peak_loc jte_peak_dope jte_depth
  "Positive" 1 0
)

(STDGaussProf
  "jte_R.profile"
  "PhosphorusActiveConcentration"
  ymin jte_R_xmin jte_R_xmax
  jte_peak_loc jte_peak_dope jte_depth
  "Positive" 1 0
)

(STDGaussProf
  "pplus.profile"
  "BoronActiveConcentration"
  ymin pplus_xmin pplus_xmax
  pplus_peak_loc pplus_peak_dope pplus_depth
  "Positive" 1 0
)

(STDGaussProf
  "backplate.profile"
  "BoronActiveConcentration"
  ymax xmin xmax
  backplate_peak_loc backplate_peak_dope backplate_depth
  "Negative" 0 0
)

; ==============================================================================
; Creating oxide surface and defining electrical contact

(sdegeo:create-rectangle
  (position oxide_L_xmin ymin 0) (position oxide_L_xmax (- ymin oxide_thickness) 0)
  "Oxide"
  "oxide_L"
)
(sdegeo:create-rectangle
  (position oxide_R_xmin ymin 0) (position oxide_R_xmax (- ymin oxide_thickness) 0)
  "Oxide"
  "oxide_R"
)

(pixelization_real "pad" oxide_L_xmax oxide_R_xmin 0 5 oxide_thickness)

(sdegeo:define-contact-set "back_contact"  4.0 (color:rgb 1.0 0.0 0.0) "##")
(sdegeo:insert-vertex (position xmin (+ ymax 0.0) 0))
(sdegeo:insert-vertex (position xmax (+ ymax 0.0) 0))
(define p_contact_point (/ (+ xmin xmax) 2))
(sdegeo:set-current-contact-set "back_contact")
(define p_contact_edge (find-edge-id (position p_contact_point (+ ymax 0.0) 0)))
(sdegeo:set-contact-edges p_contact_edge "back_contact")

; ==============================================================================
; Meshing

(define jte_mesh_ymin 0.01) ; 0.1
(define jte_mesh_ymax 0.1) ; 0.1
(define jte_mesh_xmin 0.01) ; 5
(define jte_mesh_xmax 0.1) ; 5

(define gain_mesh_ymin 0.1) ;0.1
(define gain_mesh_ymax 0.5) ;0.1
(define gain_mesh_xmin 1) ;0.1
(define gain_mesh_xmax 5) ;0.1

(define inject_win_mesh_ymin 0.01)
(define inject_win_mesh_ymax 0.05)
(define inject_win_mesh_xmin 0.1)
(define inject_win_mesh_xmax 1.0)

(define n_backside_mesh 10)
(define backside_mesh_ymin 0.01) ; 0.05
(define backside_mesh_ymax 0.05) ; 0.1
(define backside_mesh_xmin 1) ; 5
(define backside_mesh_xmax (/ (- xmax xmin) n_backside_mesh)) ; 10


(ConstDopeMesh
  "gain.mesh" "Rectangle"
  nplus_xmin nplus_xmax
  ymin 5
  0
  gain_mesh_xmin gain_mesh_xmax
  gain_mesh_ymin gain_mesh_ymax
)

(ConstDopeMesh
  "jte_L.mesh" "Rectangle"
  jte_L_xmin jte_L_xmax
  ymin (* 6 jte_depth)
  10
  jte_mesh_xmin jte_mesh_xmax
  jte_mesh_ymin jte_mesh_ymax
)

(ConstDopeMesh
  "jte_L_nplus.mesh" "Rectangle"
  jte_L_xmax pplus_xmin
  ymin 3
  2
  0.01 0.05
  jte_mesh_ymin jte_mesh_ymax
)

(ConstDopeMesh
  "jte_R.mesh" "Rectangle"
  jte_R_xmin jte_R_xmax
  ymin (* 6 jte_depth)
  10
  jte_mesh_xmin jte_mesh_xmax
  jte_mesh_ymin jte_mesh_ymax
)

(ConstDopeMesh
  "jte_R_nplus.mesh" "Rectangle"
  pplus_xmax jte_R_xmin
  ymin 3
  2
  0.01 0.05
  jte_mesh_ymin jte_mesh_ymax
)

(ConstDopeMesh
  "thin_gain.mesh" "Rectangle"
  nplus_xmin nplus_xmax
  ymin 0.8
  0
  gain_mesh_xmin gain_mesh_xmax
  0.01 0.1
)

(ConstDopeMesh
  "backplate.mesh" "Rectangle"
  xmin xmax
  (- ymax 1) ymax
  0
  backside_mesh_xmin backside_mesh_xmax
  backside_mesh_ymin backside_mesh_ymax
)

(define pad_center (/ (+ xmin xmax) 2))
(define mip_width 2.5)
(define mip_1_min (- pad_center mip_width))
(define mip_1_max (+ pad_center mip_width))

(define mip_mesh_min 0.15)
(define mip_mesh_max 0.25)
; (define mip_mesh_ymin 1.0)
; (define mip_mesh_ymax 1.5)
(define mip_mesh_ymin 0.15)
(define mip_mesh_ymax 0.25)

(define inject_win_width 10)
(define inject_win_depth 5)
(define inject_win_xmin (- pad_center inject_win_width))
(define inject_win_xmax (+ pad_center inject_win_width))

; mesh for vertical drifting path
(ConstantMesh
  "ver_track.mesh" "Rectangle"
  mip_1_min mip_1_max ymin ymax 0
  mip_mesh_min mip_mesh_max
  mip_mesh_ymin mip_mesh_ymax
)
(ConstantMesh
  "inject_win.mesh" "Rectangle"
  inject_win_xmin inject_win_xmax ymin inject_win_depth 0
  inject_win_mesh_xmin inject_win_mesh_xmax
  inject_win_mesh_ymin inject_win_mesh_ymax
)

;Saving CMD file
(sdedr:write-cmd-file "@commands/o@")

;Build Mesh. NOTE that this snmesh command might not work for different Sentaurus version.
(sde:build-mesh "snmesh" "-numThreads 5 -AI" "n@node@_LGAD")
