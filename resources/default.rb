resource_name :ssmtp

property :name, String, name_property: true

property :sender_email, String, required: true

property :smtp_host, String, required: true
property :smtp_port, Integer, required: true
property :smtp_username, String, required: true
property :smtp_password, String, required: true
property :smtp_enable_starttls, [TrueClass, FalseClass], default: false
property :smtp_enable_ssl, [TrueClass, FalseClass], default: false
property :from_line_override, [TrueClass, FalseClass], default: true

property :users, Array, default: []

default_action :install

action :install do
  instance = ::ChefCookbook::Instance::Helper.new(node)
  pkgs = %w[ssmtp]

  case node['platform_family']
  when 'rhel', 'fedora', 'amazon'
    pkgs << 'mailx'
  when 'debian'
    pkgs << 'mailutils'
  end

  pkgs.each do |pkg_name|
    package pkg_name do
      action :install
    end
  end

  ssmtp_dir = '/etc/ssmtp'

  template ::File.join(ssmtp_dir, 'ssmtp.conf') do
    cookbook 'ssmtp-lwrp'
    source 'ssmtp.conf.erb'
    owner instance.root
    group node['root_group']
    variables(
      sender_email: new_resource.sender_email,
      smtp_host: new_resource.smtp_host,
      smtp_port: new_resource.smtp_port,
      smtp_username: new_resource.smtp_username,
      smtp_password: new_resource.smtp_password,
      smtp_enable_starttls: new_resource.smtp_enable_starttls,
      smtp_enable_ssl: new_resource.smtp_enable_ssl,
      from_line_override: new_resource.from_line_override
    )
    sensitive true
    action :create
  end

  revaliases_users = new_resource.users.dup
  revaliases_users << instance.root

  template ::File.join(ssmtp_dir, 'revaliases') do
    cookbook 'ssmtp-lwrp'
    source 'revaliases.erb'
    owner instance.root
    group node['root_group']
    variables(
      users: revaliases_users,
      sender_email: new_resource.sender_email,
      smtp_host: new_resource.smtp_host,
      smtp_port: new_resource.smtp_port
    )
    action :create
  end

  node.run_state['ssmtp'] = {}
  node.run_state['ssmtp']['installed'] = true
end
