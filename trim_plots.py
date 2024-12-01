import os
import sys

def delete_files_without_string(directory, search_string):
    # List all files in the directory
    for filename in os.listdir(directory):
        file_path = os.path.join(directory, filename)
        
        # Skip directories, only process files
        if os.path.isfile(file_path):
            # If the file name does not contain the search string, delete it
            if search_string not in filename:
                os.remove(file_path)

def main():
    # Check if the correct number of arguments is provided
    if len(sys.argv) != 2:
        print("Usage: python script.py <search_string>")
        sys.exit(1)

    # Get the search string from the command-line argument
    search_string = sys.argv[1]
    
    # Set the directory to "plots"
    directory = "plots"
    
    # Delete files without the search string
    delete_files_without_string(directory, search_string)

if __name__ == "__main__":
    main()
