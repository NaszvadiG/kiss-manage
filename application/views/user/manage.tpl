{% extends "wrapper.tpl" %}
{% block content %}
<br>
<div class="row">
    <div class="col-md-6">
        <div class="panel panel-primary">
            <div class="panel-heading">
               <b>Manage Users</b>
            </div>
            <div class="panel-body">
                <div class="table-responsive container-fluid">
                    <table class="table" id="manage-table">
                        <thead>
                            <tr>
                                <th>&nbsp;</th>
                                <th>Username</th>
                            </tr>
                        </thead>
                        <tbody>
                            {% for id, email in data %}
                            <tr>
                                <td style="width: 100px;">
                                    <a class="btn btn-primary btn-circle fa fa-times fa-pencil" href="/user/profile/{{ id }}"></a>&nbsp;
                                    <a class="btn btn-danger btn-circle fa fa-times delete_row" row_id="{{ id }}"></a>
                                </td>
                                <td class="delete_row_entry">{{ email }}</td>
                            </tr>
                            {% endfor %}
                            <tr>
                                <td colspan="2" style="text-align: left">
                                    <a class="btn btn-primary" href="/user/add">Add User</a>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <form id="delete_form" method="POST" action="/user/delete">
                    <input id="delete_id" type="hidden" name="delete_id" value="">
                </form>
            </div>
        </div>
    </div>
</div>
{% include 'kiss_modal.tpl' %}
<script>
$(document).ready(function() {
    $(".delete_row").click(function(){
        var row_id = $(this).attr('row_id');
        $("#delete_id").val(row_id);
        var delete_row_entry = $(this).closest('tr').find('.delete_row_entry').html();

        var confirm = "<p>Are you sure you want to delete user: "+delete_row_entry+"?</p>";        
        $("#modal_body").html(confirm);
        $('#kiss_modal').modal('show');
    });
    $("#kiss_modal_confirm").click(function(event){
        $('#kiss_modal').modal('hide');
        $("#delete_form").submit();
    });
});
</script>
{% endblock %}