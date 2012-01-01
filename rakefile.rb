task :default => [:jekyll]
task :publish => [:githubpublish]

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