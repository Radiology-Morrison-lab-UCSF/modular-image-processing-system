import subprocess

def RunExecutable(executable_path:str, args=None):
    """
    Runs the specified executable and waits for it to complete.

    :param executable_path: Path to the executable.
    :param args: List of arguments to pass to the executable (optional).
    :return: The standard output of the executable if successful.
    :raises subprocess.CalledProcessError: If the executable fails.
    """
    if args is None:
        args = []

    try:
        # Run the executable and wait for it to complete
        result = subprocess.run(
            [executable_path] + args, 
            check=True, 
            capture_output=True, 
            text=True
        )
        
        print(result.returncode)

        # Return the standard output if successful
        return result.stdout
    
    except subprocess.CalledProcessError as e:
        # Handle error: print the error message and raise an exception
        print(f"Error: The executable failed with exit code {e.returncode}")
        print("Error Output:", e.stderr)  # Print error output if any
        raise  # Re-raise the exception to signal failure