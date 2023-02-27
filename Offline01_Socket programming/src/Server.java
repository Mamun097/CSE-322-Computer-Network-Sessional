import java.io.*;
import java.net.ServerSocket;

public class Server {
    public static void main(String[] args) throws IOException {
        ServerSocket serverSocket = new ServerSocket(5028);
        System.out.println("Server started.\nWaiting for connections on port : " + 5028+"\n");

        while (true) {
            Thread thread = new ServerThread(serverSocket.accept());
            thread.start();
        }
    }
}