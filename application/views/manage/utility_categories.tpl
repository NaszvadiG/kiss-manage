{% extends "wrapper.tpl" %}
{% block content %}
<br>
<div class="row">
    <div class="col-md-9">
        <div class="panel panel-primary">
            <div class="panel-heading">
               <b>Manage Utility Categories</b>
            </div>
            <div class="panel-body">
                <form role="form" id="manage_form" method="POST" action="/manage/setUtilityCategories">
                    <div class="table-responsive container-fluid">
                        <table class="table" id="manage-table">
                            <thead>
                                <tr>
                                    <th>&nbsp;</th>
                                    <th>Category Name</th>
                                    <th>Vendor Name</th>
                                    <th>Default Check Account</th>
                                </tr>
                            </thead>
                            <tbody>
                                {% for id, row in data %}
                                <tr>
                                    <td style="width: 50px;">
                                        <a class="btn btn-danger btn-circle fa fa-times delete_row" row_id="{{ id }}"></a>
                                    </td>
                                    <td>
                                        <input class="form-control delete_row_entry" type="text" name="data[{{ id }}][name]" value="{{ row.name }}" data-validation="required" data-validation-error-msg="You must provide a category name">
                                    </td>
                                    <td>
                                        <input class="form-control" type="text" name="data[{{ id }}][vendor]" value="{{ row.vendor }}" data-validation="required" data-validation-error-msg="You must provide a vendor name">
                                    </td>
                                    <td>
                                        <select class="form-control" name="data[{{ id }}][checks_accounts_id]">
                                            <option value="0">- Select -</option>
                                            {% for option in row.account_options %}
                                            {{ option|raw }}
                                            {% endfor %}
                                        </select>
                                    </td>
                                </tr>
                                {% endfor %}
                                <tr>
                                    <td>&nbsp</td>
                                    <td>
                                        <input class="form-control new_rows" type="text" name="data_new_name[]" value="" placeholder="Add new category">
                                    </td>
                                    <td>
                                        <input class="form-control" type="text" name="data_new_vendor[]" value="" placeholder="Add new vendor">
                                    </td>
                                    <td>
                                        <select class="form-control" name="data_new_account[]">
                                            <option value="0">- Select -</option>
                                            {% for option in acctount_options %}
                                            {{ option|raw }}
                                            {% endfor %}
                                        </select>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <button type="submit" class="btn btn-primary" id="submit_button" style="margin-left: 15px;">Save</button>&nbsp;
                </form>
                <form id="delete_form" method="POST" action="/manage/deleteUtilityCategory">
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