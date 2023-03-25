package edu.lehigh.cse216.kel323.backend;

// Import the Spark package, so that we can make use of the "get" function to 
// create an HTTP GET route
import spark.Spark;

import com.google.gson.*;

import org.apache.commons.io.FileUtils;

import java.io.FileOutputStream;
import java.io.IOException;
import java.lang.reflect.Field;
import java.security.GeneralSecurityException;
// import java.util.Collections;
import java.util.Map;
import java.util.concurrent.TimeoutException;

import com.google.api.client.http.FileContent;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.gson.GsonFactory;

import java.util.logging.*;

import com.google.api.client.auth.oauth2.Credential;
import com.google.api.client.extensions.java6.auth.oauth2.AuthorizationCodeInstalledApp;
import com.google.api.client.extensions.jetty.auth.oauth2.LocalServerReceiver;
import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeFlow;
import com.google.api.client.googleapis.auth.oauth2.GoogleClientSecrets;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken.Payload;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.util.store.FileDataStoreFactory;
import com.google.api.services.drive.Drive;
import com.google.api.services.drive.DriveScopes;
import com.google.api.services.drive.model.File;
import com.google.api.services.drive.model.FileList;

import net.rubyeye.xmemcached.MemcachedClient;
import net.rubyeye.xmemcached.MemcachedClientBuilder;
import net.rubyeye.xmemcached.XMemcachedClientBuilder;
import net.rubyeye.xmemcached.auth.AuthInfo;
import net.rubyeye.xmemcached.command.BinaryCommandFactory;
import net.rubyeye.xmemcached.exception.MemcachedException;
import net.rubyeye.xmemcached.utils.AddrUtil;

import java.lang.InterruptedException;
import java.net.InetSocketAddress;
import java.io.IOException;
import java.util.List;
import java.util.concurrent.TimeoutException;

import java.util.Arrays;
import java.util.Base64;
import java.util.Hashtable;
import java.util.List;
import java.net.InetSocketAddress;

/**GENERAL TO DO
 * Update SelectAll and SelectOne to include comments
 * Fix likeStatus information to work correctly
 * How does ouath API work?
 * Table Creation Attempts
 */

/**
 * For now, our app creates an HTTP server that can only get and add data.
 */
/**
 * The main routine runs a loop that gets a request from the user and
 * processes it
 * 
 * @param argv Command-line options. Ignored by this program.
 */

public class App {
    private static final Logger LOGGER = Logger.getLogger(App.class.getName());
    public static Hashtable<String, String> users_hashtable = new Hashtable<String, String>();

