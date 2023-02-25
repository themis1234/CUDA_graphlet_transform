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
            //printf("%d %d\n",width_i,width_j);
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
    int x[7] = {0,2,6,9,13,17,18};
    int y[18] = {1,4,0,2,3,4,1,3,4,1,2,4,5,0,1,2,3,3};
    int* k = p1(&x[0],6);
    int* m = c3(&x[0],6,&y[0]);
    int** l = p2_3(k,m,&x[0],&y[0],6);

    for(int i = 0; i < 6; i ++){
        printf("%d %d %d %d\n",k[i],l[0][i],l[1][i], m[i]);
    }

    return 0;
}
