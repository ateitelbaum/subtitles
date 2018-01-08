/*subtitles.c - a CGI program that returns a subtitle file*/
#include "csapp.h"
#include <stdio.h>
#include <regex.h>
#include <string.h>
#include <libxml/xmlmemory.h>
#include <libxml/parser.h>*/

/* finds element in the XML doc and returns cur pointing to it */

char* elementExtracter(xmlNodePtr cur, char* element){
  cur = cur->xmlChildrenNode;
  while (cur != NULL){
    if ((!xmlStrcmp(cur->name, (const xmlChar *)element))){
      return cur;
    }
    cur = cur-> next;
  }
}


char* XMLParser(char* file){
  xmlDocPtr doc;
  xmlNodePtr cur; 


/* loads the string into a tree */

doc = xmlParseDoc(file);
  if (doc == NULL){
    fprintf(stderr, "Document not parsed successfully.");
    return;
  }


/* gets a pointer to the root of the tree */


  cur = xmlDocGetRootElement(doc);
  if (cur == NULL){
    fprintf(stderr, "empty document\n");
    xmlFreeDoc(doc);
    return;
  }


  /*goes through tree */ 


  cur = elementExtracter(cur, "items");
  cur = elementExtracter(cur, "item");
  cur = elementExtracter(cur, "link");


/* returns the content of the element link */


  return (char*)xmlNodeGetContent(cur);
}


int main() {
  char *p, *title1;
  char buf[MAXLINE], title2[MAXLINE], getrequest[MAXLINE];
  title1 = malloc(MAXLINE);
  
   printf("Content-type: text/html\r\n\r\n");

   
  /* Extract the movie title */
   if (getenv("QUERY_STRING") != NULL) strcpy(buf, getenv("QUERY_STRING"));
   else strcpy(buf,"movietitle=foo+is+movie+");
   p = strchr(buf,'=');
  
   
    strcpy(title1, p+1);
    
    p = title2;
   
    while(*title1 != '\0'){
      if (*title1 == '+'){
	*p = '-';
      }
      else{
	*p = *title1;
      }
      title1++;
      p++;
    }


  rio_t rio;

  char *host = "subsmax.com";
  char *port = "80";

  int clientfd;
  
  clientfd = Open_clientfd(host, port);
  Rio_readinitb(&rio, clientfd);

  /*Send GET request to the API*/

  strcpy(getrequest, "GET http://subsmax.com/api/10/en-");
  strcat(getrequest, title2);
  strcat(getrequest, " HTTP/1.1\r\nHost:80.255.11.149\r\n\r\n\r\n");
  
  Rio_writen(clientfd, getrequest, strlen(getrequest));
  char result[100000];
  char buf2[1000];
  int j;
  for(j=0; j<14; j++){
    Rio_readlineb(&rio, buf2, 1000);
  }
  while(Rio_readlineb(&rio, buf2, 1000)){
    if (buf2[0] != '0'){
	strcat(result, buf2);
      }
  }
  
  char* l = XMLParser(result);
  
  /* getting html */
  char *htmlRequest;
  htmlRequest = calloc("\0",MAXLINE);
  strcpy(htmlRequest, "GET ");
  strcat(htmlRequest, l);
  strcat(htmlRequest, "/index.html HTTP/1.1\r\nHost:80.255.11.149\r\n\r\n\r\n");
  clientfd = Open_clientfd(host, port);
  Rio_readinitb(&rio, clientfd);
  Rio_writen(clientfd, htmlRequest, strlen(htmlRequest));
  char *buf3;
  char *result2;
  buf3 = malloc(MAXLINE);
  result2 = malloc(MAXLINE);
  for(j=0; j<14; j++){
    Rio_readlineb(&rio, buf3, 1000);
  }

  /* parsing html */
  while(Rio_readlineb(&rio, buf3, MAXLINE)){
    if (buf3[12] == '<' && buf3[13] == 'B'){
      strcpy(result2, buf3);
      char *newline = strrchr(result2, '\n');
      Rio_readlineb(&rio, buf3, MAXLINE);
      Rio_readlineb(&rio, buf3, MAXLINE);
      strcpy(newline, buf3);
      char *start = memchr(result2, 'h', 100) +6;
      char *stop = memchr(start, '"', 100);
      memcpy(l, start, stop-start);
      break;
    }
  }

  /*Return subtitles on screen*/
  
  printf("<!DOCTYPE html>\n<html>\n<body style=\"background-color:black;\">\n<h1 style=\"color:red;\">Click on the link below for your subtitles!</h1>\n<img src=\"http://portugalresident.com/sites/default/files/field/image/t-hill-s-top-movies-of-2011-so-far-.jpg\" width=\"316\" height=\"272\">\n<p></p>\n<a style=\"font-size: 50px; color:red;\" href=\"");
  printf("%s", l);
  printf("\">Retrieve your Subtitles</a>\n</body>\n</html>");
  
  exit(0);
}
