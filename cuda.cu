#include <stdio.h>
#include <stdlib.h>


__global__ void p1(int* indices, int n, int* result){
    for(int i = threadIdx.x; i < n; i+=blockDim.x){
        result[i] = indices[i+1] - indices[i];
    }
}   



__global__ void p2_3(int* p1, int* c3, int* indices, int* data, int n, int* result1, int* result2){
    
    for(int i = blockIdx.x * blockDim.x + threadIdx.x; i < n; i+=blockDim.x * gridDim.x){
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
    

    FILE* ind;
    int num_ind;
    ind = fopen("indices.txt","r");
    fscanf(ind,"%d\n",&num_ind);
    int* host_ind = (int*)malloc(sizeof(int)*num_ind);
    int* indices;
    cudaMalloc((void**)&indices,num_ind*sizeof(int));

    for(int i = 0; i < num_ind; i++){
        fscanf(ind,"%d\n",&host_ind[i]);
    }    
    cudaMemcpy(indices,host_ind,num_ind*sizeof(int),cudaMemcpyHostToDevice);


    int num_data;
    ind = fopen("data.txt","r");
    fscanf(ind,"%d\n",&num_data);
    int* host_data = (int*)malloc(sizeof(int)*num_data);
    int* data; 
    cudaMalloc((void**)&data,num_data*sizeof(int));

    for(int i = 0; i < num_data; i++){
        fscanf(ind,"%d\n",&host_data[i]);
    }    
    cudaMemcpy(data,host_data,num_data*sizeof(int),cudaMemcpyHostToDevice);
    int n = num_ind-1;

    int* d1;
    int* d2;
    int* d3;
    int* d4;

    cudaMalloc((void**)&d1,n*sizeof(int));
    cudaMalloc((void**)&d2,n*sizeof(int));
    cudaMalloc((void**)&d3,n*sizeof(int));
    cudaMalloc((void**)&d4,n*sizeof(int));

    printf("Data copied for host to device, Finding Nodes' degree...\n");
    p1<<<1,1024>>>(indices,n,d1);
    cudaDeviceSynchronize();

    printf("Nodes' degree found, Calculating 3-cliques...\n");

    c3<<<4,1024>>>(indices,n,data,d4);
    cudaDeviceSynchronize();
    printf("3-cliques found, Calculating 2-paths and biforks...\n");



    p2_3<<<1,1024>>>(d1,d4,indices,data,n,d2,d3);
    cudaDeviceSynchronize();
    printf("All Done\n");


    // cudaMemcpy(host1,d1,n*sizeof(int),cudaMemcpyDeviceToHost);
    // cudaMemcpy(host2,d4,n*sizeof(int),cudaMemcpyDeviceToHost);

    // for(int i = 0; i < n; i++){
    //     printf("%d %d %d\n",host1[i], host2[i],i);
    // }
    //int** l = p2_3(host,m,&x[0],&y[0],6);
    

    // for(int i = 0; i < 6; i ++){
    //     printf("%d %d %d %d\n",host[i],l[0][i],l[1][i], m[i]);
    // }
 
    cudaFree(d1);
    cudaFree(d2);
    cudaFree(d3);
    cudaFree(d4);

    return 0;
}
