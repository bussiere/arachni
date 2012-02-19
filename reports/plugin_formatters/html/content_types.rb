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

module Reports

class HTML
module PluginFormatters

    #
    # HTML formatter for the results of the ContentTypes plugin
    #
    # @author Tasos "Zapotek" Laskos
    #                                      <tasos.laskos@gmail.com>
    #                                      <zapotek@segfault.gr>
    # @version 0.1.1
    #
    class ContentTypes < Arachni::Plugin::Formatter
    include Arachni::Reports::HTML::Utils

        def run
            return ERB.new( tpl ).result( binding )
        end

        def tpl
            %q{
                <% @results.each_pair do |type, responses| %>
                    <ul>

                        <li>
                            <%=type%>
                            <ul>
                                <% responses.each do |res| %>
                                <li>
                                    URL: <a href="<%=escapeHTML(res[:url])%>"><%=escapeHTML(res[:url])%></a><br/>
                                    Method: <%=res[:method]%>

                                    <% if res[:params] && res[:method].downcase == 'post' %>
                                        <ul>
                                            <li>Parameters:</li>
                                            <%res[:params].each_pair do |name, val|%>
                                            <li>
                                                <%=name%> = <%=val%>
                                            </li>
                                            <%end%>
                                        <ul>
                                    <%end%>
                                </li>
                                <%end%>
                            </ul>
                        </li>

                    </ul>

                <%end%>
            }

        end

    end

end
end

end
end
