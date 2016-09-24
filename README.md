Jekyll Preview Tag
==================
This plugin uses nokogiri and ruby-readability to create previews and a locally cached snippets.

Required Gems/Libraries: nokogiri, open-uri, ruby-readability, digest

Usage:
 
1. Generate a new folder called "```_cache```" in your Jekyll directory. 
This will hold all linked snippets, so you don't need to regenerate them on every regeneration of your site.
 
2. Use the following link syntax: 
 
   ```{% preview http://example.com/some-article.html %}```
 
3. In case we can't fetch the Title from a linksource, you can set it manually:

   ```{% preview "Some Article" http://example.com/some-article.html %}```
 
Feel free to send a pull-request!
