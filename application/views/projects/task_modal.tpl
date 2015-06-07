{% block content %}
<div class="modal fade" id="task_modal" tabindex="-1" role="dialog" aria-labelledby="task_modal_label" aria-hidden="true" data-backdrop="false">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="task_modal_label">{{ modal_title }}</h4>
            </div>
            <div class="modal-body" id="modal_body">
                <form role="form" id="task_modal_form" method="POST" action="/projects/setTask">
                    <input type="hidden" id="task_redirect" name="task_redirect" value="">
                    <input type="hidden" id="task_id" name="task_id" value="0">
                    <input type="hidden" id="task_project_id" name="task[project_id]" value="0">
                    <div class="form-group">
                        <label>Name</label>
                        <input id="task_name" class="form-control" placeholder="Enter task name" type="text" name="task[name]" value="">
                    </div>
                    <div class="form-group">
                        <label>Created Date</label>
                        <input id="task_created_date" class="form-control" placeholder="Select Date" type="text" name="task[created_date]" style="width: 120px;" value="">
                    </div>
                    <div class="form-group">
                        <label>Due Date</label> 
                        <input id="task_due_date" class="form-control" placeholder="Select Date" type="text" name="task[due_date]" style="width: 120px;" value="">
                    </div>
                    <div class="form-group">
                        <label>Status</label> 
                        <select id="task_status" name="task[status]" class="form-control" style="width: 150px;"></select>
                    </div>
                    <div class="form-group">
                        <label>Details</label>
                        <textarea id="task_detail" class="form-control" name="task[detail]" style="width: 100%; height: 150px;"></textarea>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" id="task_modal_confirm">Save</button>
            </div>
        </div>
    </div>
</div>
{% endblock %}