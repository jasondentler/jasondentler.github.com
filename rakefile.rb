task :default => [:jekyll]
task :publish => [:githubpublish]

desc "Run Jekyll"
task :jekyll do
	puts "Running Jekyll"
	jekyll
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