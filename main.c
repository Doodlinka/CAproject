#include <stdio.h>
#include <stdlib.h>

#define MAX_ID_LEN 16
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
struct DataPoint* mergeSort(struct DataPoint* arr, struct DataPoint* aux, int length);
void printstr(char str[]);


int main() {   
    struct DataPoint data[MAX_INPUT_AMOUNT];
    int data_length = readDataFromSTDIN(data);
    // printf("data length: %d\n", data_length);
    for (int i = 0; i < data_length; i++) {
        // printf("i: %d\n", i);
        // printf("id: ");
        // printstr(data[i].id);
        // printf(", sum: %ld, count: %d", data[i].avg.fraction.sum, data[i].avg.fraction.count);
        data[i].avg.value = (double)data[i].avg.fraction.sum / data[i].avg.fraction.count;
        // printf(", value: %.3f\n", data[i].avg.value);
    }
    struct DataPoint* aux = malloc(sizeof(char) * data_length);
    struct DataPoint* sorted_data_ptr = mergeSort(data, aux, data_length);
    for (int i = 0; i < data_length; i++) {
        printstr(sorted_data_ptr[i].id);
        printf("\n");
    }
    free(aux);
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

            case SAVE_VALUES: ;
                int record_index = findRecordWithID(data, data_index, current_id);
                // create a new record if there isn't one for the key
                if (record_index == data_index) {
                    movstr(data[record_index].id, current_id);
                    data[record_index].avg.fraction.sum = 0;
                    data[record_index].avg.fraction.count = 0;  
                    data_index++;
                }
                if (negative) current_val = -current_val;
                data[record_index].avg.fraction.sum += current_val;
                data[record_index].avg.fraction.count++;  
                // reset the current values
                id_index = 0;
                current_val = 0;
                fillWithNewlines(current_id);
                negative = false;
                state = READ_ID;
                // consume the second newline characher if it's there
                if (ch == '\r' || ch == '\n') break;

            case READ_ID:
                if (ch == ' ') state = READ_VAL;
                else {
                    current_id[id_index] = (char)ch;
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
    // printstr(current_id);
    for (int i = data_index - 1; i >= 0; i--) {
        bool equals = true;
        for (int j = 0; j < MAX_ID_LEN; j++) {
            if (data[i].id[j] != current_id[j]) {
                equals = false;
                break;
            }
            if (data[i].id[j] == '\n') break;
        }
        if (equals) return i;
    }
    return data_index;
}


void movstr(char dst[], char src[]) {
    for (int i = 0; i < MAX_ID_LEN; i++) {
        dst[i] = src[i];
    }
}


void fillWithNewlines(char str[]) {
    for (int i = 0; i < MAX_ID_LEN; i++) {
        str[i] = '\n';
    }
}


// returns the array that ends up containing the sorted data
struct DataPoint* mergeSort(struct DataPoint* arr, struct DataPoint* aux, int length) {
    for (int width = 1; width < length; width *= 2) {
        int mid = width, right = 2*width;
        if (right >= length) right = length;
        int i = 0, j = width, k = 0;
        for (k = 0; k < length;) {
            if (i < mid && (j >= right || arr[i].avg.value <= arr[j].avg.value)) {
                aux[k] = arr[i];
                i++;
                k++;
            } else {
                aux[k] = arr[j];
                j++;  
                k++;  
            }
            if (k >= right) {
                i = right;
                mid += 2*width;
                if (mid >= length) mid = length;
                right += 2*width;
                if (right >= length) right = length;
                j = mid;
            }
        }
        struct DataPoint* temp = aux;
        aux = arr;
        arr = temp;
    }
    return arr;
}

void printstr(char str[]) {
    for (int i = 0; i < MAX_ID_LEN; i++) {
        if (str[i] == '\n') return;
        printf("%c", str[i]);
    }
}