#Tinderfish
##Catfish Guys with the Tinder API

![Tinderfish](http://www.spencerlloyddixon.co.uk/wp-content/uploads/2015/03/tinderfish.png)

Tinderfish uses Neal Kemp's ruby implementation of the reverse engineered Tinder API to relay messages
between two victim profiles through a fake profile. As far as the victims are concerned, they're talking to a match.
In reality, they're talking directly to each other thanks to Tinderfish.

### Setup

Create a fake facebook profile and grab the profile ID for the ```FACEBOOK_ID``` constant. Visit the link in the tinder_pyro documentation to grab your ```OAUTH_TOKEN```. You will need to install the Tinder app on your phone to verify your account via text message. I had to wait almost a week before my account became valid, likely due to it being a new facebook profile.

You'll need to follow the blog post below to modify the gem slightly.

### Blog Post

Accompanying blog post and code walkthrough can be found on my website here:

### Credit

Credit to Neal Kemp's fantastic tinder_pyro wrapper here https://github.com/nneal/tinder_pyro
