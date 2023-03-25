package edu.lehigh.cse216.kel323.backend;

import com.google.api.client.auth.oauth2.Credential;
import com.google.api.client.extensions.java6.auth.oauth2.AuthorizationCodeInstalledApp;
import com.google.api.client.extensions.jetty.auth.oauth2.LocalServerReceiver;
import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeFlow;
import com.google.api.client.googleapis.auth.oauth2.GoogleClientSecrets;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.googleapis.media.MediaHttpUploader;
import com.google.api.client.googleapis.media.MediaHttpUploaderProgressListener;
import com.google.api.client.auth.oauth2.Credential;
import com.google.api.client.googleapis.auth.oauth2.GoogleCredential;
import com.google.api.client.auth.oauth2.CredentialRefreshListener;
import com.google.api.client.auth.oauth2.DataStoreCredentialRefreshListener;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.client.json.jackson2.JacksonFactory;
import com.google.api.client.util.store.FileDataStoreFactory;
import com.google.api.services.drive.Drive;
import com.google.api.services.drive.DriveScopes;
import com.google.api.services.drive.Drive.Files.Create;
import com.google.api.services.drive.model.File;
import com.google.api.services.drive.model.FileList;
// import com.google.api.services.drive.model.ParentReference;
import com.google.api.client.http.FileContent;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.*;
import java.security.GeneralSecurityException;
import java.util.Collections;
import java.util.List;
import java.util.Arrays;
import java.io.ByteArrayOutputStream;

import com.google.api.client.auth.oauth2.Credential;
import com.google.api.client.extensions.java6.auth.oauth2.AuthorizationCodeInstalledApp;
import com.google.api.client.extensions.jetty.auth.oauth2.LocalServerReceiver;
import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeFlow;
import com.google.api.client.googleapis.auth.oauth2.GoogleClientSecrets;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.client.util.store.FileDataStoreFactory;
import com.google.api.services.drive.Drive;
import com.google.api.services.drive.DriveScopes;
import com.google.api.services.drive.model.File;
import com.google.api.services.drive.model.FileList;

class CustomProgressListener implements MediaHttpUploaderProgressListener {
    public void progressChanged(MediaHttpUploader uploader) throws IOException {
        switch (uploader.getUploadState()) {
            case INITIATION_STARTED:
                System.out.println("Initiation has started!");
                break;
            case INITIATION_COMPLETE:
                System.out.println("Initiation is complete!");
                break;
            case MEDIA_IN_PROGRESS:
                System.out.println(uploader.getProgress());
                break;
            case MEDIA_COMPLETE:
                System.out.println("Upload is complete!");
        }
    }
}

public class DriveQuickstart {

    private static final String APPLICATION_NAME = "Google Drive API Java Quickstart";
    private static final JsonFactory JSON_FACTORY = GsonFactory.getDefaultInstance();
    private static final String TOKENS_DIRECTORY_PATH = "tokens";
    private static final String dirID = "1PHLkPn9TlsFbgXwSKDz-YZhyhlpVslZg";
    /**
     * Global instance of the scopes required by this quickstart.
     * If modifying these scopes, delete your previously saved tokens/ folder.
     */
    private static final List<String> SCOPES = Collections.singletonList(DriveScopes.DRIVE_FILE);
    private static final String CREDENTIALS_FILE_PATH = "/credentials.json";

    private static NetHttpTransport HTTP_TRANSPORT;
    private static Drive service;

    public static boolean setup() throws GeneralSecurityException, IOException {
        // Build a new authorized API client service.
        try {
            HTTP_TRANSPORT = GoogleNetHttpTransport.newTrustedTransport();
            service = new Drive.Builder(HTTP_TRANSPORT, JSON_FACTORY, getCredentials(HTTP_TRANSPORT))
                    .setApplicationName(APPLICATION_NAME)
                    .build();
            System.out.println("here?: " + service.about());
            System.out.println(service.getBaseUrl());
            System.out.println(service.getRootUrl());

            return true;
        } catch (Exception e) {
            System.out.println("An error occurred: " + e);
            return false;
        }
        // final NetHttpTransport HTTP_TRANSPORT =
        // GoogleNetHttpTransport.newTrustedTransport();
        // service = new Drive.Builder(HTTP_TRANSPORT, JSON_FACTORY,
        // getCredentials(HTTP_TRANSPORT))
        // .setApplicationName(APPLICATION_NAME)
        // .build();

        // System.out.println("here?: "+service.about());

        // return false;
    }

    /**
     * Getter for NetHttpTransport object
     */
    public static NetHttpTransport getNetHttpTransport() {
        return HTTP_TRANSPORT;
    }

    /**
     * Getter for Drive object
     */
    public static Drive getDrive() {
        try {
            setup();
        } catch (GeneralSecurityException e) {
            System.out.println("GeneralSecurityException lolz");
            e.printStackTrace();
        } catch (IOException e) {
            System.out.println("IOException lolz");
            e.printStackTrace();
        }
        return service;
    }

    /**
     * Creates an authorized Credential object.
     * 
     * @param HTTP The network HTTP Transport.
     * @return An authorized Credential object.
     * @throws IOException If the credentials.json file cannot be found.
     */
    // String accessToken = "";
    // private static Credential getCredentials(final NetHttpTransport
    // HTTP_TRANSPORT) throws IOException {

    // GoogleCredential credential = new
    // GoogleCredential().setAccessToken(accessToken);
    // Plus plus = new Plus.builder(new NetHttpTransport(),
    // GsonFactory.getDefaultInstance(),
    // credential)
    // .setApplicationName("Google-PlusSample/1.0")
    // .build();

