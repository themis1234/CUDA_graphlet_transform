#include <stdio.h>
#include <stdlib.h>


int* p1(int* indices, int n){
    int* result = malloc(sizeof(int)*n);
    for(int i = 0; i < n; i ++){
        result[i] = indices[i+1] - indices[i];
    }
    return result;
}



int** p2_3(int* p1, int* c3, int* indices, int* data, int n){
    int* result1 = calloc(sizeof(int),n);
    int* result2 = calloc(sizeof(int),n);
    int** result = malloc(sizeof(int*)*2);
    for(int i = 0; i < n; i++){
        for(int j = indices[i]; j < indices[i+1]; j++){
            result1[i] += p1[data[j]];
        }
        result1[i]-=(p1[i]+2*c3[i]);
        result2[i] = p1[i]*(p1[i]-1)/2-c3[i];
    }
    result[0] = result1;
    result[1] = result2;
    return result;
}

int* c3(int* indices, int n, int* data){
    int col;
    int* result = calloc(sizeof(int),n);
    for(int i = 0; i < n; i++){//All nodes
        int start_i = indices[i];
        int end_i = indices[i+1];
        int width_i = end_i-start_i;
        for(int j = start_i; j < end_i; j++){//CSC
            col = data[j];
            int start_j = indices[col];
            int width_j = indices[col+1] - start_j;
            int idx_i = 0;
            int idx_j = 0;
            while(idx_i<width_i&&idx_j<width_j)//matrix mult
            {
                if(data[start_i+idx_i]==data[start_j+idx_j]){
                    result[i]++;
                    idx_i++;
                    idx_j++;
                    continue;
                }
                if(data[start_i+idx_i]>data[start_j+idx_j]){
                    idx_j++;
                    continue;
                }
                else{
                    idx_i++;
                }
            }
        }
        result[i] = result[i]/2;
    }
    return result;
}




int main(int argc, char const *argv[])
{
    FILE* ind;
    int num_ind;
    ind = fopen("indices.txt","r");
    fscanf(ind,"%d\n",&num_ind);
    int* indices = malloc(sizeof(int)*num_ind);
    for(int i = 0; i < num_ind; i++){
        fscanf(ind,"%d\n",&indices[i]);
    }    


    int num_data;
    ind = fopen("data.txt","r");
    fscanf(ind,"%d\n",&num_data);
    int* data = malloc(sizeof(int)*num_data);
    for(int i = 0; i < num_data; i++){
        fscanf(ind,"%d\n",&data[i]);
    }    
    int n = num_ind-1;

    printf("Finging Nodes' degree");
    int* k = p1(indices,n);
    printf("Nodes' degree found, Calculating 3-cliques...\n");
    int* m = c3(indices,n,data);
    printf("3-cliques found, Calculating 2-paths and biforks...\n");

    int** l = p2_3(k,m,indices,data,n);
    printf("All Done\n");



    return 0;
}
