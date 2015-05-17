{% extends "wrapper.tpl" %}
{% block content %}
<br>
<div class="row">
    <div class="col-md-6">
        <div class="panel panel-primary">
            <div class="panel-heading">
               <b>Manage Receipt Categories</b>
            </div>
            <div class="panel-body">
                <form role="form" id="manage_form" method="POST" action="/manage/setCategories">
                    <div class="table-responsive container-fluid">
                        <table class="table" id="manage-table">
                            <thead>
                                <tr>
                                    <th>&nbsp;</th>
                                    <th>Category Name</th>
                                    <th>Group</th>
                                </tr>
                            </thead>
                            <tbody>
                                {% for id, row in data %}
                                <tr>
                                    <td style="width: 50px;">
                                        <a class="btn btn-danger btn-circle fa fa-times delete_row" row_id="{{ id }}"></a>
                                    </td>
                                    <td>
                                        <div class="form-group">
                                        <input class="form-control delete_row_entry" type="text" name="data[{{ id }}][name]" value="{{ row.name }}" data-validation="required" data-validation-error-msg="You must provide a category name">
                                        </div>
                                    </td>
                                    <td>
                                        <div class="form-group">
                                        <select class="form-control" name="data[{{ id }}][deductible]">
                                            {% for group_id, group in ded_groups %}
                                                {% if row.deductible == group_id %}
                                                <option value="{{ group_id }}" selected>{{ group }}</option>
                                                {% else %} 
                                                <option value="{{ group_id }}">{{ group }}</option>
                                                {% endif %}
                                            {% endfor %}
                                        </select>
                                        </div>
                                    </td>
                                </tr>
                                {% endfor %}
                                <tr>
                                    <td>&nbsp</td>
                                    <td>
                                        <input class="form-control new_rows" type="text" name="data_names[]" value="" placeholder="Add new category">
                                    </td>
                                    <td>
                                        <div class="form-group">
                                        <select class="form-control" name="data_deductibles[]">
                                        {% for option in ded_options %}
                                        {{ option|raw }}
                                        {% endfor %}
                                        </select>
                                        </div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                        <button type="submit" class="btn btn-primary" id="submit_button">Save</button>&nbsp;
                    </div>
                </form>
                <form id="delete_form" method="POST" action="/manage/deleteCategories">
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
    $.validate({
        onError : function() {
            return false;
        }
    });
    $("#manage-table").on("change keyup paste", ".new_rows", function (event){
        var status = true;
        $(".new_rows").each(function(){
            if(!$(this).val()) {
                status = false;
            }
        });
        if(status) {
            var lastRow = $('#manage-table tr:last');
            var newRow = lastRow.clone();
            newRow.find(':text').val('');
            lastRow.after(newRow);
        }
    });
    
    $(".delete_row").click(function(){
        var row_id = $(this).attr('row_id');
        $("#delete_id").val(row_id);
        var delete_row_entry = $(this).closest('tr').find('.delete_row_entry').val();

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