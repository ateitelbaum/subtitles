/*
  subtitles.c - a CGI program that returns a subtitle file
 */
/* $begin subtitles */
#include "csapp.h"

int main() {
  /*  char *buf, *p;
    char arg1[MAXLINE], arg2[MAXLINE], content[MAXLINE];
    int n1=0, n2 = 0

    /* Extract the two arguments */
  /*  if ((buf = getenv("QUERY_STRING")) != NULL) {
	p = strchr(buf, '&');
	*p = '\0';
	strcpy(arg1, buf);
	
    }

  */

  char *host = "subsmax.com";
  char *port = "80";
  printf("w");
  int clientfd;
  clientfd = Open_clientfd(host, port);

  char *getRequest = "GET http://subsmax.com/api/10/matrix HTTP/1.1 \
	 Host: 80.255.11.149\r\n \r\n \r\n";
  send(clientfd, getRequest, strlen(getRequest), 0);

  
  
	 

    

    /* Make the response body */
    /*    sprintf(content, "Welcome to Ayliana's add.com: ");
    sprintf(content, "%sTHE Internet addition portal.\r\n<p>", content);
    sprintf(content, "%sThe answer is: %d + %d = %d\r\n<p>", 
	    content, n1, n2, n1 + n2);
    sprintf(content, "%sThanks for visiting!\r\n", content);
  
    /* Generate the HTTP response */
    /*  printf("Connection: close\r\n");
    printf("Content-length: %d\r\n", (int)strlen(content));
    printf("Content-type: text/html\r\n\r\n");
    printf("%s", content);
    fflush(stdout);
    */
    exit(0);
}
/* $end adder */
