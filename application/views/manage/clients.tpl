{% extends "wrapper.tpl" %}
{% block content %}
<br>
<div class="row">
    <div class="col-md-6">
        <div class="panel panel-primary">
            <div class="panel-heading">
               <b>Manage Clients</b>
            </div>
            <div class="panel-body">
                <div class="table-responsive container-fluid">
                    <table class="table" id="manage-table">
                        <thead>
                            <tr>
                                <th>&nbsp;</th>
                                <th>Client Name</th>
                            </tr>
                        </thead>
                        <tbody>
                            {% for id, row in data %}
                            <tr>
                                <td style="width: 100px;">
                                    <a class="btn btn-primary btn-circle fa fa-edit" href="/manage/editClient/{{ id }}"></a>
                                    <a class="btn btn-danger btn-circle fa fa-times delete_row" row_id="{{ id }}"></a>
                                </td>
                                <td class="delete_row_entry">
                                    {{ row.name }}
                                </td>
                            </tr>
                            {% endfor %}
                            <tr>
                                <td colspan="2" style="text-align: left">
                                    <a href="/manage/editClient" class="btn btn-primary">Add New Client</a>&nbsp;
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <form id="delete_form" method="POST" action="/manage/deleteClient">
                    <input id="delete_id" type="hidden" name="delete_id" value="">
                    <input id="transfer_id" type="hidden" name="transfer_id" value="">
                    <div id="dialog-confirm"></div>
                </form>
            </div>
        </div>
    </div>
</div>
{% include 'kiss_modal.tpl' %}
<script>
var replace_opts = {{ replace_opts|raw }};
$(document).ready(function() {    
    $(".delete_row").click(function(){
        var row_id = $(this).attr('row_id');
        $("#delete_id").val(row_id);
        var delete_row_entry = $(this).closest('tr').find('.delete_row_entry').html();

        var replace_select = '<select id="replace_select">';
        replace_select = replace_select + '<option value="0">- None -</option>';
        $.each(replace_opts, function (id, value) {
            if(id != row_id) {
                replace_select = replace_select + '<option value="'+id+'">' + value.name + '</option>';
            }
        });
        replace_select = replace_select + "</select>";

        var confirm = "<p>Are you sure you want to delete: "+delete_row_entry+"?  If so, if you would like to reassign all related data please select the target entry below:</p><p>"+replace_select+"</p>";
        $("#modal_body").html(confirm);
        $('#kiss_modal').modal('show');
    });
    $("#kiss_modal_confirm").click(function(event){
        var transfer_id = $("#replace_select").val();
        $('#kiss_modal').modal('hide');
        $("#transfer_id").val(transfer_id)
        $("#delete_form").submit();
    });
});
</script>
{% endblock %}