# example for mapping with regex groups
s#songs/artist_(.*)/(.*\.(mp3))#music/\1/\2#g

s#^my_dir/#other_dir/#g
# leaving out the slash works too
# ATTENTION: watch out for unwanted chained mappings (see below)
s#^no_slash_mapping#some_dir#g

s#^empty_dir(.*)#mapped_dir/\1#g

# source / target contains space
s#^spacey dir/#not_so_spacey_target/#g
s#^not_so_spacey/#spacey target/#g

# special characters
s#^stran"F%lder/#normalFolder/#g
s#^someNormalFolder/#st"F%lder/#g
s#^notStrangeFolder/#stranger$Folder/#g

# nested directories
s#nested/first/#first/#g
s#nested/second/#second/#g

# folder that will be present on startup already
s#^existBeforeStart/#mappedDuringStart/#g

# existing content won't get updated on start
s#^update_test/#update_test_target/#g

# ignore `.dot` files, map only mp3/json, create subdirectories
s#^on_demand_(\w+)\/([^\.](.+\.(mp3|json)))#ondemand/\1/\2#g

# ATTENTION, replacements are chained:
# files put into /one will end up in /three
s#^one/(.*)#two/\1#g
s#^two/(.*)#three/\1#g
