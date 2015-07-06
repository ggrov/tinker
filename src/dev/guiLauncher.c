#include <stddef.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>
#include <string.h>


int openGUI(const char *path, const char *version) {
	
	char jarFile[100];
	strcpy(jarFile, path);
	strcat(jarFile,"tinkerGUI-");
	strcat(jarFile,version);
	strcat(jarFile,".jar");

	int status;
	pid_t pid;
	pid = fork ();
	if (pid == 0) {
      /* This is the child process.  Execute the shell command. */
		execlp ("java", "java", "-jar", jarFile, NULL);
		_exit (EXIT_FAILURE);
	}
	else if (pid < 0)
    /* The fork failed.  Report failure.  */
		status = -1;
	else {
    /* This is the parent process.  Wait for the child to complete.  */
		return pid;
		// if (waitpid (pid, &status, 0) != pid)
		// 	status = -1;
	}
	return status;
}

int closeGUI(const int pid) {
	int status = 0;
	kill(pid, SIGKILL);
	if (waitpid (pid, &status, 0) != pid)
		status = -1;
	return status;
}

// int main() {
// 	int success = openGUI("/home/pierre/Documents/HW/Tinker/tinkerGit/tinker/src/tinkerGUI/release/", "0.3");
// 	int c = 1, d = 1;
 
//    for ( c = 1 ; c <= 50000 ; c++ )
//        for ( d = 1 ; d <= 50000 ; d++ )
//        {}
// 	int successClose = closeGUI(success);
// }