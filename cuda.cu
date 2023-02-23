#include <stdio.h>
#include <stdlib.h>


__global__ void p1(int* indices, int n, int* result){
    
    for(int i = threadIdx.x; i < n; i+=blockDim.x){
        result[i] = indices[i+1] - indices[i];
    }
}   



__global__ void p2_3(int* p1, int* c3, int* indices, int* data, int n, int* result1, int* result2){
    
    for(int i = threadIdx.x; i < n; i+=blockDim.x){
        result1[i] = 0;
        result2[i] = 0;
        for(int j = indices[i]; j < indices[i+1]; j++){
            result1[i] += p1[data[j]];
        }
        result1[i]-=(p1[i]+2*c3[i]);
        result2[i] = p1[i]*(p1[i]-1)/2-c3[i];
    }
    
}

__global__ void c3(int* indices, int n, int* data, int* result){
    int col;
    for(int i = threadIdx.x; i < n; i+=blockDim.x){//All nodes
        if(i<n){
            result[i] = 0;
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
    }
}


int main(int argc, char const *argv[])
{
    int x[7] = {0,2,6,9,13,17,18};
    int y[18] = {1,4,0,2,3,4,1,3,4,1,2,4,5,0,1,2,3,3};
    int* d1;
    int* d2;
    int* d3;
    int* d4;
    int* ind;
    int* data;
    int* host1 = (int*)malloc(sizeof(int)*6);
    int* host2 = (int*)malloc(sizeof(int)*6);

    cudaMalloc((void**)&ind,7*sizeof(int));
    cudaMalloc((void**)&data,18*sizeof(int));
    cudaMemcpy(ind,&x[0],7*sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(data,&y[0],18*sizeof(int),cudaMemcpyHostToDevice);

    cudaMalloc((void**)&d1,6*sizeof(int));
    cudaMalloc((void**)&d2,6*sizeof(int));
    cudaMalloc((void**)&d3,6*sizeof(int));
    cudaMalloc((void**)&d4,6*sizeof(int));

    
    p1<<<1,1024>>>(ind,6,d1);

    c3<<<1,1024>>>(ind,6,data,d4);

    p2_3<<<1,2>>>(d1,d4,ind,data,6,d2,d3);

    cudaMemcpy(host1,d2,6*sizeof(int),cudaMemcpyDeviceToHost);
    cudaMemcpy(host2,d3,6*sizeof(int),cudaMemcpyDeviceToHost);

    for(int i = 0; i < 6; i++){
        printf("%d %d\n",host1[i], host2[i]);
    }
    //int** l = p2_3(host,m,&x[0],&y[0],6);
    

    // for(int i = 0; i < 6; i ++){
    //     printf("%d %d %d %d\n",host[i],l[0][i],l[1][i], m[i]);
    // }
 
    cudaFree(d1);
    cudaFree(d4);

    return 0;
}
