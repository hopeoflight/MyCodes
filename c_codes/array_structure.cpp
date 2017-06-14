#include <stdio.h>

struct A
{
    char a;
	int b;
	float c;
	int* d; 
	char e;
};

struct B
{
    struct A a;
    int* p;
	char e;
	struct A b;
	char c;
	short int d;
	double r;
	char q;
};

struct C
{
	int a;
	double b;
	char c;
	short e;
	short f;
	int *d;
	char g;
};

void show(int* arr,int x,int y)
{
    for(int i = 0;i < x;++i)
	{
	    for(int j = 0;j < y;++j)
		{
		    printf("arr[%d][%d]=%d ",i,j,*(arr+i*y+j));
		}
		printf("\n");
	}
}
// 二维数组在空间中存放连续的地址，仍然是一级指针
void fun()
{
	int a[3][4] = {{1,2,3},{4,5,6,7},{8,9}};
	int b[3][4] = {1,2,3,4,5,6,7,8,9};

	printf("a[1]+4=%2d\nb[1]+4=%2d\n",*(a[1]+4),*(b[1]+4));
	printf("array a:\n");
	show((int*)a,3,4);
	printf("array b:\n");
	show((int*)b,3,4);
	
}


void main()
{
	printf("A:%2d\nB:%2d\nC:%2d\n",sizeof(struct A),sizeof(struct B),sizeof(struct C));
	printf("char:%02d,short int:%02d,int:%02d,float:%02d,double:%02d,int*:%02d\n",
		sizeof(char),sizeof(short int),sizeof(int),sizeof(float),sizeof(double),sizeof(int*));

	fun();
}

/****** 结构体对齐和补齐规则：
*******1.成员变量占用空间的起始位置是成员变量占用空间大小的整数倍 
*******2.结构体的总大小，必须是结构体成员中占用空间最大的成员变量占用空间大小的整数倍
*******3.结构体成员变量中的结构体成员，不参与对齐 
*******/
