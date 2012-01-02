task :default => [:jekyll]
task :publish => [:githubpublish, :sitemap]

desc "Run Jekyll"
task :jekyll do
	puts "Changing codepage for windows"
	sh 'chcp 65001'
	puts "Running Jekyll"
	jekyll
	puts "Publishing to local IIS"
	publishLocal
	puts "To test, browse to http://localhost:81"
	puts "Run 'rake publish' to publish to github"
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

def publishLocal
	sh 'rm -r c:\\blog\\'
	sh 'cp -r _site c:\\blog'
end