require "stringex"
new_post_ext = "md"
posts_dir = "_posts"

task :default => [:jekyll]
task :publish => [:githubpublish, :sitemap]

desc "Run Jekyll"
task :jekyll do
	puts "Changing codepage for windows"
	sh 'chcp 65001'
	puts "Running Jekyll"
	jekyll
	puts "To test, browse to http://localhost:81"
	puts "rake publish to publish to github"
	puts "rake new_post[my-new-post] or rake new_post['my new post']"
end

desc "Publish to GitHub"
task :githubpublish do
	clean
	stage
	commit
	push
end

#usage rake sitemap, but this task will be executed automatically after deploying
desc 'notify search engines'
task :sitemap do
  begin
    require 'net/http'
    require 'uri'
    puts '* Pinging Google about our sitemap'
    Net::HTTP.get('www.google.com', '/webmasters/tools/ping?sitemap=' + URI.escape('http://jasondentler.com/sitemap.xml'))
    puts '* Pinging Bing about our sitemap'
    Net::HTTP.get('www.bing.com', '/ping?sitemap=' + URI.escape('http://jasondentler.com/sitemap.xml'))
  rescue LoadError
    puts '! Could not ping Google about our sitemap, because Net::HTTP or URI could not be found.'
  end
end

# borrowed this from octopress
# usage rake new_post[my-new-post] or rake new_post['my new post'] or rake new_post (defaults to "new-post")
desc "Begin a new post in _posts"
task :new_post, :title do |t, args|
  mkdir_p "#{posts_dir}"
  args.with_defaults(:title => 'new-post')
  title = args.title
  filename = "#{posts_dir}/#{Time.now.strftime('%Y-%m-%d')}-#{title.to_url}.#{new_post_ext}"
  if File.exist?(filename)
    abort("rake aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
  end
  puts "Creating new post: #{filename}"
  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "layout: post"
    post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
    post.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
    post.puts "tags: "
    post.puts "---"
  end
end

def clean
	sh 'rm -rf _site'
end

def jekyll(opts = '--pygments --safe')
	clean
	sh 'jekyll ' + opts
end

def stage
	sh 'git add -A'
end

def commit
	sh 'git commit --message="Publish with rake at ' + Time.now.inspect + '"'
end

def push
	sh 'git push'
end
