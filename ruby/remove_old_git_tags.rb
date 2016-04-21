#!/usr/bin/ruby
require 'pp'
require 'date'

# This script is useful in deleting old tags after X amount of days
# With long running project, I tend to find lots of old tags hanging around
# with no easy way to remove them. This script examine the tag creation date
# and delete it if it older then 120 days (6 months)

# TO USE: ./remove_old_git_tags.rb [--dryrun]
# Obviously, you will have to run this script in the directory when you want to prune the tags...

days_to_keep = 120
dryrun = true if ARGV[0] == "--dryrun"
all_remote_tags = `git ls-remote --tags origin`

# TO match '3a078f63ce615fbf09a3ef6cbe026922c87ac343  refs/tags/master-1.0.2578'
# And ignore lightweight tags eg: 09d8f75d04c4dec778f24ffa9b99c8b7420255e0  refs/tags/master-1.0.2578^{}
regex = /^(.*)(\s+)(refs\/tags\/(.*(?<!\^{})))$/
date_threshold = Date.today - days_to_keep

results = all_remote_tags.scan(regex)
results.each  do |result|
  remote_tag = result[2]
  tag_name = result[3]

  tag_created_time = `git log -1 --format=%ai #{remote_tag}`
  parsed_tag_created_time = DateTime.strptime(tag_created_time, '%Y-%m-%d %H:%M:%S')
  
  if parsed_tag_created_time < date_threshold
    puts "Too old. Deleting tag #{tag_name}"
    unless dryrun
      # Delete local tag
      `git tag -d #{tag_name}`

      # Delete remote tag
      `git push origin :#{remote_tag}`
    end
  end
end