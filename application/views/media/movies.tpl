{% extends "wrapper.tpl" %}
{% block content %}
<br>
<div class="row">
    <div class="col-md-12">
        <div class="panel panel-default">
            <div class="panel-heading">
               <b>Movie List</b>
            </div>
            <!-- /.panel-heading -->
            <div class="panel-body">
                <div id="loading"><span class="glyphicon glyphicon-refresh spinning"></span> Loading...</div>
                <div class="dataTable_wrapper table-responsive container-fluid" id="media-list-table-wrapper" style="display: none;">
                    <table class="table table-striped table-bordered table-hover" id="media-list-table">
                        <thead>
                            <tr>
                                <th width="40%">Name</th>
                                <th width="10%">Created Date</th>
                                <th width="8%">Location</th>
                                <th width="40%">Filename</th>
                            </tr>
                        </thead>
                        <tbody>
                        {% for movie in movies %}
                            <tr>
                                <td>{{ movie.name }}</td>
                                <td>{{ movie.created_date }}</td>
                                <td>{{ movie.location }}</td>
                                <td>{{ movie.filename }}</td>
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
            "searching": true,
            "initComplete": function(settings, json) {
                $("#loading").css('display', 'none');
                $("#media-list-table-wrapper").css('display', '');
            }
    });
});
</script>
{% endblock %}