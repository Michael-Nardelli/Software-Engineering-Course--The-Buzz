package edu.lehigh.cse216.kel323.backend;

public class User {
    String userId;
    String email;
    boolean emailVerified;
    String name;
    String pictureUrl;
    String locale;
    String familyName;
    String givenName;
    String AccessKey;

    public User(String userId, String email, boolean emailVerified, String name, String pictureUrl, String locale, String familyName, String givenName, String AccessKey){
        this.userId = userId;
        this.email = email;
        this.emailVerified = emailVerified;
        this.name = name;
        this.pictureUrl = pictureUrl;
        this.locale = locale;
        this.familyName  = familyName;
        this.givenName = givenName;
        this.AccessKey = AccessKey;
    }
    public User(String userId, String email, String name) {
        this.userId = userId;
        this.email = email;
        this.emailVerified = true;
        this.name = name;
        this.pictureUrl = "";
        this.locale = "";
        this.familyName  = "";
        this.givenName = "";
        this.AccessKey = "";
    }
    
}
