//
//  main.swift
//  MediaLibraryManager
//
//  Created by Paul Crane on 18/06/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

// TODO create your instance of your library here
var library:MMCollection? = MultiMediaCollection()
var last = MMResultSet()

// The while-loop below implements a basic command line interface. Some
// examples of the (intended) commands are as follows:
//
// load foo.json bar.json
//  from the current directory load both foo.json and bar.json and
//  merge the results
//
// list foo bar baz
//  results in a set of files with metadata containing foo OR bar OR baz
//
// add 3 foo bar
//  using the results of the previous list, add foo=bar to the file
//  at index 3 in the list
//
// add 3 foo bar baz qux
//  using the results of the previous list, add foo=bar and baz=qux
//  to the file at index 3 in the list
//
// Feel free to extend these commands/errors as you need to.
while let line = prompt("> "){
    var command : String = ""
    var parts = line.split(separator: " ").map({String($0)})
    
    do{
        guard parts.count > 0 else {
            throw MMCliError.noCommand
        }
        command = parts.removeFirst();
        switch(command){
        case "load":
            last = try LoadCommandHandler().handle(parts, last:last)
            break
        
        case "list":
            last = try ListCommandHandler().handle(parts, last:last)
            
        case "add":
            last = try AddCommandHandler().handle(parts, last:last)
            break
        
        case "set":
            last = try SetCommandHandler().handle(parts, last: last)
            break
        
        case "del":
            last = try DelCommandHandler().handle(parts, last:last)
            break
            
        case "save":
            last = try SaveCommandHandler().handle(parts, last:last)
            break
            
        case "save-search":
            last = try SaveSearchCommandHandler().handle(parts, last:last)
            break
            
        case "help":
            last = try HelpCommandHandler().handle(parts, last:last)
            break
        
        case "clear":
            last = try ClearCommandHandler().handle(parts, last:last)
            break
            
        case "quit":
            last = try QuitCommandHandler().handle(parts, last:last)
            // so we don't show the results of the previous command
            // (before the quit), we'll continue here instead of breaking
            continue
        default:
            throw MMCliError.unknownCommand
        }
        last.showResults();
    }catch MMCliError.noCommand {
        print("No command given -- see \"help\" for details.")
    }catch MMCliError.unknownCommand {
        print("Command \"\(command)\" not found -- see \"help\" for details.")
    }catch MMCliError.invalidParameters {
        print("Invalid parameters for \"\(command)\" -- see \"help\" for details.")
    }catch MMCliError.unimplementedCommand {
        print("The \"\(command)\" command is not implemented.")
    }catch MMCliError.missingResultSet {
        print("No previous results to work from.")
    }catch MMCliError.invalidFile(let fileName) {
        print("File \(URL(fileURLWithPath: fileName).lastPathComponent) not found.")
    }catch MMCliError.couldNotParse {
        print("Could not successfully parse the file, please check your JSON.")
    }catch MMCliError.couldNotDecode {
        print("Could not decode the json file. Please ensure it follows the expected format:")
        print("[")
        print(" {")
        print("""
                "fullpath": "/path/to/foobar.ext",
              """)
        print("""
                "type": "image|video|document|audio",
              """)
        print("""
                "metadata": {
              """)
        print("""
                    "key1": "value1",
              """)
        print("""
                    "key2": "value1",
              """)
        print("""
                    "...": "...",
              """)
        print("    }")
        print(" },")
        print("...")
        print("]")
    }
}
