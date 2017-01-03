Announcements
=============

Creating a new announcement
--

First, open up the banner HTML file (https://github.com/klavinslab/aquarium/tree/master/app/views/layouts/_banner.html.erb). The content of the banner takes the following form:

```html
<div class='banner'>
  <h3>[Announcement Title]</h3>
  <p>[Announcement Description]</p>
</div>
```

You can format the announcement using any standard HTML tags, attributs, etc. However, a single `<h3>` and `<p>` is the current standard.

Once you've written the announcement and committed the change to GitHub, kindly ask Eric to restart the production server.

Removing an announcement
--

To remove an announcement, simply comment it out, using `<!-- -->` as in

```html
<!-- mm/dd/yy
<div class='banner'>
  <h3>[Announcement Title]</h3>
  <p>[Announcement Description]</p>
</div>
-->
```

Commenting out old announcements and stamping them with the date of removal will serve to log old announcements.

Don't forget to commit to GitHub and restart the server.

Current list of potential improvements by priority
--
1. Button to dismiss the announcement that remembers if it's been dismissed
2. Pull HTML straight from GitHub, so that we don't have to restart the Aquarium server every time
3. "See more" button if announcement is too long
4. Log of all previous announcements
5. Non-hacky UI for posting announcements