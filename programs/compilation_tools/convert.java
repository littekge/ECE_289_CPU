import java.io.File;
import java.util.Scanner;
import java.io.PrintWriter;

class convert {
    public static void main(String[] args) {
        File inputFile = new File("programs\\compilation_tools\\program.hex");
        File outputFile = new File("memory\\program.mif");
        int count = 1000;
        try {
            PrintWriter out = new PrintWriter(outputFile);
            Scanner in = new Scanner(inputFile);
            out.println("WIDTH=32;");
            out.println("DEPTH=65536;");
            out.println("ADDRESS_RADIX=UNS;");
            out.println("DATA_RADIX=HEX;");
            out.println("CONTENT BEGIN");
            out.println("[0..999] : 0;");
            while (in.hasNextLine()) {
                out.printf("%d : %s;\n", count, in.nextLine());
                count++;
            }
            out.printf("[%d..65535] : 0;\n", count);
            out.println("END;");
            in.close();
            out.close();
        } catch (Exception e) {
            System.out.println(e);
            System.out.println("conversion failed");
        }
    
    }
}