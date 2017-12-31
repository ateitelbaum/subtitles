/*It worked!!!*/
/*
  subtitles.c - a CGI program that returns a subtitle file
 */
/* $begin subtitles */
#include "csapp.h"
#include <regex.h>
/*
int parseLink(char *line){
  regex_t regex;
  char *reg;
  reg = "<link>.*subtitles.*</link>";
  int compReg;
  compReg = (&regex, reg, REG_EXTENDED);
  if(regexec(&regex, line, (size_t) 0, NULL, 0)!=0){
    printf("no match");
      }
}
*/

int main() {
  char* url = "file.//localhost/Users/rivkagreenberg/Documents/signup-submit.php?name=The+dark+night";
  char *buf, *p;
  char arg1[MAXLINE], content[MAXLINE];
  int n1=0, n2 = 0;

  /* Extract the two arguments */
  if ((buf = getenv("QUERY_STRING")) != NULL) {
    printf("%s", arg1);
	
  }

  

  rio_t rio;

  char *host = "subsmax.com";
  char *port = "80";

  int clientfd;
  clientfd = Open_clientfd(host, port);
  Rio_readinitb(&rio, clientfd);
  
  char *getRequest = "GET http://subsmax.com/api/10/matrix HTTP/1.1\r\nHost:80.255.11.149\r\n\r\n\r\n";
  Rio_writen(clientfd, getRequest, strlen(getRequest));
  char result[1000];
  int i;
  for(i = 0; i < 1000; i++){
    Rio_readlineb(&rio, result, 1000);
    /* int x = parseLink(result);*/
    /* printf("%d", result); */
  }
  
  
	 

    

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
