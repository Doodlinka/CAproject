#include <stdio.h>

#define IN_STR_LEN 25
#define MAX_INPUT_AMOUNT 10000

struct DataPoint
{
    char id[16];
    double avg;
};

enum State {READ_ID, READ_VAL, SKIP_NEWLINE};


int main() {   
    // TODO: make a prefix tree for efficient updating?
    // since i'm reading char by char anyway
    // but keep this list (at least the ids) cuz i'll have to sort it?
    struct DataPoint data[MAX_INPUT_AMOUNT];
    int free_data_index = 0;
    int ch;
    enum State state = READ_ID;
    while ((ch = getchar()) != EOF) {
        if (ch == 0x0D || ch == 0x0A) {

        }
    }
}


void mergeSort() {

}