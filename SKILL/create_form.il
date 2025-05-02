/*
Create layout form.
A practical example of creating layout forms and adding callbacks.

Usage example:
	form = createLibrariesCellsInUseForm()
	hiDisplayForm(form)

	
Author: Eugeny Khanchin
Source: AnalogHub.ie
*/


procedure( createLibrariesCellsInUseForm()
	
	;Creates a form for displaying and interacting with library, cell, and
	;view information.

	;@return formObject
	;	The created form object for libraries and cells in use.
	
	let( (libraryLabel libraryStringField cellLabel cellStringField viewLabel
		  viewStringField topGridLayout browseButton horizontalLayout
		  infoReportField getInfoButton verticalLayout)
		
		libraryLabel = hiCreateLabel(
			?name 'libraryLabel
			?labelText "Library"
			?justification 'right
		)

		libraryStringField = hiCreateStringField(
			?name 'libraryStringField
			?modifyCallback 'libraryNameModifyCB
		)
		
		cellLabel = hiCreateLabel(
			?name 'cellLabel
			?labelText "Cell"
			?justification 'right
		)

		cellStringField = hiCreateStringField(
			?name 'cellStringField
		)
		
		viewLabel = hiCreateLabel(
			?name 'viewLabel
			?labelText "View"
			?justification 'right
		)

		viewStringField = hiCreateStringField(
			?name 'viewStringField
		)
		
		topGridLayout = hiCreateGridLayout(
			'topGridLayout
			?spacing 10
			?items list(
				list(libraryLabel 'row 0 'col 0)
				list(libraryStringField 'row 0 'col 1)	
				list(cellLabel 'row 1 'col 0)
				list(cellStringField 'row 1 'col 1)
				list(viewLabel 'row 2 'col 0)
				list(viewStringField 'row 2 'col 1)
				list('col_stretch 0 0)
				list('col_stretch 1 1)	
			)
		)
		
		browseButton = hiCreateButton(
			?name 'browseButton
			?buttonText "Browse"
			?callback "browseLibraryCellViewCB(hiGetCurrentForm())"
		)

		horizontalLayout = hiCreateHorizontalBoxLayout(
			'horizontalLayout
			?frame "Top Cell Info"
			?spacing 10
			?items list(
				list(topGridLayout 'stretch 1)
				list(browseButton 'stretch 0)
			)	
		)
		
		infoReportField = hiCreateReportField(
			?name 'infoReportField
			?title "Hierarchy Info"
			?headers list(
				list("Library" 100 'left 'string t)
				list("Cell" 100 'left 'string t)
			)
		)
		
		getInfoButton = hiCreateButton(
			?name 'getInfoButton
			?buttonText "Get Hierarchy Info"
			?callback "getUsedLibrariesCellsCB(hiGetCurrentForm())"
		)
		
		verticalLayout = hiCreateVerticalBoxLayout(
			'verticalLayout
			?items list(horizontalLayout infoReportField getInfoButton)	
		)
	
		hiCreateLayoutForm(
			'librariesCellsInUseForm
			"Libraries Cells in Use"
			verticalLayout
			?buttonLayout 'Empty
			?mapCB 'librariesCellsInUseFormMapCB
		)
	);let
);procedure


procedure( librariesCellsInUseFormMapCB(form)
	
	;Map callback function for initializing the Libraries Cells In Use
	;form fields.
	
	;@param form formObject
	;	The form object being instantiated.
	
	let( (cellView)
		
		hiInstantiateForm(form)
		hiSetFieldMinSize(form 'browseButton ?widgetHeight 25)
		hiSetFieldMinSize(form 'getInfoButton ?widgetHeight 35)
		
		cellView = geGetEditCellView()
		when( cellView
			form~>libraryStringField~>value = cellView~>libName
			form~>cellStringField~>value = cellView~>cellName
			form~>viewStringField~>value = cellView~>viewName
		);when
	);let
);procedure


procedure( libraryNameModifyCB(field scope latestTextValue sourceOfChange)
	
	;Modify callback function for validating and highlighting the library
	;name field.
	
	;@param field formField
	;    The form field being modified.
	;@param scope formObject
	;    The form object containing the field.
	;@param latestTextValue string
	;    The latest text value entered in the field.
	;@param sourceOfChange any
	;	The source of the change, indicating whether the modification
	;	was user-initiated.
	;@return t boolean
	;	Returns t to allow the changes made to the field.

	let( (libraryObject)
		when( sourceOfChange
			libraryObject = ddGetObj(latestTextValue)
			if( !libraryObject
			then
				hiHighlightField(scope field~>hiFieldSym 'error)
			else
				hiHighlightField(scope field~>hiFieldSym 'background)
			);if
		);when
		
		t
	);let
);procedure


procedure( browseLibraryCellViewCB(form)

	;Callback function for synchronizing library, cell, and view fields with
	;the form.

	;@param form formObject
	;	The form object containing the fields to be synchronized.
	
	ddsSyncWithForm(form 'browse 'libraryStringField 'cellStringField
		'viewStringField)
);procedure


procedure( getUsedLibrariesCellsCB(form)
	
	;Callback function to extract and display used libraries and cells from a
	;specified cell view.
	
	;@param form formObject
	;	The form object containing the input fields and report field.
	
	prog( (libName cellName viewName cellView usedLibrariesCellsTable choices)
		
		; Get input
		libName = form~>libraryStringField~>value
		cellName = form~>cellStringField~>value
		viewName = form~>viewStringField~>value
		
		; Check input
		unless( checkInput(libName cellName viewName)
			return()
		);unless
		
		; Pre-process input
		cellView = dbOpenCellViewByType(libName cellName viewName)
		
		; Run the libraries and cells extraction function
		usedLibrariesCellsTable = getLibrariesCellsUsedIn(cellView)
		
		; Post-process output
		foreach( library usedLibrariesCellsTable
			foreach( cell usedLibrariesCellsTable[library]
				choices = cons(list(library cell) choices)
			);foreach
		);foreach

		; Show output in a table
		form~>infoReportField~>choices = choices
		
		return(t)
	);prog
);procedure


procedure( checkInput(libName cellName viewName)
	
	;Validates the existence of a specified library, cell, and view
	;combination.
	
	;@param libName string
	;       The name of the library to check.
	;@param cellName string
	;       The name of the cell to check.
	;@param viewName string
	;       The name of the view to check.
	;@return boolean
	;        Returns t if the library, cell, and view exist; otherwise,
	;        displays an error dialog and returns nil.
	
	prog( (viewObject)
	
		viewObject = ddGetObj(libName cellName viewName)
		unless( viewObject
			hiDisplayAppDBox(
				?name 'errorAppDBox
				?dboxBanner "*ERROR* Libraries Cells in Use"
				?dboxText "Selected library, cell or view don't exist!"
				?dialogType hicErrorDialog	
				?buttonLayout 'Close
			)
			
			return()
		);unless
		
		return(t)
	);prog
);procedure


procedure( getLibrariesCellsUsedIn(cellView 
            @optional (usedLibrariesCellsTable nil))
    
    ;Retrieves all libraries and cells used in the hierarchy of a given
    ;cell view.

    ;@param cellView dbObject
    ;The cell view object from which to retrieve the hierarchy.

    ;@param usedLibrariesCellsTable table
    ;Optional. A table to keep track of used libraries and cells.
    ;If not provided, a new table is created.

    ;@return table
    ;A table containing libraries as keys and tables of cell names as
    ;values, representing the hierarchy.
    
    let( (cellTable libName cellName cellObject message viewName nextCellView)

        ; First initialization
        unless( usedLibrariesCellsTable
            usedLibrariesCellsTable = makeTable('usedLibrariesCellsTable nil)
            cellTable = makeTable('cellTable nil)
            cellTable[cellView~>cellName] = t
            usedLibrariesCellsTable[cellView~>libName] = cellTable
        );unless

        foreach( instance cellView~>instHeaders
            libName = instance~>libName
            cellName = instance~>cellName
            cellObject = ddGetObj(libName cellName)
                            
            if( !cellObject
            then
                message = strcat("[getLibrariesCellsUsedIn] " libName "/"
                    cellName " cell doesn't exist in your Library Manager")
                warn(message)
            else
                ; Creates cells' table for a library
                unless( usedLibrariesCellsTable[libName]
                    cellTable = makeTable('cellTable nil)
                    usedLibrariesCellsTable[libName] = cellTable
                );unless
                
                unless( usedLibrariesCellsTable[libName][cellName]
                    ; This cell is not in table yet
                    usedLibrariesCellsTable[libName][cellName] = t
                    
                    ; Gets instance's cell view
                    viewName = mapViewName(instance~>viewName)
                    nextCellView = dbOpenCellViewByType(libName cellName viewName)
                    when( nextCellView
                        usedLibrariesCellsTable = getLibrariesCellsUsedIn(nextCellView
                            usedLibrariesCellsTable)
                    );when
                );unless
            );if
        );foreach
            
        usedLibrariesCellsTable
    );let
);procedure


procedure( mapViewName(viewName)
    ; Maps a view name to a common view name that includes 'instances'
    ;for hierarchy traversal.

    ;@param viewName string
    ;The name of the view to be mapped.

    ;@return string
    ;The mapped view name.
    

    if( viewName == "symbol"  ; Symbol's cell view doesn't have ~>instances
    then
        "schematic"
    else
        viewName
    );if
);procedure
