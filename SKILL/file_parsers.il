/*
This file includes file parsers: (currenly only) JSON.

Example usage - JSON:
	table = makeTable('table nil)
	table["one"] = 1
	table["two"] = 2
	table["list"] = list(1 2 3)

	hashTableIntoJSON(table "table.json")
	table2 = jsonIntoHashTable("table.json")
	print(table2["list"])
*/


procedure( hashTableIntoJSON(hashTable file "ot")
	/*
	Converts a hash table into a JSON format and writes it to a specified
	file.

	@param hashTable table
		The hash table to be converted into JSON format.

	@param file string
		The path to the JSON file where the converted data will be written.
		Ensure the path is valid and writable.
	*/
	let( (outPort)
		
		cond(
			( !hashTable || !tablep(hashTable)
				error("hashTableIntoJSON: 1st argument should be a table")
			)
			( !file || blankstrp(file)
				error("hashTableIntoJSON: 2nd argument should be a path to a JSON file")
			)
			( t
				outPort = outfile(file "w")
				if( !outPort then
					error("hashTableIntoJSON: Could not open JSON file. Please, check writing permissions in the directory")
				else
					_hashTableIntoJSON(hashTable outPort)
					close(outPort)
				);if
			)
		);cond
	);let
);procedure


procedure( jsonIntoHashTable(file "t")
	/*
	Reads a JSON file and converts its contents into a hash table.

	@param file string
		The path to the JSON file to be read. Ensure the file exists and is
		readable.

	@return table
		Returns a hash table containing the data extracted from the JSON file.
	*/
	prog( (hashTable inPort)
	
		unless( isFile(file)
			error("[jsonIntoHashTable] Files doesn't exist!")
			return()
		);unless
		
		inPort = infile(file)
		unless( inPort
			error("[jsonIntoHashTable] Failed to open JSON file! Please check read permission.")
			return()
		);unless
		
		hashTable = _extractHashTableFromJSON(inPort)
		close(inPort)
		
		unless( hashTable
			error("[jsonIntoHashTable] Failed to extract hash table from JSON! Please check JSON file's syntax.")
			return()
		);unless

		return(hashTable)
	);prog
);procedure


procedure( _hashTableIntoJSON(hashTable outPort @optional (identation "  "))
	/*
	Helper function to convert a hash table into JSON format and write it
	to an output port.

	@param hashTable table
		The hash table to be converted into JSON format.

	@param outPort port
		The output port where the JSON data will be written.

	@param identation string
		Optional parameter specifying the indentation level for formatting
		the JSON output. Used for recursion.
	*/	
	let( (value (i 1))

		fprintf(outPort "{ ")
		
		foreach( key hashTable
			when( i > 1
				fprintf(outPort ", ")
			);when			
			
			; Determines key type
			fprintf(outPort "\n%s\"%s\":" identation artMakeString(key))

			; Determines value type
			value = hashTable[key]
			_determineValueTypeForJSON(value identation outPort)
			
			i += 1
		);foreach
		
		identation = substring(identation 1 length(identation)-2) || ""
		fprintf(outPort "\n%s }" identation)
	);let
);procedure


procedure( _determineValueTypeForJSON(value identation outPort)
	/*
	Helper function to determine the type of a value and format it
	appropriately for JSON output.

	@param value any
		The value to be formatted for JSON output.

	@param identation string
		The current indentation level for formatting the JSON output.

	@param outPort port
		The output port where the formatted JSON value will be written.
	*/
	cond( 
		( stringp(value)
			; Value is a string
			fprintf(outPort "\"%s\"" value)
		)
		( numberp(value)
			; Value is an integer or a float number
			fprintf(outPort "%s" artMakeString(value))
		)
		( listp(value)
			; Value is a list
			_handleListForJSON(value identation outPort)
		)
		( tablep(value)
			; Value is a table
			if( !value->?
				then
					fprintf(outPort "\"\"")
			else
				_hashTableIntoJSON(value outPort
					strcat(identation "  "))
			);if
		)
		( t
			; Unknown type
			sprintf(value "%L" value)
			fprintf(outPort "\"%s\"" value)
		)
	);cond
);procedure


procedure( _handleListForJSON(valueList identation outPort)
	/*
	Helper function to format a list for JSON output.

	@param valueList list
		The list to be formatted for JSON output.

	@param identation string
		The current indentation level for formatting the JSON output.

	@param outPort port
		The output port where the formatted JSON list will be written.
	*/
	let( (len (i 0))
	
		len = length(valueList)
		
		fprintf(outPort "[ ")
		foreach( value valueList
			_determineValueTypeForJSON(value identation outPort)
			
			when( i < len-1
				fprintf(outPort ", ")
			);when
			
			i += 1
		);foreach
		fprintf(outPort " ]")
	);let
);procedure


procedure( _extractHashTableFromJSON(inPort)
	/*
	Helper function to extract a hash table from a JSON input port.

	@param inPort port
		The input port from which the JSON data will be read.

	@return table
		Returns a hash table containing the data extracted from the JSON
		input.
	*/
	let( (whitespacePattern line table tableStack key currentTable isKey
		  toBuildList value isTableEnd)
		
		whitespacePattern = pcreCompile("[\n\t]")
		while( gets(line inPort)
			line = parseString(line "")
			foreach( character line
				cond(
					( pcreMatchp(whitespacePattern character)
						; Skips whitespaces
						t
					)
					( character == "{"
						; New table
						table = makeTable('jsonTable)
						tableStack = cons(table tableStack)
						when( key
							currentTable[key] = table
						);when
						
						currentTable = table
						
						isKey = t
						key = ""
						isTableEnd = nil
					)
					( character == "}"
						; Closes table and goes to previous one
						when( !blankstrp(key)
							value = _evaluateValue(value)
							currentTable[key] = value
						);when

						tableStack = cdr(tableStack)
						when( tableStack
							currentTable = car(tableStack)
						);when
					
						isTableEnd = t
						isKey = t
						key = ""
					)
					( character == "["
						; New list
						toBuildList = t
					)
					( character == "]"
						; Closes list
						toBuildList = nil
						value = parseString(value ",")
					)
					( character == ":"
						; Assigns key
						key = evalstring(key)
						
						isKey = nil
						value = ""
					)
					( character == "," && !toBuildList && !isTableEnd
						; Assigns value
						value = _evaluateValue(value)
						currentTable[key] = value
						
						isKey = t
						key = ""
					)
					( isKey
						; Builds key
						key = strcat(key character)
					)
					( !isKey
						; Builds value
						value = strcat(value character)
					)
				);cond
			);foreach
		);while
		
		currentTable
	);let
);procedure


procedure( _evaluateValue(value)
	/*
	Helper function to evaluate a value, converting it from a string
	representation if necessary.

	@param value any
		The value to be evaluated and potentially converted.

	@return any
		Returns the evaluated value, converted from its string representation
		if applicable.
	*/
	if( listp(value)
	then
		value = foreach(mapcar item value evalstring(item))
	else
		value = evalstring(value)
	);if
	
	value
);procedure
