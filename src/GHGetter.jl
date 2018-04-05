

module GHGetter

	using GitHub

	function auth()
		myauth = GitHub.authenticate(ENV["GITHUB_AUTH"]) # don't hardcode your access tokens!
	end

	function getPRs(repo;pars=Dict("state" => "open", "per_page" => 6))

		prs, page_data = pull_requests(repo; params = pars, page_limit = 10);
		return prs,page_data

	end


	"""
		run(repo)

	Gets all open PRs from `repo`, checks out each PR as a branch in `repo`, runs the code with `include("run.jl")`, deletes the local branch, and exits when done.
	"""
	function run(repo)
		prs,pg = getPRs(repo)

		for p in prs
			@info("running $(p.user)'s PR")
			@info("		Title: $(p.title)")
			n = p.number
			pn = "pr_$n"

			run(`git fetch origin pull/$n/head:pr$pn`)
			run(`git checkout $pn`)
			julia_exe = Base.julia_cmd()
            run(`$julia_exe --check-bounds=yes run.jl`)
			run(`git stash && git checkout master`)
			@info("done")
		end
	end

end