/*
Run external tools.
A practical example of how to run external scripts and tools using two
main approaches - system() and ipcBeginProcess() functions.

Usage example:
    ; Copy file with system()
    filePath = "./myfile"
	destinationPath = "./new_file"
    copyFile(filePath destinationPath)

    ; Run script in shell with system()
    scriptFile = "/tmp/myScript.sh"
    runScriptInShell(scriptFile)

    ; Run command and read its output with ipcBeginProcess()
    command = "find . -name '*.txt'"
    output = readCommandOutput(command)
    printf("%s\n" output)

    ; Run command and use handlers to read its output on-the-fly with ipcBeginProcess()
    command = "find . -name '*.txt'"
    runCommandWithHandlers(command)


Author: Eugeny Khanchin
Source: AnalogHub.ie
*/


procedure( copyFile(filePath destinationPath)
    let( (command exitCode)
        sprintf(command "cp %s %s" filePath destinationPath)
        
        exitCode = system(command)
        if( exitCode == 0
        then
            printf("Succeeded to copy file\n")
        else
            printf("Failed to copy file\n")
        );if
    );let
);procedure


procedure( runScriptInShell(scriptFile)
    let( (command exitCode)
        sprintf(command "sh %s" scriptFile)
        
        exitCode = system(command)
        if( exitCode == 0
        then
            printf("Succeeded to run the script\n")
        else
            printf("Failed to run the script\n")
        );if
    );let
);procedure


procedure( readCommandOutput(command)
    let( (process output nextLine)
        process = ipcBeginProcess(command)
        ipcWait(process)
        
        output = ""
        while( nextLine = ipcReadProcess(process)
            output = strcat(output nextLine)
        );while
        
        output
    );let
);procedure


procedure( runCommandWithHandlers(command)
    ipcBeginProcess(
        command
        ""  ; Local
        'readData
        'readError
        'exitHandler
    )
);procedure


procedure( readData(childId data)
	; Do data handling stuff here
	printf("Process: %d\nOutput:\n%s\n" childId data)
);procedure


procedure( readError(childId data)
	; Do error handling stuff here
	printf("Process: %d\nOutput:\n%s\n" childId data)
);procedure


procedure( exitHandler(childId exitStatus)
	; Do post processing stuff here
	printf("Process %d finished with code %d\n" childId exitStatus)
);procedure
