# Luxyy 

## Specs

### General
- ~~only allow https~~

### Analytics
- ~~implement segment user tracking~~
- ~~implement error tracking~~

### navigation controller
- ~~have icon animation like tinder (AHPagingMenuViewController)~~
- ~~controller swiping animation like tinder~~
- ~~get unread messages badge on message icon~~
- ~~need to be able to pick which icon to set badge on~~
- ~~clear unread when user goes to message page~~
- <Later>update badge count on push notification when user is not on the message page

### browse page
- ~~load images from parse~~
- ~~"swipe to decide" animation~~
- ~~"tap to decide" with animation~~
- ~~card UI~~
- ~~add image overlay effect to swipe action to emphasize user is making decision~~
- ~~save swipe decisions to backend~~
- ~~save initial itemset to parse~~
- ~~need to build system to get "random" records from parse~~
- ~~button UI~~
- ~~overlay UI~~
- ~~user interaction is disabled before images are populated~~
- ~~rethink the autolayout for the buttons to acommodate smaller phone sizes~~
- <Later>rethink the trigger for the share functionality

##### browseDetail
- ~~initial zoom on image is set by width of view~~
- ~~image gallery~~
- ~~allow getting swipe decision~~
- ~~update UI for buttons~~
- ~~tap to zoom on image doesn't work from the fulllistview~~
- ~~allow updating swipe decision~~
- ~~apply some layouts to the text~~
- ~~prevent crashing where there are enough cards in the back to swipe~~
- ~~make sure scroll view when scrolled to the bottom does not overlap with the bottom buttons~~

### profile page
- ~~have a collection view with 2 playlists liked and disliked~~
- ~~design a UI for the cells~~
- ~~disallow tapping if there aren't any decision records for save/skip~~
- ~~add settings cell~~ 
- ~~settings cell: signout/take user to login page~~
- <Later>settings cell: give app store review
- <Later>refactor so that refreshing doesn't show the base 'x' and 'star' images
- <Later>updating decision should also reload liked/passed list

#### login page
- <Later>play mp4 in background of login page
- <Later>move buttons to bottom of page

##### playlistDetail
- ~~tapping on playlist loads a collection view of items~~
- ~~add a back button (its the first cell)~~
- ~~load list from parse~~
- ~~finish loading all lists~~
- ~~tapping on the item loads the item's browseDetail~~
- ~~load all images async~~
- ~~update lists on each decision~~
- ~~solve collection view crashing when scrolling too fast~~
- ~~load view as full screen modal~~
- ~~style nav bar~~
- <Later>updating decision automatically updates the other list
- <Later>disable user interaction while cell is loading

#### message page
- ~~send and receive text messages with JSQMessagesViewController~~
- ~~integrate with parse server~~
- ~~add login page~~
- ~~setup push notifications / real time updating~~
- ~~add message sending/receiving sound~~
- ~~allow admin to chat with all users~~
- ~~add photo library send/receiving support~~
- ~~add cammera photo send/receiving support~~
- ~~take current item's photo send support~~
- ~~implement progress bar for image uploading~~
- ~~receive push notifications~~
- ~~hide the attachments button unless user is admin~~
- push notifications must be confirmed to work
- loading messages needs to be async, especially when there are photos
- <Later>upload/download image to parse with progress bar callback