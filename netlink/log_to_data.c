/*
 * (c) 2008-2011 Daniel Halperin <dhalperi@cs.washington.edu>
 */
#include "iwl_connector.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <linux/netlink.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>

#define MAX_PAYLOAD 2048
#define SLOW_MSG_CNT 1

int sock_fd = -1;							// the socket
FILE* out = NULL;

void check_usage(int argc, char** argv);

FILE* open_file(char* filename, char* spec);

void caught_signal(int sig);

void exit_program(int code);
void exit_program_err(int code, char* func);
void get_file_size(char* filename);
void sequence_generator(int *sequence, char gesture[9][15], int index_of_gesture, int mode);

int main(int argc, char** argv)
{	//printf("start  \n");
	check_usage(argc, argv);
	/* Local variables */
	//printf("??? \n");
	struct sockaddr_nl proc_addr, kern_addr;	// addrs for recv, snow, bind
	struct cn_msg *cmsg;
	char buf[4096];
	int ret;
	unsigned short l, l2;
	int count = 0;
	char* name = argv[1];
	char* filename[50];
	strcopy(filename, argv[1]);
	strcopy(filename, "_");
	strcopy(filename, argv[2]);
	int index_of_gesture = atoi(argv[2]); // require mode 0
	int mode = atoi(argv[3]);
	int expected_count = 0;
	if (mode == 0){
		expected_count = 95 * 1000;
	}
	else{
		expected_count = 95 * 1000;
	}
	int factor = 1;
	int expected_time = expected_count * 1000 * factor;
	int expected_interval = 1000;

	struct timespec start, now;
	int32_t total_time_used =0;
	int time_record = 0;
	int last_record = 0;
	int last_record_2 = 0;
	int start_indicator = 0;
	int now_indicator = 0;
	char gesture[9][15] = {
		"swipe left", // swipe right hand from left to right
		"swipe right",
		"swipe down",
		"swipe up",
		"circle left", // circle from left to right
		"circle right" // circle from right to left
		"draw circle",
		"draw zigzag",
		"double tap",
	};
	//printf("gesture %s", gesture[0] );
	int current_gesture = 0;
	int sequence[30];
	sequence_generator(sequence, gesture, index_of_gesture, mode);

	printf("Expected count %d, expected interval %d, expected time %dus\n", expected_count, expected_interval, expected_time);

	/* Make sure usage is correct */
	

	/* Open and check log file */
	out = open_file(filename, "w");
	//printf("build socket \n");
	/* Setup the socket */
	sock_fd = socket(PF_NETLINK, SOCK_DGRAM, NETLINK_CONNECTOR);
	if (sock_fd == -1)
		exit_program_err(-1, "socket\n");

	//printf("Initialize the address structs \n");
	/* Initialize the address structs */
	memset(&proc_addr, 0, sizeof(struct sockaddr_nl));
	proc_addr.nl_family = AF_NETLINK;
	proc_addr.nl_pid = getpid();			// this process' PID
	proc_addr.nl_groups = CN_IDX_IWLAGN;
	memset(&kern_addr, 0, sizeof(struct sockaddr_nl));
	kern_addr.nl_family = AF_NETLINK;
	kern_addr.nl_pid = 0;					// kernel
	kern_addr.nl_groups = CN_IDX_IWLAGN;

	//printf("Now bind the socket  \n");
	/* Now bind the socket */
	if (bind(sock_fd, (struct sockaddr *)&proc_addr, sizeof(struct sockaddr_nl)) == -1)
		exit_program_err(-1, "bind \n ");

	//printf("subscribe to netlink group  \n");
	/* And subscribe to netlink group */
	{
		int on = proc_addr.nl_groups;
		ret = setsockopt(sock_fd, 270, NETLINK_ADD_MEMBERSHIP, &on, sizeof(on));
		if (ret)
			exit_program_err(-1, "setsockopt \n ");
	}


	//printf("Set up the caught_signal \n");
	/* Set up the "caught_signal" function as this program's sig handler */

	printf("Socket set up. Ready to receive packet! \n");
	signal(SIGINT, caught_signal);  
	struct timeval timeout = {5,expected_interval*5};
	setsockopt(sock_fd, SOL_SOCKET, SO_RCVTIMEO, (char *)&timeout, sizeof(struct timeval));
	/* Poll socket forever waiting for a message */
	while (1)
	{		


		if (count >= expected_count) {
			printf("count %d >= expected_count %d, exit\n", count, expected_count);
			break;
 		}		
 		else if ((int)total_time_used > expected_time ) {
			printf("total_time_used > expected_time \n");
			break;
 		}		
		/* Receive from socket with infinite timeout */
		ret = recv(sock_fd, buf, sizeof(buf), 0);

		if (ret == -1){
			printf("timeout in 5.000001 second\n");
			total_time_used -= 5.000001 * 1000000;
			//exit_program_err(-1, "recv \n");
			break;
		}

		/* Pull out the message portion and print some stats */
		cmsg = NLMSG_DATA(buf);

		/*
		if (count % SLOW_MSG_CNT == 0)
			printf("received %d bytes: id: %d val: %d seq: %d clen: %d\n", cmsg->len, cmsg->id.idx, cmsg->id.val, cmsg->seq, cmsg->len);
		Log the data to file */


		l = (unsigned short) cmsg->len;
		l2 = htons(l);
		fwrite(&l2, 1, sizeof(unsigned short), out);
		ret = fwrite(cmsg->data, 1, l, out);
		int divide = (int) expected_count / 10;
		if (start_indicator == 0){
			clock_gettime(CLOCK_MONOTONIC, &start);
			start_indicator = 1;
			printf("Begin recording packet!!! \n");
			//printf("start time stamp %lus %luus\n",start.tv_sec, start.tv_nsec/1000); 
		}

		//if (count % divide == 0){
			//printf("wrote %d bytes [msgcnt=%u] \n", ret, count);}
		//if (count > divide * 5){
			//printf("round %d \n", count);
		//	now_indicator = 1;
		//}
		
 		++count;
		if (ret != l){
			exit_program_err(1, "fwrite \n");
		}		
		clock_gettime(CLOCK_MONOTONIC, &now);
		/*
		last_record_2 =  (now.tv_sec - start.tv_sec) ;

		if (time_record != last_record){
			printf("%d \n", time_record);
			last_record = time_record;
		}
		*/
		time_record =  (now.tv_sec - start.tv_sec) *1000+  (now.tv_nsec - start.tv_nsec)/1000000;	
		if (time_record - last_record == 3000){
			last_record = time_record;
			last_record_2 = last_record;
			printf("\n");
			printf("The %dth gesture: %s \n", current_gesture, gesture[sequence[current_gesture]]);
			int timestamp = now.tv_sec *1000000 + now.tv_nsec/1000;
			printf("Current time in us is %d \n", timestamp);
			current_gesture += 1;
		}
		if(time_record - last_record_2 == 500 ){
			last_record_2 = time_record;
			//printf("%f second \n", (float)(time_record - last_record) /1000);
			printf("..... ");
			fflush(stdout);
		}
	
	}
	printf("\n");
	printf("finished record \n")
	clock_gettime(CLOCK_MONOTONIC, &now);
	total_time_used +=  (now.tv_sec - start.tv_sec)*1000000 +  (now.tv_nsec - start.tv_nsec)/1000;	
	printf("count %d, expected_count %d, ", count, expected_count);
	printf("expected_time %d, ", expected_time/factor); // us
	printf("used_time %d, ", total_time_used); // us
	get_file_size(filename);
	exit_program(0);
	return 0;
}

