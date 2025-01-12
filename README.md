## Build based upon [PowerSync](https://github.com/powersync-ja/powersync-swift.git) and [Supabase](https://github.com/supabase/supabase-swift.git)

| Login | Home | Comments | Reels | UserProfile | PhotoPicker | Chat |
|-|-|-|-|-|-|-|
| ![Login](/AppScreenshots/login.PNG) | ![Home](/AppScreenshots/home.PNG) | ![Comments](/AppScreenshots/comments.PNG) | ![Reels](/AppScreenshots/reels.PNG) | ![UserProfile](/AppScreenshots/userProfile.PNG) | ![PhotoPicker](/AppScreenshots/photoPicker.PNG) | ![Chat](/AppScreenshots/chat.PNG)



## Code structure
```mermaid
%%{ init : { "theme" : "default", "flowchart" : { "curve" : "monotoneY" }}}%%
graph LR
    AppReducer ---> AppDelegateReducer
    AppReducer ---> LaunchReducer
    AuthReducer ---> LoginReducer
    ChatMessageInputReducer ---> ChatMessageInputTextFieldReducer
    ChatMessageInputReducer -- optional --> MessagePreviewReducer
    ChatReducer ---> ChatAppBarReducer
    ChatReducer ---> ChatMessageInputReducer
    ChatReducer ---> MessageListReducer
    CommentReducer -- optional --> RepliedCommentsReducer
    CommentReducer ---> UserCommentReducer
    CommentsReducer ---> CommentTextInputReducer
    HomeReducer ---> ChatsReducer
    HomeReducer ---> FeedReducer
    HomeReducer ---> MediaPickerReducer
    HomeReducer ---> ReelsReducer
    HomeReducer ---> TimelineReducer
    HomeReducer ---> UserProfileReducer
    LoginReducer ---> LoginFormReducer
    MediaPickerReducer -- optional --> CreatePostReducer
    PostEditReducer ---> PostMediaReducer
    PostLargeReducer ---> PostFooterReducer
    PostLargeReducer ---> PostHeaderReducer
    PostLargeReducer ---> PostMediaReducer
    PostMediaReducer ---> MediaCarouselReducer
    SignUpReducer -- optional --> MediaPickerReducer
    SignUpReducer ---> SignUpFormReducer
    UserProfilePostsReducer ---> PostsListReducer
    UserProfileReducer ---> UserProfileHeaderReducer
    UserStatisticsReducer ---> UserProfileListReducer
    UserStatisticsReducer ---> UserProfileListReducer
    UserStatisticsReducer -- optional --> UserProfileReducer

    AppDelegateReducer(AppDelegateReducer: 1)
    ChatAppBarReducer(ChatAppBarReducer: 1)
    ChatMessageInputReducer(ChatMessageInputReducer: 1)
    ChatMessageInputTextFieldReducer(ChatMessageInputTextFieldReducer: 1)
    ChatsReducer(ChatsReducer: 1)
    CommentTextInputReducer(CommentTextInputReducer: 1)
    CreatePostReducer(CreatePostReducer: 1)
    FeedReducer(FeedReducer: 1)
    LaunchReducer(LaunchReducer: 1)
    LoginFormReducer(LoginFormReducer: 1)
    LoginReducer(LoginReducer: 1)
    MediaCarouselReducer(MediaCarouselReducer: 1)
    MediaPickerReducer(MediaPickerReducer: 2)
    MessageListReducer(MessageListReducer: 1)
    MessagePreviewReducer(MessagePreviewReducer: 1)
    PostFooterReducer(PostFooterReducer: 1)
    PostHeaderReducer(PostHeaderReducer: 1)
    PostMediaReducer(PostMediaReducer: 2)
    PostsListReducer(PostsListReducer: 1)
    ReelsReducer(ReelsReducer: 1)
    RepliedCommentsReducer(RepliedCommentsReducer: 1)
    SignUpFormReducer(SignUpFormReducer: 1)
    TimelineReducer(TimelineReducer: 1)
    UserCommentReducer(UserCommentReducer: 1)
    UserProfileHeaderReducer(UserProfileHeaderReducer: 1)
    UserProfileListReducer(UserProfileListReducer: 2)
    UserProfileReducer(UserProfileReducer: 2)
```

  
