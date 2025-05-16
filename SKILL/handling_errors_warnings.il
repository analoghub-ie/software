procedure( writeData(filePath data)
	/*
	An example of using error message box to indicate that the file
	couldn't be open or the type of provided data is not a string.	
	*/
	prog( (outPort message)
		
		outPort = outfile(filePath "w")
		unless( outPort
			sprintf(message "Failed to open a \"%s\" file!\nPlease check that the provided path is correct and you have write permissions."
				filePath)
			hiDisplayAppDBox(
				?name 'errorAppDBox
				?dboxBanner "*ERROR* Writing Data"
				?dboxText message
				?dialogType hicErrorDialog	
				?buttonLayout 'Close
			)
			
			return()
		);unless
		
		unless( stringp(data)
			sprintf(message "The provided data type - %L.\nPlease provide data as a string!"
				type(data))
			
			hiDisplayAppDBox(
				?name 'errorAppDBox
				?dboxBanner "*ERROR* Writing Data"
				?dboxText message
				?dialogType hicErrorDialog	
				?buttonLayout 'Close
			)
			
			return()
		);unless
		
		fprintf(outPort "%s\n" data)
		close(outPort)
		
		return(t)
	);prog
);procedure


procedure( runVerifications()
	/*
	An example of using a warning message box to indicate that an
	environment variable is missing, but still can continue to run the code.	
	*/
	let( (message)
		
		unless( getShellEnvVar("NETBATCH_POOL")
			message = "Netbatch settings are missing!\nRunning the tasks locally."
			hiDisplayAppDBox(
				?name 'warningAppDBox
				?dboxBanner "*WARNING* My App"
				?dboxText message
				?dialogType hicWarningDialog	
				?buttonLayout 'Close
			)
		);unless
		
		; Rest of the code here
	);let
);procedure


procedure( runTask()
	/*
	An example of using info message box to indicate
	that the task is finished.	
	*/
	let( (message success)
		
		; Implement task logic here
		
		if( success
		then
			message = "The task is finished successfully!"
		else
			message = "The task is finished with errors!\nPlease refer to a log file."
		);if
		
		hiDisplayAppDBox(
			?name 'infoAppDBox
			?dboxBanner "*INFO* My App"
			?dboxText message
			?dialogType hicMessageDialog	
			?buttonLayout 'Close
		)
	);let
);procedure


procedure( askUser()
	/*
	An example of using a dialog box to indicate what user wants to do next.	
	*/
	let( (answer)

		answer = hiDisplayAppDBox(
			?name 'questionAppDBox
			?dboxBanner "*QUESTION* My App"
			?dboxText "A file is missing!\nYou can either create a new one, continue or abort."
			?dialogType hicQuestionDialog	
			?buttonLayout 'UserDefined
			?buttons list("Create New File" "Continue" "Abort")
			?callback list("createNewFile()" nil "abort()")
		)
		
		; If you're using ?callback, then the "answer" will get "t"
		case( answer
			( 1
				printf("Creating a new file\n")
			)
			( 2
				printf("Continuing\n")
			)
			( 3
				printf("Aborting\n")
			)
		);case
	);let
);procedure


procedure( createNewFile()
	printf("Running a callback function to create a new file\n")
);procedure


procedure( abort()
	printf("Running a callback function to abort\n")
);procedure


procedure( displayInfoMessage(@key (title "INFO")
				(message "Placeholder text") (parent nil))
	/*
	Displays an informational message box, optionally centered relative
	to a parent form.
	
	Example usage:
		displayInfoMessage(
			?title "*INFO* My Info"
			?message "This is an info message"
			?parent myForm
		)

	@param title string
		The title of the dialog box, displayed in the banner. Defaults to "INFO".

	@param message string
		The message text to be displayed within the dialog box. Defaults to
		"Placeholder text".

	@param parent form/nil
		An optional parent form. If provided, the dialog box will be centered
		relative to this form. If 'nil', the dialog box will appear at the
		default location.
	*/
	let( (location)
	
		when( parent
			location = getParentCenterPoint(parent)
		);when
		
		hiDisplayAppDBox(
			?name 'infoAppDBox
			?dboxBanner title
			?dboxText message
			?dialogType hicMessageDialog	
			?buttonLayout 'Close
			?location location
		)
	);let
);procedure


procedure( displayWarningMessage(@key (title "WARNING")
				(message "Placeholder text") (parent nil))
	/*
	Displays a warning message box, optionally centered relative to a
	parent form.
	
	Example usage:
		displayWarningMessage(
			?title "*WARNING* My Warning"
			?message "This is a warning message"
			?parent myForm
		)

	@param title string
		The title of the dialog box, displayed in the banner. Defaults to
		"WARNING".

	@param message string
		The message text to be displayed within the dialog box. Defaults to
		"Placeholder text".

	@param parent form/nil
		An optional parent form. If provided, the dialog box will be centered
		relative to this form. If 'nil', the dialog box will appear at the
		default location.
	*/
	let( (location)
	
		when( parent
			location = getParentCenterPoint(parent)
		);when	
			
		hiDisplayAppDBox(
			?name 'warningAppDBox
			?dboxBanner title
			?dboxText message
			?dialogType hicWarningDialog	
			?buttonLayout 'Close
			?location location
		)
	);let
);procedure


procedure( displayErrorMessage(@key (title "ERROR")
				(message "Placeholder text") (parent nil))
	/*
	Displays an error message box, optionally centered relative to a
	parent form.
	
	Example usage:
		displayErrorMessage(
			?title "*ERROR* My Error"
			?message "This is an error message"
			?parent myForm
		)

	@param title string
		The title of the dialog box, displayed in the banner. Defaults to
		"ERROR".

	@param message string
		The message text to be displayed within the dialog box. Defaults to
		"Placeholder text".

	@param parent form/nil
		An optional parent form. If provided, the dialog box will be centered
		relative to this form. If 'nil', the dialog box will appear at the
		default location.
	*/
	let( (location)
	
		when( parent
			location = getParentCenterPoint(parent)
		);when	
		
		hiDisplayAppDBox(
			?name 'errorAppDBox
			?dboxBanner title
			?dboxText message
			?dialogType hicErrorDialog	
			?buttonLayout 'Close
			?location location
		)
	);let
);procedure


procedure( getParentCenterPoint(parent)
	/*
	Calculates the center point of a given parent form.

	@param parent form
		The parent form whose center point is to be calculated. This form
		should have retrievable location and size properties.

	@return list
		Returns a list containing the x and y coordinates of the center point
		of the parent form.
	*/
	let( (formLocation x y formSize width height)
		
		formLocation = hiGetFormLocation(parent)
		x = car(formLocation)
		y = cadr(formLocation)
		formSize = hiGetFormSize(parent)
		width = car(formSize)
		height = cadr(formSize)
		
		x+width/2:y+height/2
	);let
);procedure
