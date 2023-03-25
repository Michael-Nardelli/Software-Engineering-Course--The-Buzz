# buzz_app

A flutter project used to create a social media app for individuals to share their ideas in a collaborative and safe space. Functionality includes, posting a message, commenting on a message, viewing the profiles of those who wrote the message or comment, liking or disliking a message and posting a picture as an idea or comment. This is the mobile application of said social media platform.

## Developers Manual

There is key infomation regarding the functionality and usefulness of this application in the developers manual for the social media platform. It is highly recommened that that documentation is read as well.

## Key Functionalities

Walking through the key ideas of this application will follow the same path as its performance. First, the user is authenticated during a login from the googel ouath API. This API allows security and versitility when it comes to the implementation of login and user storage information. Once the user is logged in and authenticated, they are permitted to interact with and different posts.

A user has the opportunitiy to create a new post, or like, dislike, or comment on an exisiting one. The key to this functionality is the different routes implemented to enable a connection with the backend and database containing all information about the Buzz. The routes implemented are generally self-explanatory following their names. Their uses include getting all messages to view, posting a new message, updating like and dislike counts, adding comments etc. These functionalities allow for an app that is useful and user friendly.

The less intutivie processes in the applciation are the attatchments and display of images in the app. The image_picker plugin is used to take pictures and choose them from the gallery. With the ability to add pictures to posts, they also need to be displayed. Upon sending a post to the backend, a picture is converted to a base64 string. That string is created into a file in the backend and sent to google drive where they are stored. The url_launcher is then used to display these images when returned from the backend. To store these links with ease, they are written to the cache where they may be accessed again.


## Usefule Resources

- [Google_Apis] (https://docs.flutter.dev/development/data-and-backend/google-apis)
- [cache_manager] (https://pub.dev/packages/cache_manager)
- [image_picker] (https://pub.dev/packages/image_picker)
- [url_launcher] (https://pub.dev/packages/url_launcher)

# Questions

With any questions please reach out to Michael Nardelli for additional information