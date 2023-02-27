import java.io.*;
import java.net.Socket;

public class ClientThread extends Thread {
    String _readline;
    Socket sct;
    PrintWriter print_writer;
    DataOutputStream output_stream;
    BufferedReader br;

    public ClientThread(String str) throws IOException {
        _readline = str;
        sct = new Socket("localhost", 5028);
        print_writer = new PrintWriter(sct.getOutputStream());
        br = new BufferedReader(new InputStreamReader(sct.getInputStream()));
        output_stream = new DataOutputStream(sct.getOutputStream());
    }

    @Override
    public void run() {
        try {
            if (!_readline.startsWith("UPLOAD")) {
                // send the _request to server
                print_writer.println(_readline);
                print_writer.flush();
                // read the response from server
                String temp = br.readLine();
                System.out.println(temp);
                return;
            }

            String fileName = _readline.split(" ")[1];
            File file = new File(fileName);
            if (file.isDirectory()) {
                String _error="Directory cannot be uploaded";
                System.out.println(_error);
                print_writer.println(_error);
                print_writer.flush();
                return;
            }
            if (!file.exists()) {
                String _error="File not found!";
                System.out.println(_error);
                print_writer.println(_error);
                print_writer.flush();
                return;
            }

            String extension=fileName.split("\\.")[1];
            if (extension.matches("txt|csv|html|htm|log|mp4|gif|jpeg|jpg|png")) {

                print_writer.println(_readline);
                print_writer.flush();

                // read the response from server
                String response = br.readLine();
                System.out.println(response);

                if (response.contains("OK")) {
                    print_writer.println("UPLOADING...");
                    print_writer.flush();
                    System.out.println("Server is ready to receive file");
                    System.out.println("Uploading file: " + fileName);

                    // upload the file to server
                    try {
                        FileInputStream input_stream = new FileInputStream(file);
                        output_stream.writeLong(file.length());
                        output_stream.flush();

                        int data;
                        byte[] buffer = new byte[32];
                        while (true) {
                            if ((data = input_stream.read(buffer)) == -1) break;
                            output_stream.write(buffer, 0, data);
                            output_stream.flush();
                        }
                        System.out.println();
                        input_stream.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    System.out.println("Uploaded file: " + fileName);
                }
                else {
                    System.out.println("Request rejected!");
                    print_writer.println("CANCEL");
                    print_writer.flush();
                }
            }

            else {
                String _error = "File format not supported!";
                System.out.println(_error);
                print_writer.println(_error);
                print_writer.flush();
                return;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
//        finally {
//            try {
//                sct.close();
//            } catch (IOException e) {
//                e.printStackTrace();
//            }
//        }
    }
}