void check_usage(int argc, char** argv)
{
	if (argc != 5)
	{	
		fprintf(stderr, "Usage: %s name gesture_index mode\n", argv[0]);
		exit_program(1);
	}
	printf("creating %s_%s \n", argv[1], argv[2]);
}

FILE* open_file(char* filename, char* spec)
{
	FILE* fp = fopen(filename, spec);
	if (!fp)
	{
		perror("fopen");
		exit_program(1);
	}
	return fp;
	printf("opening %s", filename);
}

void caught_signal(int sig)
{
	fprintf(stderr, "Caught signal %d\n", sig);
	exit_program(0);
}

void exit_program(int code)
{
	if (out)
	{
		fclose(out);
		out = NULL;
	}
	if (sock_fd != -1)
	{
		close(sock_fd);
		sock_fd = -1;
	}
	exit(code);
}

void exit_program_err(int code, char* func)
{	
	perror(func);
	exit_program(code);
}

void get_file_size(char* filename)
{
	struct stat stat_buf;
	stat(filename, &stat_buf);
	printf("%s filesize %ld \n", filename, stat_buf.st_size);
	//return rc == 0 ? stat_buf.st_size : -1;
}

void sequence_generator(int *sequence, char gesture[9][15], int index_of_gesture, int mode)
{

	// mode 0, same gesture for the whole time
	// mdoe 1, random gesture sequence

	if (mode ==0){
		int i = 0;
		printf("Clean mode: You need to perform gesture %s for 30 times! \n", gesture[index_of_gesture]);
		printf("The sequence is ");
		for (i = 0; i<30; ++i){
			sequence[i] = index_of_gesture;
			printf("%d", index_of_gesture);
		}
		printf("\n");
		
	}
	else{
		srand((unsigned) time(NULL));
		int i = 0;
		printf("Random mode: You need to perform 30 different gesture.\nThe sequence is ");
		for (i = 0; i<30; ++i){
			sequence[i] = rand()%9;
			//printf("%s, ", gesture[sequence[i]]);
			printf("%d", sequence[i]);
		}
		printf("\n");
	}
}
