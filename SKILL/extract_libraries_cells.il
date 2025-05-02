/*
Extract libraries and cells.
A function that can be used to extract libraries and cells names from a
given top cell hierarchy.

Usage example:
    libName = “my_lib_name”  ; Replace with actual names
    cellName = “my_cell_name”
    viewName = “view_name”  ; Layout or schematic
    cellView = dbOpenCellViewByType(libName cellName viewName)
    table = getLibrariesCellsUsedIn(cellView)


Author: Eugeny Khanchin
Source: AnalogHub.ie
*/


procedure( getLibrariesCellsUsedIn(cellView 
    @optional (usedLibrariesCellsTable nil))
;Retrieves all libraries and cells used in the hierarchy of a given
;cell view.

@param cellView dbObject
;The cell view object from which to retrieve the hierarchy.

@param usedLibrariesCellsTable table
;Optional. A table to keep track of used libraries and cells.
;If not provided, a new table is created.

@return table
;A table containing libraries as keys and tables of cell names as
;values, representing the hierarchy.
*/
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
;Maps a view name to a common view name that includes 'instances'
;for hierarchy traversal.

@param viewName string
;The name of the view to be mapped.

@return string
;The mapped view name.

if( viewName == "symbol"  ; Symbol's cell view doesn't have ~>instances
then
"schematic"
else
viewName
);if
);procedure