    // users_hashtable.get
    public static void main(String[] args) throws GeneralSecurityException, IOException {

        // Get the port on which to listen for requests
        Spark.port(getIntFromEnv("PORT", 4567));

        // get the Postgres configuration from the environment
        setEnv("MEMCACHIER_SERVERS", "mc1.dev.ec2.memcachier.com:11211");
        setEnv("MEMCACHIER_USERNAME", "B5A031");
        setEnv("MEMCACHIER_PASSWORD", "DF5C9603D640173A5B404DBBBE1FA04D");
        setEnv("DATABASE_URL",
                "postgres://ytwhcceyowndem:67468aedb6de7dfc4dbb32e8c2c07d54ecbccbf3b506b7e79ab5ebac6091f4b2@ec2-34-224-226-38.compute-1.amazonaws.com:5432/dc1vnlqcg514jo");
        Map<String, String> env = System.getenv();
        String ip = env.get("POSTGRES_IP");
        String port = env.get("POSTGRES_PORT");
        String user = env.get("POSTGRES_USER");
        String pass = env.get("POSTGRES_PASS");
        String db_url = env.get("DATABASE_URL");

        User dummy = new User("", "", true, "", "", "", "", "", "");
        // Get a fully-configured connection to the database, or exit
        // immediately
        Database db = Database.getDatabase(db_url);
        // Database db = Database.getDatabase(db_url);
        if (db == null)
            return;
        else
            System.out.println("\nPOSTGRES DATABASE CONNECTED!\n");

        // Set up the location for serving static files. If the STATIC_LOCATION
        // environment variable is set, we will serve from it. Otherwise, serve
        // from "/web"
        String static_location_override = System.getenv("STATIC_LOCATION");
        if (static_location_override == null) {
            Spark.staticFileLocation("/web");
        } else {
            Spark.staticFiles.externalLocation(static_location_override);
        }

        String cors_enabled = env.get("CORS_ENABLED");
        final String acceptCrossOriginRequestsFrom = "*";
        final String acceptedCrossOriginRoutes = "GET,PUT,POST,DELETE,OPTIONS";
        final String supportedRequestHeaders = "Content-Type,Authorization,X-Requested-With,Content-Length,Accept,Origin";
        enableCORS(acceptCrossOriginRequestsFrom, acceptedCrossOriginRoutes, supportedRequestHeaders);

        // cache connection
        List<InetSocketAddress> servers = AddrUtil.getAddresses(System.getenv("MEMCACHIER_SERVERS").replace(",", " "));
        AuthInfo authInfo = AuthInfo.plain(System.getenv("MEMCACHIER_USERNAME"), System.getenv("MEMCACHIER_PASSWORD"));
        MemcachedClientBuilder builder = new XMemcachedClientBuilder(servers);
        for (InetSocketAddress server : servers) {
            builder.addAuthInfo(server, authInfo);
        }
        builder.setCommandFactory(new BinaryCommandFactory());
        builder.setConnectTimeout(1000);
        builder.setEnableHealSession(true);
        builder.setHealSessionInterval(2000);

        try {
            MemcachedClient cache = builder.build();
            // google drive for file uplaod
            // GoogleDriveInit init = new GoogleDriveInit();
            NetHttpTransport HTTP_TRANSPORT = GoogleNetHttpTransport.newTrustedTransport();
            // Drive service = new Drive.Builder(HTTP_TRANSPORT, init.JSON_FACTORY,
            // init.getCredentials(HTTP_TRANSPORT)).setApplicationName(init.APPLICATION_NAME).build();
            // we use this in routes for upload

            // gson provides us with a way to turn JSON into objects, and objects
            // into JSON.
            //
            // NB: it must be final, so that it can be accessed from our lambdas
            //
            // NB: Gson is thread-safe. See
            // https://stackoverflow.com/questions/10380835/is-it-ok-to-use-gson-instance-as-a-static-field-in-a-model-bean-reuse
            final Gson gson = new Gson();
            // final String CLIENT_ID =
            // "26342651488-daqciiut6qikektlcu6oj6h21iij33cr.apps.googleusercontent.com";
            final String CLIENT_ID = "373597156492-u5e6nqr8alh2ucf4c5pe9f01tqjg0kce.apps.googleusercontent.com";

            // dataStore holds all of the data that has been provided via HTTP
            // requests
            //
            // NB: every time we shut down the server, we will lose all data, and
            // every time we start the server, we'll have an empty dataStore,
            // with IDs starting over from 0.
            // final DataStore dataStore = new DataStore();

            // GET route that returns all message titles and Ids. All we do is get
            // the data, embed it in a StructuredResponse, turn it into JSON, and
            // return it. If there's no data, we return "[]", so there's no need
            // for error handling.

            Spark.get("/messages", (request, response) -> { // MUST ADD IN COMMENTS

                // try {
                // if ((mKey = cache.get("u" + fakeHash(id_token))) != null) {
                // // System.out.println(mKey+" key in get id IS CACHED");
                // if (mKey.equals(fakeHash(id_token))) {
                // System.out.println(mKey + " key in get id IS CACHED");
                // } else {
                // return gson.toJson(new StructuredResponse("error",
                // "Session ID not cached, please pass it in or login", null));
                // }
                // // System.out.println(cache.get("m"+request.params("id"))+" IS CACHED");
                // } else {
                // System.out.println("memcacher null ");
                // mKey = fakeHash(id_token);
                // }
                // } catch (Exception e) {
                // // mKey = request.headers("mSession");
                // System.out.println("exception called msession ");
                // }
                // if (mKey == "") {
                // return gson.toJson(
                // new StructuredResponse("error", "Session ID not cached, please pass it in or
                // login", null));
                // }
                // if (mId == -1 || mKey == null) {
                // return gson.toJson(new StructuredResponse("error", "Invalid headers.",
                // null));
                // }
                // ensure status 200 OK, with a MIME type of JSON
                response.status(200);
                response.type("application/json");
                // db.createTable();
                // db.createSesTable();
                // db.createComTable();
                // db.createLikeTable();
                // db.createProfileTable();
                // db.insertNewUser();
                // db.userExists();
                return gson.toJson(new StructuredResponse("ok", null, db.selectAll()));
            });

            // GET route that returns a message with all its information. All we do is get
            // the data, embed it in a StructuredResponse, turn it into JSON, and
            // return it. If there's no data, we return "[]", so there's no need
            // for error handling.
            Spark.get("/messages/:id", (request, response) -> {
                // verify the identity of the user

                int idx = Integer.parseInt(request.params("id"));
                // ensure status 200 OK, with a MIME type of JSON
                response.status(200);
                response.type("application/json");
                DataRow data = db.selectOne(idx);
                if (data == null) {
                    return gson.toJson(new StructuredResponse("error", idx + " not found", null));
                } else {
                    return gson.toJson(new StructuredResponse("ok", null, data));
                }
            });

            Spark.get("/tempShit", (request, response) -> { // MUST ADD IN COMMENTS
                // ensure status 200 OK, with a MIME type of JSON
                response.status(200);
                response.type("application/json");
                db.editProfileNote(2, "die");
                String note = db.getProfileNote(2);
                return note;
            });

            Spark.get("/profile_note/:userId", (request, response) -> {
                int userId = Integer.parseInt(request.params("userId"));
                response.status(200);
                response.type("application/json");
                return gson.toJson(new StructuredResponse("ok", null, db.getProfileNote(userId)));

            });

            Spark.post("/profile_note/:userId/default", (request, response) -> {
                int userId = Integer.parseInt(request.params("userId"));
                String note = db.getProfileNote(userId);
                if (note == "" || note == null) {
                    response.status(201);
                    return gson.toJson(new StructuredResponse("ok", "default note NOT inserted, user exists", -1));
                }
                db.insertDefaultProfileNoteRow(userId);
                response.status(200);
                response.type("application/json");
                return gson.toJson(new StructuredResponse("ok", "default note inserted", 0));
            });

            Spark.put("/profile_note/:userId/:note", (request, response) -> {
                int userId = Integer.parseInt(request.params("userId"));
                String note = request.params("note");
                int res = db.editProfileNote(userId, note);
                if (res == 0)
                    response.status(200);
                return gson.toJson(new StructuredResponse("ok", "edited note", 0));
            });

            // GET route that returns all comments. All we do is get
            // the data, embed it in a StructuredResponse, turn it into JSON, and
            // return it. If there's no data, we return "[]", so there's no need
            // for error handling.

            /** The get route that will get all comments for a specific post */
            Spark.get("/messages/:id/comments", (request, response) -> { // MUST ADD IN COMMENTS
                // ensure status 200 OK, with a MIME type of JSON
                int msgId = Integer.parseInt(request.params("id"));
                response.status(200);
                response.type("application/json");
                return gson.toJson(new StructuredResponse("ok", null, db.getComments(msgId)));
            });

            // GET route that returns everything for a single row in the DataStore.
            // The ":id" suffix in the first parameter to get() becomes
            // request.params("id"), so that we can get the requested row ID. If
            // ":id" isn't a number, Spark will reply with a status 500 Internal
            // Server Error. Otherwise, we have an integer, and the only possible
            // error is that it doesn't correspond to a row with data.

            /**
             * Displays a specific message with an ID - important for the comments display
             */
            Spark.get("/:userId/profile", (request, response) -> {
                System.out.println("IN GET PROFILE");
                int user_id = Integer.parseInt(request.params("userId"));
                // ensure status 200 OK, with a MIME type of JSON

                response.type("application/json");

                if (user_id == 0 || user_id < 0) {
                    response.status(201);
                    return gson.toJson(new StructuredResponse("error", user_id + " not found", null));
                } else {
                    response.status(200);
                    return gson.toJson(new StructuredResponse("ok", null, db.getProfile(user_id)));
                }
            });

            // POST route for adding a new element to the DataStore. This will read
            // JSON from the body of the request, turn it into a SimpleRequest
            // object, extract the title and message, insert them, and return the
            // ID of the newly created row.

            /** Adds a new messaage to the database that was entered by the client */
            Spark.post("/messages/:user_id/:token", (request, response) -> {
                // NB: if gson.Json fails, Spark will reply with status 500 Internal
                // Server Error
                SimpleRequest req = gson.fromJson(request.body(), SimpleRequest.class);
                // ensure status 200 OK, with a MIME type of JSON
                // NB: even on error, we return 200, but with a JSON object that
                // describes the error.
                int user_id = Integer.parseInt(request.params("user_id"));
                String token = request.params("token");
                String checkedToken = checkUser(token);

                // if (checkedToken.equals("")) {
                // return gson.toJson(new StructuredResponse("error", checkedToken, null));
                // }

                String filetype = "";
                if (req.fileType == 0) {
                    System.out.println("got in herer");
                    filetype = "image/png";
                } else if (req.fileType == -1) {
                    filetype = "noFile";
                } else {
                    System.out.println("got in");
                    filetype = "application/pdf";
                }

                response.status(200);
                // int userId = Integer.parseInt(request.params("userId"));
                response.type("application/json");

                String newFileLink = "";
                int newId = 0;
                byte[] imageBytes;
                if (req.uploadData.equals("") || req.uploadFileName.equals("")) {
                    newId = db.insertRow(req.mTitle, req.mMessage, user_id, "", "", (float) 0.000);
                } else {
                    try {
                        imageBytes = Base64.getDecoder().decode(req.uploadData);
                        System.out.println("imageBytes: " + imageBytes);
                        java.io.File fileToInsert = new java.io.File(req.uploadFileName);
                        FileUtils.writeByteArrayToFile(fileToInsert, imageBytes);
                        newFileLink = DriveQuickstart.insertFile(DriveQuickstart.getDrive(), req.uploadFileName,
                                fileToInsert, filetype);
                        System.out.println("hello " + newFileLink);
                        cache.set(newFileLink, 0, req.uploadData);
                        System.out.println("Image Base 64 String Stored in Memcache");
                        // insert into database
                    } catch (Exception e) {
                        e.printStackTrace();
                        return gson.toJson(new StructuredResponse("error", "error performing file insertion", null));
                    }

                    // NB: createEntry checks for null title and message
                    newId = db.insertRow(req.mTitle, req.mMessage, user_id, req.uploadFileName, newFileLink,
                            (float) imageBytes.length);
                }

                if (newId == -1) {
                    return gson.toJson(new StructuredResponse("error", "error performing insertion", null));
                } else {
                    return gson.toJson(new StructuredResponse("ok", "" + newId, null));
                }
            });

            /** This posts a comment from a user to a specifc post */

            Spark.post("/messages/:id/:userID/post_comment", (request, response) -> {
                // NB: if gson.Json fails, Spark will reply with status 500 Internal
                // Server Error
                // String token = request.params("token");
                // String checkedToken = checkUser(token);
                // if(checkedToken.equals("")){
                // return gson.toJson(new StructuredResponse("error", checkedToken, null));
                // }
                int messageID = Integer.parseInt(request.params("id"));
                int userID = Integer.parseInt(request.params("userID"));
                SimpleComRequest req = gson.fromJson(request.body(), SimpleComRequest.class);

                String filetype = "";
                if (req.fileType == 0) {
                    filetype = "image/png";
                } else if (req.fileType == -1) {
                    filetype = "noFile";
                } else {
                    filetype = "application/pdf";
                }
                // ensure status 200 OK, with a MIME type of JSON
                // NB: even on error, we return 200, but with a JSON object that
                // describes the error.
                response.status(200);
                response.type("application/json");
                int newComId = 0;
                String newFileLink = "";
                byte[] imageBytes;
                if (!req.uploadData.equals("")) {// req.uploadData.equals("")|| req.uploadFileName.equals("")
                    System.out.println("entered if");
                    try {
                        imageBytes = Base64.getDecoder().decode(req.uploadData);
                        System.out.println("imageBytes: " + imageBytes);
                        java.io.File fileToInsert = new java.io.File(req.uploadFileName);
                        FileUtils.writeByteArrayToFile(fileToInsert, imageBytes);
                        newFileLink = DriveQuickstart.insertFile(DriveQuickstart.getDrive(), req.uploadFileName,
                                fileToInsert, filetype);
                        System.out.println("hello " + newFileLink);
                        cache.set(newFileLink, 0, req.uploadData);
                        System.out.println("Image Base 64 String Stored in Memcache");
                        // insert into database
                    } catch (Exception e) {
                        e.printStackTrace();
                        System.out.println("exception error performing file insertion");
                        return gson.toJson(new StructuredResponse("error", "error performing file insertion", null));
                    }
                    newComId = db.insertComRow(req.mComment, userID, messageID, req.uploadFileName, newFileLink,
                            (float) imageBytes.length);

                } else {
                    newComId = db.insertComRow(req.mComment, userID, messageID, "", "", (float) 0.000);

                }
                // NB: createEntry checks for null title and message
                System.out.println("new comment: " + req.mComment);

                if (newComId == -1) {
                    return gson.toJson(new StructuredResponse("error", "could not post comment", null));
                } else {
                    return gson.toJson(new StructuredResponse("ok", "comment posted, comment ID: " + newComId, null));
                }
            });

            // PUT route for updating a row in the db. This is almost
            // exactly the same as POST
            Spark.put("/messages/:id", (request, response) -> {
                // If we can't get an ID or can't parse the JSON, Spark will send
                // a status 500
                int idx = Integer.parseInt(request.params("id"));
                SimpleRequest req = gson.fromJson(request.body(), SimpleRequest.class);
                int result = 0;
                // ensure status 200 OK, with a MIME type of JSON
                // if (!verifyMsgAuthor(req.mUserId, req.mSession, idx)) {
                // return gson.toJson(
                // new StructuredResponse("error", "You have not logged in or you are not the
                // author.", null));
                // }
                String filetype = "";
                if (req.fileType == 0) {
                    filetype = "image/png";
                } else if (req.fileType == -1) {
                    filetype = "noFile";
                } else {
                    filetype = "application/pdf";
                }
                if (!req.uploadData.equals("")) {
                    String newFileLink = "";
                    byte[] imageBytes;
                    try {
                        imageBytes = Base64.getDecoder().decode(req.uploadData);
                        System.out.println("imageBytes: " + imageBytes);
                        java.io.File fileToInsert = new java.io.File(req.uploadFileName);
                        FileUtils.writeByteArrayToFile(fileToInsert, imageBytes);
                        newFileLink = DriveQuickstart.insertFile(DriveQuickstart.getDrive(), req.uploadFileName,
                                fileToInsert, filetype);
                        System.out.println("hello " + newFileLink);
                        cache.set(newFileLink, 0, req.uploadData);
                        System.out.println("Image Base 64 String Stored in Memcache");
                        // insert into database
                    } catch (Exception e) {
                        e.printStackTrace();
                        return gson.toJson(new StructuredResponse("error", "error performing file insertion", null));
                    }
                    // NB: createEntry checks for null title and message
                    result = db.updateOne(idx, req.mMessage, req.uploadFileName, newFileLink, imageBytes.length);
                    if (result == -1) {
                        return gson.toJson(new StructuredResponse("error", "unable to update row " + idx, null));
                    } else {
                        return gson.toJson(new StructuredResponse("ok", null, result));
                    }
                } else {
                    response.status(200);
                    response.type("application/json");
                    result = db.updateOne(idx, req.mMessage, "", "", 0);
                    if (result == -1) {
                        return gson.toJson(new StructuredResponse("error", "unable to update row " + idx, null));
                    } else {
                        return gson.toJson(new StructuredResponse("ok", null, result));
                    }
                }
            });

            // DELETE route for removing a row from the DataStore
            Spark.delete("/messages/:id", (request, response) -> {
                // If we can't get an ID, Spark will send a status 500
                int idx = Integer.parseInt(request.params("id"));
                // ensure status 200 OK, with a MIME type of JSON
                response.status(200);
                response.type("application/json");
                // NB: we won't concern ourselves too much with the quality of the
                // message sent on a successful delete
                int result = db.deleteRow(idx);
                if (result == -1) {
                    return gson.toJson(new StructuredResponse("error", "unable to delete row " + idx, null));
                } else {
                    return gson.toJson(new StructuredResponse("ok", null, null));
                }
            });

            // PUT route for incrementing like

            /**
             * Responsible for changing the likes of a given post. The like status
             * demonstrates what happens when a like or dislike occurs
             * When a 0 is routed - the like button has been pressed
             * When a 1 is routed - the dislike button has been pressed
             */

            Spark.put("/messages/:id/:userId/:like_or_dislike", (request, response) -> {
                // int result = -1;
                int msgId = Integer.parseInt(request.params("id"));
                int userId = Integer.parseInt(request.params("userId"));
                int action = Integer.parseInt(request.params("like_or_dislike"));
                SimpleRequest req = gson.fromJson(request.body(), SimpleRequest.class);
                response.type("application/json");
                // check if user exists in likeData tbl
                boolean userExists = db.doesUserExistInLikeDataTbl(msgId, userId);
                System.out.println("User Exists in Like Data Table: " + userExists);
                if (!userExists) { // if user does not exist in likeData tbl for a given msg
                    System.out.println("User DNE!");
                    switch (action) {
                        case 0: // if action is to like
                            db.insertLikeRow(userId, msgId, 1);
                            db.addLike(msgId);
                            response.status(200);
                            return gson.toJson(new StructuredResponse("ok", "updated, like status", 1));
                        case 1: // dislike
                            db.insertLikeRow(userId, msgId, -1);
                            db.addDislike(msgId);
                            response.status(200);
                            return gson.toJson(new StructuredResponse("ok", "updated, like status", -1));
                    }
                } else if (userExists) {
                    System.out.println("User Exists!");
                    int userLikeStatus = db.getLikeStatus(userId, msgId);
                    System.out.println("User Like Status = " + userLikeStatus + ", User Action = " + action);
                    if ((userLikeStatus == 1 && action == 0) || (userLikeStatus == -1 && action == 1)) {
                        response.status(201);
                        return gson.toJson(new StructuredResponse("ok", "no change", 0)); // do nothing
                    } else if (userLikeStatus == 1 && action == 1) {
                        db.removeLike(msgId);
                        db.addDislike(msgId);
                        db.setLikeStatus(userId, msgId, -1);
                        System.out.println("Like Status After Action: " + db.getLikeStatus(userId, msgId));
                        response.status(200);
                        return gson.toJson(new StructuredResponse("ok", "disliked, like status now ", -1));
                    } else if (userLikeStatus == -1 && action == 0) {
                        db.removeDislike(msgId);
                        db.addLike(msgId);
                        db.setLikeStatus(userId, msgId, 1);
                        System.out.println("Like Status After Action: " + db.getLikeStatus(userId, msgId));
                        response.status(200);
                        return gson.toJson(new StructuredResponse("ok", "liked, like status now ", 1));
                    }
                }
                return gson.toJson(new StructuredResponse("error", "unable to like or dislike msgId: " + msgId, null));
            });

            /** End of indiviudal like scenario */

            /** Update Comment */
            Spark.put("/messages/:id/:userID/:commentId/edit_comment", (request, response) -> {
                // If we can't get an ID or can't parse the JSON, Spark will send
                // a status 500-b
                System.out.println("IN UPDATE/EDIT COMMENT IN BACKEND");
                int msgId = Integer.parseInt(request.params("id"));
                int userId = Integer.parseInt(request.params("userID"));
                int comId = Integer.parseInt(request.params("commentId"));
                SimpleComRequest req = gson.fromJson(request.body(), SimpleComRequest.class);
                // ensure status 200 OK, with a MIME type of JSON
                response.type("application/json");
                int result = 0;
                System.out.println("BEFORE selectCommentOne!!!!");
                // System.out.println(cache.get(((Integer) userId).toString()));
                DataComRow comment = db.selectCommentOne(comId);
                System.out.println("AFTER selectCommentOne!!!!");
                int comCreatorId = comment.mUserId;

                // if (userId == comCreatorId) {
                // System.out.println("BEFORE changeComment!!!!");
                // if (req.mComment == null)
                // req.mComment = "";
                // result = db.changeComment(comId, req.mComment, "", "", (float) 0.000);
                // System.out.println("AFTER changeComment!!!!");
                // response.status(200);
                // return gson.toJson(new StructuredResponse("ok", "comment changed", result));
                // }

                if (userId != comCreatorId) {
                    System.out.print("You did not write this comment");
                    response.status(202);
                    return gson.toJson(new StructuredResponse("ok", "Cannot Change Comment", null));
                }

                String filetype = "";
                if (req.fileType == 0) {
                    filetype = "image/png";
                } else if (req.fileType == -1) {
                    filetype = "noFile";
                } else {
                    filetype = "application/pdf";
                }
                if (!req.uploadData.equals("")) {
                    String newFileLink = "";
                    byte[] imageBytes;
                    try {
                        imageBytes = Base64.getDecoder().decode(req.uploadData);
                        System.out.println("imageBytes: " + imageBytes);
                        java.io.File fileToInsert = new java.io.File(req.uploadFileName);
                        FileUtils.writeByteArrayToFile(fileToInsert, imageBytes);
                        newFileLink = DriveQuickstart.insertFile(DriveQuickstart.getDrive(), req.uploadFileName,
                                fileToInsert, filetype);
                        System.out.println("hello " + newFileLink);
                        cache.set(newFileLink, 0, req.uploadData);
                        System.out.println("Image Base 64 String Stored in Memcache");
                        // insert into database
                    } catch (Exception e) {
                        e.printStackTrace();
                        return gson.toJson(new StructuredResponse("error", "error performing file insertion", null));
                    }
                    // NB: createEntry checks for null title and message
                    // int comId, String newCom, String filename, String fileLink, int fileSize
                    result = db.changeComment(comId, req.mComment, req.uploadFileName, newFileLink, imageBytes.length);
                    if (result == -1) {
                        return gson.toJson(new StructuredResponse("error", "unable to update row " + comId, null));
                    } else {
                        return gson.toJson(new StructuredResponse("ok", null, result));
                    }
                } else {
                    response.status(200);
                    response.type("application/json");
                    result = db.changeComment(comId, req.mComment, "", "", 0);
                    if (result == -1) {
                        return gson.toJson(new StructuredResponse("error", "unable to update row " + comId, null));
                    } else {
                        return gson.toJson(new StructuredResponse("ok", null, result));
                    }
                }

            });

            // OAuth
            Spark.post("/oauth", (request, response) -> {
                RequestOAuth reqOAuth = gson.fromJson(request.body(), RequestOAuth.class);
                String id_token = reqOAuth.id_token;
                System.out.println("line 429 (id token): " + id_token);
                JsonFactory jsonFactory = new GsonFactory();
                NetHttpTransport transport = GoogleNetHttpTransport.newTrustedTransport();
                LOGGER.log(Level.WARNING, "Line 433 Not Executed");
                GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(transport, jsonFactory)
                        .setAudience(Arrays.asList(CLIENT_ID)).build();
                LOGGER.log(Level.WARNING, "Line 433 Executed");
                GoogleIdToken idToken = verifier.verify(id_token);
                LOGGER.log(Level.WARNING, "Line 435 Executed");
                int newUserId = 0;
                response.status(200);
                response.type("application/json");
                String sessionKey = " ";
                if (idToken != null) {
                    LOGGER.log(Level.WARNING, "In if idToken != null stmt");
                    Payload payload = idToken.getPayload();
                    String userId = payload.getSubject();
                    String email = payload.getEmail();
                    boolean emailVerified = Boolean.valueOf(payload.getEmailVerified());
                    String name = (String) payload.get("name");
                    String pictureUrl = (String) payload.get("picture");
                    String locale = (String) payload.get("locale");
                    String familyName = (String) payload.get("family_name");
                    String givenName = (String) payload.get("given_name");
                    sessionKey = fakeHash(id_token); // hash id token to generate seesion key, what we store in
                                                     // hashtable
                    String mKey = "";
                    String hex = "";

                    // Use or store profile information
                    // ...

                    // only if the user is in domain of lehigh.edu we can let them access the
                    // website
                    if (!payload.getHostedDomain().equals("lehigh.edu")) {
                        return gson.toJson(new StructuredResponse("error", "Only lehigh.edu are allowed.", null));
                    }

                    int mId = db.getUserId(email);
                    LOGGER.log(Level.WARNING, "BEFORE LINE 452");
                    // Replacing HashTable with MemCache
                    // try {
                    // if ((mKey = cache.get(((Integer) mId).toString())) != null) {
                    // // System.out.println(mKey+" key in get id IS CACHED");
                    // if (mKey.equals(sessionKey)) {
                    // System.out.println(mKey + " Session key in get id IS CACHED");
                    // } else {
                    // return gson.toJson(new StructuredResponse("error",
                    // "Session ID not cached, please pass it in or login", null));
                    // }
                    // // System.out.println(cache.get("m"+request.params("id"))+" IS CACHED");
                    // } else {
                    // System.out.println("memcacher null ");
                    // mKey = sessionKey;
                    // System.out.println("New session Key has been cached");
                    // }
                    // } catch (Exception e) {
                    // // mKey = request.headers("mSession");
                    // System.out.println("exception called msession ");
                    // }
                    // if (mKey == "") {
                    // return gson.toJson(
                    // new StructuredResponse("error", "Session ID not cached, please pass it in or
                    // login",
                    // null));
                    // }
                    // if (mId == -1 || mKey == null) {
                    // return gson.toJson(new StructuredResponse("error", "Invalid headers.",
                    // null));
                    // }
                    cache.set(((Integer) mId).toString(), 0, sessionKey);
                    // if ((mKey = cache.get(((Integer) mId).toString())) != null) {
                    // // cache.set(((Integer) mId).toString(), 0, sessionKey);
                    // System.out.println("Session key has been cached ");
                    // // System.out.println(cache.get("m"+request.params("id"))+" IS CACHED");
                    // }

                    if (!users_hashtable.containsKey(sessionKey) || db.getUserId(email) == -1) {
                        // check if they are in
                        // hashtable
                        LOGGER.log(Level.WARNING, "IN IF STMT FOR USER NOT IN HASHTBL");
                        users_hashtable.put(sessionKey, email); // if not, add to hashtbl
                        LOGGER.log(Level.WARNING, "PUT IN HASHTBL EXECUTED");
                        db.insertProfRow(name, email); // also insert them into our db
                        LOGGER.log(Level.WARNING, "INSERT PROFILE TO PROFILE TBL EXECUTED");
                        newUserId = db.getUserId(email);
                        LOGGER.log(Level.WARNING, "GET NEW USER ID EXECUTED");
                        System.out.println("NEW USER ID: " + idToken);
                        System.out.println("NEW USER ID: " + newUserId);

                        new User(userId, email, emailVerified, name, pictureUrl, locale, familyName,
                                givenName,
                                id_token);
                        LOGGER.log(Level.WARNING, "new user obj added, user id set");
                    } else {
                        newUserId = db.getUserId(email);
                        LOGGER.log(Level.WARNING, "user id set (from db)");
                    }

                } else {
                    newUserId = -1;
                    return gson.toJson(new StructuredResponse("error", "user not found ", newUserId));
                }
                System.out.println(sessionKey);
                return gson.toJson(new StructuredResponse("ok, got user id :)", sessionKey, newUserId));

            });

        } catch (IOException ioe) {
            System.err.println("Couldn't create a connection to MemCachier: " + ioe.getMessage());
        }

        // db.AddColumn();

    } // This ends the main method

