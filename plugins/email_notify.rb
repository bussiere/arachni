=begin
    Copyright 2010-2012 Tasos Laskos <tasos.laskos@gmail.com>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
=end

module Arachni
module Plugins

#
# Uses the Pony gem send a notification (and optionally report) at the end
# of the scan over SMTP.
#
# @author Tasos "Zapotek" Laskos
#                                      <tasos.laskos@gmail.com>
#                                      <zapotek@segfault.gr>
# @version 0.1
#
class EmailNotify < Arachni::Plugin::Base

    def run
        wait_while_framework_running
    end

    def clean_up
        issue_cnt = @framework.audit_store.issues.size
        time      = @framework.audit_store.delta_time
        url       = @framework.opts.url

        opts = {
            :subject => "Scan for #{url} finished in #{time}",
            :body    => "Found #{issue_cnt} unique issues.",
            :to      => @options['to'],
            :cc      => @options['cc'],
            :bcc     => @options['bcc'],
            :from    => @options['from'],
            :via => :smtp,
            :via_options => {
                :address              => @options['server_address'],
                :port                 => @options['server_port'],
                :enable_starttls_auto => @options['tls'],
                :user_name            => @options['username'],
                :password             => @options['password'],
                :authentication       => !@options['authentication'].empty? ? @options['authentication'].to_sym : nil,
                :domain               => "localhost.localdomain"
            }
        }

        if @options['report'] != 'none'
            report = @framework.reports[ @options['report'] ]

            rep_opts = {}
            report.info[:options].each {
                |opt|
                rep_opts[opt.name] = opt.default if opt.default
            }

            rep_opts['outfile'] = 'scan_report.' + @options['report']
            report.new( @framework.audit_store( true ), rep_opts ).run

            opts[:attachments] = {
                rep_opts['outfile'] => File.read( rep_opts['outfile'] )
            }

            FileUtils.rm( rep_opts['outfile'] )
        end

        print_status( 'Sending the notification...' )
        Pony.mail( opts )
        print_status( 'Done.' )
    end

    def self.gems
        [ 'pony' ]
    end

    def self.info
        {
            :name           => 'E-mail notify',
            :description    => %q{Sends a notification (and optionally a report) over SMTP
                at the end of the scan.},
            :author         => 'Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>',
            :version        => '0.1',
            :options        => [
                Arachni::OptString.new( 'to', [ true, 'E-mail address of the receiver.' ] ),
                Arachni::OptString.new( 'cc', [ false, 'E-mail address to which to send a carbon copy of the notification.' ] ),
                Arachni::OptString.new( 'bcc', [ false, 'E-mail address for a blind carbon copy.' ] ),
                Arachni::OptString.new( 'from', [ true, 'E-mail address of the sender.' ] ),
                Arachni::OptAddress.new( 'server_address', [ true, 'Address of the SMTP server to use.' ] ),
                Arachni::OptPort.new( 'server_port', [ true, 'SMTP port.' ] ),
                Arachni::OptBool.new( 'tls', [ false, 'Use TLS/SSL?.' ] ),
                Arachni::OptString.new( 'username', [ true, 'SMTP username.' ] ),
                Arachni::OptString.new( 'password', [ true, 'SMTP password.' ] ),
                Arachni::OptString.new( 'authentication', [ false, 'Authentication.', 'plain', [ 'plain', 'login', 'cram_md5', '' ] ] ),
                Arachni::OptEnum.new( 'report', [ false, 'Report type to send as an attachment.', 'txt', [ 'txt', 'xml', 'html', 'json', 'yaml', 'marshal' 'none' ] ] )
            ]

        }
    end

end

end
end
