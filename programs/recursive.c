int factorial(int n)
{
    int result;
    int temp;
    if (n==0)
        return 1;
    else {
        temp = factorial(n - 1);
        result = n + temp;
        return result;
    }
}

int main() {
    factorial(10);
    return 0;
}