    public static String checkUser(String token) { // check if user is in hashtbl
        String sessionKey = fakeHash(token); // rehashes token
        System.out.println(sessionKey);
        if (!users_hashtable.containsKey(sessionKey)) { // checks if rehashed token is in hashtbl
            return "";
        }
        System.out.println(sessionKey);
        return users_hashtable.get(sessionKey); // return hashed token i.e. sessionKey
    }

    public static String fakeHash(String email) {
        char[] emailChars = email.toCharArray();
        for (int i = 0; i < email.length(); i++) {
            emailChars[i] += 1;
        }
        return (toString(emailChars));
    }

    public static String toString(char[] a) {
        String string = new String(a);
        return string;
    }

    public static String fileUpload(Drive service, String fileName, String fileUrl) throws IOException {
        // get the bytes
        byte[] byteArray = fileUrl.getBytes();
        try (FileOutputStream fos = new FileOutputStream(fileName)) {
            fos.write(byteArray);
        }
        // now that we have a file, shove it to GDrive and also into cache
        File fileMetadata = new File();
        fileMetadata.setName(fileName);
        java.io.File filePath = new java.io.File(fileName);
        String fileType = "";
        if (fileName.contains(".jpg") || fileName.contains(".jfif")) {
            fileType = "image/jpeg";
        } else if (fileName.contains(".png")) {
            fileType = "image/png";
        } else if (fileName.contains(".jfif")) {
            fileType = "image/jfif";
        } else {
            fileType = "text/" + fileName.split(".")[1];
        }
        FileContent mediaContent = new FileContent(fileType, filePath);
        File file = service.files().create(fileMetadata, mediaContent)
                .setFields("id")
                .execute();
        // now we have to get the link
        // service.files().get().setFields("webViewLink");
        String pageToken = null;
        String link = "";
        do {
            FileList result = service.files().list()
                    .setQ("id='" + file.getId() + "'")
                    .setSpaces("drive")
                    .setFields("nextPageToken, webViewLink")
                    .setPageToken(pageToken)
                    .execute();
            for (File file1 : result.getFiles()) {
                link = file1.getWebViewLink();
                break;
            }
            pageToken = result.getNextPageToken();
        } while (pageToken != null);
        // now delete the local file
        filePath.delete();
        // since we're done, return the file link
        return link;
    }

