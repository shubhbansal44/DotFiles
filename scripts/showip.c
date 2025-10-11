#define _POSIX_C_SOURCE 200112L
#include<stdio.h>
#include<string.h>
#include<sys/socket.h>
#include<netdb.h>
#include<sys/types.h>
#include<arpa/inet.h>
#include<netinet/in.h>

int main(int argc, char *argv[]) {
    struct addrinfo hints, *p, *res;
    int status;
    char ipstr[INET6_ADDRSTRLEN];

    if(argc != 2) {
        fprintf(stderr, "usage: showip <host>\n");
        return 1;
    }

    memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;

    char *query = argv[1];

    if((status = getaddrinfo(query, NULL, &hints, &res)) != 0) {
        fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(status));
        return 1;
    }

    printf("IP Address(s) For %s:\n\n", query);

    for(p = res; p != NULL; p = p->ai_next) {
        void *addr;
        void *ipver;
        struct sockaddr_in *ipv4;
        struct sockaddr_in6 *ipv6;

        if(p->ai_family == AF_INET) {
            ipv4 = (struct sockaddr_in *)p->ai_addr;
            addr = &(ipv4->sin_addr);
            ipver = "IPv4";
        } else {
            ipv6 = (struct sockaddr_in6 *)p->ai_addr;
            addr = &(ipv6->sin6_addr);
            ipver = "IPv6";
        }

        inet_ntop(p->ai_family, addr, ipstr, sizeof ipstr);
        printf(" %s: %s\n", ipver, ipstr);
    }

    freeaddrinfo(res);
    return 0;
}