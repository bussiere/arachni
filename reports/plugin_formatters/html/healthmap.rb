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
    # HTML formatter for the results of the HealthMap plugin
    #
    # @author Tasos "Zapotek" Laskos
    #                                      <tasos.laskos@gmail.com>
    #                                      <zapotek@segfault.gr>
    # @version 0.1.1
    #
    class HealthMap < Arachni::Plugin::Formatter
        include Arachni::Reports::HTML::Utils

        def run
            return ERB.new( tpl ).result( binding )
        end

        def tpl
            %q{
                <style type="text/css">
                    a.safe {
                        color: blue
                    }
                    a.unsafe {
                        color: red
                    }
                </style>

                <% @results[:map].each do |entry| %>
                    <% state = entry.keys[0]%>
                    <% url   = entry.values[0]%>

                    <a class="<%=state%>" href="<%=escapeHTML(url)%>"><%=escapeHTML(url)%></a> <br/>
                <%end%>

                <br/>

                <h3>Stats</h3>
                <strong>Total</strong>: <%=@results[:total]%> <br/>
                <strong>Safe</strong>: <%=@results[:safe]%> <br/>
                <strong>Unsafe</strong>: <%=@results[:unsafe]%> <br/>
                <strong>Issue percentage</strong>: <%=@results[:issue_percentage]%>%
            }
        end


    end

end
end

end
end