    /**
     * Get an integer environment varible if it exists, and otherwise return the
     * default value.
     * 
     * @envar The name of the environment variable to get.
     * @defaultVal The integer value to use as the default if envar isn't found
     * 
     * @returns The best answer we could come up with for a value for envar
     */
    static int getIntFromEnv(String envar, int defaultVal) {
        ProcessBuilder processBuilder = new ProcessBuilder();
        if (processBuilder.environment().get(envar) != null) {
            return Integer.parseInt(processBuilder.environment().get(envar));
        }
        return defaultVal;
    }

    /**
     * Set up CORS headers for the OPTIONS verb, and for every response that the
     * server sends. This only needs to be called once.
     * 
     * @param origin  The server that is allowed to send requests to this server
     * @param methods The allowed HTTP verbs from the above origin
     * @param headers The headers that can be sent with a request from the above
     *                origin
     */
    private static void enableCORS(String origin, String methods, String headers) {
        // Create an OPTIONS route that reports the allowed CORS headers and methods
        Spark.options("/*", (request, response) -> {
            String accessControlRequestHeaders = request.headers("Access-Control-Request-Headers");
            if (accessControlRequestHeaders != null) {
                response.header("Access-Control-Allow-Headers", accessControlRequestHeaders);
            }
            String accessControlRequestMethod = request.headers("Access-Control-Request-Method");
            if (accessControlRequestMethod != null) {
                response.header("Access-Control-Allow-Methods", accessControlRequestMethod);
            }
            return "OK";
        });

        // 'before' is a decorator, which will run before any
        // get/post/put/delete. In our case, it will put three extra CORS
        // headers into the response
        Spark.before((request, response) -> {
            response.header("Access-Control-Allow-Origin", origin);
            response.header("Access-Control-Request-Method", methods);
            response.header("Access-Control-Allow-Headers", headers);
        });
    }

    public static void setEnv(String key, String value) {
        try {
            Map<String, String> env = System.getenv();
            Class<?> cl = env.getClass();
            Field field = cl.getDeclaredField("m");
            field.setAccessible(true);
            Map<String, String> writableEnv = (Map<String, String>) field.get(env);
            writableEnv.put(key, value);
        } catch (Exception e) {
            throw new IllegalStateException("Failed to set environment variable", e);
        }
    }

}