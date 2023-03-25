package edu.lehigh.cse216.kel323.backend;

import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;

/**
 * Unit test for simple App.
 */
public class DataRowTest extends TestCase {
    /**
     * Create the test case
     *
     * @param testName name of the test case
     */
    public DataRowTest(String testName) {
        super(testName);
    }

    /**
     * @return the suite of tests being tested
     */
    public static Test suite() {
        return new TestSuite(DataRowTest.class);
    }

    /**
     * Ensure that the constructor populates every field of the object it
     * creates
     */
    public void testConstructor() {
        String title = "Test Title";
        String content = "Test Content";
        int id = 17;
        DataRow d = new DataRow(id, title, 5, content); // Must fix

        assertTrue(d.mTitle.equals(title));
        assertTrue(d.mContent.equals(content));
        assertTrue(d.mId == id);
        assertFalse(d.mCreated == null);
    }

    /**
     * Ensure that the copy constructor works correctly
     */
    public void testCopyconstructor() {
        String title = "Test Title For Copy";
        String content = "Test Content For Copy";
        int id = 177;
        DataRow d = new DataRow(id, title, 5, content); // Must fix
        DataRow d2 = new DataRow(d);
        assertTrue(d2.mTitle.equals(d.mTitle));
        assertTrue(d2.mContent.equals(d.mContent));
        assertTrue(d2.mId == d.mId);
        assertTrue(d2.mCreated.equals(d.mCreated));
    }

    public void testFactConstructor() {
        String title = "[Unit Test]: Fact";
        String content = "[Unit Test]: A hand has five fingers.";
        int user_id = 9;
        int id = 17;

        int likes = 10;
        int dislikes = 5;
        String filename = "";
        String filelink = "";

        DataRow d = new DataRow(id, title, user_id, content, likes, dislikes, filename, filelink);

        assertTrue(d.mId == id);
        assertTrue(d.mTitle.equals(title));
        assertTrue(d.mId == id);
        assertTrue(d.mContent.equals(content));
        assertTrue(d.mLikeCount == likes);
        assertTrue(d.mDislikeCount == dislikes);
        assertTrue(d.mFileName.equals(filename));
        assertTrue(d.mFileLink.equals(filelink));
    }

    public void testCopyconstructorCom() {
        String comment = "Test comment";
        int user_id = 13;
        int id = 17;
        int comid = 9;
        int likes = 10;
        int dislikes = 5;
        int postId = 5;
        String filename = "";
        String filelink = "";

        // DataComRow(int comId, String comment, int userId, int id, String fileName,
        // String fileLink) {

        DataComRow d = new DataComRow(comid, comment, user_id, id, filename, filelink);

        assertTrue(d.mComment.equals(comment));
        assertTrue(d.mcomId == comid);
        assertTrue(d.mId == id);
        assertTrue(d.mUserId == user_id);
        assertTrue(d.mFileName.equals(filename));
        assertTrue(d.mFileLink.equals(filelink));

    }

}