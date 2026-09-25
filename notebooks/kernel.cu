__global__ void half_active_per_warp(float *out, const float *in, int n) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    int lane = threadIdx.x % 32;
    if (tid >= n) {
        return;
    }
    int data = 0;
    device_function(data);
    if (lane & 0xF0F0F0F0) {
        out[tid] = in[tid] * 2.0f + data;
    }
}

// We will dispatch this kernel with a grid of (256,1,1). There are 128 thread slots in the entire (theoretical) GPU, 
// 32 threads per warp. The dispatch currently has an Achieved Occupancy of 10%. Why is the occupancy so low? 
// Note: the & operator in C++ is a "bitwise AND", 'lane & 0xF0F0F0F0' means every bit in lane is AND'd with the corresponding bit in '0xF0F0F0F0'

__global__ void kernelToRun(const float* input_current, const float* mem0, const float* threshold, int32_t B, int32_t H, float* spikes, float* final_mem)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int total = B * H;
    if (idx >= total) return;
    float mem = mem0[idx];
    device_func(&mem, idx % H, b_val & 0xFF1122);
    final_mem[idx] = mem;
}

void reference(
    const float* inout_current, // length of B*H
    const float* mem0 // length of B*H
    const float* threshold, //length of H*1000
    int32_t B, int32_t H,
    float* spikes, // length of B*H
    float* final_mem // length of B*H
)
{
    int total = B * H;
    int blockSize = 256;
    int gridSize = (total + blockSize - 1) / blockSize - 1) / blockSize;
    kernelToRun<<<gridSize, blockSize>>>(input_current, mem0, threshold, B, H, spikes, final_mem);
}

// You are given the following metrics from a NSight Compute profile (do not assume the exact CUDA device capabilities; do not assume anything about implementation);

| Metric | Value | Unit |
|---|---:|---|
| DRAM Throughput | 12.25 | % |
| L1/TEX Cache Throughput | 11.28 | % |
| L2 Cache Throughput | 12.00 | % |
| Compute (SM) Throughput | 13.43 | % |
| Registers Per Thread | 32 | register/thread |
| Theoretical Occupancy | 100 | % |
| Achieved Occupancy | 10.50 | % |

// The kernel above was launched with the following inputs for B, and H: B = 32, H = 32, Assume register spilling does not occur.
// 1. If possible, describe an optimization for the kernel that will reduce its runtime by increasing 'DRAM THroughput' (assume the inputs are unchanged). Describe why ths will 
//    help performance.
// 2. Why is Achieved Occupancy low?

__global__ void convolution_kernel(
    const float* input,
    float* output,
    int width,
    int height
) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;
    if (x < width && y < height) {
        const float kernel[5][5] = {
            {0.0f, 0.0f, 0.0f, 0.0f},
            {0.0f, 0.0f, 0.0f, 0.0f},
            {0.0f, 0.0f, 0.0f, 0.0f},
            {0.0f, 0.0f, 0.0f, 0.0f},
            {0.0f, 0.0f, 0.0f, 0.0f}
        };
        float sum = 0.0f;
        for (int ky = -2; ky <= 2; ky++) {
            for (int kx = -2; kx <= 2; kx++) {
                int nx = x + kx;
                int ny = y + ky;
                if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
                    int neighborIdx = ny * width + nx;
                    sum += input[neighborIdx] * kernel[ky + 2][kx + 2];
                }
            }
        }
        output[y * width + x] = sum;
    }
}
// How would we optimize this kernel? Please do not write code, but rather describe in text the approach you would take.
// You may write as little or as much as you would like for a solution.