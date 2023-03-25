# Back-End Server
Backend
This project serves as a very slim backend written in Java and demonstrates proper use of the Java SDK. This server receives purchase requests issued by the sample applications, and forwards these requests to Heroku.

The server itself is implemented using Heroku. Even if one is not familiar with the language,  the code has been extensively documented.  The Heroku server logs all API requests it performs to the terminal on the website (view logs), so you can see what's going on even without looking at the code. In heroku one can find the different config variables used in implementing the database and MemCache.

The main files in backend one must know about to understand its functionality can be found in backend/src/main/java. This part of the manual will briefly touch on the files available in Backend.  App contains the main logic of how the backend works consisting of multiple get, put, post and delete routes and other useful functions relevant to the applications running. Database.java holds the main information on our systems database written in Java and SQL. It contains multiple prepared statements and functions that define how the database is structured. Any file with the keyword Request in it simply provides a format for clients to present title and message strings to the server. Any file with the keyword Row simply​​ holds a row of information for a particular table. User, RequestOauth and Oauth are files that were used to enable GoogleOauth for login capabilities. DataStore provides access to a set of objects, and makes sure that each has a unique identifier that remains unique even after the object is deleted. StructuredResponse provides a common format for success and failure messages, with an optional payload of type Object that can be converted into JSON. DriverQuickStart is a support class that enables the google drive to be used in our web and mobile front ends to upload pdfs and images to a specified google drive. 


One important file not found under the backend/src/main/java directory is pom.xml. This contains all the dependencies needed to implement the different features of our application.

The test file under backend/src/ contains unit test files used in testing the functionality of the application.

Important terminal commands: mvn package; (compiling the program), mvn heroku:deploy;(deploying code onto the server).