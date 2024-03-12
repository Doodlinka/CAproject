#include <stdio.h>

#define MAX_STR_LEN 25
#define MAX_INPUT_AMOUNT 10000
#define ASCII_INT_OFFSET 48

#define bool char
#define false 0
#define true 1

struct DataPoint
{
    char id[16];
    union {
        struct {
            signed long int sum;
            unsigned short int count;
        } fraction;
        double value;
    } avg;
};

enum ReadState {READ_ID, READ_VAL, SAVE_VALUES};


int readDataFromSTDIN(struct DataPoint data[]);
int findRecordWithID(struct DataPoint data[], int data_index, char current_id[]);
void movstr(char dst[], char src[]);
void fillWithNewlines(char str[]);
// struct DataPoint[] mergeSort()


int main() {   
    struct DataPoint data[MAX_INPUT_AMOUNT];
    int data_length = readDataFromSTDIN(data);
    // TODO: convert average fractions to doubles
}


// reads into provided array, returns the length used
int readDataFromSTDIN(struct DataPoint data[]) {
    int data_index = 0, id_index = 0;
    int ch = 0, current_val = 0;
    char current_id[16];
    fillWithNewlines(current_id);
    bool negative = false;
    enum ReadState state = READ_ID;

    while ((ch = getchar()) != EOF) {
        switch (state) {

            case SAVE_VALUES:
                int index = findRecordWithID(data, data_index, current_id);
                if (index == data_index) {
                    movstr(data[index].id, current_id);
                    data[index].avg.fraction.sum = 0;
                    data[index].avg.fraction.count = 0;  
                }
                data[index].avg.fraction.sum += current_val;
                data[index].avg.fraction.count++;  
                // reset the current values
                id_index = 0;
                current_val = 0;
                fillWithNewlines(current_id);
                negative = false;
                state = READ_ID;
                // consume the second newline characher if it's there
                if (ch == '\r' || ch == '\n') break;

            case READ_ID:
                if (ch = ' ') state = READ_VAL;
                else {
                    current_id[id_index] = ch;
                    id_index++;
                }
                break;

            case READ_VAL:
                if (ch == '\r' || ch == '\n') state = SAVE_VALUES;
                else if (ch == '-') negative = true;
                else {
                    current_val *= 10;
                    current_val += ch - ASCII_INT_OFFSET;
                }
        }
    }

    return data_index;
}


int findRecordWithID(struct DataPoint data[], int data_index, char current_id[]) {
    for (int i = data_index - 1; i >= 0; i--) {
        bool equals = true;
        for (int j = 0; j < MAX_STR_LEN; j++) {
            if (data[i].id[j] == '\n') break;
            if (data[i].id[j] != current_id[j]) {
                equals = false;
                break;
            }
        }
        if (equals) return i;
    }
    return data_index;
}


void movstr(char dst[], char src[]) {
    for (int i = 0; i < MAX_STR_LEN; i++) {
        dst[i] = src[i];
    }
}


void fillWithNewlines(char str[]) {
    for (int i = 0; i < MAX_STR_LEN; i++) {
        str[i] = '\n';
    }
}


// returns the array that ends up containing the sorted data
// struct DataPoint[] mergeSort() {

// }