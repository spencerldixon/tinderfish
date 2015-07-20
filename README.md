#Tinderfish
##Catfish Guys with the Tinder API

![Tinderfish](http://www.spencerlloyddixon.co.uk/wp-content/uploads/2015/03/tinderfish.png)

Tinderfish uses Neal Kemp's ruby implementation of the reverse engineered Tinder API to relay messages
between two victim profiles through a fake profile. As far as the victims are concerned, they're talking to a match.
In reality, they're talking directly to each other thanks to Tinderfish.

### Setup

Create a fake facebook profile and grab the profile ID for the ```FACEBOOK_ID``` constant. Visit the link in the tinder_pyro documentation to grab your ```OAUTH_TOKEN```. You will need to install the Tinder app on your phone to verify your account via text message. I had to wait almost a week before my account became valid, likely due to it being a new facebook profile.

### Running

Add in your slack URL (We use a private group) and facebook, ID and TOKEN.

```tinderfish = Tinderfish.new```

```tinderfish.sign_in(facebook_id, facebook_token)```

Assuming you already have matches... (if not just run ```matches = tinderfish.get_nearby_users``` followed by ```tinderfish.generate_matches(matches, 3)``` where 3 is how many of your matches you want to swipe on).

```tinderfish.make_victims```

This will print a list of victims and their bios to your console. Select the worst and match them up by using the VID of each user

```tinderfish.introduce_and_run(victim1_12345678, victim2_87654321)```


### Blog Post

Accompanying blog post and code walkthrough can be found on my website here: http://www.spencerlloyddixon.co.uk/2015/06/16/tinderfish-hacking-tinder-for-maximum-bromance/

It's outdated now, but an interesting look into how to build something like this.

### Credit

Credit to Neal Kemp's fantastic tinder_pyro wrapper here https://github.com/nneal/tinder_pyro
Also Andrea for refactoring Tinderfish, check him out @lucidstack
