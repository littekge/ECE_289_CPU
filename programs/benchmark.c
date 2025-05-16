

void while_loop() {
    int a = 300;
    while (a != 1)
    {
        if (a % 2 == 0)
        {
            a = a / 2;
        }
        else 
        {
            a = 3 * a + 1;
        }
    }   
}

int main() {
    while_loop();
    return 0;
}