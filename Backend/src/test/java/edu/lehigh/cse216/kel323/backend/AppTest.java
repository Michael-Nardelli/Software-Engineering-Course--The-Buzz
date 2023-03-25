package edu.lehigh.cse216.kel323.backend;

import java.util.Base64;

import com.google.gson.*;

import org.apache.commons.io.FileUtils;

import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;

/**
 * Unit test for simple App.
 */
public class AppTest
        extends TestCase {

    /**
     * Create the test case
     *
     * @param testName name of the test case
     */
    public AppTest(String testName) {
        super(testName);
    }

    /**
     * Create the test case
     *
     * @param testName name of the test case
     */

    /**
     * @return the suite of tests being tested
     */
    public static Test suite() {
        return new TestSuite(AppTest.class);
    }

    /**
     * Rigourous Test :-)
     */
    public void testApp() {
        assertTrue(true);
    }

    public void testStructuredResponseConstructor() {
        String status = "ok";
        String message = "test message";
        Object data = 1;
        StructuredResponse s = new StructuredResponse(status, message, data);
        assertTrue(s.mStatus.equals(status));
        assertTrue(s.mMessage.equals(message));
        assertTrue(s.mData.equals(data));

        assertFalse(s.mStatus == null || s.mStatus.equals("invalid"));
        assertFalse(s.mData == null);
    }

    public void testSimpleRequest() {
        SimpleRequest req = new SimpleRequest();
        String title = "test title";
        String message = "test message";
        req.mTitle = title;
        req.mMessage = message;
        assertTrue(req.mTitle.equals(title));
        assertTrue(req.mMessage.equals(message));
    }

    // Tests the new simpleComRequest
    public void testSimpleComRequest() {
        SimpleComRequest req = new SimpleComRequest();
        String title = "test title";
        req.mComment = title;
        assertTrue(req.mComment.equals(title));
    }

    // public void insertSelectTestAttachment(String db_url, SimpleRequest req) {
    // Database db = Database.getDatabase(db_url);
    // String title0 = "select test title";
    // String msg0 = "select test message";
    // String id = "";
    // String filename = "";
    // String filelink = "";
    // String newFileLink ="";
    // String filetype = "img";
    // boolean special = false;

    // byte[] imageBytes;
    // try {
    // imageBytes = Base64.getDecoder().decode(req.uploadData);
    // System.out.println("imageBytes: "+imageBytes);
    // java.io.File fileToInsert = new java.io.File(req.uploadFileName);
    // FileUtils.writeByteArrayToFile(fileToInsert, imageBytes);
    // newFileLink = DriveQuickstart.insertFile(DriveQuickstart.getDrive(),
    // req.uploadFileName, fileToInsert, filetype);
    // System.out.println("hello "+ newFileLink);
    // //insert into database
    // }
    // catch(Exception e) {
    // System.out.println("exception thrown");
    // }
    // // int filesize = 0;
    // // //int selectID = db.insertRow(title0, msg0, id, filename, filelink,
    // filesize, special, date);
    // // int selectID = db.insertRow(id, title0, msg0, filename, filelink,
    // filesize, special);
    // // DataRow d0 = db.selectOne(selectID);
    // // assertFalse(d0 == null);
    // }

}
