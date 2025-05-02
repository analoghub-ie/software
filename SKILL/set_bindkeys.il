/*
Set bind keys.
A practical example of how to set bind keys for single and multiple actions.


Author: Eugeny Khanchin
Source: AnalogHub.ie
*/


; Single action - one command that does the job.
; For example - make all layers invisible except the selected layer in
; the Layout window’s palette.
hiSetBindKey("Layout" "Ctrl<Key>Q" "leSetAllLayerVisible(nil)")


; Multiple actions - a set of commands that do the job.
; For example - toggling layout dimming and changing its intensity.
procedure(toggleLayoutDimming()
    ;Toggles the dimming feature in the current layout window.
    let((window)
        
        window = hiGetCurrentWindow()
        
        window~>dimmingOn = !window~>dimmingOn
        window~>dimmingScope = "all"
        
        printf("Enable dimming = %L\n" window~>dimmingOn)
    )
)


procedure(changeLayoutDimmingIntensity(signum @key (byValue 5))
	;Adjusts the dimming intensity of the current layout window by a
	;specified value and direction.
	
	;@param signum int
	;       The direction of adjustment. Positive values increase
	;       intensity, negative values decrease it.
	;@key byValue int
	;     Optional. The amount by which to adjust the dimming intensity.
	;     Default is 5.
	
	let((window intensity)
		
		window = hiGetCurrentWindow()
		
		intensity = window~>dimmingIntensity
		intensity = (signum * byValue) + intensity
		cond(
			(intensity < 0
				intensity = 0
			)
			(intensity > 100
				intensity = 100
			)
		)
		
		window~>dimmingIntensity = intensity
		
		printf("Dimming intensity = %d\n" window~>dimmingIntensity)
	)
)


hiSetBindKey("Layout" "<Key>," "changeLayoutDimmingIntensity(-1)")
hiSetBindKey("Layout" "<Key>." "changeLayoutDimmingIntensity(1)")
hiSetBindKey("Layout" "<Key>/" "toggleLayoutDimming()")
