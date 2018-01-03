/*subtitles.c - a CGI program that returns a subtitle file*/
#include "csapp.h"
#include <regex.h>
#include <libxml/xmlmemory.h>
#include <libxml/parser.h>

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
/* goes through tree */ 
  cur = elementExtracter(cur, "items");
  cur = elementExtracter(cur, "item");
  cur = elementExtracter(cur, "link");
/* returns the content of the element link */
  return (char*)xmlNodeGetContent(cur);
}

int main() {
  /*
  char* url = "file.//localhost/Users/rivkagreenberg/Documents/signup-submit.php?name=The+dark+night";
  char *buf, *p;
  char arg1[MAXLINE], content[MAXLINE];
  int n1=0, n2 = 0;

  /* Extract the two arguments 
  if ((buf = getenv("QUERY_STRING")) != NULL) {
    printf("%s", arg1);
	
  }
  */
  

  rio_t rio;

  char *host = "subsmax.com";
  char *port = "80";

  int clientfd;
  clientfd = Open_clientfd(host, port);
  Rio_readinitb(&rio, clientfd);
  
  char *getRequest = "GET http://subsmax.com/api/10/Snow-White HTTP/1.1\r\nHost:80.255.11.149\r\n\r\n\r\n";
  Rio_writen(clientfd, getRequest, strlen(getRequest));
  char result[100000];
  char buf[1000];
  int j;
  for(j=0; j<14; j++){
    Rio_readlineb(&rio, buf, 1000);
  }
  while(Rio_readlineb(&rio, buf, 1000)){
    if (buf[0] != '0'){
	strcat(result, buf);
      }
  }
  char* l = XMLParser(result);
  printf("%s", l);
  exit(0);
}
