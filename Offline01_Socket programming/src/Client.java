import java.io.IOException;
import java.util.Scanner;

public class Client {
    public static void main(String[] args) throws IOException {
        Scanner s = new Scanner(System.in);
            while (true) {
                new ClientThread(s.nextLine()).start();
            }
    }
}
