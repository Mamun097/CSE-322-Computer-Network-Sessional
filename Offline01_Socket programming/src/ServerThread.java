import java.io.*;
import java.net.Socket;
import java.util.Date;

public class ServerThread extends Thread {
    Socket sct;
    PrintWriter print_writer;
    DataInputStream input_stream;
    DataOutputStream output_stream;
    BufferedWriter bw;
    BufferedReader br;

    public ServerThread(Socket s) {
        sct = s;

        try {
            bw = new BufferedWriter(new FileWriter("log_file.txt", true));
            print_writer = new PrintWriter(sct.getOutputStream());
            output_stream = new DataOutputStream(sct.getOutputStream());
            br = new BufferedReader(new InputStreamReader(sct.getInputStream()));
            input_stream = new DataInputStream(sct.getInputStream());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void run() {
        try {
            String _readline = br.readLine();

            if (_readline == null || _readline.length() == 0) return;

            if (_readline.contains("/favicon.ico")) {
                String response="HTTP/1.1 404 Not Found\r\n" +
                        "Server: Java HTTP Server : 1.0\r\n" +
                        "Date: " + new Date() + "\r\n" +
                        "Content-type: text/html\r\n" +
                        "Content-Length: 0\r\n" +
                        "Connection: close\r\n" +
                        "\r\n";
                print_writer.write(response);
                print_writer.flush();
                return;
            }

            System.out.println("Request: " + _readline);
            bw.write("Request:\n" + _readline + "\n\n");
            bw.flush();

            if (!_readline.startsWith("UPLOAD") && !_readline.startsWith("GET")) {
                print_writer.write("Invalid Request");
                print_writer.flush();
                bw.write("Response:\nInvalid Request\n\n");
                bw.flush();
                return;
            }


            if (_readline.startsWith("GET")) {                              // G E T
                String _content_type = "";
                String _path = _readline.split(" ")[1].replaceAll("%20"," ");

                if (_path.equals("/")) {          //root folder
                    _content_type = "text/html";
                    String str = "<html><body>\n"
                            + "\t<b><i><a href=\"root\">root</a></i></b><br>\n"
                            + "\t<b><i><a href=\"uploaded_files\">uploaded_files</a></i></b>\n"
                            + "</body></html>";

                    //Printing response
                    String response= "HTTP/1.1 200 OK\r\n" +
                            "Server: Java HTTP Server : 1.0\r\n" +
                            "Content-type: " + _content_type + "\r\n" +
                            "Content-Length: " + str.length() + "\r\n" +
                            "Date: " + new Date() + "\r\n" +
                            "\r\n";
                    print_writer.write(response + str);
                    print_writer.flush();
                    bw.write("Response:\n" + response + "\n\n");
                    bw.flush();
                }

                _path = _path.replaceFirst("/", "");
                File dir = new File(_path);
                if (!dir.exists()) {
                    //Printing 404 response
                    String response="HTTP/1.1 404 Not Found\r\n" +
                            "Server: Java HTTP Server : 1.0\r\n" +
                            "Date: " + new Date() + "\r\n" +
                            "Content-type: text/html\r\n" +
                            "Content-Length: 0\r\n" +
                            "Connection: close\r\n" +
                            "\r\n";
                    print_writer.write(response);
                    print_writer.flush();
                    bw.write("Response:\n" + response + "\n\n");
                    bw.flush();
                    return;
                    //force to terminate here
                }

                //if reach here, directory exist
                StringBuilder string_builder = new StringBuilder();
                File[] _list_of_files = dir.listFiles();

                if (_list_of_files != null) {       //directory contains some directories/files
                    _content_type = "text/html";
                    string_builder.append("<html><body>\n");

                    for (int i = 0, list_of_filesLength = _list_of_files.length; i < list_of_filesLength; i++) {
                        File f = _list_of_files[i];
                        if (f.isDirectory()) {
                            String html = "\t<a href=\"/" + f.getPath() + "\"><b><i>" + f.getName() + "</i></b><br>";
                            string_builder.append(html);

                        } else {
                            String extension = "";
                            if (f.getName().contains(".")) {        //not a directory, a file(eg abc.pdf)
                                extension = f.getName().split("\\.")[1];
                            }

                            String html;
                            if (extension.equals("jpg") || extension.equals("txt") || extension.equals("png")) {
                                //show in new html page
                                html = "\t<a href=\"/" + f.getPath() + "\" target=\"blank\">";
                            } else {
                                //enforce downloading
                                html = "\t<a href=\"/" + f.getPath() + "\">";
                            }
                            string_builder.append(html);
                            string_builder.append(f.getName());
                        }
                        string_builder.append("</a><br>\n");
                    }
                    string_builder.append("</body></html>");

                    //Printing response
                    String response= "HTTP/1.1 200 OK\r\n" +
                            "Server: Java HTTP Server : 1.0\r\n" +
                            "Content-type: " + _content_type + "\r\n" +
                            "Content-Length: " + string_builder.toString().getBytes().length + "\r\n" +
                            "Date: " + new Date() + "\r\n" +
                            "\r\n";
                    print_writer.write(response + string_builder.toString());
                    print_writer.flush();
                    bw.write("Response:\n" + response + "\n\n");
                    bw.flush();
                    return;
                }

                // requested url is a file
                String extension = "";
                if (dir.getName().contains(".")) {
                    extension = dir.getName().split("\\.")[1];
                }
                if (extension.equalsIgnoreCase("txt")) {
                    _content_type = "text/plain";

                } else if (extension.equals("png") || extension.equals("jpg")) {
                    _content_type = "image; Format:" + extension;

                } else {
                    _content_type = "application/octet-stream";

                }

                //Printing response
                String response= "HTTP/1.1 200 OK\r\n" +
                        "Server: Java HTTP Server : 1.0\r\n" +
                        "Content-type: " + _content_type + "\r\n" +
                        "Content-Length: " + (int) dir.length() + "\r\n" +
                        "Date: " + new Date() + "\r\n" +
                        "\r\n";
                print_writer.write(response + "");
                print_writer.flush();
                bw.write("Response:\n" + response + "\n\n");
                bw.flush();


                FileInputStream inputStream = new FileInputStream(dir);
                byte[] buffer = new byte[32];   //chunk size 32 byte
                int read;
                while (true) {
                    if ((read = inputStream.read(buffer)) == -1) break;
                    output_stream.write(buffer, 0, read);
                    output_stream.flush();
                }
                inputStream.close();
                return;
            }

            if (_readline.startsWith("UPLOAD")) {                                   // U P L O A D
                if (_readline.split(" ").length == 2) {
                    String response = "HTTP/1.1 200 OK\r\n" +
                            "Server: Java HTTP Server : 1.0\r\n" +
                            "Content-type: text/html\r\n" +
                            "Date: " + new Date() + "\r\n" +
                            "\r\n";

                    bw.write("Response:\n" + response + "\n\n");
                    bw.flush();
                    print_writer.write(response + "");
                    print_writer.flush();

                    String[] temp = _readline.split(" ")[1].split("/");
                    String name = temp[temp.length - 1];
                    FileOutputStream _output_stream = new FileOutputStream("uploaded_files/" + name);

                    int data;
                    byte[] buffer = new byte[32];
                    long length = input_stream.readLong();

                    while (true) {
                        if (length <= 0 || (data = input_stream.read(buffer, 0, (int) Math.min(buffer.length, length))) == -1) {
                            break;
                        } else {
                            _output_stream.write(buffer, 0, data);
                            _output_stream.flush();
                        }
                    }
                    _output_stream.close();
                    System.out.println("\nUpload complete: " + name);
                }
                else {           //format should be: UPLOAD img.jpg
                    print_writer.write("Invalid Request");
                    print_writer.flush();
                    bw.write("Response:\nInvalid request\n\n");
                    bw.flush();
                }
            }

        } catch (Exception e) {
            e.printStackTrace();

        } finally {
            try {
                bw.close();
                sct.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}