package edu.lehigh.cse216.kel323.backend;

/**
 * SimpleComRequest provides a format for clients to present comments.
 * 
 * NB: since this will be created from JSON, all fields must be public, and we
 * do not need a constructor.
 */
public class SimpleComRequest {
    /**
     * The title being provided by the client.
     */
    public String mComment;

    /**
     * The file type of the attachment.
     */

    public int fileType;

    /**
     * The file name of the attachment.
     */

    public String uploadFileName;

    /**
     * The file data of the attachment.
     */

    public String uploadData;

    /**
     * The file data of the attachment.
     */

    public String mKey;

}