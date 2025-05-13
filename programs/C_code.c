void for_loop()
{
    int fib = 1;
    int prev = 0;
    int temp = 0;
    for (int i = 0; i < 10; i++)
    {
        temp = fib;
        fib += prev;
        prev = temp;
    }
}

int main()
{
    for_loop();
    return 0;
}

