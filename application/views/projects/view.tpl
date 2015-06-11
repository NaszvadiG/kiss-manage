{% extends "wrapper.tpl" %}
{% block content %}
<br>
<div class="row">
    <div class="col-md-8">
        <div class="panel panel-primary">
            <div class="panel-heading">
                Filter Projects
            </div>
            <div class="panel-body" style="padding-bottom: 0px;">
                <form role="form" id="filter_form" method="POST">
                    <input type="hidden" id="filter_clear" name="filter[clear]" value="0">
                    <div class="table-responsive container-fluid">
                        <table class="table ">
                            <thead>
                                <tr>
                                    <th>Due Date</th>
                                    <th>Status</th>
                                    <th>Client</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td style="width: 110px;">
                                         <input id="filter_date" class="form-control" type="text" name="filter[due_date]" style="width: 100px;" value="{{ filter.filter_date }}">
                                    </td>
                                    <td style="width: 250px;">
                                        <select class="form-control" name="filter[status]">
                                            <option value="-1">- All -</option>
                                            <option value="-2" {{ filter_status_value == -2 ? 'selected' : '' }}>- All Incomplete Statuses -</option>
                                            {% for option in filter_status_options %}
                                            {{ option|raw }}
                                            {% endfor %}
                                        </select>
                                    </td>
                                    <td style="width: 250px;">
                                        <select class="form-control" name="filter[client_id]">
                                            <option value="0">- All -</option>
                                            {% for option in filter_client_options %}
                                            {{ option|raw }}
                                            {% endfor %}
                                        </select>
                                    </td>
                                </tr>
                            </tbody>
                            <tfoot>
                                <tr>
                                    <td colspan="3">
                                        <button type="submit" class="btn btn-small btn-primary">Filter</button>
                                        <button type="button" id="filter_clear_button" class="btn btn-small btn-default">Clear</button>
                                    </td>
                                </tr>
                            </tfoot>
                        </table>      
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
<div class="row">
    <div class="col-md-12">
        <div class="panel panel-primary">
            <div class="panel-heading">
                Project List
            </div>
            <div class="panel-body">
                <div class="panel-group" id="accordion" role="tablist" aria-multiselectable="true">
                    {% for row in projects %}
                    {% if row.id > 0 %}
                        {% if row.status_name == 'Pending' or row.status_name == 'On Hold' %}
                            {% set row_class = 'danger' %}
                        {% elseif row.status_name == 'In Progress' %}
                            {% set row_class = 'warning' %}
                        {% else %}
                            {% set row_class = 'success' %}
                        {% endif %}
                    {% else %}
                        {% set row_class = 'default' %}
                    {% endif %}
                    <div class="panel panel-{{ row_class }}">
                        <div class="panel-heading success" role="tab" id="heading{{ loop.index }}">
                            <h4 class="panel-title">
                                <a {{ row.selected ? '' : 'class="collapsed"' }} data-toggle="collapse" data-parent="#accordion" href="#collapse{{ loop.index }}" aria-expanded="{{ row.selected ? 'true' : 'false' }}" aria-controls="collapse{{ loop.index }}" style="font-weight: bold; vertical-align: middle;" {{ row.selected ? 'id="scroll_to_project"' : '' }}>{{ row.header_name }}</a>
                                <div class="pull-right">{{ row.client_name }}</div>
                            </h4>
                        </div>
                        <div id="collapse{{ loop.index }}" class="panel-collapse collapse {{ row.selected ? 'in' : '' }}" role="tabpanel" aria-labelledby="heading{{ loop.index }}">
                            <div class="panel-body" style="padding-right: 0px;">
                                <div class="col-md-5">
                                <form role="form" method="POST" action="/projects/setProject">
                                    <input type="hidden" name="project_id" value="{{ row.id }}">
                                    <div class="form-group">
                                        <label>Name</label>
                                        <input class="form-control" placeholder="Enter project name" type="text" name="project[name]" value="{{ row.name }}">
                                    </div>
                                    <div class="form-group">
                                        <label>Client</label>
                                        <select class="form-control" name="project[client_id]" style="width: 300px;">
                                        {% for option in row.client_options %}
                                        {{ option|raw }}
                                        {% endfor %}
                                        </select>
                                    </div>
                                    <div class="form-group">
                                        <label>Status</label>
                                        <select class="form-control" name="project[status]" style="width: 150px;">
                                        {% for option in row.status_options %}
                                        {{ option|raw }}
                                        {% endfor %}
                                        </select>
                                    </div>
                                    <div class="form-group">
                                        <label>Created Date</label>
                                        <input class="form-control project_created_date" placeholder="Select Date" type="text" name="project[created_date]" style="width: 120px;" value="{{ row.created_date }}">
                                    </div>
                                    <div class="form-group">
                                        <label>Due Date</label>
                                        <input class="form-control project_due_date" placeholder="Select Date" type="text" name="project[due_date]" style="width: 120px;" value="{{ row.due_date }}">
                                    </div>
                                    <div class="form-group">
                                        <label>Details</label>
                                        <textarea class="form-control" style="width: 400px; height: 150px;" name="project[detail]">{{ row.detail }}</textarea>
                                    </div>
                                    <div class="form-group">
                                        <button type="submit" class="btn btn-small btn-primary">Save</button>&nbsp;&nbsp;
                                        <button type="button" class="btn btn-small btn-danger delete_project_button" project_id="{{ row.id }}" project_name="{{ row.name }}">Delete</button>
                                    </div>
                                </form>
                                </div>
                                <div class="col-md-7" style="padding-right: 0px;">
                                    <div class="table-responsive container-fluid" >
                                        <table class="table table-striped">
                                            <thead>
                                                <tr>
                                                    <th>Task</th>
                                                    <th>Due Date</th>
                                                    <th>&nbsp;</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                            {% if row.tasks is not empty %}
                                            {% for task in row.tasks %}
                                            {% if task.status_name == 'Pending' or task.status_name == 'On Hold'%}
                                                {% set icon_class = 'fa-play' %}
                                                {% set row_class = 'danger' %}
                                                {% set set_status = '2' %}
                                            {% elseif task.status_name == 'In Progress' %}
                                                {% set icon_class = 'fa-check' %}
                                                {% set set_status = '1' %}
                                                {% set row_class = 'warning' %}
                                            {% else %}
                                                {% set set_status = '0' %}
                                                {% set row_class = 'success' %}
                                            {% endif %}
                                            <tr class="{{ row_class }}">
                                                <td class="task_name">{{ task.name }}</td>
                                                <td style="width: 90px;">{{ task.due_date }}</td>
                                                <td style="width: 120px; text-align: right;">
                                                    {% if set_status != '0' %}
                                                    <a class="btn btn-success btn-circle fa {{ icon_class }} toggle_task_button" task_id="{{ task.id }}" project_id="{{ task.project_id }}" set_status="{{ set_status }}"></a>
                                                    {% endif %}
                                                    <a class="btn btn-primary btn-circle fa fa-pencil edit_task_button" task_id="{{ task.id }}" project_id="{{ task.project_id }}"></a>
                                                    <a class="btn btn-danger btn-circle fa fa-times delete_task_button" task_id="{{ task.id }}" project_id="{{ task.project_id }}"></a>
                                                </td>
                                            </tr>
                                            {% endfor %}
                                            {% else %}
                                            <tr><td colspan="3" align="center">No Tasks Defined</td></tr>
                                            {% endif %}
                                            </tbody>
                                            {% if row.id > 0 %}
                                            <tfoot>
                                                <tr><td colspan="3" style="text-align: right;"><button class="btn btn-small btn-default edit_task_button" project_id="{{ row.id }}" task_id="0">Add Task</button></td></tr>
                                            </tfoot>
                                            {% endif %}
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    {% endfor %}
                </div>
            </div>
        </div>
    </div>
