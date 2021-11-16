class GhWebhookController < ApplicationController

  skip_before_action :verify_authenticity_token, :check_if_login_required
  wrap_parameters format: [:json]

  def handler
    puts "new webhook events #{request.headers['X-GitHub-Event']}"
    if request.headers["X-GitHub-Event"] == "repository" then
      data = params['gh_webhook']
      if data['action'] != "created" then
        puts 'not created event'
        return
      end
      setting = Setting.plugin_redmine_repo_sync_gh_org
      dir = setting['repository_root'] 
      if dir == '' then
        puts 'not set valid conhfig'
        return
      end
      FileUtils.mkdir_p(dir) unless File.exists?(dir)
      if data['repository']['private'] and setting['github_user'] == '' then
        puts 'cloning private repo with no auth info'
        return
      end
      repo = data['repository']['clone_url']
      name = data['repository']['full_name']
      if data['repository']['private'] then
        repo = repo.gsub("://", "://#{CGI.escape(setting["github_user"])}:#{CGI.escape(setting["github_token"])}@")
      end
      cmd = "git clone --bare #{repo} #{name}"
      puts cmd
      spawn(cmd, chdir: dir)
    end
    if request.headers["X-GitHub-Event"] == "push" then
      setting = Setting.plugin_redmine_repo_sync_gh_org
      data = params['gh_webhook']
      name = File.join(setting['repository_root'], data['repository']['full_name'])
      projects = Project.active.has_module(:repository)
      projects.each do |project|
        project.repositories.each do |repo|
          if repo.url == name then
            cmd = "git -C #{repo.url} fetch origin 'refs/heads/*:refs/heads/*' --prune"
            i = spawn(cmd)
            Process.wait i
            repo.fetch_changesets
          end
        end
      end
    end
  end

end
