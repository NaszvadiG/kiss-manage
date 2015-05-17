{% extends "wrapper.tpl" %}
{% block content %}
&nbsp;
<div class="row">
    <div class="col-lg-12">
        <div class="panel panel-default">
            <div class="panel-heading">
               <b>All TV Shows</b>
            </div>
            <div class="panel-body">
                <div id="loading"><span class="glyphicon glyphicon-refresh spinning"></span> Loading...</div>
                <div class="dataTable_wrapper table-responsive container-fluid" id="media-list-table-wrapper" style="display: none;">
                    <table class="table table-striped table-bordered table-hover" id="media-list-table">
                        <thead>
                            <tr>
                                <th width="40%">Show Name</th>
                                <th width="5%">Monitored?</th>
                                <th width="8%"># of Seasons</th>
                                <th width="8%">Last Updated</th>
                                <th width="8%">Location</th>
                            </tr>
                        </thead>
                        <tbody>
                        {%for show in shows %}
                            {% if show.status == 1 %}
                                {% set active_icon_class = 'fa-check-circle' %}
                                {% set active = 'Yes' %}
                            {% else %}
                                {% set active_icon_class = 'fa-times-circle' %}
                                {% set active = 'No' %}
                            {% endif %}
                            <tr>
                                <td><a href="/media/editTv/{{ show.id }}">{{ show.name }}</a></td>
                                <td align="center"><p class="fa {{ active_icon_class}}">&nbsp;{{ active }}</p></td>
                                <td>{{ counts[show.id] }}</td>
                                <td>{{ show.last_updated }}</td>
                                <td>{{ show.location }}</td>
                            </tr>
                        {% endfor %}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
<script>
$(document).ready(function() {
    $('#media-list-table').DataTable({
        "responsive": true,
        "pageLength": 25,
        "stateSave": true,
        "initComplete": function(settings, json) {
            $("#loading").css('display', 'none');
            $("#media-list-table-wrapper").css('display', '');
        }
    });
});
</script>
{% endblock %}