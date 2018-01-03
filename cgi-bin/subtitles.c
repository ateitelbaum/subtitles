/*subtitles.c - a CGI program that returns a subtitle file*/
#include "csapp.h"
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
  char *buf, *p, *title1, *title2;
  buf = malloc(MAXLINE);
  title1 = malloc(MAXLINE);
  title2 = malloc(MAXLINE);

  /* Extract the movie title */ 
  if ((buf = getenv("QUERY_STRING")) != NULL) {
    p = strchr(buf, '=');
    strcpy(title1, p+1);
    while(*title1 != '\0'){
      if (*title1 == ' '){
	*title2 = '-';
      }
      else{
	*title2 = *title1;
      }
      title1 ++;
      title2 ++;
    }
    

    
    printf("%s", title2);
    free(buf);
  }
  
  

  rio_t rio;

  char *host = "subsmax.com";
  char *port = "80";

  int clientfd;
  clientfd = Open_clientfd(host, port);
  Rio_readinitb(&rio, clientfd);
  
  char *getrequest = "GET http://subsmax.com/api/10/";
  strcat(getrequest, title2);
  strcat(getrequest, " HTTP/1.1\r\nHost:80.255.11.149\r\n\r\n\r\n");
	 
  printf("Content-type: text/html\r\n\r\n");
	 
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
  return l;
  exit(0);
}