    // // Load client secrets.
    // InputStream in =
    // DriveQuickstart.class.getResourceAsStream(CREDENTIALS_FILE_PATH);
    // if (in == null) {
    // throw new FileNotFoundException("Resource not found: " +
    // CREDENTIALS_FILE_PATH);
    // }
    // GoogleCredential credential = GoogleCredential.fromStream(in)
    // .createScoped(SCOPES);

    // return credential;
    // }

    /**
     * Creates an authorized Credential object.
     * 
     * @param HTTP_TRANSPORT The network HTTP Transport.
     * @return An authorized Credential object.
     * @throws IOException If the credentials.json file cannot be found.
     */
    // private static Credential getCredentials(final NetHttpTransport
    // HTTP_TRANSPORT) throws IOException {
    // // Load client secrets.
    // InputStream in =
    // DriveQuickstart.class.getResourceAsStream(CREDENTIALS_FILE_PATH);
    // if (in == null) {
    // throw new FileNotFoundException("Resource not found: " +
    // CREDENTIALS_FILE_PATH);
    // }
    // GoogleClientSecrets clientSecrets = GoogleClientSecrets.load(JSON_FACTORY,
    // new InputStreamReader(in));

    // // Build flow and trigger user authorization request.
    // GoogleAuthorizationCodeFlow flow = new GoogleAuthorizationCodeFlow.Builder(
    // HTTP_TRANSPORT, JSON_FACTORY, clientSecrets, SCOPES)
    // .setDataStoreFactory(new FileDataStoreFactory(new
    // java.io.File(TOKENS_DIRECTORY_PATH)))
    // .setAccessType("online")
    // .build();
    // LocalServerReceiver receiver = new
    // LocalServerReceiver.Builder().setPort(8888).build();
    // Credential credential = new AuthorizationCodeInstalledApp(flow,
    // receiver).authorize("user");
    // //returns an authorized Credential object.
    // return credential;
    // }
    private static Credential getCredentials(final NetHttpTransport HTTP_TRANSPORT) throws IOException {
        // Load client secrets.
        InputStream in = DriveQuickstart.class.getClass().getResourceAsStream(CREDENTIALS_FILE_PATH);
        if (in == null) {
            System.out.println("res not found");
            throw new FileNotFoundException("Resource not found: " + CREDENTIALS_FILE_PATH);
        }
        GoogleCredential credential = GoogleCredential.fromStream(in).createScoped(SCOPES);
        return credential;
    }

    /**
     * Uploads file into Drive
     *
     * @param service     Static variable that was created for the DriveQuickstart
     *                    class
     * @param title       Name of the file
     * @param description Description of file being uploaded
     * @param parentId    Optional parent folder's ID
     * @param mimeType    MIME type of the file being uploaded
     * @return File that was uploaded
     */
    // public static String insertFile(Drive service, String title, java.io.File
    // file, String mimeType) {
    // // File's metadata.
    // File body = new File();
    // String file_id ="";
    // body.setName(title);
    // body.setMimeType(mimeType);

    // // File's content.
    // java.io.File fileContent = file;
    // FileContent mediaContent = new FileContent(mimeType, fileContent);
    // try {
    // System.out.println("body: "+body);
    // System.out.println("mediaContent: "+mediaContent);
    // Create request = service.files().create(body, mediaContent);
    // // request.getMediaHttpUploader().setProgressListener(new
    // CustomProgressListener());
    // // request.execute();
    // // System.out.println("mediaContenttest: " + service.files().insert(body,
    // mediaContent).execute());
    // // newFile.getId();
    // }
    // catch (Exception e) {
    // System.out.println("An error occurred: " + e);
    // e.printStackTrace();
    // return null;
    // }
    // String link="";
    // try {
    // link = service.files().get(file_id).toString();
    // System.out.println("link: "+link);
    // } catch (IOException e) {
    // // TODO Auto-generated catch block
    // e.printStackTrace();
    // }
    // return link;
    // }
    public static String insertFile(Drive service, String title, java.io.File file, String mimeType) {
        String id = "";
        File fileMetadata = new File();

        fileMetadata.setName(title);
        // fileMetadata.setParents(parents)

        // dirID.add("1yHdxfzLrJ_gqmmB8Gu08WYlRDgA2cLgL");
        fileMetadata.setParents(Collections.singletonList(dirID));
        // java.io.File filePath = new java.io.File("files/"+title);
        FileContent mediaContent = new FileContent(mimeType, file);
        // System.out.println("heloooo");
        File file2 = null;
        try {
            file2 = service.files().create(fileMetadata, mediaContent)
                    .setFields("id, webContentLink, webViewLink")
                    .execute();
            id = file2.getId();
            System.out.println("id: " + id);

        } catch (IOException e) {
            System.out.println("exception thrown in insert file");
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        if (mimeType == "application/pdf") {
            return ("https://drive.google.com/open?id=" + id);
        }
        return ("https://drive.google.com/thumbnail?id=" + id);
    }

    /**
     * Downloads file from Drive
     *
     * @param fileId of the file to be downloaded from Drive
     * @return Byte array stream of the data for the file
     */
    public static ByteArrayOutputStream getFile(Drive service, String fileId) {
        try {
            ByteArrayOutputStream stream = new ByteArrayOutputStream();
            service.files().get(fileId).executeMediaAndDownloadTo(stream);
            return stream;
        } catch (Exception e) {
            System.out.println("Error obtaining file");
            return null;
        }
    }

    /**
     * Deletes file from Drive
     *
     * @param fileId of the file to be deleted from Drive
     * @return True if succesfully deleted from Drive, false if not
     */
    public static boolean deleteFile(Drive service, String fileId) {
        try {
            service.files().delete(fileId).execute();
            return true;
        } catch (Exception e) {
            System.out.println("Error deleting file");
            return false;
        }
    }

}