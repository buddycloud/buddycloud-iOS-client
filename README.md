buddycloud for iOS
=====================

**An opensource XMPP client for the iPhone with buddycloud support**

Abstract
--------

The world desperately needs an open alternative to the current closed
social networks.

This project is about designing and building an opensouce client that
uses XMPP for the iPhone. The client will use different portions of the
XMPP specs to present iPhone users with a viable alternative to the
current social networking giants and their REST-based protocols.

We can build the better real-time experience by using XMPP capabilities
and XMPP’s federation to decentralise control of a future social
network. Standards such as XEP-0600 and XEP-0030 for channel
synchronization, XEP-00175 and XEP- 0078 for authentication &
registration, XEP-0800/0255 for user location by providing Lat/Long
coordinates, XEP-0054/0153/0234/0206 for avatars & media exchange, and
so many other extensions used on features demand. It will highly improve
the overall user experience including performance which mostly the first
requirement of any smart-phone user.

Problem Description
-------------------

Building a federated social networking client based on XMPP needs a
well-designed system which allow the clients to perform tasks with low
CPU and network use. (it’s no point only being social until your battery
quickly runs flat). In order to cope with these problems, the design
will try to push all hard work to the server and keep the client doing
less CPU intense tasks like just displaying the posts and social
streams.

Whenever the client comes online/offline the re-sync operation need to
be nicely handle the updates which requires client to query for all
items and resync in the background while allowing end-user to perform
other operations.

Another major problem that iPhone Core location & MapKit frameworks
perform the GPS triangulation frequently adding to the battery overhead.
A could be to limit the number of user-location updates.

Implementation Plan
-------------------

The project consists of components

### Authentication/Authorization & Registration

A federated social networking client experience should be designed for
all people - “who can experience it, even without having an account”.
So, the client will divided the experience into two different
components: Explore and view channels:

Using an anonymous bind, this will enable iphone users, perhaps their
first experience of an open social network before they need to sign up.
In order to implement this feature, it requires clients to implement the
XEP-0175 which do anonymous-bind and users can see channels posts and
place bookmarks.When a user tries to post or create new place bookmark
it will ask them to sign-in with their jid or create an account on any
domain offering channel services. Join:

Users can also login by using their existing XMPP accounts. The user
credentials would be persisted under iPhone settings and the application
setting as well to allow the clients login automatically or trying with
different user account.

### Channels directory, Follower & Post Management

A channel is like your Facebook/Status.net wall where your friends can
post to your channel and you receive instant push-based updates. All the
user channel updates can be retrieved through XEP-0060 pub-sub model and
also in addition to channel discovery XEP-0030 which allow the user to
receive updates from their friends belong to same or different remote
channels. There are couple of roles defined for channel to subscribe for
each based on different criteria, clients need to sync all the
subscriptions of user once it becomes online.

Users have much more control over their own channel than the Facebook
wall. A channel allows moderators to delete content on their behalf and
user also has an option to blacklist those followers causing problems.

The client will handle channel post management in two different
situations: In first scenario, if client is online and someone posts a
new comment on any topic then the channel server will send instant push
updates and mark it as read which will exclude that item for future
updates (until and unless - if someone again post a comment for that
topic). And also clients cache all the followed channel topics which may
reduce the re-sync process time.

In the second scenario, if a client comes online first time or after 1
or 2 days then there would be a bunch of new posts on the server for it.
To reduce the re-sync overhead and also to keep a smooth experience,
clients need to query for certain amount of new updates (Right, which
means pagination using RSM) and that also allow user to navigate for old
entries as well depending upon the client disk storage limitation.

### Place Management

Place management involves to track all the place bookmarks of user which
may be personal or shared to other people. This portion of the client
allows the users to create/edit/delete/search the places and also see
the details of bookmark places shared by other people with great user
interface which also plays a vital role in user experience. In order to
implement this tab in the client, it require clients to implement the
XEP-0080/0255 with back and forth packets exchange between host channel.
And clients also need to get the location coordinates (Lat/Long) through
CoreLocation API and also require place the user-location bookmarks on
map via MapKit framework on the iPhone.

### Media Management

Media also play a vital role in federated social networking enabling
users to share real-time experience with their friends. In order to
implement this feature, clients need to implement
XEP-0054/0153/0234/0206 for avatars and exchange
images/video/audio/location through jingle.

Deliverables
------------

There is already existing code for the buddycloud iphone client. This
project will attempt to reuse that code (also under and Apache2
license).

Federated Social Networking Experience

-   Explore (anonymous bind - No user account required)

### Authentication & Authorization

-   Login with different XMPP based networks (Gmail/Gtalk, Gmx.de,
    LiveJournal and other XMPP accounts)
-   TLS binding by default
-   DNS-SRV server lookup
-   Registration: Create new account on a list of servers that are
    offering channels

### Channel Management

-   Channels activity streams (status video, audio, picture and etc)
-   Go Online/offline presence
-   Create/Retrieve/Delete channel
-   Retrieve user own channel subscription
-   Set the channel's default affiliations (producer, follower,
    moderator, banned)
-   Follow/Un-follow channels
-   Post new topics
-   Track of unread/read messages (personal, admin, and channel)
-   Channel detail screen

### Browse Channel Directory

-   Federated Channel Directory list (Explore nearby, active topics,
    featured channels, and newest channels)
-   Channel list from directory
    -   Topic channels
    -   Personal Channels

-   Channel detail page
    -   All channel posts
    -   Show privates instant messages (isn't show for topic channels)
    -   Show channel details
    -   Show channel Producer
    -   Show channel Moderators
    -   Show channel Followers
    -   Channel On Air (broadcasting for no:of days)
    -   Channel Rank
    -   Producer Options (promote channel, permanently remove, approve
        followers)
    -   Channel Activity (for personal channels)

### Place Management

-   Current Place change
-   Next place setting
-   Create/Delete Place bookmarks
    -   Public (public places bookmarks that other people can use such
        as Star-bucks, Home and etc)
    -   Private (private places bookmarks are visible to itself)

-   Place details page
-   Place bookmarked by others
-   Find people nearby
-   Place age

### Setting Preferences

-   Application Settings (General \> Settings \> buddycloud)
    -   Change username/password
    -   Enable/Disable auto-login

-   Account Settings
    -   Edit user profile

-   Notifications (@replies, followed channels, moderated channels,
    personal messages)
-   Privacy Settings (allow private messages, share location)
-   About buddycloud
-   Help Channel (help@buddycloud.com)

# License 

Apache 2.0

