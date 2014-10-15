// to compile without worry about classpath issues, add -cp .:lib/* 

import org.marc4j.MarcReader;
import org.marc4j.MarcStreamReader;
import org.marc4j.marc.Record;
import java.io.InputStream;
import java.io.FileInputStream;

public class ReadMarcExample {

    public static void main(String args[]) throws Exception {

		System.out.println(args[0]);

    InputStream in = new FileInputStream(args[0]);
        MarcReader reader = new MarcStreamReader(in);
        while (reader.hasNext()) {
             Record record = reader.next();
             System.out.println(record.toString());
        }    

    }

}