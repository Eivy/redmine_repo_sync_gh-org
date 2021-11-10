Redmine::Plugin.register :redmine_repo_sync_gh_org do
  name 'Redmine Repo Sync Gh Org plugin'
  author 'Eivy'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/Eivy/redmine_repo_sync_gh_org'
  author_url 'https://eivy.github.io/'
  settings :partial => 'settings/gh_webhook_settings', :default => {'repository_root' => '', 'github_user' => '', 'github_token' => ''}
end
