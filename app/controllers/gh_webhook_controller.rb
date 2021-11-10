class GhWebhookController < ApplicationController

  skip_before_action :verify_authenticity_token, :check_if_login_required
  wrap_parameters format: [:json]

  def handler
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
    if data['repository']['private'] then
      repo = repo.gsub("://", "://#{CGI.escape(setting["github_user"])}:#{CGI.escape(setting["github_token"])}@")
    end
    cmd = "git clone --bare #{repo}"
    puts cmd
    spawn(cmd, chdir: dir)
  end

end
