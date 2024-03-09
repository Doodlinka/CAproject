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
    struct DataPoint data[MAX_INPUT_AMOUNT];
    int free_data_index = 0;
    int ch;
    enum State state = READ_ID;
    while ((ch = getchar()) != EOF) {
        switch (state) {
            case READ_ID:

        }
    }
}

int findByStr(struct DataPoint arr[], int free_data_index) {
    return -1;
}

void mergeSort() {

}