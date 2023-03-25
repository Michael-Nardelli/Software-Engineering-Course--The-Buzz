package edu.lehigh.cse216.kel323.backend;

/**
 * SimpleRequest provides a format for clients to present title and message
 * strings to the server.
 * 
 * NB: since this will be created from JSON, all fields must be public, and we
 * do not need a constructor.
 */
public class SimpleRequest {
    /**
     * The title being provided by the client.
     */
    public String mTitle;

    /**
     * The message being provided by the client.
     */

    public String mMessage;

    /**
     * The message being provided by the client.
     */

    public String mContent;

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

}