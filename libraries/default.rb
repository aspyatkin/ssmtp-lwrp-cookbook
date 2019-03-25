module ChefCookbook
  module SSMTP
    class Helper
      def initialize(node)
        @node = node
      end

      def mail_send_command(subject, from, to, suppress_empty_message = false)
        case @node['platform_family']
        when 'rhel', 'fedora', 'amazon'
          %(mail #{suppress_empty_message ? '-E ' : ''}-s "#{subject}" -S from="#{from}" #{to})
        when 'debian'
          %(mail #{suppress_empty_message ? '-E "set nonullbody" ' : ''}-s "#{subject}" -a "From: #{from}" #{to})
        else
          %(mail #{suppress_empty_message ? '-E "set nonullbody" ' : ''}-s "#{subject}" -a "From: #{from}" #{to})
        end
      end
    end
  end
end