</div>
<form id="delete_task_form" method="POST" action="/projects/deleteTask">
    <input id="delete_task_id" type="hidden" name="task_id" value="">
    <input id="delete_task_project_id" type="hidden" name="project_id" value="">
</form>
<form id="delete_project_form" method="POST" action="/projects/deleteProject">
    <input id="delete_project_id" type="hidden" name="project_id" value="">
</form>
<form id="toggle_task_form" method="POST" action="/projects/setTask">
    <input id="toggle_redirect" type="hidden" name="task_redirect" value="">
    <input id="toggle_task_id" type="hidden" name="task_id" value="">
    <input id="toggle_status" type="hidden" name="task[status]" value="">
</form>

{% include 'kiss_modal.tpl' %}
{% include 'projects/task_modal.tpl' %}
<script>
function showTaskModal(project_id) {
    $("#task_created_date").datepicker({
        dateFormat: "yy-mm-dd",
    });
    $("#task_due_date").datepicker({
        dateFormat: "yy-mm-dd",
    });
    $("#task_redirect").val("/projects/view/"+project_id);
    $("#task_modal").modal('show');
}
$(document).ready(function() {
    var offset = $("#scroll_to_project").offset();
    if(offset) {
        var scrollpoint = offset.top - 150;
        $('html, body').animate({
            scrollTop: scrollpoint
        }, 0);
    }
    $("#filter_date").datepicker({
        dateFormat: "yy-mm-dd",
    });
    $(".project_created_date").datepicker({
        dateFormat: "yy-mm-dd",
    });
    $(".project_due_date").datepicker({
        dateFormat: "yy-mm-dd",
    });
    $("#filter_clear_button").click(function() {
        $("#filter_clear").val(1);
        $("#filter_form").submit();
    });
    $(".edit_task_button").click(function() {
        var project_id = $(this).attr('project_id');
        var task_id = $(this).attr('task_id');
        if(task_id > 0) {
            var title = "Edit Task";
        } else {
            var title = "Add Task";
        }
        $.get("/projects/getTaskData/"+task_id+"/"+project_id, function(data) {
            if(data.hasOwnProperty('id')) {
                $("#task_id").val(task_id);
                $("#task_project_id").val(project_id);
                $("#task_name").val(data.name);
                $("#task_created_date").val(data.created_date);
                $("#task_due_date").val(data.due_date);
                $("#task_status").html(data.status_options);
                $("#task_detail").val(data.detail);
                $("#task_modal_label").html(title);
                showTaskModal(project_id);
            }
        });
    });
    $("#task_modal_confirm").click(function() {
        $("#task_modal_form").submit();
    });
    $(".toggle_task_button").click(function(){
        var task_id = $(this).attr('task_id');
        var project_id = $(this).attr('project_id');
        var set_status = $(this).attr('set_status');
        $("#toggle_task_id").val(task_id);
        $("#toggle_redirect").val("/projects/view/"+project_id);
        $("#toggle_status").val(set_status);
        $("#toggle_task_form").submit();
    });
    $(".delete_task_button").click(function(){
        var task_id = $(this).attr('task_id');
        var project_id = $(this).attr('project_id');
        $("#delete_task_id").val(task_id);
        $("#delete_task_project_id").val(project_id);
        var task_name = $(this).closest('tr').find('.task_name').html();
        var confirm = "<p>Are you sure you want to delete task: "+task_name+"?</p><input type=\"hidden\" name=\"confirm_type\" id=\"confirm_type\" value=\"task\">";
        $("#modal_body").html(confirm);
        $('#kiss_modal').modal('show');
    });
    $(".delete_project_button").click(function() {
        var project_id = $(this).attr('project_id');
        $("#delete_project_id").val(project_id);
        var project_name = $(this).attr('project_name');
        var confirm = "<p>Are you sure you want to delete project: "+project_name+"?  All related tasks will also be deleted.</p><input type=\"hidden\" name=\"confirm_type\" id=\"confirm_type\" value=\"project\">";
        $("#modal_body").html(confirm);
        $('#kiss_modal').modal('show');
    });
    $("#kiss_modal_confirm").click(function(event){
        var type = $("#confirm_type").val();
        $('#kiss_modal').modal('hide');
        if(type == 'task') {
            $("#delete_task_form").submit();
        } else {
            $("#delete_project_form").submit();
        }
    });
});
</script>
{% endblock %}